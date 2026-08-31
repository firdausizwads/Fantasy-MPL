-- ==============================================================================
-- FANTASY MPL — PANDASCORE AUTO-VERIFY & DATABASE REPAIR SCRIPT
-- ==============================================================================
-- Run this script in your Supabase SQL Editor (Dashboard -> SQL Editor -> New Query -> Run)
-- This replaces the legacy auto-verify RPC, fixes the "pandascore_sync_config does not exist"
-- error, and synchronizes migrations 031 through 036.
-- ==============================================================================

-- 1. Compatibility fallback: Create table if any legacy query looks for pandascore_sync_config
create table if not exists public.pandascore_sync_config (
  integration text primary key default 'pandascore',
  secret_hash text,
  updated_at timestamptz not null default now()
);

alter table public.pandascore_sync_config enable row level security;
drop policy if exists "admins manage pandascore_sync_config" on public.pandascore_sync_config;
create policy "admins manage pandascore_sync_config" on public.pandascore_sync_config
  for all to authenticated
  using ((select public.is_platform_admin()))
  with check ((select public.is_platform_admin()));

-- 2. Drop legacy function signatures
drop function if exists public.apply_verified_pandascore_fixtures(text, text) cascade;
drop function if exists public.apply_verified_pandascore_fixtures(jsonb) cascade;
drop function if exists public.apply_verified_pandascore_fixtures cascade;

