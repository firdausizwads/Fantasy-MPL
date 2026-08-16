-- Fantasy MPL — Self-service data export and account deletion
-- Run after 014_realtime_league_lobby.sql

create or replace function public.export_my_data()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  current_user_id uuid := (select auth.uid());
  result jsonb;
begin
  if current_user_id is null then
    raise exception 'Authentication required';
  end if;

  select jsonb_build_object(
    'exported_at', now(),
    'account', (
      select jsonb_build_object('id', u.id, 'email', u.email, 'created_at', u.created_at)
      from auth.users u where u.id = current_user_id
    ),
    'public_profile', (
      select to_jsonb(p) from public.profiles p where p.id = current_user_id
    ),
    'private_profile', (
      select to_jsonb(p) from public.profile_private p where p.user_id = current_user_id
    ),
    'regional_memberships', coalesce((
      select jsonb_agg(to_jsonb(x)) from (
        select region_code, joined_at from public.region_memberships
        where user_id = current_user_id order by joined_at
      ) x
    ), '[]'::jsonb),
    'match_predictions', coalesce((
      select jsonb_agg(to_jsonb(x)) from (
        select match_id, predicted_winner_team_id, predicted_home_score,
               predicted_away_score, submitted_at, updated_at
        from public.match_predictions where user_id = current_user_id
        order by submitted_at
      ) x
    ), '[]'::jsonb),
    'weekly_mvp_predictions', coalesce((
      select jsonb_agg(to_jsonb(x)) from (
        select week_id, player_id, submitted_at, updated_at
        from public.weekly_mvp_predictions where user_id = current_user_id
        order by submitted_at
      ) x
    ), '[]'::jsonb),
    'playoff_brackets', coalesce((
      select jsonb_agg(to_jsonb(x)) from (
        select season_id, bracket_version, picks, predicted_champion_team_id,
               locks_at, submitted_at, updated_at
        from public.playoff_bracket_predictions where user_id = current_user_id
        order by updated_at
      ) x
    ), '[]'::jsonb),
    'meta_predictions', coalesce((
      select jsonb_agg(to_jsonb(x)) from (
        select * from public.meta_predictions where user_id = current_user_id
        order by updated_at
      ) x
    ), '[]'::jsonb),
    'league_memberships', coalesce((
      select jsonb_agg(to_jsonb(x)) from (
        select league_id, member_role, status, draft_position,
               waiver_priority, joined_at, eliminated_at
        from public.league_members where user_id = current_user_id
        order by joined_at
      ) x
    ), '[]'::jsonb),
    'draft_picks', coalesce((
      select jsonb_agg(to_jsonb(x)) from (
        select draft_id, league_id, player_id, pick_number, round_number,
               auto_picked, picked_at
        from public.draft_picks where user_id = current_user_id
        order by picked_at
      ) x
    ), '[]'::jsonb),
    'player_ownership', coalesce((
      select jsonb_agg(to_jsonb(x)) from (
        select league_id, player_id, acquired_via, acquired_at, released_at
        from public.player_ownership where user_id = current_user_id
        order by acquired_at
      ) x
    ), '[]'::jsonb),
    'weekly_lineups', coalesce((
      select jsonb_agg(
        to_jsonb(wl) || jsonb_build_object(
          'players', coalesce((
            select jsonb_agg(to_jsonb(lp))
            from public.lineup_players lp where lp.lineup_id = wl.id
          ), '[]'::jsonb)
        )
      )
      from public.weekly_lineups wl where wl.user_id = current_user_id
    ), '[]'::jsonb),
    'score_transactions', coalesce((
      select jsonb_agg(to_jsonb(x)) from (
        select season_id, region_code, week_id, league_id, category,
               points, reason_code, description, created_at
        from public.score_transactions where user_id = current_user_id
        order by created_at
      ) x
    ), '[]'::jsonb),
    'roster_transactions', coalesce((
      select jsonb_agg(to_jsonb(x)) from (
        select league_id, week_id, player_id, related_player_id,
               action, metadata, created_at
        from public.roster_transactions where user_id = current_user_id
        order by created_at
      ) x
    ), '[]'::jsonb),
    'chat_messages', coalesce((
      select jsonb_agg(to_jsonb(x)) from (
        select league_id, message, message_type, created_at, removed_at
        from public.league_chat_messages where user_id = current_user_id
        order by created_at
      ) x
    ), '[]'::jsonb)
  ) into result;

  return result;
end;
$$;

create or replace function public.delete_my_account(confirmation_name text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_user_id uuid := (select auth.uid());
  current_manager_name text;
  managed_league record;
  successor_id uuid;
begin
  if current_user_id is null then
    raise exception 'Authentication required';
  end if;

  select manager_name into current_manager_name
  from public.profiles where id = current_user_id;

  if current_manager_name is null then
    raise exception 'Profile not found';
  end if;

  if lower(trim(confirmation_name)) <> lower(trim(current_manager_name)) then
    raise exception 'Manager name confirmation does not match';
  end if;

  -- Preserve multiplayer leagues by transferring commissioner ownership to
  -- the oldest active manager. Empty leagues are deleted.
  for managed_league in
    select id from public.fantasy_leagues
    where commissioner_id = current_user_id
    for update
  loop
    select user_id into successor_id
    from public.league_members
    where league_id = managed_league.id
      and user_id <> current_user_id
      and status = 'active'
    order by joined_at
    limit 1;

    if successor_id is null then
      delete from public.fantasy_leagues where id = managed_league.id;
    else
      update public.fantasy_leagues
      set commissioner_id = successor_id,
          creator_profile_id = case
            when creator_profile_id = current_user_id then null
            else creator_profile_id
          end
      where id = managed_league.id;

      update public.league_members
      set member_role = 'manager'
      where league_id = managed_league.id
        and user_id = current_user_id;

      update public.league_members
      set member_role = 'commissioner'
      where league_id = managed_league.id
        and user_id = successor_id;
    end if;

    successor_id := null;
  end loop;

  -- Remove or anonymize administrative references that intentionally do not
  -- cascade with the user's account.
  update public.official_weekly_mvps set finalized_by = null
    where finalized_by = current_user_id;
  update public.scoring_rule_sets set created_by = null
    where created_by = current_user_id;
  update public.h2h_matchups set winner_user_id = null
    where winner_user_id = current_user_id;
  update public.player_match_stats set entered_by = null
    where entered_by = current_user_id;
  delete from public.league_moderation
    where actioned_by = current_user_id;

  -- Remove public avatar objects before deleting the Auth user.
  delete from storage.objects
  where bucket_id = 'avatars'
    and (storage.foldername(name))[1] = current_user_id::text;

  -- Foreign-key cascades remove profiles, memberships, predictions, lineups,
  -- picks, ownership, chat messages and score records belonging to this user.
  delete from auth.users where id = current_user_id;
end;
$$;

revoke all on function public.export_my_data() from public;
revoke all on function public.delete_my_account(text) from public;
grant execute on function public.export_my_data() to authenticated;
grant execute on function public.delete_my_account(text) to authenticated;

select
  to_regprocedure('public.export_my_data()') is not null as export_ready,
  to_regprocedure('public.delete_my_account(text)') is not null as deletion_ready;
