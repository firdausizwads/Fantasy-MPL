-- Fantasy MPL — Prevent public-profile privilege escalation
-- Run after 011_fixture_management.sql

-- Browser users may update only safe public-profile columns.
revoke update on public.profiles from authenticated;
grant update (manager_name, country_code, avatar_url, bio)
  on public.profiles to authenticated;

-- Defense in depth if table-level permissions change later.
create or replace function public.protect_profile_privileges()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if (select auth.uid()) = old.id and not (select public.is_platform_admin()) then
    new.account_role := old.account_role;
    new.creator_verified := old.creator_verified;
  end if;
  return new;
end;
$$;

drop trigger if exists protect_profile_privileges_before_update on public.profiles;
create trigger protect_profile_privileges_before_update
before update on public.profiles
for each row execute function public.protect_profile_privileges();

-- Audit current elevated accounts. Review this result after running.
select manager_name, account_role, creator_verified
from public.profiles
where account_role <> 'user' or creator_verified = true
order by account_role, manager_name;
