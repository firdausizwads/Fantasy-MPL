-- Fantasy MPL — Live Draft Lab intelligence foundation
-- Run after 018_controlled_beta_activity_reset.sql

-- Approved source registry ---------------------------------------------------
create table if not exists public.draft_data_sources (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  provider_url text not null,
  terms_url text,
  license_name text,
  attribution_text text,
  approval_status text not null default 'pending'
    check (approval_status in ('pending','approved','rejected','suspended')),
  commercial_use_confirmed boolean not null default false,
  primary_for_model boolean not null default false,
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id) on delete set null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (name, provider_url),
  check (not primary_for_model or (approval_status = 'approved' and commercial_use_confirmed))
);

create unique index if not exists one_primary_draft_data_source
  on public.draft_data_sources (primary_for_model)
  where primary_for_model = true;

-- Versioned recommendation configuration -----------------------------------
create table if not exists public.draft_model_versions (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  version text not null,
  description text,
  patch_id uuid references public.patches(id) on delete set null,
  weights jsonb not null default '{"ban_rate":0.60,"contest_rate":0.40,"pick_rate":0.35,"win_rate":0.25,"pick_contest":0.15,"synergy":0.15,"counter":0.10}'::jsonb,
  minimum_sample integer not null default 10 check (minimum_sample between 1 and 10000),
  active boolean not null default false,
  activated_at timestamptz,
  activated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  unique (name, version)
);

create unique index if not exists one_active_draft_model
  on public.draft_model_versions (active)
  where active = true;

insert into public.draft_model_versions
  (name, version, description, minimum_sample, active)
values
  ('FANTASY MPL DRAFT INTELLIGENCE', '0.1-FOUNDATION',
   'Evidence-based current-patch professional draft ranking. Remains inactive until an approved source is imported.',
   10, false)
on conflict (name, version) do nothing;

-- Ordered professional drafts ----------------------------------------------
create table if not exists public.pro_draft_games (
  id uuid primary key default gen_random_uuid(),
  source_id uuid not null references public.draft_data_sources(id) on delete restrict,
  source_match_key text not null,
  season_id uuid references public.seasons(id) on delete set null,
  region_code text not null references public.regions(code),
  patch_id uuid references public.patches(id) on delete set null,
  blue_team_id uuid references public.teams(id) on delete set null,
  red_team_id uuid references public.teams(id) on delete set null,
  game_number integer not null default 1 check (game_number between 1 and 20),
  played_at timestamptz,
  winner_side text check (winner_side is null or winner_side in ('BLUE','RED')),
  first_pick_side text not null default 'BLUE' check (first_pick_side in ('BLUE','RED')),
  verified boolean not null default false,
  verified_at timestamptz,
  verified_by uuid references auth.users(id) on delete set null,
  source_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (source_id, source_match_key, game_number)
);

create table if not exists public.pro_draft_actions (
  id uuid primary key default gen_random_uuid(),
  game_id uuid not null references public.pro_draft_games(id) on delete cascade,
  sequence_number integer not null check (sequence_number between 1 and 30),
  phase integer not null check (phase in (1,2)),
  action_type text not null check (action_type in ('BAN','PICK')),
  side text not null check (side in ('BLUE','RED')),
  hero_id uuid not null references public.heroes(id) on delete restrict,
  team_id uuid references public.teams(id) on delete set null,
  created_at timestamptz not null default now(),
  unique (game_id, sequence_number),
  unique (game_id, hero_id)
);

create index if not exists pro_draft_games_region_patch_idx
  on public.pro_draft_games (region_code, patch_id, verified, played_at desc);
create index if not exists pro_draft_actions_hero_idx
  on public.pro_draft_actions (hero_id, action_type, side);

-- Aggregated metrics imported from an approved source. Rates are calculated
-- by PostgreSQL from counts rather than trusted from client input.
create table if not exists public.hero_patch_metrics (
  id uuid primary key default gen_random_uuid(),
  source_id uuid not null references public.draft_data_sources(id) on delete restrict,
  patch_id uuid not null references public.patches(id) on delete cascade,
  region_code text not null references public.regions(code),
  hero_id uuid not null references public.heroes(id) on delete cascade,
  games integer not null check (games >= 0),
  picks integer not null check (picks >= 0),
  bans integer not null check (bans >= 0),
  wins integer not null check (wins >= 0),
  pick_rate numeric(7,3) not null default 0,
  ban_rate numeric(7,3) not null default 0,
  contest_rate numeric(7,3) not null default 0,
  win_rate numeric(7,3) not null default 0,
  verified_at timestamptz not null default now(),
  imported_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (source_id, patch_id, region_code, hero_id),
  check (picks <= games),
  check (bans <= games),
  check (wins <= picks)
);

