-- Fantasy MPL — Server-enforced transfer market
-- Run after 008_prediction_scoring.sql

-- 1. Count a manager's used transfers in a league -----------------------------

create or replace function public.transfers_used(target_league uuid, target_user uuid)
returns integer
language sql
stable
security definer
set search_path = ''
as $$
  select count(*)::integer
  from public.roster_transactions
  where league_id = target_league
    and user_id = target_user
    and action = 'transfer';
$$;

-- 2. The transfer itself --------------------------------------------------------
-- Releases player_out, acquires player_in. Server enforces:
--   * league is active and caller is an active member
--   * transfer limit not exceeded (fantasy_leagues.transfer_limit)
--   * caller owns player_out
--   * player_in has no active owner in this league
--   * same role, and no professional-team conflict with the rest of the roster
-- Both moves are logged in the append-only roster_transactions ledger.

create or replace function public.make_transfer(
  target_league uuid,
  player_out uuid,
  player_in uuid
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  league_row public.fantasy_leagues;
  used integer;
  out_role text;
  in_role text;
  in_team uuid;
  out_ownership uuid;
begin
  if (select auth.uid()) is null then
    raise exception 'Authentication required';
  end if;
  if player_out = player_in then
    raise exception 'Choose two different players';
  end if;

  select * into league_row from public.fantasy_leagues
  where id = target_league for update;
  if not found then raise exception 'League not found'; end if;
  if league_row.status <> 'active' then
    raise exception 'Transfers open once the league is active';
  end if;

  if not exists (
    select 1 from public.league_members
    where league_id = target_league
      and user_id = (select auth.uid())
      and status = 'active'
  ) then
    raise exception 'You are not an active manager in this league';
  end if;

  used := public.transfers_used(target_league, (select auth.uid()));
  if used >= league_row.transfer_limit then
    raise exception 'Transfer limit reached (% of %)', used, league_row.transfer_limit;
  end if;

  select id into out_ownership
  from public.player_ownership
  where league_id = target_league
    and user_id = (select auth.uid())
    and player_id = player_out
    and released_at is null
  for update;
  if out_ownership is null then
    raise exception 'You do not own this player';
  end if;

  if exists (
    select 1 from public.player_ownership
    where league_id = target_league
      and player_id = player_in
      and released_at is null
  ) then
    raise exception 'That player is already owned in this league';
  end if;

  select sr.role into out_role
  from public.season_rosters sr
  where sr.season_id = league_row.season_id
    and sr.player_id = player_out and sr.active = true
  order by sr.starts_at desc limit 1;

  select sr.role, sr.team_id into in_role, in_team
  from public.season_rosters sr
  where sr.season_id = league_row.season_id
    and sr.player_id = player_in and sr.active = true
    and sr.role in ('EXP','JUNGLE','MID','GOLD','ROAM')
  order by sr.starts_at desc limit 1;

  if in_role is null then
    raise exception 'Incoming player is not eligible this season';
  end if;
  if out_role is distinct from in_role then
    raise exception 'Transfers must be role-for-role (% for %)', in_role, out_role;
  end if;

  if exists (
    select 1
    from public.player_ownership po
    join public.season_rosters sr on sr.player_id = po.player_id
      and sr.season_id = league_row.season_id and sr.active = true
    where po.league_id = target_league
      and po.user_id = (select auth.uid())
      and po.released_at is null
      and po.player_id <> player_out
      and sr.team_id = in_team
  ) then
    raise exception 'You already own a player from that professional team';
  end if;

  update public.player_ownership
  set released_at = now()
  where id = out_ownership;

  insert into public.player_ownership
    (league_id, user_id, player_id, acquired_via)
  values
    (target_league, (select auth.uid()), player_in, 'transfer');

  insert into public.roster_transactions
    (league_id, user_id, player_id, related_player_id, action, metadata)
  values
    (target_league, (select auth.uid()), player_in, player_out, 'transfer',
     jsonb_build_object('role', in_role)),
    (target_league, (select auth.uid()), player_out, player_in, 'drop',
     jsonb_build_object('via', 'transfer'));
end;
$$;

-- 3. Announce transfers in league chat ------------------------------------------

create or replace function public.announce_transfer()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  in_handle text;
  out_handle text;
begin
  if new.action <> 'transfer' then return new; end if;

  select handle into in_handle from public.players where id = new.player_id;
  select handle into out_handle from public.players where id = new.related_player_id;

  insert into public.league_chat_messages
    (league_id, user_id, message, message_type)
  values
    (new.league_id, new.user_id,
     'TRANSFER — ' || upper(coalesce(in_handle, 'PLAYER')) || ' IN · '
       || upper(coalesce(out_handle, 'PLAYER')) || ' OUT',
     'draft_event');
  return new;
end;
$$;

drop trigger if exists roster_transaction_announcement on public.roster_transactions;
create trigger roster_transaction_announcement
after insert on public.roster_transactions
for each row execute function public.announce_transfer();

-- 4. Allow league members to insert nothing directly: roster_transactions stays
--    admin/function-written only (no new policies needed — the security definer
--    functions above bypass RLS for their controlled writes).
