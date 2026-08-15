-- Fantasy MPL — Competition, prediction and scoring foundation
-- Run after 001_profiles_and_regions.sql

create or replace function public.is_platform_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles
    where id = (select auth.uid())
      and account_role in ('admin', 'super_admin')
  );
$$;

create table if not exists public.seasons (
  id uuid primary key default gen_random_uuid(),
  region_code text not null references public.regions(code),
  season_number integer not null check (season_number > 0),
  name text not null,
  starts_at timestamptz,
  ends_at timestamptz,
  status text not null default 'draft'
    check (status in ('draft','published','active','completed','archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (region_code, season_number)
);

create table if not exists public.competition_weeks (
  id uuid primary key default gen_random_uuid(),
  season_id uuid not null references public.seasons(id) on delete cascade,
  week_number integer not null check (week_number > 0),
  name text not null,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  meta_locks_at timestamptz not null,
  mvp_locks_at timestamptz not null,
  finalized_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (season_id, week_number),
  check (ends_at > starts_at)
);

create table if not exists public.teams (
  id uuid primary key default gen_random_uuid(),
  region_code text not null references public.regions(code),
  code text not null,
  name text not null,
  logo_url text,
  active boolean not null default true,
  source_url text,
  verified_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (region_code, code),
  unique (region_code, name)
);

create table if not exists public.players (
  id uuid primary key default gen_random_uuid(),
  handle citext not null,
  legal_name text,
  country_code text,
  photo_url text,
  active boolean not null default true,
  source_url text,
  verified_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.season_rosters (
  id uuid primary key default gen_random_uuid(),
  season_id uuid not null references public.seasons(id) on delete cascade,
  player_id uuid not null references public.players(id) on delete cascade,
  team_id uuid not null references public.teams(id),
  role text not null check (role in ('EXP','JUNGLE','MID','GOLD','ROAM','FLEX','COACH')),
  starts_at timestamptz not null,
  ends_at timestamptz,
  active boolean not null default true,
  source_url text,
  verified_at timestamptz,
  created_at timestamptz not null default now(),
  check (ends_at is null or ends_at >= starts_at),
  unique (season_id, player_id, starts_at)
);

create table if not exists public.matches (
  id uuid primary key default gen_random_uuid(),
  season_id uuid not null references public.seasons(id) on delete cascade,
  week_id uuid not null references public.competition_weeks(id) on delete cascade,
  home_team_id uuid not null references public.teams(id),
  away_team_id uuid not null references public.teams(id),
  best_of integer not null default 3 check (best_of in (1,3,5,7)),
  scheduled_at timestamptz not null,
  prediction_locks_at timestamptz not null,
  status text not null default 'scheduled'
    check (status in ('draft','scheduled','live','completed','postponed','cancelled')),
  home_score integer check (home_score is null or home_score >= 0),
  away_score integer check (away_score is null or away_score >= 0),
  winner_team_id uuid references public.teams(id),
  result_state text not null default 'unverified'
    check (result_state in ('unverified','verified','finalized','corrected')),
  source_url text,
  finalized_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (home_team_id <> away_team_id)
);

create index if not exists matches_week_time_idx
  on public.matches (week_id, scheduled_at);
create index if not exists matches_season_status_idx
  on public.matches (season_id, status);

create table if not exists public.heroes (
  id uuid primary key default gen_random_uuid(),
  name citext not null unique,
  portrait_url text,
  standard_roles text[] not null default '{}',
  active boolean not null default true,
  source_url text,
  updated_at timestamptz not null default now()
);

create table if not exists public.patches (
  id uuid primary key default gen_random_uuid(),
  version text not null unique,
  released_at timestamptz,
  notes_url text,
  active boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.match_predictions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  match_id uuid not null references public.matches(id) on delete cascade,
  predicted_winner_team_id uuid not null references public.teams(id),
  predicted_home_score integer check (predicted_home_score is null or predicted_home_score >= 0),
  predicted_away_score integer check (predicted_away_score is null or predicted_away_score >= 0),
  submitted_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, match_id),
  check (
    predicted_home_score is null
    or predicted_away_score is null
    or predicted_home_score <> predicted_away_score
  )
);

create table if not exists public.weekly_mvp_predictions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  week_id uuid not null references public.competition_weeks(id) on delete cascade,
  player_id uuid not null references public.players(id),
  submitted_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, week_id)
);

create table if not exists public.playoff_bracket_predictions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  season_id uuid not null references public.seasons(id) on delete cascade,
  bracket_version integer not null default 1,
  picks jsonb not null default '{}'::jsonb,
  predicted_champion_team_id uuid references public.teams(id),
  locks_at timestamptz not null,
  submitted_at timestamptz,
  updated_at timestamptz not null default now(),
  unique (user_id, season_id, bracket_version)
);

