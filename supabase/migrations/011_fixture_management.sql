-- Fantasy MPL — Admin fixture and week management
-- Run after 010_roster_completion.sql

-- 1. Create or update a competition week ---------------------------------------

create or replace function public.admin_upsert_week(
  target_season uuid,
  week_num integer,
  week_starts timestamptz,
  week_ends timestamptz
)
returns public.competition_weeks
language plpgsql
security definer
set search_path = ''
as $$
declare
  result public.competition_weeks;
begin
  if not public.is_platform_admin() then
    raise exception 'Not authorized';
  end if;
  if week_num < 1 or week_num > 30 then
    raise exception 'Week number out of range';
  end if;
  if week_ends <= week_starts then
    raise exception 'Week must end after it starts';
  end if;

  insert into public.competition_weeks
    (season_id, week_number, name, starts_at, ends_at, meta_locks_at, mvp_locks_at)
  values
    (target_season, week_num, 'Week ' || week_num, week_starts, week_ends, week_starts, week_starts)
  on conflict (season_id, week_number) do update set
    starts_at = excluded.starts_at,
    ends_at = excluded.ends_at,
    meta_locks_at = excluded.meta_locks_at,
    mvp_locks_at = excluded.mvp_locks_at
  returning * into result;

  return result;
end;
$$;

-- 2. Create a fixture -------------------------------------------------------------

create or replace function public.admin_create_match(
  target_week uuid,
  home_team uuid,
  away_team uuid,
  match_time timestamptz,
  series_best_of integer default 3
)
returns public.matches
language plpgsql
security definer
set search_path = ''
as $$
declare
  week_row public.competition_weeks;
  result public.matches;
begin
  if not public.is_platform_admin() then
    raise exception 'Not authorized';
  end if;
  if home_team = away_team then
    raise exception 'A team cannot play itself';
  end if;

  select * into week_row from public.competition_weeks where id = target_week;
  if not found then raise exception 'Week not found'; end if;

  insert into public.matches
    (season_id, week_id, home_team_id, away_team_id, best_of,
     scheduled_at, prediction_locks_at, status)
  values
    (week_row.season_id, target_week, home_team, away_team, series_best_of,
     match_time, match_time, 'scheduled')
  returning * into result;

  return result;
end;
$$;

-- 3. Reschedule / cancel a fixture ------------------------------------------------

create or replace function public.admin_update_match_schedule(
  target_match uuid,
  new_time timestamptz default null,
  new_status text default null
)
returns public.matches
language plpgsql
security definer
set search_path = ''
as $$
declare
  result public.matches;
begin
  if not public.is_platform_admin() then
    raise exception 'Not authorized';
  end if;
  if new_status is not null
     and new_status not in ('scheduled','postponed','cancelled') then
    raise exception 'Status must be scheduled, postponed or cancelled';
  end if;

  update public.matches set
    scheduled_at = coalesce(new_time, scheduled_at),
    prediction_locks_at = coalesce(new_time, prediction_locks_at),
    status = coalesce(new_status, status)
  where id = target_match
    and result_state = 'unverified'
  returning * into result;

  if result is null then
    raise exception 'Match not found or already has a verified result';
  end if;

  return result;
end;
$$;

-- 4. Delete a fixture that has no result and no predictions -------------------------

create or replace function public.admin_delete_match(target_match uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_platform_admin() then
    raise exception 'Not authorized';
  end if;

  if exists (select 1 from public.match_predictions where match_id = target_match) then
    raise exception 'Match already has predictions — cancel it instead of deleting';
  end if;
  if exists (
    select 1 from public.matches
    where id = target_match and result_state <> 'unverified'
  ) then
    raise exception 'Verified matches cannot be deleted';
  end if;

  delete from public.matches where id = target_match;
end;
$$;
