-- Fantasy MPL — PandaScore fixture synchronization and review queue
-- Run after 023_atomic_profile_updates.sql

alter table public.matches add column if not exists external_provider text;
alter table public.matches add column if not exists external_match_id bigint;
create unique index if not exists matches_external_provider_id_unique
  on public.matches(external_provider,external_match_id)
  where external_provider is not null and external_match_id is not null;

create table if not exists public.integration_secret_hashes(
  integration text primary key,
  secret_hash text not null,
  configured_at timestamptz not null default now(),
  configured_by uuid references auth.users(id) on delete set null
);

create table if not exists public.external_team_mappings(
  provider text not null,
  external_team_id bigint not null,
  region_code text not null references public.regions(code),
  external_name text not null,
  external_acronym text,
  team_id uuid references public.teams(id) on delete set null,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id) on delete set null,
  primary key(provider,external_team_id)
);

create table if not exists public.fixture_sync_runs(
  id uuid primary key default gen_random_uuid(),
  provider text not null,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  fetched_count integer not null default 0,
  staged_count integer not null default 0,
  unresolved_count integer not null default 0,
  status text not null default 'running' check(status in('running','completed','failed')),
  error_message text,
  triggered_by uuid references auth.users(id) on delete set null
);

create table if not exists public.fixture_import_staging(
  provider text not null,
  external_match_id bigint not null,
  league_id bigint not null,
  region_code text not null references public.regions(code),
  serie_id bigint not null,
  serie_name text not null,
  season_number integer not null,
  season_year integer not null,
  serie_begin_at timestamptz not null,
  tournament_id bigint,
  tournament_name text,
  week_number integer not null,
  scheduled_at timestamptz,
  end_at timestamptz,
  provider_status text not null,
  best_of integer not null,
  external_team_a_id bigint not null,
  external_team_a_name text not null,
  external_team_b_id bigint not null,
  external_team_b_name text not null,
  team_a_score integer,
  team_b_score integer,
  winner_external_team_id bigint,
  mapping_status text not null default 'unresolved' check(mapping_status in('unresolved','ready','conflict')),
  applied_at timestamptz,
  raw_payload jsonb not null,
  first_seen_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key(provider,external_match_id)
);

alter table public.integration_secret_hashes enable row level security;
alter table public.external_team_mappings enable row level security;
alter table public.fixture_sync_runs enable row level security;
alter table public.fixture_import_staging enable row level security;

do $$ declare table_name text; begin
 for table_name in select unnest(array['integration_secret_hashes','external_team_mappings','fixture_sync_runs','fixture_import_staging']) loop
  execute format('drop policy if exists "admins manage %s" on public.%I',table_name,table_name);
  execute format('create policy "admins manage %s" on public.%I for all to authenticated using ((select public.is_platform_admin())) with check ((select public.is_platform_admin()))',table_name,table_name);
 end loop;
end $$;

grant select,insert,update,delete on public.external_team_mappings,public.fixture_sync_runs,public.fixture_import_staging to authenticated;

create or replace function public.configure_pandascore_sync_secret(raw_secret text)
returns void language plpgsql security definer set search_path='' as $$
begin
 if not public.is_platform_admin() then raise exception 'Not authorized'; end if;
 if char_length(coalesce(raw_secret,''))<32 then raise exception 'Sync secret is too short'; end if;
 insert into public.integration_secret_hashes(integration,secret_hash,configured_at,configured_by)
 values('pandascore',encode(extensions.digest(raw_secret,'sha256'),'hex'),now(),(select auth.uid()))
 on conflict(integration) do update set secret_hash=excluded.secret_hash,configured_at=now(),configured_by=(select auth.uid());
end $$;

