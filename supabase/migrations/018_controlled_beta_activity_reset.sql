-- Fantasy MPL — controlled closed-beta activity reset
-- Run after 017_prediction_windows.sql
--
-- This migration creates guarded preview/reset functions. Running this file
-- does NOT delete data. The destructive reset requires a separate call with
-- the exact confirmation phrase documented at the bottom of this file.

create table if not exists public.beta_reset_audit (
  id uuid primary key default gen_random_uuid(),
  executed_at timestamptz not null default now(),
  executed_by uuid,
  database_session text not null,
  confirmation_phrase text not null,
  before_counts jsonb not null,
  after_counts jsonb not null
);

alter table public.beta_reset_audit enable row level security;

drop policy if exists "platform admins read beta reset audit" on public.beta_reset_audit;
create policy "platform admins read beta reset audit"
on public.beta_reset_audit for select
to authenticated
using ((select public.is_platform_admin()));

create or replace function public.beta_activity_counts()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'match_predictions', (select count(*) from public.match_predictions),
    'weekly_mvp_predictions', (select count(*) from public.weekly_mvp_predictions),
    'meta_predictions', (select count(*) from public.meta_predictions),
    'playoff_bracket_predictions', (select count(*) from public.playoff_bracket_predictions),
    'score_transactions', (select count(*) from public.score_transactions),
    'fantasy_leagues', (select count(*) from public.fantasy_leagues),
    'league_members', (select count(*) from public.league_members),
    'drafts', (select count(*) from public.drafts),
    'draft_picks', (select count(*) from public.draft_picks),
    'player_ownership', (select count(*) from public.player_ownership),
    'weekly_lineups', (select count(*) from public.weekly_lineups),
    'lineup_players', (select count(*) from public.lineup_players),
    'roster_transactions', (select count(*) from public.roster_transactions),
    'h2h_matchups', (select count(*) from public.h2h_matchups),
    'h2h_bans', (select count(*) from public.h2h_bans),
    'survivor_eliminations', (select count(*) from public.survivor_eliminations),
    'league_chat_messages', (select count(*) from public.league_chat_messages),
    'league_chat_reactions', (select count(*) from public.league_chat_reactions),
    'league_moderation', (select count(*) from public.league_moderation)
  );
$$;

create or replace function public.preview_beta_activity_reset()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if session_user not in ('postgres', 'supabase_admin')
     and not public.is_platform_admin() then
    raise exception 'Platform administrator required';
  end if;

  return jsonb_build_object(
    'mode', 'PREVIEW_ONLY',
    'will_preserve', jsonb_build_array(
      'auth users', 'profiles', 'private profiles', 'avatars',
      'regional memberships', 'regions', 'seasons', 'weeks',
      'teams', 'players', 'season rosters', 'fixtures',
      'fixture results', 'heroes', 'patches', 'player prices',
      'scoring rules', 'official weekly MVP records'
    ),
    'will_delete_counts', public.beta_activity_counts(),
    'required_confirmation', 'RESET FANTASY MPL BETA ACTIVITY'
  );
end;
$$;

create or replace function public.run_beta_activity_reset(confirmation text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  required_phrase constant text := 'RESET FANTASY MPL BETA ACTIVITY';
  before_snapshot jsonb;
  after_snapshot jsonb;
  audit_id uuid;
begin
  if session_user not in ('postgres', 'supabase_admin')
     and not public.is_platform_admin() then
    raise exception 'Platform administrator required';
  end if;

  if confirmation is distinct from required_phrase then
    raise exception 'Confirmation phrase does not match. No data was deleted.';
  end if;

  -- Prevent two reset sessions from running concurrently.
  perform pg_advisory_xact_lock(hashtext('fantasy_mpl_beta_activity_reset'));

  before_snapshot := public.beta_activity_counts();

  -- Independent prediction and scoring activity.
  delete from public.match_predictions;
  delete from public.weekly_mvp_predictions;
  delete from public.meta_predictions;
  delete from public.playoff_bracket_predictions;
  delete from public.score_transactions;

  -- Deleting league roots cascades through members, drafts, draft picks,
  -- ownership, weekly lineups and players, transactions, H2H, survivor,
  -- chat, reactions and moderation. Shared fantasy configuration remains.
  delete from public.fantasy_leagues;

  after_snapshot := public.beta_activity_counts();

  insert into public.beta_reset_audit (
    executed_by,
    database_session,
    confirmation_phrase,
    before_counts,
    after_counts
  ) values (
    (select auth.uid()),
    session_user,
    required_phrase,
    before_snapshot,
    after_snapshot
  ) returning id into audit_id;

  return jsonb_build_object(
    'reset_complete', true,
    'audit_id', audit_id,
    'executed_at', now(),
    'before', before_snapshot,
    'after', after_snapshot,
    'preserved_accounts', (select count(*) from auth.users),
    'preserved_profiles', (select count(*) from public.profiles),
    'preserved_fixtures', (select count(*) from public.matches),
    'preserved_players', (select count(*) from public.players)
  );
end;
$$;

revoke all on function public.beta_activity_counts() from public, anon, authenticated;
revoke all on function public.preview_beta_activity_reset() from public, anon, authenticated;
revoke all on function public.run_beta_activity_reset(text) from public, anon, authenticated;

-- SQL Editor usage after running this migration:
--
-- 1. Preview only (safe; deletes nothing):
--    select public.preview_beta_activity_reset();
--
-- 2. Execute only after reviewing the preview:
--    select public.run_beta_activity_reset('RESET FANTASY MPL BETA ACTIVITY');
--
-- 3. Confirm the latest audit entry:
--    select id, executed_at, before_counts, after_counts
--    from public.beta_reset_audit
--    order by executed_at desc
--    limit 1;

select
  to_regprocedure('public.preview_beta_activity_reset()') is not null as preview_ready,
  to_regprocedure('public.run_beta_activity_reset(text)') is not null as reset_ready;
