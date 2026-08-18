-- Fantasy MPL — account age/guardian and terms acceptance record
-- Run after 029_server_only_fixture_ingestion.sql.
-- Deploy the updated registration form before applying this migration.

alter table public.profile_private
  add column if not exists age_or_guardian_confirmed boolean not null default false,
  add column if not exists terms_accepted_at timestamptz,
  add column if not exists terms_version text;

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
  select raw_user_meta_data into metadata
  from auth.users
  where id = new.user_id;

  accepted := coalesce((metadata ->> 'age_confirmation')::boolean, false);
  accepted_version := nullif(trim(metadata ->> 'terms_version'), '');

  if not accepted or accepted_version is null then
    raise exception 'Age, guardian and terms confirmation is required';
  end if;

  new.age_or_guardian_confirmed := true;
  new.terms_accepted_at := coalesce(new.terms_accepted_at, now());
  new.terms_version := accepted_version;
  return new;
end;
$$;

revoke all on function public.capture_account_acceptance()
  from public, anon, authenticated;

drop trigger if exists capture_account_acceptance_before_insert
  on public.profile_private;
create trigger capture_account_acceptance_before_insert
before insert on public.profile_private
for each row execute function public.capture_account_acceptance();

-- Existing beta accounts predate recorded acceptance. Leave them false/null so
-- they can be identified and asked to accept the current terms in a future flow.
comment on column public.profile_private.age_or_guardian_confirmed is
  'True when signup metadata confirmed age 13+ and guardian approval when legally required.';
comment on column public.profile_private.terms_accepted_at is
  'Server-recorded time at which the signup acceptance was captured.';
comment on column public.profile_private.terms_version is
  'Version identifier supplied by the deployed registration form.';

create or replace function public.accept_current_terms(
  accepted_version text,
  age_or_guardian boolean
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_user_id uuid := (select auth.uid());
begin
  if current_user_id is null then raise exception 'Authentication required'; end if;
  if age_or_guardian is not true then raise exception 'Age and guardian confirmation is required'; end if;
  if accepted_version <> '2026-08-18' then raise exception 'Unsupported terms version'; end if;

  update public.profile_private set
    age_or_guardian_confirmed = true,
    terms_accepted_at = now(),
    terms_version = accepted_version,
    updated_at = now()
  where user_id = current_user_id;
  if not found then raise exception 'Private profile not found'; end if;
end;
$$;

create or replace function public.my_account_bootstrap()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'profile',(select jsonb_build_object(
      'manager_name',p.manager_name,'country_code',p.country_code,
      'avatar_url',p.avatar_url,'bio',p.bio,'account_role',p.account_role
    ) from public.profiles p where p.id=(select auth.uid())),
    'private_profile',(select jsonb_build_object(
      'full_name',pp.full_name,'address',pp.address,'date_of_birth',pp.date_of_birth,
      'age_or_guardian_confirmed',pp.age_or_guardian_confirmed,
      'terms_accepted_at',pp.terms_accepted_at,'terms_version',pp.terms_version
    ) from public.profile_private pp where pp.user_id=(select auth.uid())),
    'memberships',coalesce((select jsonb_agg(rm.region_code order by rm.joined_at)
      from public.region_memberships rm where rm.user_id=(select auth.uid())),'[]'::jsonb)
  );
$$;

revoke all on function public.accept_current_terms(text,boolean) from public,anon;
revoke all on function public.my_account_bootstrap() from public,anon;
grant execute on function public.accept_current_terms(text,boolean) to authenticated;
grant execute on function public.my_account_bootstrap() to authenticated;

select
  to_regprocedure('public.capture_account_acceptance()') is not null as acceptance_trigger_ready,
  to_regprocedure('public.accept_current_terms(text,boolean)') is not null as existing_account_acceptance_ready,
  exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='profile_private'
      and column_name='terms_accepted_at'
  ) as acceptance_columns_ready;