-- 3. Create verified apply_verified_pandascore_fixtures function (Migration 031)
create or replace function public.apply_verified_pandascore_fixtures(
  raw_secret text,
  target_region text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  expected_hash text;
  rec record;
  season_uuid uuid;
  week_uuid uuid;
  home_uuid uuid;
  away_uuid uuid;
  winner_uuid uuid;
  existing_uuid uuid;
  applied integer := 0;
  verified integer := 0;
  mapped_status text;
  is_verified boolean;
begin
  -- Authenticate: allow service_role, platform admin, or callers with valid sync secret
  select secret_hash into expected_hash
  from public.integration_secret_hashes
  where integration = 'pandascore';

  if auth.role() <> 'service_role' and not (select public.is_platform_admin()) then
    if expected_hash is null or encode(extensions.digest(coalesce(raw_secret, ''), 'sha256'), 'hex') <> expected_hash then
      raise exception 'Invalid integration secret';
    end if;
  end if;

  -- Verify target season
  select id into season_uuid
  from public.seasons
  where region_code = target_region and season_number = 18;

  if season_uuid is null then
    raise exception 'Season 18 not found for region %', target_region;
  end if;

  -- Iterate through staged fixtures ready to apply
  for rec in
    select *
    from public.fixture_import_staging
    where provider = 'pandascore'
      and region_code = target_region
      and mapping_status = 'ready'
    order by scheduled_at nulls last
  loop
    select team_id into home_uuid
    from public.external_team_mappings
    where provider = 'pandascore' and external_team_id = rec.external_team_a_id;

    select team_id into away_uuid
    from public.external_team_mappings
    where provider = 'pandascore' and external_team_id = rec.external_team_b_id;

    select team_id into winner_uuid
    from public.external_team_mappings
    where provider = 'pandascore' and external_team_id = rec.winner_external_team_id;

    if rec.scheduled_at is null or home_uuid is null or away_uuid is null then
      continue;
    end if;

    mapped_status := case rec.provider_status
      when 'not_started' then 'scheduled'
      when 'running' then 'live'
      when 'finished' then 'completed'
      when 'canceled' then 'cancelled'
      when 'postponed' then 'postponed'
      else 'scheduled'
    end;

    is_verified := (rec.provider_status = 'finished' and rec.team_a_score is not null and rec.team_b_score is not null);

    -- Find existing match
    select id into existing_uuid
    from public.matches
    where external_provider = 'pandascore' and external_match_id = rec.external_match_id;

    if existing_uuid is null then
      select id into existing_uuid
      from public.matches
      where season_id = season_uuid
        and external_match_id is null
        and home_team_id = home_uuid
        and away_team_id = away_uuid
        and abs(extract(epoch from (scheduled_at - rec.scheduled_at))) < 43200
      order by abs(extract(epoch from (scheduled_at - rec.scheduled_at)))
      limit 1;
    end if;

    -- Ensure competition week exists
    insert into public.competition_weeks (
      season_id, week_number, name, starts_at, ends_at, meta_locks_at, mvp_locks_at
    ) values (
      season_uuid,
      rec.week_number,
      'Week ' || rec.week_number,
      rec.serie_begin_at + (rec.week_number - 1) * interval '7 days',
      rec.serie_begin_at + rec.week_number * interval '7 days',
      rec.serie_begin_at + (rec.week_number - 1) * interval '7 days',
      rec.scheduled_at
    )
    on conflict (season_id, week_number) do nothing;

    select id into week_uuid
    from public.competition_weeks
    where season_id = season_uuid and week_number = rec.week_number;

    if existing_uuid is null then
      if mapped_status <> 'cancelled' then
        insert into public.matches (
          season_id,
          week_id,
          home_team_id,
          away_team_id,
          best_of,
          scheduled_at,
          prediction_locks_at,
          status,
          home_score,
          away_score,
          winner_team_id,
          result_state,
          source_url,
          external_provider,
          external_match_id
        ) values (
          season_uuid,
          week_uuid,
          home_uuid,
          away_uuid,
          rec.best_of,
          rec.scheduled_at,
          rec.scheduled_at,
          mapped_status,
          case when is_verified then rec.team_a_score else null end,
          case when is_verified then rec.team_b_score else null end,
          case when is_verified then winner_uuid else null end,
          case when is_verified then 'verified' else 'unverified' end,
          'https://api.pandascore.co/matches/' || rec.external_match_id,
          'pandascore',
          rec.external_match_id
        );
        applied := applied + 1;
        if is_verified then
          verified := verified + 1;
        end if;
      end if;
    else
      update public.matches set
        week_id = week_uuid,
        home_team_id = home_uuid,
        away_team_id = away_uuid,
        best_of = rec.best_of,
        scheduled_at = rec.scheduled_at,
        prediction_locks_at = rec.scheduled_at,
        status = mapped_status,
        home_score = case when is_verified then rec.team_a_score else home_score end,
        away_score = case when is_verified then rec.team_b_score else away_score end,
        winner_team_id = case when is_verified then winner_uuid else winner_team_id end,
        result_state = case when is_verified then 'verified' else result_state end,
        external_provider = 'pandascore',
        external_match_id = rec.external_match_id,
        updated_at = now()
      where id = existing_uuid;

      applied := applied + 1;
      if is_verified then
        verified := verified + 1;
      end if;
    end if;

    update public.fixture_import_staging
    set applied_at = now(), updated_at = now()
    where provider = 'pandascore' and external_match_id = rec.external_match_id;
  end loop;

  return jsonb_build_object(
    'region', target_region,
    'applied', applied,
    'verified', verified
  );
end;
$$;

revoke all on function public.apply_verified_pandascore_fixtures(text, text) from public, anon;
grant execute on function public.apply_verified_pandascore_fixtures(text, text) to authenticated, service_role;

-- 4. Apply Migration 034 (Deaths & Games breakdown in player match stats)
alter table public.player_match_stats 
  add column if not exists deaths integer not null default 0 check (deaths >= 0);

alter table public.player_match_stats 
  add column if not exists games jsonb default '[]'::jsonb;

create or replace function public.admin_upsert_player_stat(
  target_match uuid,
  target_player uuid,
  target_team uuid,
  kill_count integer,
  assist_count integer,
  death_count integer default 0,
  games_breakdown jsonb default '[]'::jsonb
)
returns public.player_match_stats
language plpgsql
security definer
set search_path = ''
as $$
declare
  m public.matches;
  result public.player_match_stats;
begin
  if not public.is_platform_admin() then
    raise exception 'Not authorized';
  end if;

  select * into m from public.matches where id = target_match;
  if not found then raise exception 'Match not found'; end if;
  if target_team not in (m.home_team_id, m.away_team_id) then
    raise exception 'Team did not play in this match';
  end if;

  insert into public.player_match_stats
    (match_id, player_id, team_id, kills, assists, deaths, games, entered_by)
  values
    (target_match, target_player, target_team, kill_count, assist_count, coalesce(death_count, 0), coalesce(games_breakdown, '[]'::jsonb), (select auth.uid()))
  on conflict (match_id, player_id) do update set
    team_id = excluded.team_id,
    kills = excluded.kills,
    assists = excluded.assists,
    deaths = excluded.deaths,
    games = excluded.games,
    entered_by = excluded.entered_by
  returning * into result;

  return result;
end;
$$;

-- 5. Apply Migration 035 (Player Scores Leaderboard RPC)
drop function if exists public.get_player_scores_leaderboard(text, uuid);

create or replace function public.get_player_scores_leaderboard(
  target_region text default null,
  target_week uuid default null
)
returns table (
  player_id uuid,
  handle text,
  photo_url text,
  role text,
  team_id uuid,
  team_code text,
  team_name text,
  team_logo_url text,
  region_code text,
  matches_played bigint,
  kills bigint,
  deaths bigint,
  assists bigint,
  fantasy_score bigint,
  kda_ratio numeric
)
language sql
stable
security definer
set search_path = ''
as $func$
  select
    p.id as player_id,
    p.handle,
    p.photo_url,
    coalesce(sr.role, 'FLEX') as role,
    t.id as team_id,
    t.code as team_code,
    t.name as team_name,
    t.logo_url as team_logo_url,
    t.region_code,
    count(distinct pms.match_id) as matches_played,
    coalesce(sum(pms.kills), 0)::bigint as kills,
    coalesce(sum(pms.deaths), 0)::bigint as deaths,
    coalesce(sum(pms.assists), 0)::bigint as assists,
    coalesce(sum((pms.kills * 3) + (pms.assists * 1)), 0)::bigint as fantasy_score,
    case
      when coalesce(sum(pms.deaths), 0) = 0 then
        round(coalesce(sum(pms.kills + pms.assists), 0)::numeric, 2)
      else
        round((coalesce(sum(pms.kills + pms.assists), 0)::numeric / nullif(sum(pms.deaths), 0)::numeric), 2)
    end as kda_ratio
  from public.player_match_stats pms
  join public.matches m on m.id = pms.match_id
  join public.seasons s on s.id = m.season_id
  join public.players p on p.id = pms.player_id
  join public.teams t on t.id = pms.team_id
  left join public.season_rosters sr on sr.season_id = s.id and sr.player_id = p.id and sr.team_id = t.id
  where
    (target_region is null or (upper(s.region_code) = upper(target_region) and upper(t.region_code) = upper(target_region)))
    and (target_week is null or m.week_id = target_week)
  group by
    p.id,
    p.handle,
    p.photo_url,
    sr.role,
    t.id,
    t.code,
    t.name,
    t.logo_url,
    t.region_code
  having
    coalesce(sum((pms.kills * 3) + (pms.assists * 1)), 0) > 0 or count(distinct pms.match_id) > 0
  order by
    fantasy_score desc,
    kills desc,
    assists desc,
    handle asc;
$func$;

grant execute on function public.get_player_scores_leaderboard(text, uuid) to anon, authenticated;

-- 6. Apply Migration 036 (TNC Vin Portrait)
update public.players
set 
  photo_url = '/players/ph/tnc/vin.webp',
  country_code = coalesce(country_code, 'PH'),
  source_url = 'https://liquipedia.net/mobilelegends/Vinnn',
  verified_at = now()
where handle in ('Vin', 'Vinnn');

-- 7. Verification check
select
  to_regprocedure('public.apply_verified_pandascore_fixtures(text,text)') is not null as auto_verify_rpc_ready,
  to_regprocedure('public.get_player_scores_leaderboard(text,uuid)') is not null as leaderboard_rpc_ready,
  exists (select 1 from information_schema.tables where table_schema = 'public' and table_name = 'pandascore_sync_config') as fallback_table_ready;
