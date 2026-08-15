-- Fantasy MPL — Initial Supabase foundation
-- Safe to run in the Supabase SQL Editor for a new project.

create extension if not exists pgcrypto;
create extension if not exists citext;

-- Public profile information. This table must never contain addresses,
-- dates of birth, private full names, or authentication secrets.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  manager_name citext not null,
  country_code text not null default 'OTHER'
    check (country_code in ('MY','ID','PH','SG','BN','TH','VN','KH','MM','LA','OTHER')),
  avatar_url text,
  bio text check (bio is null or char_length(bio) <= 180),
  account_role text not null default 'user'
    check (account_role in ('user','creator','admin','super_admin')),
  creator_verified boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint manager_name_length check (char_length(manager_name) between 3 and 30),
  constraint manager_name_unique unique (manager_name)
);

-- Private profile information, available only to its owner and authorized
-- server-side administration. Never expose this through a public view.
create table if not exists public.profile_private (
  user_id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  address text,
  date_of_birth date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint full_name_length check (char_length(full_name) between 3 and 120),
  constraint address_length check (address is null or char_length(address) <= 300)
);

create table if not exists public.regions (
  code text primary key check (code in ('MY','ID','PH')),
  name text not null unique,
  time_zone text not null,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

insert into public.regions (code, name, time_zone) values
  ('MY', 'MPL Malaysia', 'Asia/Kuala_Lumpur'),
  ('ID', 'MPL Indonesia', 'Asia/Jakarta'),
  ('PH', 'MPL Philippines', 'Asia/Manila')
on conflict (code) do update set
  name = excluded.name,
  time_zone = excluded.time_zone;

create table if not exists public.region_memberships (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  region_code text not null references public.regions(code),
  joined_at timestamptz not null default now(),
  unique (user_id, region_code)
);

-- Keep updated_at accurate without trusting the browser.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists profile_private_set_updated_at on public.profile_private;
create trigger profile_private_set_updated_at
before update on public.profile_private
for each row execute function public.set_updated_at();

-- Create profile records when a new Supabase Auth user is created.
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
begin
  requested_manager_name := coalesce(
    nullif(trim(new.raw_user_meta_data ->> 'manager_name'), ''),
    'manager_' || substr(replace(new.id::text, '-', ''), 1, 8)
  );

  requested_full_name := coalesce(
    nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''),
    'New Manager'
  );

  requested_country := coalesce(
    nullif(upper(trim(new.raw_user_meta_data ->> 'country_code')), ''),
    'OTHER'
  );

  if requested_country not in ('MY','ID','PH','SG','BN','TH','VN','KH','MM','LA','OTHER') then
    requested_country := 'OTHER';
  end if;

  insert into public.profiles (id, manager_name, country_code)
  values (new.id, requested_manager_name, requested_country);

  insert into public.profile_private (user_id, full_name)
  values (new.id, requested_full_name);

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- Row Level Security
alter table public.profiles enable row level security;
alter table public.profile_private enable row level security;
alter table public.regions enable row level security;
alter table public.region_memberships enable row level security;

-- Public profile fields are safe for leaderboards and creator discovery.
drop policy if exists "profiles are publicly readable" on public.profiles;
create policy "profiles are publicly readable"
on public.profiles for select
using (true);

drop policy if exists "users update own public profile" on public.profiles;
create policy "users update own public profile"
on public.profiles for update
to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

-- Private records are owner-only.
drop policy if exists "users read own private profile" on public.profile_private;
create policy "users read own private profile"
on public.profile_private for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "users update own private profile" on public.profile_private;
create policy "users update own private profile"
on public.profile_private for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

-- Regional reference data is publicly readable.
drop policy if exists "regions are publicly readable" on public.regions;
create policy "regions are publicly readable"
on public.regions for select
using (active = true);

-- Users control only their own regional memberships.
drop policy if exists "users read own memberships" on public.region_memberships;
create policy "users read own memberships"
on public.region_memberships for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "users join regions for themselves" on public.region_memberships;
create policy "users join regions for themselves"
on public.region_memberships for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "users leave own regions" on public.region_memberships;
create policy "users leave own regions"
on public.region_memberships for delete
to authenticated
using ((select auth.uid()) = user_id);

-- Public avatar bucket. File writes are restricted to a folder named after
-- the authenticated user's UUID: avatars/{user-id}/profile.webp
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'avatars',
  'avatars',
  true,
  5242880,
  array['image/jpeg','image/png','image/webp']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "public can view avatars" on storage.objects;
create policy "public can view avatars"
on storage.objects for select
using (bucket_id = 'avatars');

drop policy if exists "users upload own avatars" on storage.objects;
create policy "users upload own avatars"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists "users update own avatars" on storage.objects;
create policy "users update own avatars"
on storage.objects for update
to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = (select auth.uid())::text
)
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists "users delete own avatars" on storage.objects;
create policy "users delete own avatars"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

-- Explicit grants. RLS still applies to all authenticated operations.
grant usage on schema public to anon, authenticated;
grant select on public.profiles, public.regions to anon, authenticated;
grant select, update on public.profile_private to authenticated;
grant select, insert, delete on public.region_memberships to authenticated;
grant update on public.profiles to authenticated;
