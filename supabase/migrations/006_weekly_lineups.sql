-- Fantasy MPL — Weekly lineup and captain submission
-- Run after 005_realtime_draft.sql

-- 1. Server-validated lineup submission --------------------------------------
-- Confirms the lineup is complete (every role filled), the captain is one of
-- the selected players, and the league deadline has not passed.

create or replace function public.submit_weekly_lineup(target_lineup uuid)
returns public.weekly_lineups
language plpgsql
security definer
set search_path = ''
as $$
declare
  lineup_row public.weekly_lineups;
  league_row public.fantasy_leagues;
  slot_count integer;
  captain_in_lineup boolean;
  result public.weekly_lineups;
begin
  if (select auth.uid()) is null then
    raise exception 'Authentication required';
  end if;

  select * into lineup_row from public.weekly_lineups
  where id = target_lineup for update;

  if not found then raise exception 'Lineup not found'; end if;
  if lineup_row.user_id <> (select auth.uid()) then
    raise exception 'Not authorized';
  end if;
  if lineup_row.status in ('locked','scored') then
    raise exception 'Lineup is locked';
  end if;

  select * into league_row from public.fantasy_leagues
  where id = lineup_row.league_id;

  if league_row.lineup_locks_at is not null and now() >= league_row.lineup_locks_at then
    raise exception 'Lineup deadline has passed';
  end if;

  select count(*) into slot_count
  from public.lineup_players
  where lineup_id = lineup_row.id;

  if slot_count < 5 then
    raise exception 'All five role slots must be filled (currently %)', slot_count;
  end if;

  if lineup_row.captain_player_id is null then
    raise exception 'Choose a captain before submitting';
  end if;

  select exists (
    select 1 from public.lineup_players
    where lineup_id = lineup_row.id
      and player_id = lineup_row.captain_player_id
  ) into captain_in_lineup;

  if not captain_in_lineup then
    raise exception 'Captain must be one of your five lineup players';
  end if;

  update public.weekly_lineups set
    status = 'submitted',
    submitted_at = now()
  where id = lineup_row.id
  returning * into result;

  return result;
end;
$$;

-- 2. Guard captain changes on locked lineups ---------------------------------
-- The existing update policy already restricts locked/scored rows, but this
-- trigger also prevents captains who are not on the saved lineup once the
-- lineup has been submitted.

create or replace function public.validate_weekly_lineup_update()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if old.status in ('locked','scored') and new.status = old.status
     and new.captain_player_id is distinct from old.captain_player_id then
    raise exception 'Lineup is locked';
  end if;

  if new.status = 'submitted'
     and new.captain_player_id is not null
     and exists (select 1 from public.lineup_players where lineup_id = new.id)
     and not exists (
       select 1 from public.lineup_players
       where lineup_id = new.id and player_id = new.captain_player_id
     ) then
    raise exception 'Captain must be one of your lineup players';
  end if;

  return new;
end;
$$;

drop trigger if exists validate_weekly_lineup_before_update on public.weekly_lineups;
create trigger validate_weekly_lineup_before_update
before update on public.weekly_lineups
for each row execute function public.validate_weekly_lineup_update();
