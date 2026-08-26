-- Migration 031: Auto Verify PandaScore Fixtures and Match Results
-- Allows automated server-side sync to apply verified Season 18 schedules and finished series results.

drop function if exists public.apply_verified_pandascore_fixtures(text, text);
drop function if exists public.apply_verified_pandascore_fixtures(jsonb);
drop function if exists public.apply_verified_pandascore_fixtures cascade;

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

select
  to_regprocedure('public.apply_verified_pandascore_fixtures(text,text)') is not null as auto_verify_rpc_ready;
