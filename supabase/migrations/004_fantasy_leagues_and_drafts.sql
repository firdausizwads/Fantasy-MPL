-- Fantasy MPL — Multiplayer leagues, drafts, lineups and social foundation
-- Run after 003_verified_season18_seed.sql

-- Utility helpers -----------------------------------------------------------

create or replace function public.generate_invite_code()
returns text
language plpgsql
volatile
security invoker
set search_path = ''
as $$
declare
  candidate text;
begin
  loop
    candidate := upper(substr(encode(extensions.gen_random_bytes(6), 'hex'), 1, 8));
    exit when not exists (
      select 1 from public.fantasy_leagues where invite_code = candidate
    );
  end loop;
  return candidate;
end;
$$;

-- Core leagues --------------------------------------------------------------

create table if not exists public.fantasy_leagues (
  id uuid primary key default gen_random_uuid(),
  season_id uuid not null references public.seasons(id) on delete cascade,
  commissioner_id uuid not null references auth.users(id) on delete cascade,
  creator_profile_id uuid references public.profiles(id) on delete set null,
  name text not null,
  description text,
  invite_code text not null default public.generate_invite_code(),
  visibility text not null default 'private'
    check (visibility in ('private','public','unlisted')),
  format text not null default 'seasonal'
    check (format in (
      'seasonal','weekend_salary','weekend_draft','hero_lock',
      'survivor','creator_public','h2h'
    )),
  status text not null default 'forming'
    check (status in (
      'forming','draft_scheduled','drafting','active',
      'completed','cancelled'
    )),
  max_managers integer not null default 8 check (max_managers between 2 and 100000),
  salary_budget numeric(8,2) check (salary_budget is null or salary_budget > 0),
  transfer_limit integer not null default 3 check (transfer_limit >= 0),
  pick_seconds integer not null default 60 check (pick_seconds between 15 and 300),
  scoring_starts_at timestamptz,
  scoring_ends_at timestamptz,
  lineup_locks_at timestamptz,
  constraints jsonb not null default '{}'::jsonb,
  chat_enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint league_name_length check (char_length(name) between 3 and 60),
  constraint league_description_length check (description is null or char_length(description) <= 500),
  constraint league_invite_code_unique unique (invite_code),
  check (scoring_ends_at is null or scoring_starts_at is null or scoring_ends_at > scoring_starts_at)
);

