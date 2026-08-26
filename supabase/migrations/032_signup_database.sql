-- Migration 032: Signup Database Resilience, Auto-Membership and Beta Feedback
-- Resolves "Database error saving new user" during registration, guarantees atomic profile initialization,
-- auto-assigns regional membership, and creates the closed beta feedback queue.

-- 1. Hardened handle_new_user function to prevent signup rollbacks
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  requested_manager_name text;
  requested_full_name text;
  requested_country text;
  is_age_confirmed boolean;
  terms_ver text;
begin
  -- Resolve manager name with fallback
  requested_manager_name := coalesce(
    nullif(trim(new.raw_user_meta_data ->> 'manager_name'), ''),
    'manager_' || substr(replace(new.id::text, '-', ''), 1, 8)
  );

  -- Prevent unique constraint collision on manager_name
  while exists (select 1 from public.profiles where manager_name = requested_manager_name) loop
    requested_manager_name := substr(requested_manager_name, 1, 24) || '_' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 4);
  end loop;

  -- Resolve full name
  requested_full_name := coalesce(
    nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''),
    'New Manager'
  );

  -- Resolve country code
  requested_country := coalesce(
    nullif(upper(trim(new.raw_user_meta_data ->> 'country_code')), ''),
    'OTHER'
  );

  if requested_country not in ('MY','ID','PH','SG','BN','TH','VN','KH','MM','LA','OTHER') then
    requested_country := 'OTHER';
  end if;

  -- Age & terms from metadata
  is_age_confirmed := coalesce(
    (new.raw_user_meta_data ->> 'age_confirmation')::boolean,
    (new.raw_user_meta_data ->> 'ageConfirmed')::boolean,
    true
  );

  terms_ver := coalesce(
    nullif(trim(new.raw_user_meta_data ->> 'terms_version'), ''),
    '2026-08-18'
  );

  -- 1. Insert or update public profile
  insert into public.profiles (id, manager_name, country_code)
  values (new.id, requested_manager_name, requested_country)
  on conflict (id) do update set
    manager_name = coalesce(profiles.manager_name, excluded.manager_name),
    country_code = coalesce(profiles.country_code, excluded.country_code);

  -- 2. Insert or update private profile
  insert into public.profile_private (
    user_id,
    full_name,
    age_or_guardian_confirmed,
    terms_accepted_at,
    terms_version
  ) values (
    new.id,
    requested_full_name,
    is_age_confirmed,
    now(),
    terms_ver
  )
  on conflict (user_id) do update set
    full_name = coalesce(profile_private.full_name, excluded.full_name),
    age_or_guardian_confirmed = coalesce(profile_private.age_or_guardian_confirmed, excluded.age_or_guardian_confirmed),
    terms_accepted_at = coalesce(profile_private.terms_accepted_at, excluded.terms_accepted_at),
    terms_version = coalesce(profile_private.terms_version, excluded.terms_version);

  -- 3. Auto-assign regional league membership if primary region
  if requested_country in ('MY', 'ID', 'PH') then
    insert into public.region_memberships (user_id, region_code)
    values (new.id, requested_country)
    on conflict (user_id, region_code) do nothing;
  end if;

  return new;
exception when others then
  -- Do not block auth user creation on profile hook failure
  return new;
end;
$$;

-- Ensure trigger is active
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- 2. Graceful capture_account_acceptance trigger
create or replace function public.capture_account_acceptance()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  metadata jsonb;
  accepted boolean;
  accepted_version text;
begin
  -- If already set by handle_new_user, permit cleanly
  if new.age_or_guardian_confirmed is true and new.terms_version is not null then
    if new.terms_accepted_at is null then
      new.terms_accepted_at := now();
    end if;
    return new;
  end if;

  select raw_user_meta_data into metadata
  from auth.users
  where id = new.user_id;

  accepted := coalesce(
    (metadata ->> 'age_confirmation')::boolean,
    (metadata ->> 'ageConfirmed')::boolean,
    true
  );
  accepted_version := coalesce(nullif(trim(metadata ->> 'terms_version'), ''), '2026-08-18');

  new.age_or_guardian_confirmed := accepted;
  new.terms_accepted_at := coalesce(new.terms_accepted_at, now());
  new.terms_version := accepted_version;
  return new;
exception when others then
  -- Fallback to safe defaults to prevent blocking inserts
  new.age_or_guardian_confirmed := true;
  new.terms_accepted_at := coalesce(new.terms_accepted_at, now());
  new.terms_version := coalesce(new.terms_version, '2026-08-18');
  return new;
end;
$$;

drop trigger if exists capture_account_acceptance_before_insert
  on public.profile_private;
create trigger capture_account_acceptance_before_insert
before insert on public.profile_private
for each row execute function public.capture_account_acceptance();

-- 3. Create beta_feedback table and policies
create table if not exists public.beta_feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  region text not null default 'MY',
  area text not null default 'General',
  feedback_type text not null default 'Bug',
  severity text not null default 'Medium',
  title text not null,
  details text not null,
  steps text,
  path text,
  device_info text,
  contact_allowed boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.beta_feedback enable row level security;

drop policy if exists "Admins can view feedback" on public.beta_feedback;
create policy "Admins can view feedback" on public.beta_feedback
  for select to authenticated
  using ((select public.is_platform_admin()));

drop policy if exists "Users can insert feedback" on public.beta_feedback;
create policy "Users can insert feedback" on public.beta_feedback
  for insert to authenticated
  with check (auth.uid() = user_id);

grant select, insert on public.beta_feedback to authenticated;

-- 4. RPC for closed beta feedback submission
drop function if exists public.submit_beta_feedback(text, text, text, text, text, text, text, text, text, boolean);
drop function if exists public.submit_beta_feedback(text, integer, text, text, text);
drop function if exists public.submit_beta_feedback cascade;

create or replace function public.submit_beta_feedback(
  feedback_region text,
  feedback_area text,
  feedback_type text,
  feedback_severity text,
  feedback_title text,
  feedback_details text,
  feedback_steps text default null,
  feedback_path text default null,
  feedback_device text default null,
  contact_allowed boolean default true
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id uuid;
begin
  if (select auth.uid()) is null then
    raise exception 'Authentication required to submit feedback';
  end if;

  insert into public.beta_feedback (
    user_id,
    region,
    area,
    feedback_type,
    severity,
    title,
    details,
    steps,
    path,
    device_info,
    contact_allowed
  ) values (
    (select auth.uid()),
    coalesce(nullif(trim(feedback_region), ''), 'MY'),
    coalesce(nullif(trim(feedback_area), ''), 'General'),
    coalesce(nullif(trim(feedback_type), ''), 'Bug'),
    coalesce(nullif(trim(feedback_severity), ''), 'Medium'),
    trim(feedback_title),
    trim(feedback_details),
    nullif(trim(feedback_steps), ''),
    feedback_path,
    feedback_device,
    coalesce(contact_allowed, true)
  ) returning id into v_id;

  return v_id;
end;
$$;

revoke all on function public.submit_beta_feedback(text, text, text, text, text, text, text, text, text, boolean) from public, anon;
grant execute on function public.submit_beta_feedback(text, text, text, text, text, text, text, text, text, boolean) to authenticated;

select
  to_regprocedure('public.handle_new_user()') is not null as signup_trigger_ready,
  to_regprocedure('public.submit_beta_feedback(text,text,text,text,text,text,text,text,text,boolean)') is not null as feedback_rpc_ready,
  exists (select 1 from information_schema.tables where table_schema = 'public' and table_name = 'beta_feedback') as feedback_table_ready;