create or replace function public.ingest_pandascore_fixture_batch(raw_secret text,matches jsonb)
returns jsonb language plpgsql security definer set search_path='' as $$
declare expected_hash text; item jsonb; run_id uuid; staged integer:=0; unresolved integer:=0; target_region text; calculated_week integer;
begin
 select secret_hash into expected_hash from public.integration_secret_hashes where integration='pandascore';
 if expected_hash is null or encode(extensions.digest(coalesce(raw_secret,''),'sha256'),'hex')<>expected_hash then raise exception 'Invalid integration secret'; end if;
 if jsonb_typeof(matches)<>'array' then raise exception 'Matches payload must be an array'; end if;
 insert into public.fixture_sync_runs(provider,fetched_count,status) values('pandascore',jsonb_array_length(matches),'running') returning id into run_id;
 for item in select value from jsonb_array_elements(matches) loop
  target_region:=case (item->>'league_id')::bigint when 5294 then 'MY' when 5276 then 'ID' when 5279 then 'PH' else null end;
  if target_region is null or (item->>'season_number')::integer<>18 or (item->>'season_year')::integer<>2026 then continue; end if;
  calculated_week:=greatest(1,floor(extract(epoch from ((item->>'scheduled_at')::timestamptz-(item->>'serie_begin_at')::timestamptz))/604800)::integer+1);
  insert into public.external_team_mappings(provider,external_team_id,region_code,external_name,external_acronym)
  values('pandascore',(item->>'team_a_id')::bigint,target_region,item->>'team_a_name',nullif(item->>'team_a_acronym',''))
  on conflict(provider,external_team_id) do update set external_name=excluded.external_name,external_acronym=excluded.external_acronym,updated_at=now();
  insert into public.external_team_mappings(provider,external_team_id,region_code,external_name,external_acronym)
  values('pandascore',(item->>'team_b_id')::bigint,target_region,item->>'team_b_name',nullif(item->>'team_b_acronym',''))
  on conflict(provider,external_team_id) do update set external_name=excluded.external_name,external_acronym=excluded.external_acronym,updated_at=now();
  update public.external_team_mappings m set team_id=t.id,updated_at=now()
  from public.teams t where m.provider='pandascore' and m.team_id is null and m.region_code=t.region_code and t.active=true
    and upper(t.code)=upper(coalesce(m.external_acronym,''));
  insert into public.fixture_import_staging(provider,external_match_id,league_id,region_code,serie_id,serie_name,season_number,season_year,serie_begin_at,tournament_id,tournament_name,week_number,scheduled_at,end_at,provider_status,best_of,external_team_a_id,external_team_a_name,external_team_b_id,external_team_b_name,team_a_score,team_b_score,winner_external_team_id,mapping_status,raw_payload,updated_at)
  values('pandascore',(item->>'match_id')::bigint,(item->>'league_id')::bigint,target_region,(item->>'serie_id')::bigint,item->>'serie_name',18,2026,(item->>'serie_begin_at')::timestamptz,nullif(item->>'tournament_id','')::bigint,item->>'tournament_name',calculated_week,nullif(item->>'scheduled_at','')::timestamptz,nullif(item->>'end_at','')::timestamptz,item->>'status',(item->>'best_of')::integer,(item->>'team_a_id')::bigint,item->>'team_a_name',(item->>'team_b_id')::bigint,item->>'team_b_name',nullif(item->>'team_a_score','')::integer,nullif(item->>'team_b_score','')::integer,nullif(item->>'winner_team_id','')::bigint,'unresolved',item,now())
  on conflict(provider,external_match_id) do update set scheduled_at=excluded.scheduled_at,end_at=excluded.end_at,provider_status=excluded.provider_status,best_of=excluded.best_of,team_a_score=excluded.team_a_score,team_b_score=excluded.team_b_score,winner_external_team_id=excluded.winner_external_team_id,week_number=excluded.week_number,raw_payload=excluded.raw_payload,updated_at=now();
  update public.fixture_import_staging s set mapping_status=case when a.team_id is not null and b.team_id is not null and a.team_id<>b.team_id then 'ready' else 'unresolved' end
  from public.external_team_mappings a,public.external_team_mappings b
  where s.provider='pandascore' and s.external_match_id=(item->>'match_id')::bigint and a.provider=s.provider and a.external_team_id=s.external_team_a_id and b.provider=s.provider and b.external_team_id=s.external_team_b_id;
  staged:=staged+1;
 end loop;
 select count(*) into unresolved from public.fixture_import_staging where provider='pandascore' and mapping_status<>'ready';
 update public.fixture_sync_runs set completed_at=now(),staged_count=staged,unresolved_count=unresolved,status='completed' where id=run_id;
 return jsonb_build_object('run_id',run_id,'staged',staged,'unresolved',unresolved);
