-- Fantasy MPL — regional operations, leaderboard snapshots and burst protection
-- Run after 021_regional_lanes_and_model_bundle.sql

create table if not exists public.regional_feature_flags (
  region_code text not null references public.regions(code) on delete cascade,
  feature_key text not null check (feature_key in ('predictions','mvp','fantasy','leaderboard','draft_lab')),
  enabled boolean not null default true,
  public_message text,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id) on delete set null,
  primary key (region_code, feature_key)
);

insert into public.regional_feature_flags (region_code, feature_key, enabled)
select r.code, f.feature_key, true
from public.regions r
cross join (values ('predictions'),('mvp'),('fantasy'),('leaderboard'),('draft_lab')) f(feature_key)
where r.code in ('MY','ID','PH')
on conflict (region_code, feature_key) do nothing;

create table if not exists public.regional_leaderboard_snapshots (
  id uuid primary key default gen_random_uuid(),
  region_code text not null references public.regions(code) on delete cascade,
  season_id uuid not null references public.seasons(id) on delete cascade,
  week_id uuid references public.competition_weeks(id) on delete cascade,
  category text not null check (category in ('total','prediction','fantasy')),
  user_id uuid not null references auth.users(id) on delete cascade,
  rank_position integer not null check (rank_position > 0),
  points numeric(12,2) not null,
  generated_at timestamptz not null default now()
);

create unique index if not exists regional_snapshot_unique_row
  on public.regional_leaderboard_snapshots (
    region_code, season_id, coalesce(week_id,'00000000-0000-0000-0000-000000000000'::uuid), category, user_id
  );
create index if not exists regional_snapshot_rank_lookup
  on public.regional_leaderboard_snapshots (
    region_code, season_id, week_id, category, rank_position
  );

alter table public.regional_feature_flags enable row level security;
alter table public.regional_leaderboard_snapshots enable row level security;

drop policy if exists "public reads regional feature flags" on public.regional_feature_flags;
create policy "public reads regional feature flags"
on public.regional_feature_flags for select using (true);

drop policy if exists "admins manage regional feature flags" on public.regional_feature_flags;
create policy "admins manage regional feature flags"
on public.regional_feature_flags for all to authenticated
using ((select public.is_platform_admin()))
with check ((select public.is_platform_admin()));

drop policy if exists "public reads regional leaderboard snapshots" on public.regional_leaderboard_snapshots;
create policy "public reads regional leaderboard snapshots"
on public.regional_leaderboard_snapshots for select using (true);

drop policy if exists "admins manage regional leaderboard snapshots" on public.regional_leaderboard_snapshots;
create policy "admins manage regional leaderboard snapshots"
on public.regional_leaderboard_snapshots for all to authenticated
using ((select public.is_platform_admin()))
with check ((select public.is_platform_admin()));

grant select on public.regional_feature_flags, public.regional_leaderboard_snapshots to anon, authenticated;
grant insert, update, delete on public.regional_feature_flags, public.regional_leaderboard_snapshots to authenticated;

create or replace function public.regional_feature_status(target_region text)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'region', target_region,
    'features', coalesce(jsonb_object_agg(feature_key, jsonb_build_object(
      'enabled', enabled,
      'message', public_message,
      'updated_at', updated_at
    )), '{}'::jsonb),
    'generated_at', now()
  )
  from public.regional_feature_flags
  where region_code = target_region;
$$;

