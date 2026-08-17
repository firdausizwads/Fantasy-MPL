-- Fantasy MPL — CDN model bundle for regional traffic lanes
-- Run after 020_ordered_draft_import_pipeline.sql

create or replace function public.draft_model_bundle(target_region text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  source_row public.draft_data_sources;
  model_row public.draft_model_versions;
  patch_version text;
  metrics_json jsonb := '[]'::jsonb;
  relationships_json jsonb := '[]'::jsonb;
  eligible integer := 0;
  games integer := 0;
  newest timestamptz;
begin
  if target_region not in ('MY','ID','PH') then raise exception 'Unsupported region'; end if;

  select * into source_row from public.draft_data_sources
  where primary_for_model = true and approval_status = 'approved'
    and commercial_use_confirmed = true limit 1;
  select * into model_row from public.draft_model_versions where active = true limit 1;

  if source_row.id is null or model_row.id is null or model_row.patch_id is null then
    return jsonb_build_object(
      'status', public.draft_intelligence_status(target_region),
      'weights', '{}'::jsonb,
      'metrics', '[]'::jsonb,
      'relationships', '[]'::jsonb,
      'generated_at', now()
    );
  end if;

  select version into patch_version from public.patches where id = model_row.patch_id;

  select count(*), coalesce(max(hpm.games),0), max(hpm.verified_at)
    into eligible, games, newest
  from public.hero_patch_metrics hpm
  where hpm.source_id = source_row.id and hpm.patch_id = model_row.patch_id
    and hpm.region_code = target_region and hpm.games >= model_row.minimum_sample;

  if eligible > 0 then
    select coalesce(jsonb_agg(jsonb_build_object(
      'hero', h.name::text,
      'games', hpm.games,
      'picks', hpm.picks,
      'bans', hpm.bans,
      'pick_rate', hpm.pick_rate,
      'ban_rate', hpm.ban_rate,
      'win_rate', hpm.win_rate,
      'contest_rate', hpm.contest_rate,
      'roles', h.standard_roles
    ) order by h.name::text), '[]'::jsonb)
    into metrics_json
    from public.hero_patch_metrics hpm
    join public.heroes h on h.id = hpm.hero_id
    where hpm.source_id = source_row.id and hpm.patch_id = model_row.patch_id
      and hpm.region_code = target_region and hpm.games >= model_row.minimum_sample;

    select coalesce(jsonb_agg(jsonb_build_object(
      'hero', h.name::text,
      'related_hero', rh.name::text,
      'type', rel.relationship_type,
      'sample_size', rel.sample_size,
      'impact_score', rel.impact_score
    ) order by h.name::text, rh.name::text), '[]'::jsonb)
    into relationships_json
    from public.hero_draft_relationships rel
    join public.heroes h on h.id = rel.hero_id
    join public.heroes rh on rh.id = rel.related_hero_id
    where rel.source_id = source_row.id and rel.patch_id = model_row.patch_id
      and rel.region_code = target_region and rel.sample_size >= 3;
  end if;

  return jsonb_build_object(
    'status', jsonb_build_object(
      'ready', eligible > 0,
      'region', target_region,
      'source_name', source_row.name,
      'source_url', source_row.provider_url,
      'attribution', source_row.attribution_text,
      'license', source_row.license_name,
      'model_name', model_row.name,
      'model_version', model_row.version,
      'patch', patch_version,
      'minimum_sample', model_row.minimum_sample,
      'eligible_heroes', eligible,
      'drafts_analyzed', games,
      'last_verified', newest,
      'blocker', case when eligible = 0 then 'CURRENT-PATCH REGIONAL SAMPLE REQUIRED' else null end
    ),
    'weights', model_row.weights,
    'metrics', metrics_json,
    'relationships', relationships_json,
    'generated_at', now()
  );
end;
$$;

revoke all on function public.draft_model_bundle(text) from public;
grant execute on function public.draft_model_bundle(text) to anon, authenticated;

select to_regprocedure('public.draft_model_bundle(text)') is not null as model_bundle_ready;
