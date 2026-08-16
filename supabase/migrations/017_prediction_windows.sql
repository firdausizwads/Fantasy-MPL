-- Fantasy MPL — 24-hour match and weekly MVP prediction windows
-- Run after 016_real_dashboard_summary.sql

-- Canonical deadlines always match the scheduled start. Opening times are
-- derived as exactly 24 hours before those deadlines.
update public.matches
set prediction_locks_at = scheduled_at
where prediction_locks_at is distinct from scheduled_at;

update public.competition_weeks cw
set mvp_locks_at = first_match.scheduled_at
from (
  select m.week_id, min(m.scheduled_at) as scheduled_at
  from public.matches m
  where m.status <> 'cancelled'
  group by m.week_id
) first_match
where cw.id = first_match.week_id
  and cw.mvp_locks_at is distinct from first_match.scheduled_at;

-- Keep match deadlines synchronized whenever an administrator creates or
-- reschedules a fixture.
create or replace function public.sync_match_prediction_deadline()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.prediction_locks_at := new.scheduled_at;
  return new;
end;
$$;

drop trigger if exists sync_match_prediction_deadline_before_write
on public.matches;
create trigger sync_match_prediction_deadline_before_write
before insert or update of scheduled_at, prediction_locks_at on public.matches
for each row execute function public.sync_match_prediction_deadline();

-- Recalculate the weekly MVP deadline from the first non-cancelled match in
-- that regional week. This runs after fixture scheduling changes.
create or replace function public.sync_weekly_mvp_deadline()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  affected_week uuid;
begin
  affected_week := coalesce(new.week_id, old.week_id);

  update public.competition_weeks cw
  set mvp_locks_at = first_match.scheduled_at
  from (
    select min(m.scheduled_at) as scheduled_at
    from public.matches m
    where m.week_id = affected_week
      and m.status <> 'cancelled'
  ) first_match
  where cw.id = affected_week
    and first_match.scheduled_at is not null;

  if tg_op = 'UPDATE' and old.week_id is distinct from new.week_id then
    update public.competition_weeks cw
    set mvp_locks_at = first_match.scheduled_at
    from (
      select min(m.scheduled_at) as scheduled_at
      from public.matches m
      where m.week_id = old.week_id
        and m.status <> 'cancelled'
    ) first_match
    where cw.id = old.week_id
      and first_match.scheduled_at is not null;
  end if;

  if tg_op = 'DELETE' then return old; end if;
  return new;
end;
$$;

drop trigger if exists sync_weekly_mvp_deadline_after_write
on public.matches;
create trigger sync_weekly_mvp_deadline_after_write
after insert or update or delete on public.matches
for each row execute function public.sync_weekly_mvp_deadline();

-- Defense in depth: reject direct writes outside the server-controlled match
-- window even if a client bypasses the application UI.
create or replace function public.validate_match_prediction_window()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  fixture public.matches;
begin
  select * into fixture from public.matches where id = new.match_id;
  if not found then raise exception 'Match not found'; end if;

  if fixture.status <> 'scheduled' then
    raise exception 'Predictions are unavailable for this match';
  end if;

  if now() < fixture.scheduled_at - interval '24 hours' then
    raise exception 'Predictions open 24 hours before match time';
  end if;

  if now() >= fixture.scheduled_at then
    raise exception 'Predictions are locked for this match';
  end if;

  return new;
end;
$$;

drop trigger if exists validate_match_prediction_window_before_write
on public.match_predictions;
create trigger validate_match_prediction_window_before_write
before insert or update on public.match_predictions
for each row execute function public.validate_match_prediction_window();

create or replace function public.validate_mvp_prediction_window()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  deadline timestamptz;
begin
  select min(m.scheduled_at) into deadline
  from public.matches m
  where m.week_id = new.week_id
    and m.status <> 'cancelled';

  if deadline is null then
    raise exception 'Weekly MVP window is unavailable until fixtures are scheduled';
  end if;

  if now() < deadline - interval '24 hours' then
    raise exception 'Weekly MVP voting opens 24 hours before the first match';
  end if;

  if now() >= deadline then
    raise exception 'Weekly MVP voting is locked';
  end if;

  return new;
end;
$$;

drop trigger if exists validate_mvp_prediction_window_before_write
on public.weekly_mvp_predictions;
create trigger validate_mvp_prediction_window_before_write
before insert or update on public.weekly_mvp_predictions
for each row execute function public.validate_mvp_prediction_window();

-- RLS mirrors the trigger rules. Both layers use database time, not the
-- browser clock, for authorization.
drop policy if exists "users create unlocked match predictions" on public.match_predictions;
create policy "users create unlocked match predictions"
on public.match_predictions for insert to authenticated
with check (
  (select auth.uid()) = user_id
  and exists (
    select 1 from public.matches m
    where m.id = match_id
      and m.status = 'scheduled'
      and now() >= m.scheduled_at - interval '24 hours'
      and now() < m.scheduled_at
      and predicted_winner_team_id in (m.home_team_id, m.away_team_id)
  )
);

drop policy if exists "users update unlocked match predictions" on public.match_predictions;
create policy "users update unlocked match predictions"
on public.match_predictions for update to authenticated
using (
  (select auth.uid()) = user_id
  and exists (
    select 1 from public.matches m
    where m.id = match_id
      and m.status = 'scheduled'
      and now() >= m.scheduled_at - interval '24 hours'
      and now() < m.scheduled_at
  )
)
with check (
  (select auth.uid()) = user_id
  and exists (
    select 1 from public.matches m
    where m.id = match_id
      and m.status = 'scheduled'
      and now() >= m.scheduled_at - interval '24 hours'
      and now() < m.scheduled_at
      and predicted_winner_team_id in (m.home_team_id, m.away_team_id)
  )
);

drop policy if exists "users create unlocked mvp predictions" on public.weekly_mvp_predictions;
create policy "users create unlocked mvp predictions"
on public.weekly_mvp_predictions for insert to authenticated
with check (
  (select auth.uid()) = user_id
  and exists (
    select 1
    from public.matches m
    where m.week_id = weekly_mvp_predictions.week_id
      and m.status <> 'cancelled'
    group by m.week_id
    having now() >= min(m.scheduled_at) - interval '24 hours'
       and now() < min(m.scheduled_at)
  )
);

drop policy if exists "users update unlocked mvp predictions" on public.weekly_mvp_predictions;
create policy "users update unlocked mvp predictions"
on public.weekly_mvp_predictions for update to authenticated
using (
  (select auth.uid()) = user_id
  and exists (
    select 1
    from public.matches m
    where m.week_id = weekly_mvp_predictions.week_id
      and m.status <> 'cancelled'
    group by m.week_id
    having now() >= min(m.scheduled_at) - interval '24 hours'
       and now() < min(m.scheduled_at)
  )
)
with check (
  (select auth.uid()) = user_id
  and exists (
    select 1
    from public.matches m
    where m.week_id = weekly_mvp_predictions.week_id
      and m.status <> 'cancelled'
    group by m.week_id
    having now() >= min(m.scheduled_at) - interval '24 hours'
       and now() < min(m.scheduled_at)
  )
);

select
  to_regprocedure('public.validate_match_prediction_window()') is not null as match_window_ready,
  to_regprocedure('public.validate_mvp_prediction_window()') is not null as mvp_window_ready,
  count(*) filter (where prediction_locks_at = scheduled_at) as synchronized_matches
from public.matches;