create or replace function public.admin_set_regional_feature(
  target_region text,
  target_feature text,
  target_enabled boolean,
  target_message text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_platform_admin() then raise exception 'Not authorized'; end if;
  if target_region not in ('MY','ID','PH') then raise exception 'Unsupported region'; end if;
  if target_feature not in ('predictions','mvp','fantasy','leaderboard','draft_lab') then raise exception 'Unsupported feature'; end if;
  insert into public.regional_feature_flags (region_code,feature_key,enabled,public_message,updated_at,updated_by)
  values (target_region,target_feature,target_enabled,nullif(trim(target_message),''),now(),(select auth.uid()))
  on conflict (region_code,feature_key) do update set
    enabled=excluded.enabled, public_message=excluded.public_message,
    updated_at=now(), updated_by=(select auth.uid());
end;
$$;

create or replace function public.admin_refresh_leaderboard_snapshots(
  target_region text,
  target_week uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_season uuid;
  generated timestamptz := now();
  inserted integer := 0;
  affected integer;
begin
  if not public.is_platform_admin() then raise exception 'Not authorized'; end if;
  if target_region not in ('MY','ID','PH') then raise exception 'Unsupported region'; end if;

  if target_week is not null then
    select s.id into target_season
    from public.competition_weeks w join public.seasons s on s.id=w.season_id
    where w.id=target_week and s.region_code=target_region;
  else
    select id into target_season from public.seasons
    where region_code=target_region and status in ('active','published','completed')
    order by case status when 'active' then 0 when 'published' then 1 else 2 end, season_number desc limit 1;
  end if;
  if target_season is null then raise exception 'Season or week not found for region'; end if;

  delete from public.regional_leaderboard_snapshots
  where region_code=target_region and season_id=target_season
    and week_id is not distinct from target_week;

  insert into public.regional_leaderboard_snapshots
    (region_code,season_id,week_id,category,user_id,rank_position,points,generated_at)
  select target_region,target_season,target_week,'total',user_id,
    rank() over(order by points desc,user_id)::integer,points,generated
  from (
    select user_id,sum(points) as points from public.score_transactions
    where region_code=target_region and season_id=target_season
      and (target_week is null or week_id=target_week)
    group by user_id
  ) totals;
  get diagnostics affected=row_count; inserted:=inserted+affected;

  insert into public.regional_leaderboard_snapshots
    (region_code,season_id,week_id,category,user_id,rank_position,points,generated_at)
  select target_region,target_season,target_week,'prediction',user_id,
    rank() over(order by points desc,user_id)::integer,points,generated
  from (
    select user_id,sum(points) as points from public.score_transactions
    where region_code=target_region and season_id=target_season and category='prediction'
      and (target_week is null or week_id=target_week)
    group by user_id
  ) totals;
  get diagnostics affected=row_count; inserted:=inserted+affected;

  insert into public.regional_leaderboard_snapshots
    (region_code,season_id,week_id,category,user_id,rank_position,points,generated_at)
  select target_region,target_season,target_week,'fantasy',user_id,
    rank() over(order by points desc,user_id)::integer,points,generated
  from (
    select user_id,sum(points) as points from public.score_transactions
    where region_code=target_region and season_id=target_season and category='fantasy'
      and (target_week is null or week_id=target_week)
    group by user_id
  ) totals;
  get diagnostics affected=row_count; inserted:=inserted+affected;

  return jsonb_build_object('region',target_region,'season_id',target_season,'week_id',target_week,'rows',inserted,'generated_at',generated);
end;
$$;

create or replace function public.regional_leaderboard_snapshot(
  target_region text,
  target_season uuid default null,
  target_week uuid default null,
  max_rows integer default 100
)
returns table (
  user_id uuid,
  manager_name text,
  country_code text,
  avatar_url text,
  total_points numeric,
  prediction_points numeric,
  fantasy_points numeric,
  rank_position integer,
  generated_at timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  with selected_season as (
    select coalesce(target_season,(
      select id from public.seasons where region_code=target_region
      order by season_number desc limit 1
    )) as id
  )
  select t.user_id,coalesce(p.manager_name,'MANAGER'),coalesce(p.country_code,'OTHER'),p.avatar_url,
    t.points,coalesce(pr.points,0),coalesce(f.points,0),t.rank_position,t.generated_at
  from public.regional_leaderboard_snapshots t
  join selected_season s on s.id=t.season_id
  left join public.regional_leaderboard_snapshots pr on pr.region_code=t.region_code and pr.season_id=t.season_id
    and pr.week_id is not distinct from t.week_id and pr.category='prediction' and pr.user_id=t.user_id
  left join public.regional_leaderboard_snapshots f on f.region_code=t.region_code and f.season_id=t.season_id
    and f.week_id is not distinct from t.week_id and f.category='fantasy' and f.user_id=t.user_id
  left join public.profiles p on p.id=t.user_id
  where t.region_code=target_region and t.category='total'
    and t.week_id is not distinct from target_week
  order by t.rank_position
  limit greatest(1,least(max_rows,500));
$$;

create or replace function public.admin_regional_operations_status(target_region text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_platform_admin() then raise exception 'Not authorized'; end if;
  return jsonb_build_object(
    'region',target_region,
    'features',public.regional_feature_status(target_region)->'features',
    'snapshots',coalesce((select jsonb_agg(to_jsonb(x)) from (
      select category,week_id,count(*) as rows,max(generated_at) as generated_at
      from public.regional_leaderboard_snapshots where region_code=target_region
      group by category,week_id order by week_id nulls first,category
    ) x),'[]'::jsonb),
    'weeks',coalesce((select jsonb_agg(jsonb_build_object('id',w.id,'number',w.week_number) order by w.week_number)
      from public.competition_weeks w join public.seasons s on s.id=w.season_id
      where s.region_code=target_region and s.season_number=18),'[]'::jsonb)
  );
end;
$$;

-- Regional kill switches and a short same-row resubmission cooldown protect
-- prediction write bursts. Batch submissions across different matches remain valid.
create or replace function public.enforce_regional_prediction_write()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare target_region text; feature_enabled boolean;
begin
  select s.region_code into target_region
  from public.matches m join public.seasons s on s.id=m.season_id where m.id=new.match_id;
  select enabled into feature_enabled from public.regional_feature_flags
  where region_code=target_region and feature_key='predictions';
  if feature_enabled is false then raise exception 'Match predictions are temporarily unavailable in this region'; end if;
  if tg_op='UPDATE' and old.updated_at > now()-interval '3 seconds' then
    raise exception 'Please wait a few seconds before resubmitting this prediction';
  end if;
  new.updated_at:=now();
  return new;
end;
$$;

drop trigger if exists enforce_regional_prediction_write_before_write on public.match_predictions;
create trigger enforce_regional_prediction_write_before_write
before insert or update on public.match_predictions
for each row execute function public.enforce_regional_prediction_write();

create or replace function public.enforce_regional_mvp_write()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare target_region text; feature_enabled boolean;
begin
  select s.region_code into target_region
  from public.competition_weeks w join public.seasons s on s.id=w.season_id where w.id=new.week_id;
  select enabled into feature_enabled from public.regional_feature_flags
  where region_code=target_region and feature_key='mvp';
  if feature_enabled is false then raise exception 'MVP voting is temporarily unavailable in this region'; end if;
  if tg_op='UPDATE' and old.updated_at > now()-interval '3 seconds' then
    raise exception 'Please wait a few seconds before resubmitting this MVP pick';
  end if;
  new.updated_at:=now();
  return new;
end;
$$;

drop trigger if exists enforce_regional_mvp_write_before_write on public.weekly_mvp_predictions;
create trigger enforce_regional_mvp_write_before_write
before insert or update on public.weekly_mvp_predictions
for each row execute function public.enforce_regional_mvp_write();

grant execute on function public.regional_feature_status(text) to anon,authenticated;
grant execute on function public.regional_leaderboard_snapshot(text,uuid,uuid,integer) to anon,authenticated;
grant execute on function public.admin_set_regional_feature(text,text,boolean,text) to authenticated;
grant execute on function public.admin_refresh_leaderboard_snapshots(text,uuid) to authenticated;
grant execute on function public.admin_regional_operations_status(text) to authenticated;

select
  to_regprocedure('public.regional_feature_status(text)') is not null as feature_flags_ready,
  to_regprocedure('public.regional_leaderboard_snapshot(text,uuid,uuid,integer)') is not null as snapshots_ready,
  to_regprocedure('public.admin_refresh_leaderboard_snapshots(text,uuid)') is not null as refresh_ready;