exception when others then
 if run_id is not null then update public.fixture_sync_runs set completed_at=now(),status='failed',error_message=sqlerrm where id=run_id; end if;
 raise;
end $$;

create or replace function public.admin_map_pandascore_team(external_id bigint,target_team uuid)
returns void language plpgsql security definer set search_path='' as $$
declare mapping_region text; team_region text;
begin
 if not public.is_platform_admin() then raise exception 'Not authorized'; end if;
 select region_code into mapping_region from public.external_team_mappings where provider='pandascore' and external_team_id=external_id;
 select region_code into team_region from public.teams where id=target_team and active=true;
 if mapping_region is null or team_region is null or mapping_region<>team_region then raise exception 'Team mapping region mismatch'; end if;
 update public.external_team_mappings set team_id=target_team,updated_at=now(),updated_by=(select auth.uid()) where provider='pandascore' and external_team_id=external_id;
 update public.fixture_import_staging s set mapping_status=case when a.team_id is not null and b.team_id is not null and a.team_id<>b.team_id then 'ready' else 'unresolved' end
 from public.external_team_mappings a,public.external_team_mappings b where s.provider='pandascore' and a.provider=s.provider and a.external_team_id=s.external_team_a_id and b.provider=s.provider and b.external_team_id=s.external_team_b_id;
end $$;

create or replace function public.admin_apply_pandascore_fixtures(target_region text)
returns jsonb language plpgsql security definer set search_path='' as $$
declare rec record; season_uuid uuid; week_uuid uuid; home_uuid uuid; away_uuid uuid; winner_uuid uuid; existing_uuid uuid; applied integer:=0; skipped integer:=0; mapped_status text;
begin
 if not public.is_platform_admin() then raise exception 'Not authorized'; end if;
 select id into season_uuid from public.seasons where region_code=target_region and season_number=18;
 if season_uuid is null then raise exception 'Season 18 not found'; end if;
 for rec in select * from public.fixture_import_staging where provider='pandascore' and region_code=target_region and mapping_status='ready' order by scheduled_at nulls last loop
  select team_id into home_uuid from public.external_team_mappings where provider='pandascore' and external_team_id=rec.external_team_a_id;
  select team_id into away_uuid from public.external_team_mappings where provider='pandascore' and external_team_id=rec.external_team_b_id;
  select team_id into winner_uuid from public.external_team_mappings where provider='pandascore' and external_team_id=rec.winner_external_team_id;
  mapped_status:=case rec.provider_status when 'not_started' then 'scheduled' when 'running' then 'live' when 'finished' then 'completed' when 'canceled' then 'cancelled' when 'postponed' then 'postponed' else 'draft' end;
  select id into existing_uuid from public.matches where external_provider='pandascore' and external_match_id=rec.external_match_id;
  if existing_uuid is null and rec.scheduled_at is not null then
   select id into existing_uuid from public.matches
   where season_id=season_uuid and external_match_id is null and home_team_id=home_uuid and away_team_id=away_uuid
     and abs(extract(epoch from (scheduled_at-rec.scheduled_at)))<43200
   order by abs(extract(epoch from (scheduled_at-rec.scheduled_at))) limit 1;
   if existing_uuid is not null then update public.matches set external_provider='pandascore',external_match_id=rec.external_match_id where id=existing_uuid; end if;
  end if;
  if rec.scheduled_at is null then skipped:=skipped+1;continue;end if;
  insert into public.competition_weeks(season_id,week_number,name,starts_at,ends_at,meta_locks_at,mvp_locks_at)
  values(season_uuid,rec.week_number,'Week '||rec.week_number,rec.serie_begin_at+(rec.week_number-1)*interval '7 days',rec.serie_begin_at+rec.week_number*interval '7 days',rec.serie_begin_at+(rec.week_number-1)*interval '7 days',rec.scheduled_at)
  on conflict(season_id,week_number) do nothing;
  select id into week_uuid from public.competition_weeks where season_id=season_uuid and week_number=rec.week_number;
  if existing_uuid is null then
   if mapped_status='cancelled' then skipped:=skipped+1;continue;end if;
   insert into public.matches(season_id,week_id,home_team_id,away_team_id,best_of,scheduled_at,prediction_locks_at,status,home_score,away_score,winner_team_id,result_state,source_url,external_provider,external_match_id)
   values(season_uuid,week_uuid,home_uuid,away_uuid,rec.best_of,rec.scheduled_at,rec.scheduled_at,mapped_status,case when mapped_status='completed' then rec.team_a_score end,case when mapped_status='completed' then rec.team_b_score end,case when mapped_status='completed' then winner_uuid end,'unverified','https://api.pandascore.co/matches/'||rec.external_match_id,'pandascore',rec.external_match_id);
  else
   update public.matches set week_id=week_uuid,home_team_id=home_uuid,away_team_id=away_uuid,best_of=rec.best_of,scheduled_at=rec.scheduled_at,prediction_locks_at=rec.scheduled_at,status=mapped_status,
    home_score=case when mapped_status='completed' then rec.team_a_score else home_score end,away_score=case when mapped_status='completed' then rec.team_b_score else away_score end,winner_team_id=case when mapped_status='completed' then winner_uuid else winner_team_id end,updated_at=now()
   where id=existing_uuid and result_state='unverified';
  end if;
  update public.fixture_import_staging set applied_at=now() where provider='pandascore' and external_match_id=rec.external_match_id;
  applied:=applied+1;
 end loop;
 return jsonb_build_object('region',target_region,'applied',applied,'skipped',skipped);
