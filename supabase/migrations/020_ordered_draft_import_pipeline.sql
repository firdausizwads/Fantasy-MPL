-- Fantasy MPL — ordered professional draft import pipeline
-- Run after 019_draft_intelligence_foundation.sql

-- Rebuild aggregate metrics and pair evidence exclusively from verified,
-- ordered professional draft records.
create or replace function public.rebuild_draft_intelligence_metrics(
  target_source uuid,
  target_patch uuid,
  target_region text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  game_total integer;
  metric_total integer;
  relationship_total integer;
begin
  if session_user not in ('postgres','supabase_admin')
     and not public.is_platform_admin() then
    raise exception 'Not authorized';
  end if;
  if target_region not in ('MY','ID','PH') then raise exception 'Unsupported region'; end if;
  if not exists (
    select 1 from public.draft_data_sources s
    where s.id = target_source and s.approval_status = 'approved'
      and s.commercial_use_confirmed = true
  ) then raise exception 'Source is not approved for use'; end if;

  select count(*) into game_total
  from public.pro_draft_games g
  where g.source_id = target_source and g.patch_id = target_patch
    and g.region_code = target_region and g.verified = true;

  delete from public.hero_draft_relationships
  where source_id = target_source and patch_id = target_patch and region_code = target_region;
  delete from public.hero_patch_metrics
  where source_id = target_source and patch_id = target_patch and region_code = target_region;

  if game_total = 0 then
    return jsonb_build_object('games',0,'hero_metrics',0,'relationships',0);
  end if;

  insert into public.hero_patch_metrics (
    source_id, patch_id, region_code, hero_id,
    games, picks, bans, wins, imported_by, verified_at
  )
  select
    target_source, target_patch, target_region, a.hero_id,
    game_total,
    count(*) filter (where a.action_type = 'PICK')::integer,
    count(*) filter (where a.action_type = 'BAN')::integer,
    count(*) filter (where a.action_type = 'PICK' and a.side = g.winner_side)::integer,
    (select auth.uid()), now()
  from public.pro_draft_actions a
  join public.pro_draft_games g on g.id = a.game_id
  where g.source_id = target_source and g.patch_id = target_patch
    and g.region_code = target_region and g.verified = true
  group by a.hero_id;
  get diagnostics metric_total = row_count;

  -- Directed ally-pair evidence. The impact is centered around a neutral
  -- 50% pair win rate and bounded by the table constraint.
  insert into public.hero_draft_relationships (
    source_id, patch_id, region_code, hero_id, related_hero_id,
    relationship_type, sample_size, impact_score, imported_by, verified_at
  )
  select
    target_source, target_patch, target_region,
    a.hero_id, ally.hero_id, 'SYNERGY', count(*)::integer,
    greatest(-1::numeric, least(1::numeric,
      ((count(*) filter (where a.side = g.winner_side)::numeric / count(*)::numeric) - 0.5) * 2
    )),
    (select auth.uid()), now()
  from public.pro_draft_actions a
  join public.pro_draft_actions ally
    on ally.game_id = a.game_id and ally.side = a.side
    and ally.action_type = 'PICK' and ally.hero_id <> a.hero_id
  join public.pro_draft_games g on g.id = a.game_id
  where a.action_type = 'PICK' and g.verified = true
    and g.source_id = target_source and g.patch_id = target_patch
    and g.region_code = target_region
  group by a.hero_id, ally.hero_id
  having count(*) >= 3;

  -- Directed enemy matchup evidence. A positive score means the candidate's
  -- side won more often than a neutral baseline when facing the related hero.
  insert into public.hero_draft_relationships (
    source_id, patch_id, region_code, hero_id, related_hero_id,
    relationship_type, sample_size, impact_score, imported_by, verified_at
  )
  select
    target_source, target_patch, target_region,
    a.hero_id, enemy.hero_id, 'COUNTER', count(*)::integer,
    greatest(-1::numeric, least(1::numeric,
      ((count(*) filter (where a.side = g.winner_side)::numeric / count(*)::numeric) - 0.5) * 2
    )),
    (select auth.uid()), now()
  from public.pro_draft_actions a
  join public.pro_draft_actions enemy
    on enemy.game_id = a.game_id and enemy.side <> a.side
    and enemy.action_type = 'PICK'
  join public.pro_draft_games g on g.id = a.game_id
  where a.action_type = 'PICK' and g.verified = true
    and g.source_id = target_source and g.patch_id = target_patch
    and g.region_code = target_region
  group by a.hero_id, enemy.hero_id
  having count(*) >= 3;

  select count(*) into relationship_total
  from public.hero_draft_relationships
  where source_id = target_source and patch_id = target_patch and region_code = target_region;

  return jsonb_build_object(
    'games', game_total,
    'hero_metrics', metric_total,
    'relationships', relationship_total,
    'region', target_region,
    'patch_id', target_patch,
    'source_id', target_source
  );
end;
$$;

create or replace function public.admin_import_pro_draft_game(
  target_source uuid,
  target_patch uuid,
  target_region text,
  target_source_match_key text,
  target_game_number integer,
  target_played_at timestamptz,
  target_blue_team_code text,
  target_red_team_code text,
  target_winner_side text,
  target_source_url text,
  target_actions jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  blue_team uuid;
  red_team uuid;
  imported_game uuid;
  item jsonb;
  expected record;
  hero_uuid uuid;
  action_count integer := 0;
  rebuild_result jsonb;
begin
  if not public.is_platform_admin() then raise exception 'Not authorized'; end if;
  if target_region not in ('MY','ID','PH') then raise exception 'Unsupported region'; end if;
  if target_game_number < 1 or target_game_number > 20 then raise exception 'Invalid game number'; end if;
  if target_winner_side not in ('BLUE','RED') then raise exception 'Winner side must be BLUE or RED'; end if;
  if nullif(trim(target_source_match_key),'') is null then raise exception 'Source match key is required'; end if;
  if target_played_at is null then raise exception 'Played-at timestamp is required'; end if;
  if target_played_at > now() then raise exception 'A verified professional draft cannot be dated in the future'; end if;
  if target_source_url is null or target_source_url !~* '^https?://' then raise exception 'A valid source game URL is required'; end if;
  if jsonb_typeof(target_actions) <> 'array' or jsonb_array_length(target_actions) <> 20 then
    raise exception 'A complete tournament draft must contain exactly 20 ordered actions';
  end if;
  if not exists (
    select 1 from public.draft_data_sources s
    where s.id = target_source and s.approval_status = 'approved'
      and s.commercial_use_confirmed = true
  ) then raise exception 'Source is not approved for use'; end if;
  if not exists (select 1 from public.patches p where p.id = target_patch) then raise exception 'Patch not found'; end if;

  select id into blue_team from public.teams
  where region_code = target_region and upper(code) = upper(trim(target_blue_team_code)) and active = true;
  select id into red_team from public.teams
  where region_code = target_region and upper(code) = upper(trim(target_red_team_code)) and active = true;
  if blue_team is null then raise exception 'Unknown active blue team code: %', target_blue_team_code; end if;
  if red_team is null then raise exception 'Unknown active red team code: %', target_red_team_code; end if;
  if blue_team = red_team then raise exception 'Blue and red teams must be different'; end if;

  insert into public.pro_draft_games (
    source_id, source_match_key, region_code, patch_id,
    blue_team_id, red_team_id, game_number, played_at,
    winner_side, first_pick_side, verified, verified_at, verified_by, source_url
  ) values (
    target_source, trim(target_source_match_key), target_region, target_patch,
    blue_team, red_team, target_game_number, target_played_at,
    target_winner_side, 'BLUE', true, now(), (select auth.uid()), nullif(trim(target_source_url),'')
  )
  on conflict (source_id, source_match_key, game_number) do update set
    region_code = excluded.region_code, patch_id = excluded.patch_id,
    blue_team_id = excluded.blue_team_id, red_team_id = excluded.red_team_id,
    played_at = excluded.played_at, winner_side = excluded.winner_side,
    verified = true, verified_at = now(), verified_by = (select auth.uid()),
    source_url = excluded.source_url, updated_at = now()
  returning id into imported_game;

  delete from public.pro_draft_actions where game_id = imported_game;

  for expected in
    select * from (values
      (1,'BLUE','BAN',1),(2,'RED','BAN',1),(3,'BLUE','BAN',1),(4,'RED','BAN',1),(5,'BLUE','BAN',1),(6,'RED','BAN',1),
      (7,'BLUE','PICK',1),(8,'RED','PICK',1),(9,'RED','PICK',1),(10,'BLUE','PICK',1),(11,'BLUE','PICK',1),(12,'RED','PICK',1),
      (13,'RED','BAN',2),(14,'BLUE','BAN',2),(15,'RED','BAN',2),(16,'BLUE','BAN',2),
      (17,'RED','PICK',2),(18,'BLUE','PICK',2),(19,'BLUE','PICK',2),(20,'RED','PICK',2)
    ) as sequence(sequence_number, side, action_type, phase)
    order by sequence_number
  loop
    item := target_actions -> (expected.sequence_number - 1);
    if (item->>'sequence')::integer <> expected.sequence_number
       or upper(item->>'side') <> expected.side
       or upper(item->>'type') <> expected.action_type
       or (item->>'phase')::integer <> expected.phase then
      raise exception 'Draft sequence mismatch at action %: expected % % phase %',
        expected.sequence_number, expected.side, expected.action_type, expected.phase;
    end if;

    select id into hero_uuid from public.heroes
    where upper(name::text) = upper(trim(item->>'hero')) and active = true;
    if hero_uuid is null then raise exception 'Unknown active hero at action %: %', expected.sequence_number, item->>'hero'; end if;
    if exists (select 1 from public.pro_draft_actions where game_id = imported_game and hero_id = hero_uuid) then
      raise exception 'Hero appears more than once in the draft: %', item->>'hero';
    end if;

    insert into public.pro_draft_actions (
      game_id, sequence_number, phase, action_type, side, hero_id, team_id
    ) values (
      imported_game, expected.sequence_number, expected.phase, expected.action_type,
      expected.side, hero_uuid, case when expected.side = 'BLUE' then blue_team else red_team end
    );
    action_count := action_count + 1;
  end loop;

  rebuild_result := public.rebuild_draft_intelligence_metrics(target_source,target_patch,target_region);
  return jsonb_build_object(
    'game_id', imported_game,
    'actions_imported', action_count,
    'verified', true,
    'metrics', rebuild_result
  );
end;
$$;

-- Expand the existing admin configuration payload with verified team codes.
create or replace function public.admin_draft_intelligence_config()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_platform_admin() then raise exception 'Not authorized'; end if;
  return jsonb_build_object(
    'sources', coalesce((select jsonb_agg(to_jsonb(s) order by s.created_at desc) from public.draft_data_sources s), '[]'::jsonb),
    'patches', coalesce((select jsonb_agg(to_jsonb(p) order by p.released_at desc nulls last, p.created_at desc) from public.patches p), '[]'::jsonb),
    'models', coalesce((select jsonb_agg(to_jsonb(m) order by m.created_at desc) from public.draft_model_versions m), '[]'::jsonb),
    'teams', coalesce((select jsonb_agg(jsonb_build_object('id',t.id,'code',t.code,'name',t.name,'region_code',t.region_code) order by t.region_code,t.name) from public.teams t where t.active = true), '[]'::jsonb),
    'metrics_by_region', coalesce((
      select jsonb_agg(to_jsonb(x)) from (
        select region_code, count(*) as heroes, max(games) as games, max(verified_at) as last_verified
        from public.hero_patch_metrics group by region_code order by region_code
      ) x
    ), '[]'::jsonb),
    'verified_games', (select count(*) from public.pro_draft_games where verified = true),
    'ordered_actions', (select count(*) from public.pro_draft_actions)
  );
end;
$$;

revoke all on function public.rebuild_draft_intelligence_metrics(uuid,uuid,text) from public, anon;
revoke all on function public.admin_import_pro_draft_game(uuid,uuid,text,text,integer,timestamptz,text,text,text,text,jsonb) from public, anon;
grant execute on function public.rebuild_draft_intelligence_metrics(uuid,uuid,text) to authenticated;
grant execute on function public.admin_import_pro_draft_game(uuid,uuid,text,text,integer,timestamptz,text,text,text,text,jsonb) to authenticated;

select
  to_regprocedure('public.admin_import_pro_draft_game(uuid,uuid,text,text,integer,timestamptz,text,text,text,text,jsonb)') is not null as ordered_import_ready,
  to_regprocedure('public.rebuild_draft_intelligence_metrics(uuid,uuid,text)') is not null as metric_rebuild_ready;