create table if not exists public.meta_predictions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  week_id uuid not null references public.competition_weeks(id) on delete cascade,
  most_picked_hero_id uuid references public.heroes(id),
  most_banned_hero_id uuid references public.heroes(id),
  most_contested_hero_id uuid references public.heroes(id),
  highest_ban_rate_range text
    check (highest_ban_rate_range is null or highest_ban_rate_range in ('UNDER_20','20_39','40_59','60_79','80_PLUS')),
  buffed_hero_id uuid references public.heroes(id),
  expected_contest_increase text
    check (expected_contest_increase is null or expected_contest_increase in ('0_9','10_19','20_29','30_PLUS')),
  flex_hero_id uuid references public.heroes(id),
  predicted_flex_role text
    check (predicted_flex_role is null or predicted_flex_role in ('EXP','JUNGLE','MID','GOLD','ROAM')),
  submitted_at timestamptz,
  updated_at timestamptz not null default now(),
  unique (user_id, week_id)
);

create table if not exists public.official_weekly_mvps (
  week_id uuid primary key references public.competition_weeks(id) on delete cascade,
  player_id uuid not null references public.players(id),
  source_url text,
  result_state text not null default 'unverified'
    check (result_state in ('unverified','verified','finalized','corrected')),
  finalized_at timestamptz,
  finalized_by uuid references auth.users(id)
);

create table if not exists public.scoring_rule_sets (
  id uuid primary key default gen_random_uuid(),
  season_id uuid not null references public.seasons(id) on delete cascade,
  version integer not null,
  effective_week_id uuid references public.competition_weeks(id),
  rules jsonb not null,
  active boolean not null default false,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  unique (season_id, version)
);

-- Append-only ledger. Corrections create reversing transactions rather than
-- editing or deleting historical points.
create table if not exists public.score_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  season_id uuid not null references public.seasons(id) on delete cascade,
  region_code text not null references public.regions(code),
  week_id uuid references public.competition_weeks(id),
  league_id uuid,
  category text not null
    check (category in ('prediction','fantasy','meta','playoff','bonus','adjustment')),
  points numeric(10,2) not null,
  reason_code text not null,
  description text not null,
  source_table text,
  source_id uuid,
  rule_set_id uuid references public.scoring_rule_sets(id),
  reverses_transaction_id uuid references public.score_transactions(id),
  created_at timestamptz not null default now()
);

create index if not exists score_user_region_idx
  on public.score_transactions (user_id, region_code, season_id);
create index if not exists score_week_idx
  on public.score_transactions (week_id, category);

-- updated_at triggers
do $$
declare
  table_name text;
begin
  for table_name in select unnest(array[
    'seasons','competition_weeks','teams','players','matches',
    'match_predictions','weekly_mvp_predictions','playoff_bracket_predictions',
    'meta_predictions'
  ]) loop
    execute format('drop trigger if exists %I_set_updated_at on public.%I', table_name, table_name);
    execute format(
      'create trigger %I_set_updated_at before update on public.%I for each row execute function public.set_updated_at()',
      table_name,
      table_name
    );
  end loop;
end;
$$;

-- Seed Season 18 containers without inventing fixtures or results.
insert into public.seasons (region_code, season_number, name, status) values
  ('MY', 18, 'MPL Malaysia Season 18', 'active'),
  ('ID', 18, 'MPL Indonesia Season 18', 'active'),
  ('PH', 18, 'MPL Philippines Season 18', 'published')
on conflict (region_code, season_number) do update set
  name = excluded.name,
  status = excluded.status;

-- Row Level Security
alter table public.seasons enable row level security;
alter table public.competition_weeks enable row level security;
alter table public.teams enable row level security;
alter table public.players enable row level security;
alter table public.season_rosters enable row level security;
alter table public.matches enable row level security;
alter table public.heroes enable row level security;
alter table public.patches enable row level security;
alter table public.match_predictions enable row level security;
alter table public.weekly_mvp_predictions enable row level security;
alter table public.playoff_bracket_predictions enable row level security;
alter table public.meta_predictions enable row level security;
alter table public.official_weekly_mvps enable row level security;
alter table public.scoring_rule_sets enable row level security;
alter table public.score_transactions enable row level security;

-- Public competition reference data and administrator management policies
do $$
declare
  table_name text;
begin
  for table_name in select unnest(array[
    'seasons','competition_weeks','teams','players','season_rosters',
    'matches','heroes','patches','official_weekly_mvps','scoring_rule_sets'
  ]) loop
    execute format('drop policy if exists "public reads %s" on public.%I', table_name, table_name);
    execute format('create policy "public reads %s" on public.%I for select using (true)', table_name, table_name);

    execute format('drop policy if exists "admins manage %s" on public.%I', table_name, table_name);
    execute format(
      'create policy "admins manage %s" on public.%I for all to authenticated using ((select public.is_platform_admin())) with check ((select public.is_platform_admin()))',
      table_name,
      table_name
    );
  end loop;
