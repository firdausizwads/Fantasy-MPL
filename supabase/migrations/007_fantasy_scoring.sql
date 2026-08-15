-- Fantasy MPL — Fantasy scoring engine and league standings
-- Run after 006_weekly_lineups.sql

-- 1. Verified per-player match statistics ------------------------------------

create table if not exists public.player_match_stats (
  id uuid primary key default gen_random_uuid(),
  match_id uuid not null references public.matches(id) on delete cascade,
  player_id uuid not null references public.players(id) on delete cascade,
  team_id uuid not null references public.teams(id),
  kills integer not null default 0 check (kills >= 0),
  assists integer not null default 0 check (assists >= 0),
  entered_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (match_id, player_id)
);

alter table public.player_match_stats enable row level security;

drop policy if exists "public reads player match stats" on public.player_match_stats;
create policy "public reads player match stats"
on public.player_match_stats for select using (true);

drop policy if exists "admins manage player match stats" on public.player_match_stats;
create policy "admins manage player match stats"
on public.player_match_stats for all to authenticated
using ((select public.is_platform_admin()))
with check ((select public.is_platform_admin()));

drop trigger if exists player_match_stats_set_updated_at on public.player_match_stats;
create trigger player_match_stats_set_updated_at
before update on public.player_match_stats
for each row execute function public.set_updated_at();

-- 2. Admin: record an official match result ----------------------------------

create or replace function public.admin_set_match_result(
  target_match uuid,
  home_score integer,
  away_score integer
)
returns public.matches
language plpgsql
security definer
set search_path = ''
as $$
declare
  m public.matches;
  result public.matches;
begin
  if not public.is_platform_admin() then
    raise exception 'Not authorized';
  end if;
  if home_score < 0 or away_score < 0 or home_score = away_score then
    raise exception 'Enter a valid series score (no draws)';
  end if;

  select * into m from public.matches where id = target_match for update;
  if not found then raise exception 'Match not found'; end if;

  update public.matches set
    home_score = admin_set_match_result.home_score,
    away_score = admin_set_match_result.away_score,
    winner_team_id = case when admin_set_match_result.home_score > admin_set_match_result.away_score
                          then m.home_team_id else m.away_team_id end,
    status = 'completed',
    result_state = 'verified',
    finalized_at = now()
  where id = target_match
  returning * into result;

  return result;
end;
$$;

-- 3. Admin: upsert player statistics for a match ------------------------------

