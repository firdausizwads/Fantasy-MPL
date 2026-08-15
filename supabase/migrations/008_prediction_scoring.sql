-- Fantasy MPL — Prediction scoring and regional leaderboard
-- Run after 007_fantasy_scoring.sql

-- 1. Admin: set the official weekly MVP ---------------------------------------

create or replace function public.admin_set_weekly_mvp(
  target_week uuid,
  target_player uuid
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_platform_admin() then
    raise exception 'Not authorized';
  end if;

  insert into public.official_weekly_mvps (week_id, player_id, result_state, finalized_at, finalized_by)
  values (target_week, target_player, 'verified', now(), (select auth.uid()))
  on conflict (week_id) do update set
    player_id = excluded.player_id,
    result_state = 'verified',
    finalized_at = now(),
    finalized_by = excluded.finalized_by;
end;
$$;

-- 2. Prediction scoring engine -------------------------------------------------
-- Awards: +30 correct series winner, +20 exact score, +100 correct weekly MVP.
-- Values read from the active rule set when configured. Idempotent per source:
-- a prediction row is only ever paid once (checked via source_table+source_id).

create or replace function public.score_week_predictions(target_week uuid)
returns table (predictions_scored integer, transactions_created integer)
language plpgsql
security definer
set search_path = ''
as $$
declare
  week_row public.competition_weeks;
  season_row public.seasons;
  winner_points numeric;
  exact_points numeric;
  mvp_points numeric;
  official_mvp uuid;
  rec record;
  scored integer := 0;
  created integer := 0;
begin
  if not public.is_platform_admin() then
    raise exception 'Not authorized';
  end if;

  select * into week_row from public.competition_weeks where id = target_week;
  if not found then raise exception 'Week not found'; end if;
  select * into season_row from public.seasons where id = week_row.season_id;

  winner_points := public.fantasy_rule(season_row.id, 'prediction_winner', 30);
  exact_points := public.fantasy_rule(season_row.id, 'prediction_exact', 20);
  mvp_points := public.fantasy_rule(season_row.id, 'prediction_mvp', 100);

  -- Match winner + exact score ------------------------------------------------
  for rec in
    select mp.id as prediction_id, mp.user_id,
           mp.predicted_winner_team_id, mp.predicted_home_score, mp.predicted_away_score,
           m.winner_team_id, m.home_score, m.away_score,
           ht.code as home_code, at.code as away_code
    from public.match_predictions mp
    join public.matches m on m.id = mp.match_id
    join public.teams ht on ht.id = m.home_team_id
    join public.teams at on at.id = m.away_team_id
    where m.week_id = target_week
      and m.result_state in ('verified','finalized')
      and m.winner_team_id is not null
      and not exists (
        select 1 from public.score_transactions st
        where st.source_table = 'match_predictions'
          and st.source_id = mp.id
      )
  loop
    scored := scored + 1;

    if rec.predicted_winner_team_id = rec.winner_team_id then
      insert into public.score_transactions
        (user_id, season_id, region_code, week_id, category, points,
         reason_code, description, source_table, source_id)
      values
        (rec.user_id, season_row.id, season_row.region_code, target_week,
         'prediction', winner_points, 'prediction_winner',
         'Series winner · ' || rec.home_code || ' vs ' || rec.away_code,
         'match_predictions', rec.prediction_id);
      created := created + 1;
    end if;

    if rec.predicted_home_score is not null
       and rec.predicted_away_score is not null
       and rec.predicted_home_score = rec.home_score
       and rec.predicted_away_score = rec.away_score then
      insert into public.score_transactions
        (user_id, season_id, region_code, week_id, category, points,
         reason_code, description, source_table, source_id)
      values
        (rec.user_id, season_row.id, season_row.region_code, target_week,
         'prediction', exact_points, 'prediction_exact',
         'Exact score ' || rec.home_score || '–' || rec.away_score || ' · '
           || rec.home_code || ' vs ' || rec.away_code,
         'match_predictions', rec.prediction_id);
      created := created + 1;
    end if;
  end loop;

  -- Weekly MVP ------------------------------------------------------------------
  select player_id into official_mvp
  from public.official_weekly_mvps
  where week_id = target_week and result_state in ('verified','finalized');

  if official_mvp is not null then
    for rec in
      select wmp.id as prediction_id, wmp.user_id, p.handle
      from public.weekly_mvp_predictions wmp
      join public.players p on p.id = wmp.player_id
      where wmp.week_id = target_week
        and wmp.player_id = official_mvp
        and not exists (
          select 1 from public.score_transactions st
          where st.source_table = 'weekly_mvp_predictions'
            and st.source_id = wmp.id
        )
    loop
      insert into public.score_transactions
        (user_id, season_id, region_code, week_id, category, points,
         reason_code, description, source_table, source_id)
      values
        (rec.user_id, season_row.id, season_row.region_code, target_week,
         'prediction', mvp_points, 'prediction_mvp',
         'Weekly MVP · ' || rec.handle,
         'weekly_mvp_predictions', rec.prediction_id);
      created := created + 1;
      scored := scored + 1;
    end loop;
  end if;

  return query select scored, created;
end;
$$;

-- 3. Regional leaderboard (public predictions competition) ---------------------

create or replace function public.regional_leaderboard(
  target_region text,
  target_season uuid default null,
  max_rows integer default 100
)
returns table (
  user_id uuid,
  manager_name text,
  country_code text,
  avatar_url text,
  total_points numeric,
  prediction_points numeric,
  fantasy_points numeric
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
    pr.avatar_url,
    sum(st.points) as total_points,
    sum(st.points) filter (where st.category = 'prediction') as prediction_points,
    sum(st.points) filter (where st.category = 'fantasy') as fantasy_points
  from public.score_transactions st
  left join public.profiles pr on pr.id = st.user_id
  where st.region_code = target_region
    and (target_season is null or st.season_id = target_season)
  group by st.user_id, pr.manager_name, pr.country_code, pr.avatar_url
  order by total_points desc
  limit greatest(1, least(max_rows, 500));
$$;

-- 4. My score summary -----------------------------------------------------------

create or replace function public.my_week_points(target_week uuid)
returns table (
  category text,
  reason_code text,
  description text,
  points numeric,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  select category, reason_code, description, points, created_at
  from public.score_transactions
  where user_id = (select auth.uid())
    and week_id = target_week
  order by created_at desc;
$$;