create or replace function public.calculate_hero_patch_rates()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.pick_rate := case when new.games > 0 then round(new.picks::numeric / new.games * 100, 3) else 0 end;
  new.ban_rate := case when new.games > 0 then round(new.bans::numeric / new.games * 100, 3) else 0 end;
  new.contest_rate := case when new.games > 0 then round((new.picks + new.bans)::numeric / new.games * 100, 3) else 0 end;
  new.win_rate := case when new.picks > 0 then round(new.wins::numeric / new.picks * 100, 3) else 0 end;
  return new;
end;
$$;

drop trigger if exists calculate_hero_patch_rates_before_write
on public.hero_patch_metrics;
create trigger calculate_hero_patch_rates_before_write
before insert or update of games, picks, bans, wins on public.hero_patch_metrics
for each row execute function public.calculate_hero_patch_rates();

-- Evidence-backed relationships. Positive impact_score means stronger
-- evidence for the relationship; no row means no claim is made.
create table if not exists public.hero_draft_relationships (
  id uuid primary key default gen_random_uuid(),
  source_id uuid not null references public.draft_data_sources(id) on delete restrict,
  patch_id uuid not null references public.patches(id) on delete cascade,
  region_code text not null references public.regions(code),
  hero_id uuid not null references public.heroes(id) on delete cascade,
  related_hero_id uuid not null references public.heroes(id) on delete cascade,
  relationship_type text not null check (relationship_type in ('SYNERGY','COUNTER','DENIAL')),
  sample_size integer not null check (sample_size > 0),
  impact_score numeric(8,5) not null check (impact_score between -1 and 1),
  verified_at timestamptz not null default now(),
  imported_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  unique (source_id, patch_id, region_code, hero_id, related_hero_id, relationship_type),
  check (hero_id <> related_hero_id)
);

-- Optional audit storage for recommendations selected for publication. Public
-- reads do not write here; a future server-side publishing job can persist a
-- bounded audit trail without allowing anonymous write amplification.
create table if not exists public.draft_recommendation_audit (
  id uuid primary key default gen_random_uuid(),
  model_version_id uuid not null references public.draft_model_versions(id) on delete restrict,
  source_id uuid not null references public.draft_data_sources(id) on delete restrict,
  patch_id uuid not null references public.patches(id) on delete restrict,
  region_code text not null references public.regions(code),
  action_type text not null check (action_type in ('BAN','PICK')),
  ally_heroes text[] not null default '{}',
  enemy_heroes text[] not null default '{}',
  banned_heroes text[] not null default '{}',
  recommendations jsonb not null,
  created_at timestamptz not null default now()
);

-- Updated-at triggers -------------------------------------------------------
do $$
declare table_name text;
begin
  for table_name in select unnest(array[
    'draft_data_sources','pro_draft_games','hero_patch_metrics'
  ]) loop
    execute format('drop trigger if exists %I_set_updated_at on public.%I', table_name, table_name);
    execute format(
      'create trigger %I_set_updated_at before update on public.%I for each row execute function public.set_updated_at()',
      table_name, table_name
    );
  end loop;
end;
$$;

-- RLS -----------------------------------------------------------------------
alter table public.draft_data_sources enable row level security;
alter table public.draft_model_versions enable row level security;
alter table public.pro_draft_games enable row level security;
alter table public.pro_draft_actions enable row level security;
alter table public.hero_patch_metrics enable row level security;
alter table public.hero_draft_relationships enable row level security;
alter table public.draft_recommendation_audit enable row level security;

do $$
declare table_name text;
begin
  for table_name in select unnest(array[
    'draft_data_sources','draft_model_versions','pro_draft_games','pro_draft_actions',
    'hero_patch_metrics','hero_draft_relationships','draft_recommendation_audit'
  ]) loop
    execute format('drop policy if exists "admins manage %s" on public.%I', table_name, table_name);
    execute format(
      'create policy "admins manage %s" on public.%I for all to authenticated using ((select public.is_platform_admin())) with check ((select public.is_platform_admin()))',
      table_name, table_name
    );
  end loop;
end;
$$;

drop policy if exists "public reads approved draft sources" on public.draft_data_sources;
create policy "public reads approved draft sources"
on public.draft_data_sources for select
using (approval_status = 'approved' and commercial_use_confirmed = true);

