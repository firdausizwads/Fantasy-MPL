-- Fantasy MPL — live admin overview and Weekly MVP management
-- Run after 024_pandascore_fixture_sync.sql

create or replace function public.admin_live_overview(target_region text)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare season_uuid uuid; week_uuid uuid; week_num integer;
begin
 if not public.is_platform_admin() then raise exception 'Not authorized'; end if;
 select id into season_uuid from public.seasons where region_code=target_region and season_number=18;
 if season_uuid is null then raise exception 'Season 18 not found'; end if;
 select id,week_number into week_uuid,week_num from public.competition_weeks where season_id=season_uuid
 order by case when now() between starts_at and ends_at then 0 when starts_at>now() then 1 else 2 end,
 case when starts_at>now() then starts_at end asc nulls last,case when starts_at<=now() then starts_at end desc nulls last limit 1;
 return jsonb_build_object(
  'region',target_region,'season_id',season_uuid,'week_id',week_uuid,'week_number',week_num,
  'registered_managers',(select count(*) from public.region_memberships where region_code=target_region),
  'new_managers_7d',(select count(*) from public.region_memberships where region_code=target_region and joined_at>=now()-interval '7 days'),
  'week_match_predictions',(select count(*) from public.match_predictions mp join public.matches m on m.id=mp.match_id where m.week_id=week_uuid),
  'week_prediction_managers',(select count(distinct mp.user_id) from public.match_predictions mp join public.matches m on m.id=mp.match_id where m.week_id=week_uuid),
  'week_mvp_predictions',(select count(*) from public.weekly_mvp_predictions where week_id=week_uuid),
  'week_lineups',(select count(*) from public.weekly_lineups where week_id=week_uuid and status in('submitted','locked','scored')),
  'scheduled_matches',(select count(*) from public.matches where week_id=week_uuid and status='scheduled'),
  'pending_results',(select count(*) from public.matches where season_id=season_uuid and status='completed' and result_state='unverified'),
  'verified_results',(select count(*) from public.matches where week_id=week_uuid and result_state in('verified','finalized','corrected')),
  'unresolved_team_mappings',(select count(*) from public.external_team_mappings where provider='pandascore' and region_code=target_region and team_id is null),
  'unapplied_staging',(select count(*) from public.fixture_import_staging where provider='pandascore' and region_code=target_region and mapping_status='ready' and applied_at is null),
  'score_transactions',(select count(*) from public.score_transactions where season_id=season_uuid),
  'last_scoring_at',(select max(created_at) from public.score_transactions where season_id=season_uuid),
  'last_sync',(select jsonb_build_object('status',status,'started_at',started_at,'fetched',fetched_count,'staged',staged_count,'unresolved',unresolved_count) from public.fixture_sync_runs where provider='pandascore' order by started_at desc limit 1),
  'official_mvp',(select jsonb_build_object('player_id',o.player_id,'handle',p.handle,'state',o.result_state,'source_url',o.source_url,'finalized_at',o.finalized_at) from public.official_weekly_mvps o join public.players p on p.id=o.player_id where o.week_id=week_uuid)
 );
end $$;

create or replace function public.admin_publish_weekly_mvp(target_week uuid,target_player uuid,target_source_url text)
returns void language plpgsql security definer set search_path='' as $$
declare season_uuid uuid;
begin
 if not public.is_platform_admin() then raise exception 'Not authorized'; end if;
 if target_source_url is null or target_source_url !~* '^https?://' then raise exception 'A valid official source URL is required'; end if;
 select season_id into season_uuid from public.competition_weeks where id=target_week;
 if season_uuid is null then raise exception 'Week not found'; end if;
 if not exists(select 1 from public.season_rosters where season_id=season_uuid and player_id=target_player and active=true and role<>'COACH') then raise exception 'Player is not active in this regional season'; end if;
 insert into public.official_weekly_mvps(week_id,player_id,source_url,result_state,finalized_at,finalized_by)
 values(target_week,target_player,trim(target_source_url),'verified',now(),(select auth.uid()))
 on conflict(week_id) do update set player_id=excluded.player_id,source_url=excluded.source_url,result_state='verified',finalized_at=now(),finalized_by=(select auth.uid());
end $$;

grant execute on function public.admin_live_overview(text) to authenticated;
grant execute on function public.admin_publish_weekly_mvp(uuid,uuid,text) to authenticated;

select
 to_regprocedure('public.admin_live_overview(text)') is not null as live_overview_ready,
 to_regprocedure('public.admin_publish_weekly_mvp(uuid,uuid,text)') is not null as live_mvp_ready;