create or replace function public.admin_upsert_player_stat(
  target_match uuid,
  target_player uuid,
  target_team uuid,
  kill_count integer,
  assist_count integer
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
    (match_id, player_id, team_id, kills, assists, entered_by)
  values
    (target_match, target_player, target_team, kill_count, assist_count, (select auth.uid()))
  on conflict (match_id, player_id) do update set
    team_id = excluded.team_id,
    kills = excluded.kills,
    assists = excluded.assists,
    entered_by = excluded.entered_by
  returning * into result;

  return result;
end;
$$;

-- 4. Scoring rules ------------------------------------------------------------
-- Reads the active scoring_rule_sets row for the season; falls back to the
-- published defaults: kill +3, assist +1, captain 2x.

create or replace function public.fantasy_rule(season uuid, rule_key text, fallback numeric)
returns numeric
language sql
stable
set search_path = ''
as $$
  select coalesce(
    (select (rules ->> rule_key)::numeric
     from public.scoring_rule_sets
     where season_id = season and active = true
     order by version desc limit 1),
    fallback
  );
$$;

-- 5. The scoring engine --------------------------------------------------------
-- Scores every submitted lineup for a week. Idempotent: lineups already
-- 'scored' are skipped, so re-running after corrections only affects new rows.

create or replace function public.score_week_fantasy(target_week uuid)
returns table (lineups_scored integer, transactions_created integer)
language plpgsql
security definer
set search_path = ''
as $$
declare
  week_row public.competition_weeks;
  season_row public.seasons;
  kill_points numeric;
  assist_points numeric;
  captain_multiplier numeric;
  lineup_record record;
  slot_record record;
  base_points numeric;
  slot_points numeric;
  lineup_total numeric;
  scored_count integer := 0;
  tx_count integer := 0;
begin
  if not public.is_platform_admin() then
    raise exception 'Not authorized';
  end if;

  select * into week_row from public.competition_weeks where id = target_week;
  if not found then raise exception 'Week not found'; end if;
  select * into season_row from public.seasons where id = week_row.season_id;

  kill_points := public.fantasy_rule(season_row.id, 'kill', 3);
  assist_points := public.fantasy_rule(season_row.id, 'assist', 1);
  captain_multiplier := public.fantasy_rule(season_row.id, 'captain_multiplier', 2);

  for lineup_record in
    select wl.*, fl.season_id as league_season
    from public.weekly_lineups wl
    join public.fantasy_leagues fl on fl.id = wl.league_id
    where wl.week_id = target_week
      and wl.status in ('submitted', 'locked')
      and fl.season_id = week_row.season_id
  loop
    lineup_total := 0;

    for slot_record in
      select lp.id as slot_id, lp.player_id, lp.slot_role, p.handle
      from public.lineup_players lp
      join public.players p on p.id = lp.player_id
      where lp.lineup_id = lineup_record.id
    loop
      select coalesce(sum(s.kills * kill_points + s.assists * assist_points), 0)
      into base_points
      from public.player_match_stats s
      join public.matches m on m.id = s.match_id
      where s.player_id = slot_record.player_id
        and m.week_id = target_week
        and m.result_state in ('verified', 'finalized');

      slot_points := base_points;
      if lineup_record.captain_player_id = slot_record.player_id then
        slot_points := base_points * captain_multiplier;
      end if;

      if slot_points <> 0 then
        insert into public.score_transactions
          (user_id, season_id, region_code, week_id, league_id, category,
           points, reason_code, description, source_table, source_id)
        values
          (lineup_record.user_id, season_row.id, season_row.region_code,
           target_week, lineup_record.league_id, 'fantasy',
           slot_points,
           case when lineup_record.captain_player_id = slot_record.player_id
                then 'fantasy_captain' else 'fantasy_player' end,
           slot_record.slot_role || ' · ' || slot_record.handle ||
             case when lineup_record.captain_player_id = slot_record.player_id
                  then ' (captain ' || captain_multiplier || 'x)' else '' end,
           'lineup_players', slot_record.slot_id);
        tx_count := tx_count + 1;
      end if;

      lineup_total := lineup_total + slot_points;
    end loop;

    update public.weekly_lineups
    set status = 'scored', locked_at = coalesce(locked_at, now())
    where id = lineup_record.id;

    scored_count := scored_count + 1;
  end loop;

  return query select scored_count, tx_count;
end;
$$;

-- 6. League standings, readable by every league member ------------------------

create or replace function public.league_standings(target_league uuid)
returns table (
  user_id uuid,
  manager_name text,
  country_code text,
  total_points numeric,
  weeks_scored bigint
)
language sql
stable
security definer
set search_path = ''
as $$
  select
    st.user_id,
    coalesce(pr.manager_name, 'MANAGER') as manager_name,
    coalesce(pr.country_code, 'OTHER') as country_code,
    sum(st.points) as total_points,
    count(distinct st.week_id) as weeks_scored
  from public.score_transactions st
  left join public.profiles pr on pr.id = st.user_id
  where st.league_id = target_league
    and st.category = 'fantasy'
    and (public.is_league_member(target_league) or public.is_platform_admin())
  group by st.user_id, pr.manager_name, pr.country_code
  order by total_points desc;
$$;

-- 7. My weekly point breakdown (already covered by "users read own scores"
--    policy) needs no changes: clients query score_transactions directly.