end;
$$;

-- Match predictions: owner-only and editable only before server lock.
drop policy if exists "users read own match predictions" on public.match_predictions;
create policy "users read own match predictions"
on public.match_predictions for select to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "users create unlocked match predictions" on public.match_predictions;
create policy "users create unlocked match predictions"
on public.match_predictions for insert to authenticated
with check (
  (select auth.uid()) = user_id
  and exists (
    select 1 from public.matches m
    where m.id = match_id
      and now() < m.prediction_locks_at
      and predicted_winner_team_id in (m.home_team_id, m.away_team_id)
  )
);

drop policy if exists "users update unlocked match predictions" on public.match_predictions;
create policy "users update unlocked match predictions"
on public.match_predictions for update to authenticated
using (
  (select auth.uid()) = user_id
  and exists (select 1 from public.matches m where m.id = match_id and now() < m.prediction_locks_at)
)
with check (
  (select auth.uid()) = user_id
  and exists (
    select 1 from public.matches m
    where m.id = match_id
      and now() < m.prediction_locks_at
      and predicted_winner_team_id in (m.home_team_id, m.away_team_id)
  )
);

-- Weekly MVP predictions
drop policy if exists "users read own mvp predictions" on public.weekly_mvp_predictions;
create policy "users read own mvp predictions"
on public.weekly_mvp_predictions for select to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "users create unlocked mvp predictions" on public.weekly_mvp_predictions;
create policy "users create unlocked mvp predictions"
on public.weekly_mvp_predictions for insert to authenticated
with check (
  (select auth.uid()) = user_id
  and exists (select 1 from public.competition_weeks w where w.id = week_id and now() < w.mvp_locks_at)
);

drop policy if exists "users update unlocked mvp predictions" on public.weekly_mvp_predictions;
create policy "users update unlocked mvp predictions"
on public.weekly_mvp_predictions for update to authenticated
using (
  (select auth.uid()) = user_id
  and exists (select 1 from public.competition_weeks w where w.id = week_id and now() < w.mvp_locks_at)
)
with check (
  (select auth.uid()) = user_id
  and exists (select 1 from public.competition_weeks w where w.id = week_id and now() < w.mvp_locks_at)
);

-- Playoff brackets
drop policy if exists "users read own playoff brackets" on public.playoff_bracket_predictions;
create policy "users read own playoff brackets"
on public.playoff_bracket_predictions for select to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "users create unlocked playoff brackets" on public.playoff_bracket_predictions;
create policy "users create unlocked playoff brackets"
on public.playoff_bracket_predictions for insert to authenticated
with check ((select auth.uid()) = user_id and now() < locks_at);

drop policy if exists "users update unlocked playoff brackets" on public.playoff_bracket_predictions;
create policy "users update unlocked playoff brackets"
on public.playoff_bracket_predictions for update to authenticated
using ((select auth.uid()) = user_id and now() < locks_at)
with check ((select auth.uid()) = user_id and now() < locks_at);

-- Meta Lab predictions
drop policy if exists "users read own meta predictions" on public.meta_predictions;
create policy "users read own meta predictions"
on public.meta_predictions for select to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "users create unlocked meta predictions" on public.meta_predictions;
create policy "users create unlocked meta predictions"
on public.meta_predictions for insert to authenticated
with check (
  (select auth.uid()) = user_id
  and exists (select 1 from public.competition_weeks w where w.id = week_id and now() < w.meta_locks_at)
);

drop policy if exists "users update unlocked meta predictions" on public.meta_predictions;
create policy "users update unlocked meta predictions"
on public.meta_predictions for update to authenticated
using (
  (select auth.uid()) = user_id
  and exists (select 1 from public.competition_weeks w where w.id = week_id and now() < w.meta_locks_at)
)
with check (
  (select auth.uid()) = user_id
  and exists (select 1 from public.competition_weeks w where w.id = week_id and now() < w.meta_locks_at)
);

-- Users can read only their own score ledger. Administrators can read all.
drop policy if exists "users read own scores" on public.score_transactions;
create policy "users read own scores"
on public.score_transactions for select to authenticated
using ((select auth.uid()) = user_id or (select public.is_platform_admin()));

-- Grants; RLS remains authoritative.
grant select on public.seasons, public.competition_weeks, public.teams,
  public.players, public.season_rosters, public.matches, public.heroes,
  public.patches, public.official_weekly_mvps, public.scoring_rule_sets
  to anon, authenticated;

grant select, insert, update on public.match_predictions,
  public.weekly_mvp_predictions, public.playoff_bracket_predictions,
  public.meta_predictions to authenticated;

grant select on public.score_transactions to authenticated;