drop policy if exists "public reads active draft model" on public.draft_model_versions;
create policy "public reads active draft model"
on public.draft_model_versions for select
using (active = true);

drop policy if exists "public reads verified pro drafts" on public.pro_draft_games;
create policy "public reads verified pro drafts"
on public.pro_draft_games for select
using (verified = true);

drop policy if exists "public reads actions from verified drafts" on public.pro_draft_actions;
create policy "public reads actions from verified drafts"
on public.pro_draft_actions for select
using (exists (select 1 from public.pro_draft_games g where g.id = game_id and g.verified = true));

drop policy if exists "public reads approved hero metrics" on public.hero_patch_metrics;
create policy "public reads approved hero metrics"
on public.hero_patch_metrics for select
using (exists (
  select 1 from public.draft_data_sources s
  where s.id = source_id and s.approval_status = 'approved'
    and s.commercial_use_confirmed = true and s.primary_for_model = true
));

drop policy if exists "public reads approved hero relationships" on public.hero_draft_relationships;
create policy "public reads approved hero relationships"
on public.hero_draft_relationships for select
using (exists (
  select 1 from public.draft_data_sources s
  where s.id = source_id and s.approval_status = 'approved'
    and s.commercial_use_confirmed = true and s.primary_for_model = true
));

-- Admin RPCs ----------------------------------------------------------------
create or replace function public.admin_upsert_draft_source(
  source_name text,
  source_provider_url text,
  source_terms_url text default null,
  source_license_name text default null,
  source_attribution_text text default null,
  source_approval_status text default 'pending',
  source_commercial_confirmed boolean default false,
  source_primary boolean default false,
  source_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare result_id uuid;
begin
  if not public.is_platform_admin() then raise exception 'Not authorized'; end if;
  if source_approval_status not in ('pending','approved','rejected','suspended') then
    raise exception 'Invalid source approval status';
  end if;
  if source_primary and (source_approval_status <> 'approved' or not source_commercial_confirmed) then
    raise exception 'Primary model source must be approved for commercial use';
  end if;
  if source_primary then update public.draft_data_sources set primary_for_model = false where primary_for_model = true; end if;

  insert into public.draft_data_sources (
    name, provider_url, terms_url, license_name, attribution_text,
    approval_status, commercial_use_confirmed, primary_for_model,
    reviewed_at, reviewed_by, notes
  ) values (
    trim(source_name), trim(source_provider_url), nullif(trim(source_terms_url),''),
    nullif(trim(source_license_name),''), nullif(trim(source_attribution_text),''),
    source_approval_status, source_commercial_confirmed, source_primary,
    case when source_approval_status = 'approved' then now() else null end,
    (select auth.uid()), nullif(trim(source_notes),'')
  )
  on conflict (name, provider_url) do update set
    terms_url = excluded.terms_url,
    license_name = excluded.license_name,
    attribution_text = excluded.attribution_text,
    approval_status = excluded.approval_status,
    commercial_use_confirmed = excluded.commercial_use_confirmed,
    primary_for_model = excluded.primary_for_model,
    reviewed_at = excluded.reviewed_at,
    reviewed_by = excluded.reviewed_by,
    notes = excluded.notes,
    updated_at = now()
  returning id into result_id;
  return result_id;
end;
$$;

create or replace function public.admin_import_hero_metrics(
  target_source uuid,
  target_patch uuid,
  target_region text,
  metrics jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare item jsonb; hero_uuid uuid; imported integer := 0;
begin
  if not public.is_platform_admin() then raise exception 'Not authorized'; end if;
  if target_region not in ('MY','ID','PH') then raise exception 'Unsupported region'; end if;
  if not exists (
    select 1 from public.draft_data_sources s where s.id = target_source
      and s.approval_status = 'approved' and s.commercial_use_confirmed = true
  ) then raise exception 'Source is not approved for use'; end if;
  if not exists (select 1 from public.patches where id = target_patch) then raise exception 'Patch not found'; end if;
  if jsonb_typeof(metrics) <> 'array' then raise exception 'Metrics payload must be an array'; end if;

  for item in select value from jsonb_array_elements(metrics)
  loop
    select id into hero_uuid from public.heroes where upper(name::text) = upper(trim(item->>'hero')) and active = true;
    if hero_uuid is null then raise exception 'Unknown active hero: %', item->>'hero'; end if;

    insert into public.hero_patch_metrics (
      source_id, patch_id, region_code, hero_id, games, picks, bans, wins, imported_by, verified_at
    ) values (
      target_source, target_patch, target_region, hero_uuid,
      (item->>'games')::integer, (item->>'picks')::integer,
      (item->>'bans')::integer, (item->>'wins')::integer,
      (select auth.uid()), now()
    )
    on conflict (source_id, patch_id, region_code, hero_id) do update set
      games = excluded.games, picks = excluded.picks, bans = excluded.bans,
      wins = excluded.wins, imported_by = excluded.imported_by,
      verified_at = now(), updated_at = now();
    imported := imported + 1;
  end loop;

  return jsonb_build_object('imported', imported, 'region', target_region, 'patch_id', target_patch);
end;
$$;

create or replace function public.admin_activate_draft_model(
  target_model uuid,
  target_patch uuid,
  target_minimum_sample integer default 10
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_platform_admin() then raise exception 'Not authorized'; end if;
  if target_minimum_sample < 1 then raise exception 'Minimum sample must be positive'; end if;
  if not exists (select 1 from public.patches where id = target_patch and active = true) then
    raise exception 'Target patch must be the active patch';
  end if;
  if not exists (
    select 1 from public.draft_data_sources
    where primary_for_model = true and approval_status = 'approved' and commercial_use_confirmed = true
  ) then raise exception 'An approved primary source is required'; end if;

  update public.draft_model_versions set active = false where active = true;
  update public.draft_model_versions set
    active = true, patch_id = target_patch, minimum_sample = target_minimum_sample,
    activated_at = now(), activated_by = (select auth.uid())
  where id = target_model;
  if not found then raise exception 'Model version not found'; end if;
end;
$$;

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

-- Public model status -------------------------------------------------------
create or replace function public.draft_intelligence_status(target_region text)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with source as (
    select * from public.draft_data_sources
    where primary_for_model = true and approval_status = 'approved'
      and commercial_use_confirmed = true limit 1
  ), model as (
    select * from public.draft_model_versions where active = true limit 1
  ), metric_summary as (
    select count(*) as heroes, coalesce(max(hpm.games),0) as games,
           min(hpm.verified_at) as oldest_verified,
           max(hpm.verified_at) as newest_verified
    from public.hero_patch_metrics hpm, source s, model m
    where hpm.source_id = s.id and hpm.patch_id = m.patch_id
      and hpm.region_code = target_region and hpm.games >= m.minimum_sample
  )
  select jsonb_build_object(
    'ready', exists(select 1 from source) and exists(select 1 from model)
      and coalesce((select heroes from metric_summary),0) > 0,
    'region', target_region,
    'source_name', (select name from source),
    'source_url', (select provider_url from source),
    'attribution', (select attribution_text from source),
    'license', (select license_name from source),
    'model_name', (select name from model),
    'model_version', (select version from model),
    'patch', (select p.version from model m join public.patches p on p.id = m.patch_id),
    'minimum_sample', (select minimum_sample from model),
    'eligible_heroes', coalesce((select heroes from metric_summary),0),
    'drafts_analyzed', coalesce((select games from metric_summary),0),
    'last_verified', (select newest_verified from metric_summary),
    'blocker', case
      when not exists(select 1 from source) then 'APPROVED PRIMARY SOURCE REQUIRED'
      when not exists(select 1 from model) then 'ACTIVE MODEL VERSION REQUIRED'
      when coalesce((select heroes from metric_summary),0) = 0 then 'CURRENT-PATCH REGIONAL SAMPLE REQUIRED'
      else null
    end
  );
$$;

-- Evidence-based recommendation RPC ----------------------------------------
create or replace function public.recommend_draft_actions(
  target_region text,
  target_action text,
  ally_hero_names text[] default '{}',
  enemy_hero_names text[] default '{}',
  banned_hero_names text[] default '{}',
  max_results integer default 3
)
returns table (
  hero_name text,
  score numeric,
  evidence_level text,
  sample_size integer,
  reason text,
  pick_rate numeric,
  ban_rate numeric,
  win_rate numeric,
  contest_rate numeric
)
language sql
stable
security definer
set search_path = ''
as $$
  with source as (
    select * from public.draft_data_sources
    where primary_for_model = true and approval_status = 'approved'
      and commercial_use_confirmed = true limit 1
  ), model as (
    select * from public.draft_model_versions where active = true limit 1
  ), candidates as (
    select h.id, h.name::text as hero_name, hpm.games, hpm.picks, hpm.bans,
           hpm.pick_rate, hpm.ban_rate, hpm.win_rate, hpm.contest_rate,
           m.weights, m.minimum_sample, m.id as model_id, m.patch_id,
           s.id as source_id
    from public.hero_patch_metrics hpm
    join public.heroes h on h.id = hpm.hero_id
    join source s on s.id = hpm.source_id
    join model m on m.patch_id = hpm.patch_id
    where hpm.region_code = target_region
      and hpm.games >= m.minimum_sample
      and not (upper(h.name::text) = any(
        select upper(x) from unnest(
          coalesce(ally_hero_names,'{}') || coalesce(enemy_hero_names,'{}') || coalesce(banned_hero_names,'{}')
        ) x
      ))
  ), relationship_scores as (
    select c.*,
      coalesce((select sum(r.impact_score) from public.hero_draft_relationships r
        join public.heroes ah on ah.id = r.related_hero_id
        where r.hero_id = c.id and r.source_id = c.source_id and r.patch_id = c.patch_id
          and r.region_code = target_region and r.relationship_type = 'SYNERGY'
          and upper(ah.name::text) = any(select upper(x) from unnest(coalesce(ally_hero_names,'{}')) x)),0) as synergy_score,
      coalesce((select sum(r.impact_score) from public.hero_draft_relationships r
        join public.heroes eh on eh.id = r.related_hero_id
        where r.hero_id = c.id and r.source_id = c.source_id and r.patch_id = c.patch_id
          and r.region_code = target_region and r.relationship_type in ('COUNTER','DENIAL')
          and upper(eh.name::text) = any(select upper(x) from unnest(coalesce(enemy_hero_names,'{}')) x)),0) as counter_score
    from candidates c
  ), ranked as (
    select rs.*,
      case when upper(target_action) = 'BAN' then
        rs.ban_rate * coalesce((rs.weights->>'ban_rate')::numeric,0.60)
        + rs.contest_rate * coalesce((rs.weights->>'contest_rate')::numeric,0.40)
      else
        rs.pick_rate * coalesce((rs.weights->>'pick_rate')::numeric,0.35)
        + rs.win_rate * coalesce((rs.weights->>'win_rate')::numeric,0.25)
        + rs.contest_rate * coalesce((rs.weights->>'pick_contest')::numeric,0.15)
        + rs.synergy_score * 100 * coalesce((rs.weights->>'synergy')::numeric,0.15)
        + rs.counter_score * 100 * coalesce((rs.weights->>'counter')::numeric,0.10)
      end as calculated_score
    from relationship_scores rs
    where upper(target_action) in ('BAN','PICK')
  )
  select r.hero_name,
    round(r.calculated_score,3) as score,
    case when r.games >= 50 then 'STRONG' when r.games >= 25 then 'MODERATE' else 'LIMITED' end,
    r.games,
    case when upper(target_action) = 'BAN'
      then format('Current-patch professional priority · %s bans across %s games', r.bans, r.games)
      else format('Current-patch professional evidence · %s picks, %s%% win rate across %s games', r.picks, round(r.win_rate,1), r.games)
    end,
    r.pick_rate, r.ban_rate, r.win_rate, r.contest_rate
  from ranked r
  order by r.calculated_score desc, r.hero_name
  limit greatest(1,least(max_results,5));
$$;

-- Explicit grants. Public functions expose only approved, model-eligible data.
grant usage on schema public to anon, authenticated;
grant select on public.draft_data_sources, public.draft_model_versions,
  public.pro_draft_games, public.pro_draft_actions, public.hero_patch_metrics,
  public.hero_draft_relationships to anon, authenticated;
grant select, insert, update, delete on public.draft_data_sources,
  public.draft_model_versions, public.pro_draft_games, public.pro_draft_actions,
  public.hero_patch_metrics, public.hero_draft_relationships,
  public.draft_recommendation_audit to authenticated;

grant execute on function public.draft_intelligence_status(text) to anon, authenticated;
grant execute on function public.recommend_draft_actions(text,text,text[],text[],text[],integer) to anon, authenticated;
grant execute on function public.admin_upsert_draft_source(text,text,text,text,text,text,boolean,boolean,text) to authenticated;
grant execute on function public.admin_draft_intelligence_config() to authenticated;
grant execute on function public.admin_import_hero_metrics(uuid,uuid,text,jsonb) to authenticated;
grant execute on function public.admin_activate_draft_model(uuid,uuid,integer) to authenticated;

select
  to_regprocedure('public.draft_intelligence_status(text)') is not null as status_ready,
  to_regprocedure('public.recommend_draft_actions(text,text,text[],text[],text[],integer)') is not null as recommendations_ready,
  to_regprocedure('public.admin_import_hero_metrics(uuid,uuid,text,jsonb)') is not null as import_ready;