end $$;

create or replace function public.admin_pandascore_sync_status(target_region text)
returns jsonb language plpgsql stable security definer set search_path='' as $$
begin
 if not public.is_platform_admin() then raise exception 'Not authorized'; end if;
 return jsonb_build_object(
  'configured',exists(select 1 from public.integration_secret_hashes where integration='pandascore'),
  'mappings',coalesce((select jsonb_agg(jsonb_build_object('external_id',m.external_team_id,'external_name',m.external_name,'acronym',m.external_acronym,'team_id',m.team_id) order by m.external_name) from public.external_team_mappings m where m.provider='pandascore' and m.region_code=target_region),'[]'::jsonb),
  'teams',coalesce((select jsonb_agg(jsonb_build_object('id',t.id,'name',t.name,'code',t.code) order by t.name) from public.teams t where t.region_code=target_region and t.active=true),'[]'::jsonb),
  'staged',coalesce((select jsonb_agg(jsonb_build_object('external_id',s.external_match_id,'name',s.external_team_a_name||' vs '||s.external_team_b_name,'scheduled_at',s.scheduled_at,'status',s.provider_status,'week',s.week_number,'mapping_status',s.mapping_status,'score',case when s.team_a_score is not null then s.team_a_score||'–'||s.team_b_score end,'applied_at',s.applied_at) order by s.scheduled_at desc nulls last) from public.fixture_import_staging s where s.provider='pandascore' and s.region_code=target_region),'[]'::jsonb),
  'runs',coalesce((select jsonb_agg(to_jsonb(r) order by r.started_at desc) from (select * from public.fixture_sync_runs where provider='pandascore' order by started_at desc limit 10) r),'[]'::jsonb)
 );
end $$;

grant execute on function public.configure_pandascore_sync_secret(text) to authenticated;
grant execute on function public.ingest_pandascore_fixture_batch(text,jsonb) to anon,authenticated;
grant execute on function public.admin_map_pandascore_team(bigint,uuid) to authenticated;
grant execute on function public.admin_apply_pandascore_fixtures(text) to authenticated;
grant execute on function public.admin_pandascore_sync_status(text) to authenticated;

select
 to_regprocedure('public.ingest_pandascore_fixture_batch(text,jsonb)') is not null as ingestion_ready,
 to_regprocedure('public.admin_apply_pandascore_fixtures(text)') is not null as apply_ready,
 to_regprocedure('public.admin_pandascore_sync_status(text)') is not null as review_ready;
