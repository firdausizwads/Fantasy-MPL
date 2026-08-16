-- Fantasy MPL — real dashboard summary
-- Run after 015_account_export_and_deletion.sql

create or replace function public.my_dashboard_summary(target_region text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  current_user_id uuid := (select auth.uid());
  target_season_id uuid;
  target_season_number integer;
  target_week_id uuid;
  target_week_number integer;
  total_points numeric;
  prediction_points numeric;
  fantasy_points numeric;
  regional_rank bigint;
  ranked_managers bigint;
  submitted_predictions bigint := 0;
  available_matches bigint := 0;
  mvp_submitted boolean := false;
  finalized_predictions bigint := 0;
  correct_predictions bigint := 0;
begin
  if current_user_id is null then
    raise exception 'Authentication required';
  end if;

  if target_region not in ('MY', 'ID', 'PH') then
    raise exception 'Unsupported region';
  end if;

  select s.id, s.season_number
    into target_season_id, target_season_number
  from public.seasons s
  where s.region_code = target_region
    and s.status in ('published', 'active', 'completed')
  order by
    case s.status when 'active' then 0 when 'published' then 1 else 2 end,
    s.season_number desc
  limit 1;

  if target_season_id is null then
    return jsonb_build_object(
      'season_id', null,
      'season_number', null,
      'week_number', null,
      'week_id', null,
      'total_points', null,
      'prediction_points', null,
      'fantasy_points', null,
      'regional_rank', null,
      'ranked_managers', 0,
      'submitted_predictions', 0,
      'available_matches', 0,
      'mvp_submitted', false,
      'finalized_predictions', 0,
      'correct_predictions', 0,
      'prediction_accuracy', null
    );
  end if;

  -- Prefer the active week, then the next upcoming week, then the most recent
  -- completed week. This avoids hardcoded "Week 5" labels in the client.
  select cw.id, cw.week_number
    into target_week_id, target_week_number
  from public.competition_weeks cw
  where cw.season_id = target_season_id
  order by
    case
      when now() between cw.starts_at and cw.ends_at then 0
      when cw.starts_at > now() then 1
      else 2
    end,
    case when cw.starts_at > now() then cw.starts_at end asc nulls last,
    case when cw.starts_at <= now() then cw.starts_at end desc nulls last
  limit 1;

  select
    sum(st.points),
    sum(st.points) filter (where st.category = 'prediction'),
    sum(st.points) filter (where st.category = 'fantasy')
  into total_points, prediction_points, fantasy_points
  from public.score_transactions st
  where st.user_id = current_user_id
    and st.season_id = target_season_id
    and st.region_code = target_region;

  with totals as (
    select st.user_id, sum(st.points) as points
    from public.score_transactions st
    where st.season_id = target_season_id
      and st.region_code = target_region
    group by st.user_id
  ), ranked as (
    select user_id, rank() over (order by points desc, user_id) as position
    from totals
  )
  select
    (select position from ranked where user_id = current_user_id),
    (select count(*) from ranked)
  into regional_rank, ranked_managers;

  if target_week_id is not null then
    select count(*) into available_matches
    from public.matches m
    where m.week_id = target_week_id
      and m.status <> 'cancelled';

    select count(*) into submitted_predictions
    from public.match_predictions mp
    join public.matches m on m.id = mp.match_id
    where mp.user_id = current_user_id
      and m.week_id = target_week_id
      and m.status <> 'cancelled';

    select exists (
      select 1 from public.weekly_mvp_predictions wmp
      where wmp.user_id = current_user_id
        and wmp.week_id = target_week_id
    ) into mvp_submitted;
  end if;

  select
    count(*),
    count(*) filter (where mp.predicted_winner_team_id = m.winner_team_id)
  into finalized_predictions, correct_predictions
  from public.match_predictions mp
  join public.matches m on m.id = mp.match_id
  where mp.user_id = current_user_id
    and m.season_id = target_season_id
    and m.result_state in ('verified', 'finalized', 'corrected')
    and m.winner_team_id is not null;

  return jsonb_build_object(
    'season_id', target_season_id,
    'season_number', target_season_number,
    'week_number', target_week_number,
    'week_id', target_week_id,
    'total_points', total_points,
    'prediction_points', prediction_points,
    'fantasy_points', fantasy_points,
    'regional_rank', regional_rank,
    'ranked_managers', coalesce(ranked_managers, 0),
    'submitted_predictions', submitted_predictions,
    'available_matches', available_matches,
    'mvp_submitted', mvp_submitted,
    'finalized_predictions', finalized_predictions,
    'correct_predictions', correct_predictions,
    'prediction_accuracy', case
      when finalized_predictions > 0
        then round((correct_predictions::numeric / finalized_predictions::numeric) * 100, 1)
      else null
    end
  );
end;
$$;

revoke all on function public.my_dashboard_summary(text) from public;
grant execute on function public.my_dashboard_summary(text) to authenticated;

select to_regprocedure('public.my_dashboard_summary(text)') is not null as dashboard_summary_ready;
