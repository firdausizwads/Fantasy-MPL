-- Fantasy MPL — Realtime synchronized draft
-- Run after 004_fantasy_leagues_and_drafts.sql

-- 1. Broadcast draft state, picks, membership and reactions over realtime ----

do $$
declare
  target text;
begin
  foreach target in array array[
    'drafts', 'draft_picks', 'league_members', 'league_chat_reactions'
  ] loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = target
    ) then
      execute format('alter publication supabase_realtime add table public.%I', target);
    end if;
  end loop;
end $$;

-- Reaction deletes must carry the full row so clients can decrement live.
alter table public.league_chat_reactions replica identity full;

-- 2. Announce every confirmed pick in league chat as a draft event ----------

create or replace function public.announce_draft_pick()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  picked_handle text;
begin
  select p.handle into picked_handle
  from public.players p
  where p.id = new.player_id;

  insert into public.league_chat_messages
    (league_id, user_id, message, message_type)
  values (
    new.league_id,
    new.user_id,
    'PICK ' || new.pick_number || ' · ROUND ' || new.round_number || ' — '
      || upper(coalesce(picked_handle, 'PLAYER'))
      || case when new.auto_picked then ' (AUTO)' else '' end,
    'draft_event'
  );
  return new;
end;
$$;

drop trigger if exists draft_pick_announcement on public.draft_picks;
create trigger draft_pick_announcement
after insert on public.draft_picks
for each row execute function public.announce_draft_pick();

-- 3. Server-validated auto pick when the turn timer expires ------------------
-- Any active league member may call this; the server verifies expiry itself,
-- so no client can force a pick early. Deterministic choice: first eligible
-- player ordered by team code then handle.

create or replace function public.auto_pick_expired_turn(target_draft uuid)
returns public.draft_picks
language plpgsql
security definer
set search_path = ''
as $$
declare
  d public.drafts;
  l public.fantasy_leagues;
  pick_number integer;
  round_number integer;
  slot_number integer;
  expected_position integer;
  on_clock_user uuid;
  chosen_player uuid;
  result public.draft_picks;
begin
  if (select auth.uid()) is null then
    raise exception 'Authentication required';
  end if;

  select * into d from public.drafts where id = target_draft for update;
  if not found or d.status <> 'active' then
    raise exception 'Draft is not active';
  end if;
  if d.manager_count is null then
    raise exception 'Draft manager count is not set';
  end if;

  if not public.is_league_member(d.league_id) then
    raise exception 'Not authorized';
  end if;

  if d.turn_expires_at is null or now() <= d.turn_expires_at then
    raise exception 'Turn timer has not expired';
  end if;

  select * into l from public.fantasy_leagues where id = d.league_id;

  pick_number := d.current_pick_number + 1;
  round_number := ((pick_number - 1) / d.manager_count) + 1;
  slot_number := ((pick_number - 1) % d.manager_count) + 1;
  expected_position := case
    when mod(round_number, 2) = 1 then slot_number
    else d.manager_count - slot_number + 1
  end;

  select user_id into on_clock_user
  from public.league_members
  where league_id = d.league_id
    and draft_position = expected_position
    and status = 'active';

  if on_clock_user is null then
    raise exception 'No active manager on the clock';
  end if;

  select sr.player_id into chosen_player
  from public.season_rosters sr
  join public.teams t on t.id = sr.team_id
  join public.players p on p.id = sr.player_id
  where sr.season_id = l.season_id
    and sr.active = true
    and sr.role in ('EXP','JUNGLE','MID','GOLD','ROAM')
    and not exists (
      select 1 from public.player_ownership po
      where po.league_id = d.league_id
        and po.player_id = sr.player_id
        and po.released_at is null
    )
    and not exists (
      select 1
      from public.player_ownership po
      join public.season_rosters owned on owned.player_id = po.player_id
        and owned.season_id = l.season_id and owned.active = true
      where po.league_id = d.league_id
        and po.user_id = on_clock_user
        and po.released_at is null
        and (owned.role = sr.role or owned.team_id = sr.team_id)
    )
  order by t.code, p.handle
  limit 1;

  if chosen_player is null then
    raise exception 'No eligible player available for auto pick';
  end if;

  insert into public.draft_picks
    (draft_id, league_id, user_id, player_id, pick_number, round_number, auto_picked)
  values
    (d.id, d.league_id, on_clock_user, chosen_player, pick_number, round_number, true)
  returning * into result;

  insert into public.player_ownership
    (league_id, user_id, player_id, acquired_via)
  values
    (d.league_id, on_clock_user, chosen_player, 'draft');

  if pick_number >= d.manager_count * d.roster_size then
    update public.drafts set
      current_pick_number = pick_number,
      status = 'completed', completed_at = now(), turn_expires_at = null
    where id = d.id;
    update public.fantasy_leagues set status = 'active' where id = d.league_id;
  else
    update public.drafts set
      current_pick_number = pick_number,
      turn_expires_at = now() + make_interval(secs => l.pick_seconds)
    where id = d.id;
  end if;

  return result;
end;
$$;

-- 4. Commissioner scheduling helper ------------------------------------------
-- Creates the draft row if needed and optionally stores a scheduled time.

create or replace function public.ensure_league_draft(
  target_league uuid,
  schedule_at timestamptz default null
)
returns public.drafts
language plpgsql
security definer
set search_path = ''
as $$
declare
  result public.drafts;
begin
  if not public.can_manage_league(target_league) then
    raise exception 'Not authorized';
  end if;

  select * into result from public.drafts where league_id = target_league for update;

  if not found then
    insert into public.drafts (league_id, scheduled_at)
    values (target_league, schedule_at)
    returning * into result;
  elsif schedule_at is not null and result.status in ('waiting','paused') then
    update public.drafts set scheduled_at = schedule_at
    where id = result.id
    returning * into result;
  end if;

  return result;
end;
$$;