create table if not exists public.league_members (
  id uuid primary key default gen_random_uuid(),
  league_id uuid not null references public.fantasy_leagues(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  member_role text not null default 'manager'
    check (member_role in ('commissioner','moderator','manager')),
  status text not null default 'active'
    check (status in ('active','eliminated','left','removed')),
  draft_position integer check (draft_position is null or draft_position > 0),
  waiver_priority integer check (waiver_priority is null or waiver_priority > 0),
  joined_at timestamptz not null default now(),
  eliminated_at timestamptz,
  unique (league_id, user_id),
  unique (league_id, draft_position)
);

create index if not exists league_members_user_idx
  on public.league_members (user_id, status);
create index if not exists fantasy_leagues_season_format_idx
  on public.fantasy_leagues (season_id, format, status);

create or replace function public.is_league_member(target_league uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.league_members
    where league_id = target_league
      and user_id = (select auth.uid())
      and status in ('active','eliminated')
  );
$$;

create or replace function public.can_manage_league(target_league uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    (select public.is_platform_admin())
    or exists (
      select 1 from public.league_members
      where league_id = target_league
        and user_id = (select auth.uid())
        and member_role in ('commissioner','moderator')
        and status = 'active'
    );
$$;

-- Automatically add the creator as commissioner.
create or replace function public.add_league_commissioner()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.league_members
    (league_id, user_id, member_role, status, draft_position, waiver_priority)
  values
    (new.id, new.commissioner_id, 'commissioner', 'active', 1, 1)
  on conflict (league_id, user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists fantasy_league_add_commissioner on public.fantasy_leagues;
create trigger fantasy_league_add_commissioner
after insert on public.fantasy_leagues
for each row execute function public.add_league_commissioner();

-- Transaction-safe private join by invite code.
create or replace function public.join_league_by_code(requested_code text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  target public.fantasy_leagues;
  active_count integer;
  next_position integer;
begin
  if (select auth.uid()) is null then
    raise exception 'Authentication required';
  end if;

  select * into target
  from public.fantasy_leagues
  where invite_code = upper(trim(requested_code))
  for update;

  if not found then
    raise exception 'League not found';
  end if;

  if target.status <> 'forming' then
    raise exception 'League is no longer accepting managers';
  end if;

  if exists (
    select 1 from public.league_members
    where league_id = target.id and user_id = (select auth.uid())
      and status in ('active','eliminated')
  ) then
    return target.id;
  end if;

  select count(*) into active_count
  from public.league_members
  where league_id = target.id and status = 'active';

  select coalesce(max(draft_position), 0) + 1 into next_position
  from public.league_members
  where league_id = target.id;

  if active_count >= target.max_managers then
    raise exception 'League is full';
  end if;

  insert into public.league_members
    (league_id, user_id, member_role, status, draft_position, waiver_priority)
  values
    (target.id, (select auth.uid()), 'manager', 'active', next_position, next_position);

  return target.id;
end;
$$;

-- Public leagues do not expose invite codes.
create or replace function public.list_public_leagues(
  requested_season uuid default null,
  requested_format text default null
)
returns table (
  id uuid,
  season_id uuid,
  name text,
  description text,
  format text,
  status text,
  max_managers integer,
  active_managers bigint,
  commissioner_id uuid,
  creator_profile_id uuid,
  scoring_starts_at timestamptz,
  scoring_ends_at timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  select
    l.id, l.season_id, l.name, l.description, l.format, l.status,
    l.max_managers,
    count(m.id) filter (where m.status = 'active') as active_managers,
    l.commissioner_id, l.creator_profile_id,
    l.scoring_starts_at, l.scoring_ends_at
  from public.fantasy_leagues l
  left join public.league_members m on m.league_id = l.id
  where l.visibility = 'public'
    and (requested_season is null or l.season_id = requested_season)
    and (requested_format is null or l.format = requested_format)
  group by l.id;
$$;

create or replace function public.join_public_league(target_league uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  target public.fantasy_leagues;
  active_count integer;
  next_position integer;
begin
  if (select auth.uid()) is null then
    raise exception 'Authentication required';
  end if;

  select * into target
  from public.fantasy_leagues
  where id = target_league and visibility = 'public'
  for update;

  if not found then raise exception 'Public league not found'; end if;
  if target.status not in ('forming','active') then raise exception 'League is closed'; end if;

  if exists (
    select 1 from public.league_members
    where league_id = target.id and user_id = (select auth.uid())
      and status in ('active','eliminated')
  ) then return target.id; end if;

  select count(*) into active_count
  from public.league_members
  where league_id = target.id and status = 'active';

  select coalesce(max(draft_position), 0) + 1 into next_position
  from public.league_members
  where league_id = target.id;

  if active_count >= target.max_managers then raise exception 'League is full'; end if;

  insert into public.league_members
    (league_id, user_id, member_role, status, draft_position, waiver_priority)
  values
    (target.id, (select auth.uid()), 'manager', 'active', next_position, next_position);

  return target.id;
end;
$$;

-- Drafts and unique ownership ----------------------------------------------

create table if not exists public.drafts (
  id uuid primary key default gen_random_uuid(),
  league_id uuid not null unique references public.fantasy_leagues(id) on delete cascade,
  status text not null default 'waiting'
    check (status in ('waiting','active','paused','completed','cancelled')),
  manager_count integer check (manager_count is null or manager_count between 2 and 10),
  roster_size integer not null default 5 check (roster_size between 1 and 10),
  current_pick_number integer not null default 0 check (current_pick_number >= 0),
  scheduled_at timestamptz,
  started_at timestamptz,
  completed_at timestamptz,
  turn_expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.draft_picks (
  id uuid primary key default gen_random_uuid(),
  draft_id uuid not null references public.drafts(id) on delete cascade,
  league_id uuid not null references public.fantasy_leagues(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  player_id uuid not null references public.players(id),
  pick_number integer not null check (pick_number > 0),
  round_number integer not null check (round_number > 0),
  auto_picked boolean not null default false,
  picked_at timestamptz not null default now(),
  unique (draft_id, pick_number),
  unique (league_id, player_id)
);

create table if not exists public.player_ownership (
  id uuid primary key default gen_random_uuid(),
  league_id uuid not null references public.fantasy_leagues(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  player_id uuid not null references public.players(id),
  acquired_via text not null
    check (acquired_via in ('draft','free_agent','waiver','transfer','commissioner')),
  acquired_at timestamptz not null default now(),
  released_at timestamptz,
  check (released_at is null or released_at >= acquired_at)
);

create unique index if not exists one_active_owner_per_league_player
  on public.player_ownership (league_id, player_id)
  where released_at is null;
create index if not exists player_ownership_manager_idx
  on public.player_ownership (league_id, user_id)
  where released_at is null;

create or replace function public.start_league_draft(target_draft uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  draft_row public.drafts;
  league_row public.fantasy_leagues;
  member_total integer;
begin
  select * into draft_row from public.drafts where id = target_draft for update;
  if not found then raise exception 'Draft not found'; end if;
  if not public.can_manage_league(draft_row.league_id) then raise exception 'Not authorized'; end if;
  if draft_row.status not in ('waiting','paused') then raise exception 'Draft cannot be started'; end if;

  select * into league_row from public.fantasy_leagues where id = draft_row.league_id;
  select count(*) into member_total from public.league_members
    where league_id = draft_row.league_id and status = 'active';

  if member_total < 2 then raise exception 'At least two active managers are required'; end if;

  update public.drafts set
    status = 'active', manager_count = member_total,
    started_at = coalesce(started_at, now()),
    turn_expires_at = now() + make_interval(secs => league_row.pick_seconds)
  where id = target_draft;

  update public.fantasy_leagues set status = 'drafting' where id = draft_row.league_id;
end;
$$;

create or replace function public.make_draft_pick(
  target_draft uuid,
  selected_player uuid
)
returns public.draft_picks
language plpgsql
security definer
set search_path = ''
as $$
declare
  d public.drafts;
  l public.fantasy_leagues;
  member_position integer;
  expected_position integer;
  pick_number integer;
  round_number integer;
  slot_number integer;
  selected_role text;
  selected_team uuid;
  result public.draft_picks;
begin
  if (select auth.uid()) is null then raise exception 'Authentication required'; end if;

  select * into d from public.drafts where id = target_draft for update;
  if not found or d.status <> 'active' then raise exception 'Draft is not active'; end if;
  if d.manager_count is null then raise exception 'Draft manager count is not set'; end if;

  select * into l from public.fantasy_leagues where id = d.league_id;

  select draft_position into member_position
  from public.league_members
  where league_id = d.league_id
    and user_id = (select auth.uid())
    and status = 'active';

  if member_position is null then raise exception 'You are not an active manager'; end if;

  pick_number := d.current_pick_number + 1;
  round_number := ((pick_number - 1) / d.manager_count) + 1;
  slot_number := ((pick_number - 1) % d.manager_count) + 1;
  expected_position := case
    when mod(round_number, 2) = 1 then slot_number
    else d.manager_count - slot_number + 1
  end;

  if member_position <> expected_position then raise exception 'It is not your turn'; end if;
  if d.turn_expires_at is not null and now() > d.turn_expires_at then
    raise exception 'Pick timer expired';
  end if;

  select sr.role, sr.team_id into selected_role, selected_team
  from public.season_rosters sr
  where sr.season_id = l.season_id
    and sr.player_id = selected_player
    and sr.active = true
    and sr.role in ('EXP','JUNGLE','MID','GOLD','ROAM')
  order by sr.starts_at desc
  limit 1;

  if selected_role is null then raise exception 'Player is not eligible for this season'; end if;

  if exists (
    select 1 from public.player_ownership
    where league_id = d.league_id and player_id = selected_player and released_at is null
  ) then raise exception 'Player is already owned'; end if;

  if exists (
    select 1
    from public.player_ownership po
    join public.season_rosters sr on sr.player_id = po.player_id
      and sr.season_id = l.season_id and sr.active = true
    where po.league_id = d.league_id
      and po.user_id = (select auth.uid())
      and po.released_at is null
      and (sr.role = selected_role or sr.team_id = selected_team)
  ) then raise exception 'Roster already contains this role or professional team'; end if;

  insert into public.draft_picks
    (draft_id, league_id, user_id, player_id, pick_number, round_number)
  values
    (d.id, d.league_id, (select auth.uid()), selected_player, pick_number, round_number)
  returning * into result;

  insert into public.player_ownership
    (league_id, user_id, player_id, acquired_via)
  values
    (d.league_id, (select auth.uid()), selected_player, 'draft');

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

-- Prices, lineups and transfers --------------------------------------------

create table if not exists public.player_prices (
  id uuid primary key default gen_random_uuid(),
  season_id uuid not null references public.seasons(id) on delete cascade,
  week_id uuid references public.competition_weeks(id) on delete cascade,
  player_id uuid not null references public.players(id) on delete cascade,
  price numeric(8,2) not null check (price > 0),
  created_at timestamptz not null default now(),
  unique (season_id, week_id, player_id)
);

create unique index if not exists player_prices_default_unique
  on public.player_prices (season_id, player_id)
  where week_id is null;

create table if not exists public.weekly_lineups (
  id uuid primary key default gen_random_uuid(),
  league_id uuid not null references public.fantasy_leagues(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  week_id uuid not null references public.competition_weeks(id) on delete cascade,
  captain_player_id uuid references public.players(id),
  status text not null default 'draft'
    check (status in ('draft','submitted','locked','scored')),
  submitted_at timestamptz,
  locked_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (league_id, user_id, week_id)
);

create table if not exists public.lineup_players (
  id uuid primary key default gen_random_uuid(),
  lineup_id uuid not null references public.weekly_lineups(id) on delete cascade,
  player_id uuid not null references public.players(id),
  team_id uuid not null references public.teams(id),
  slot_role text not null check (slot_role in ('EXP','JUNGLE','MID','GOLD','ROAM')),
  price_snapshot numeric(8,2),
  created_at timestamptz not null default now(),
  unique (lineup_id, player_id),
  unique (lineup_id, team_id),
  unique (lineup_id, slot_role)
);

create or replace function public.validate_lineup_player()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  lineup_row public.weekly_lineups;
  league_row public.fantasy_leagues;
  player_role text;
  player_team uuid;
  total_cost numeric(8,2);
begin
  select * into lineup_row from public.weekly_lineups where id = new.lineup_id;
  if not found then raise exception 'Lineup not found'; end if;
  if lineup_row.user_id <> (select auth.uid()) and not public.can_manage_league(lineup_row.league_id) then
    raise exception 'Not authorized';
  end if;
  if lineup_row.status in ('locked','scored') then raise exception 'Lineup is locked'; end if;

  select * into league_row from public.fantasy_leagues where id = lineup_row.league_id;
  if league_row.lineup_locks_at is not null and now() >= league_row.lineup_locks_at then
    raise exception 'Lineup deadline has passed';
  end if;

  select sr.role, sr.team_id into player_role, player_team
  from public.season_rosters sr
  where sr.season_id = league_row.season_id
    and sr.player_id = new.player_id and sr.active = true
  order by sr.starts_at desc limit 1;

  if player_role is null or player_role <> new.slot_role then
    raise exception 'Player is not eligible for this role';
  end if;
  if player_team <> new.team_id then raise exception 'Professional team mismatch'; end if;

  if league_row.format not in ('weekend_salary','creator_public') and not exists (
    select 1 from public.player_ownership
    where league_id = lineup_row.league_id
      and user_id = lineup_row.user_id
      and player_id = new.player_id
      and released_at is null
  ) then raise exception 'Manager does not own this player'; end if;

  if league_row.format in ('weekend_salary','creator_public') then
    select pp.price into new.price_snapshot
    from public.player_prices pp
    where pp.season_id = league_row.season_id
      and pp.player_id = new.player_id
      and (pp.week_id = lineup_row.week_id or pp.week_id is null)
    order by pp.week_id nulls last limit 1;

    if new.price_snapshot is null then raise exception 'Player price is not configured'; end if;

    select coalesce(sum(lp.price_snapshot), 0) + new.price_snapshot into total_cost
    from public.lineup_players lp
    where lp.lineup_id = new.lineup_id and lp.id <> coalesce(new.id, gen_random_uuid());

    if league_row.salary_budget is not null and total_cost > league_row.salary_budget then
      raise exception 'Salary budget exceeded';
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists validate_lineup_player_before_write on public.lineup_players;
create trigger validate_lineup_player_before_write
before insert or update on public.lineup_players
for each row execute function public.validate_lineup_player();

create table if not exists public.roster_transactions (
  id uuid primary key default gen_random_uuid(),
  league_id uuid not null references public.fantasy_leagues(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  week_id uuid references public.competition_weeks(id),
  player_id uuid not null references public.players(id),
  related_player_id uuid references public.players(id),
  action text not null
    check (action in ('draft','add','drop','waiver','transfer','commissioner')),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- H2H and Survivor ----------------------------------------------------------

create table if not exists public.h2h_matchups (
  id uuid primary key default gen_random_uuid(),
  league_id uuid not null references public.fantasy_leagues(id) on delete cascade,
  week_id uuid not null references public.competition_weeks(id) on delete cascade,
  home_user_id uuid not null references auth.users(id) on delete cascade,
  away_user_id uuid not null references auth.users(id) on delete cascade,
  ban_locks_at timestamptz not null,
  bans_reveal_at timestamptz not null,
  lineup_locks_at timestamptz not null,
  status text not null default 'scheduled'
    check (status in ('scheduled','ban_open','ban_revealed','live','completed')),
  home_score numeric(10,2),
  away_score numeric(10,2),
  winner_user_id uuid references auth.users(id),
  created_at timestamptz not null default now(),
  check (home_user_id <> away_user_id),
  unique (league_id, week_id, home_user_id, away_user_id)
);

create table if not exists public.h2h_bans (
  id uuid primary key default gen_random_uuid(),
  matchup_id uuid not null references public.h2h_matchups(id) on delete cascade,
  submitted_by uuid not null references auth.users(id) on delete cascade,
  target_user_id uuid not null references auth.users(id) on delete cascade,
  banned_player_id uuid not null references public.players(id),
  submitted_at timestamptz not null default now(),
  unique (matchup_id, submitted_by),
  check (submitted_by <> target_user_id)
);

create or replace function public.submit_h2h_ban(
  target_matchup uuid,
  target_player uuid
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  matchup public.h2h_matchups;
  target_user uuid;
  result_id uuid;
begin
  select * into matchup from public.h2h_matchups where id = target_matchup for update;
  if not found then raise exception 'Matchup not found'; end if;
  if now() >= matchup.ban_locks_at then raise exception 'Ban window is closed'; end if;
  if (select auth.uid()) = matchup.home_user_id then target_user := matchup.away_user_id;
  elsif (select auth.uid()) = matchup.away_user_id then target_user := matchup.home_user_id;
  else raise exception 'You are not part of this matchup'; end if;

  if not exists (
    select 1 from public.player_ownership
    where league_id = matchup.league_id
      and user_id = target_user
      and player_id = target_player
      and released_at is null
  ) then raise exception 'Target manager does not own this player'; end if;

  insert into public.h2h_bans
    (matchup_id, submitted_by, target_user_id, banned_player_id)
  values
    (target_matchup, (select auth.uid()), target_user, target_player)
  on conflict (matchup_id, submitted_by) do update set
    banned_player_id = excluded.banned_player_id,
    submitted_at = now()
  returning id into result_id;

  return result_id;
end;
$$;

create table if not exists public.survivor_eliminations (
  id uuid primary key default gen_random_uuid(),
  league_id uuid not null references public.fantasy_leagues(id) on delete cascade,
  week_id uuid not null references public.competition_weeks(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  weekly_score numeric(10,2) not null,
  rank_at_elimination integer,
  tie_break_data jsonb not null default '{}'::jsonb,
  eliminated_at timestamptz not null default now(),
  unique (league_id, week_id, user_id)
);

-- League chat and reactions -------------------------------------------------

create table if not exists public.league_chat_messages (
  id uuid primary key default gen_random_uuid(),
  league_id uuid not null references public.fantasy_leagues(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  message text not null,
  message_type text not null default 'text'
    check (message_type in ('text','sticker','system','draft_event')),
  reply_to_id uuid references public.league_chat_messages(id) on delete set null,
  moderated boolean not null default false,
  removed_at timestamptz,
  created_at timestamptz not null default now(),
  constraint chat_message_length check (char_length(message) between 1 and 300)
);

create table if not exists public.league_chat_reactions (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references public.league_chat_messages(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  reaction text not null check (reaction in ('GG','NICE','META','FIRE')),
  created_at timestamptz not null default now(),
  unique (message_id, user_id, reaction)
);

create table if not exists public.league_moderation (
  id uuid primary key default gen_random_uuid(),
  league_id uuid not null references public.fantasy_leagues(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  muted_until timestamptz,
  reason text,
  actioned_by uuid not null references auth.users(id),
  created_at timestamptz not null default now()
);

create index if not exists league_chat_messages_time_idx
  on public.league_chat_messages (league_id, created_at desc);

-- updated_at triggers -------------------------------------------------------

do $$
declare table_name text;
begin
  for table_name in select unnest(array['fantasy_leagues','drafts','weekly_lineups']) loop
    execute format('drop trigger if exists %I_set_updated_at on public.%I', table_name, table_name);
    execute format(
      'create trigger %I_set_updated_at before update on public.%I for each row execute function public.set_updated_at()',
      table_name, table_name
    );
  end loop;
end;
$$;

-- Score ledger can now reference leagues.
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'score_transactions_league_id_fkey'
  ) then
    alter table public.score_transactions
      add constraint score_transactions_league_id_fkey
      foreign key (league_id) references public.fantasy_leagues(id) on delete cascade;
  end if;
end;
$$;

-- Row Level Security --------------------------------------------------------

alter table public.fantasy_leagues enable row level security;
alter table public.league_members enable row level security;
alter table public.drafts enable row level security;
alter table public.draft_picks enable row level security;
alter table public.player_ownership enable row level security;
alter table public.player_prices enable row level security;
alter table public.weekly_lineups enable row level security;
alter table public.lineup_players enable row level security;
alter table public.roster_transactions enable row level security;
alter table public.h2h_matchups enable row level security;
alter table public.h2h_bans enable row level security;
alter table public.survivor_eliminations enable row level security;
alter table public.league_chat_messages enable row level security;
alter table public.league_chat_reactions enable row level security;
alter table public.league_moderation enable row level security;

-- League rows and memberships
drop policy if exists "members read leagues" on public.fantasy_leagues;
create policy "members read leagues" on public.fantasy_leagues for select to authenticated
using (public.is_league_member(id) or commissioner_id = (select auth.uid()) or public.is_platform_admin());

drop policy if exists "users create leagues" on public.fantasy_leagues;
create policy "users create leagues" on public.fantasy_leagues for insert to authenticated
with check (commissioner_id = (select auth.uid()));

drop policy if exists "managers update leagues" on public.fantasy_leagues;
create policy "managers update leagues" on public.fantasy_leagues for update to authenticated
using (public.can_manage_league(id)) with check (public.can_manage_league(id));

drop policy if exists "members read memberships" on public.league_members;
create policy "members read memberships" on public.league_members for select to authenticated
using (public.is_league_member(league_id) or public.is_platform_admin());

drop policy if exists "managers update memberships" on public.league_members;
create policy "managers update memberships" on public.league_members for update to authenticated
using (public.can_manage_league(league_id)) with check (public.can_manage_league(league_id));

-- Drafts, picks and ownership are member-readable. Writes use secure functions.
do $$
declare table_name text;
begin
  for table_name in select unnest(array['drafts','draft_picks','player_ownership']) loop
    execute format('drop policy if exists "members read %s" on public.%I', table_name, table_name);
    execute format(
      'create policy "members read %s" on public.%I for select to authenticated using (public.is_league_member(league_id) or public.is_platform_admin())',
      table_name, table_name
    );
  end loop;
end;
$$;

drop policy if exists "managers create drafts" on public.drafts;
create policy "managers create drafts" on public.drafts for insert to authenticated
with check (public.can_manage_league(league_id));

drop policy if exists "managers update drafts" on public.drafts;
create policy "managers update drafts" on public.drafts for update to authenticated
using (public.can_manage_league(league_id)) with check (public.can_manage_league(league_id));

-- Prices are public reference data; admins manage them.
drop policy if exists "public reads player prices" on public.player_prices;
create policy "public reads player prices" on public.player_prices for select using (true);
drop policy if exists "admins manage player prices" on public.player_prices;
create policy "admins manage player prices" on public.player_prices for all to authenticated
using (public.is_platform_admin()) with check (public.is_platform_admin());

-- Lineups
 drop policy if exists "members read league lineups" on public.weekly_lineups;
create policy "members read league lineups" on public.weekly_lineups for select to authenticated
using (
  public.is_league_member(league_id)
  and (
    user_id = (select auth.uid())
    or status in ('locked','scored')
    or public.can_manage_league(league_id)
  )
);

drop policy if exists "users create own lineups" on public.weekly_lineups;
create policy "users create own lineups" on public.weekly_lineups for insert to authenticated
with check (user_id = (select auth.uid()) and public.is_league_member(league_id));

drop policy if exists "users update own unlocked lineups" on public.weekly_lineups;
create policy "users update own unlocked lineups" on public.weekly_lineups for update to authenticated
using (user_id = (select auth.uid()) and status in ('draft','submitted'))
with check (user_id = (select auth.uid()) and status in ('draft','submitted','locked'));

drop policy if exists "members read lineup players" on public.lineup_players;
create policy "members read lineup players" on public.lineup_players for select to authenticated
using (
  exists (
    select 1 from public.weekly_lineups wl
    where wl.id = lineup_id
      and public.is_league_member(wl.league_id)
      and (wl.user_id = (select auth.uid()) or wl.status in ('locked','scored') or public.can_manage_league(wl.league_id))
  )
);

drop policy if exists "users manage own lineup players" on public.lineup_players;
create policy "users manage own lineup players" on public.lineup_players for all to authenticated
using (
  exists (
    select 1 from public.weekly_lineups wl
    where wl.id = lineup_id and wl.user_id = (select auth.uid()) and wl.status in ('draft','submitted')
  )
)
with check (
  exists (
    select 1 from public.weekly_lineups wl
    where wl.id = lineup_id and wl.user_id = (select auth.uid()) and wl.status in ('draft','submitted')
  )
);

-- Transactions, H2H and Survivor
drop policy if exists "members read roster transactions" on public.roster_transactions;
create policy "members read roster transactions" on public.roster_transactions for select to authenticated
using (public.is_league_member(league_id));

drop policy if exists "members read h2h matchups" on public.h2h_matchups;
create policy "members read h2h matchups" on public.h2h_matchups for select to authenticated
using (public.is_league_member(league_id));

drop policy if exists "participants read revealed bans" on public.h2h_bans;
create policy "participants read revealed bans" on public.h2h_bans for select to authenticated
using (
  submitted_by = (select auth.uid())
  or (
    exists (
      select 1 from public.h2h_matchups h
      where h.id = matchup_id
        and (h.home_user_id = (select auth.uid()) or h.away_user_id = (select auth.uid()))
        and now() >= h.bans_reveal_at
    )
  )
  or public.is_platform_admin()
);

drop policy if exists "members read survivor eliminations" on public.survivor_eliminations;
create policy "members read survivor eliminations" on public.survivor_eliminations for select to authenticated
using (public.is_league_member(league_id));

-- League chat
drop policy if exists "members read league chat" on public.league_chat_messages;
create policy "members read league chat" on public.league_chat_messages for select to authenticated
using (public.is_league_member(league_id));

drop policy if exists "members send league chat" on public.league_chat_messages;
create policy "members send league chat" on public.league_chat_messages for insert to authenticated
with check (
  user_id = (select auth.uid())
  and public.is_league_member(league_id)
  and not exists (
    select 1 from public.league_moderation lm
    where lm.league_id = league_chat_messages.league_id
      and lm.user_id = (select auth.uid())
      and lm.muted_until > now()
  )
);

drop policy if exists "managers moderate league chat" on public.league_chat_messages;
create policy "managers moderate league chat" on public.league_chat_messages for update to authenticated
using (public.can_manage_league(league_id)) with check (public.can_manage_league(league_id));

drop policy if exists "members read reactions" on public.league_chat_reactions;
create policy "members read reactions" on public.league_chat_reactions for select to authenticated
using (
  exists (
    select 1 from public.league_chat_messages msg
    where msg.id = message_id and public.is_league_member(msg.league_id)
  )
);

drop policy if exists "members add reactions" on public.league_chat_reactions;
create policy "members add reactions" on public.league_chat_reactions for insert to authenticated
with check (
  user_id = (select auth.uid())
  and exists (
    select 1 from public.league_chat_messages msg
    where msg.id = message_id and public.is_league_member(msg.league_id)
  )
);

drop policy if exists "users remove own reactions" on public.league_chat_reactions;
create policy "users remove own reactions" on public.league_chat_reactions for delete to authenticated
using (user_id = (select auth.uid()));

drop policy if exists "managers read moderation" on public.league_moderation;
create policy "managers read moderation" on public.league_moderation for select to authenticated
using (public.can_manage_league(league_id) or user_id = (select auth.uid()));

drop policy if exists "managers create moderation" on public.league_moderation;
create policy "managers create moderation" on public.league_moderation for insert to authenticated
with check (public.can_manage_league(league_id) and actioned_by = (select auth.uid()));

-- Enable realtime chat safely if it is not already part of the publication.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'league_chat_messages'
  ) then
    alter publication supabase_realtime add table public.league_chat_messages;
  end if;
end;
$$;

-- Grants -------------------------------------------------------------------

grant select, insert, update on public.fantasy_leagues to authenticated;
grant select, update on public.league_members to authenticated;
grant select, insert, update on public.drafts to authenticated;
grant select on public.draft_picks, public.player_ownership to authenticated;
grant select on public.player_prices to anon, authenticated;
grant select, insert, update on public.weekly_lineups to authenticated;
grant select, insert, update, delete on public.lineup_players to authenticated;
grant select on public.roster_transactions, public.h2h_matchups,
  public.h2h_bans, public.survivor_eliminations to authenticated;
grant select, insert, update on public.league_chat_messages to authenticated;
grant select, insert, delete on public.league_chat_reactions to authenticated;
grant select, insert on public.league_moderation to authenticated;

grant execute on function public.join_league_by_code(text) to authenticated;
grant execute on function public.join_public_league(uuid) to authenticated;
grant execute on function public.list_public_leagues(uuid,text) to anon, authenticated;
grant execute on function public.start_league_draft(uuid) to authenticated;
grant execute on function public.make_draft_pick(uuid,uuid) to authenticated;
grant execute on function public.submit_h2h_ban(uuid,uuid) to authenticated;

-- Verification summary
select
  (select count(*) from public.fantasy_leagues) as leagues,
  (select count(*) from public.league_members) as memberships,
  (select count(*) from public.drafts) as drafts,
  (select count(*) from public.weekly_lineups) as lineups;
