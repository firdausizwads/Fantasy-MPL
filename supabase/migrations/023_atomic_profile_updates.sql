-- Fantasy MPL — atomic self-service profile updates
-- Run after 022_regional_operations_and_leaderboard_snapshots.sql

create or replace function public.update_my_profile(
  new_manager_name text,
  new_country_code text,
  new_bio text,
  new_avatar_url text,
  new_full_name text,
  new_address text,
  new_date_of_birth date
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_user_id uuid := (select auth.uid());
  clean_manager text := trim(coalesce(new_manager_name,''));
  clean_full_name text := trim(coalesce(new_full_name,''));
  clean_country text := upper(trim(coalesce(new_country_code,'')));
begin
  if current_user_id is null then raise exception 'Authentication required'; end if;
  if char_length(clean_manager) < 3 or char_length(clean_manager) > 40 then raise exception 'Manager name must contain 3 to 40 characters'; end if;
  if char_length(clean_full_name) < 3 or char_length(clean_full_name) > 100 then raise exception 'Full name must contain 3 to 100 characters'; end if;
  if clean_country not in ('MY','ID','PH','SG','BN','TH','VN','KH','MM','LA','OTHER') then raise exception 'Unsupported country'; end if;
  if char_length(coalesce(new_bio,'')) > 180 then raise exception 'Bio must not exceed 180 characters'; end if;
  if char_length(coalesce(new_address,'')) > 300 then raise exception 'Address must not exceed 300 characters'; end if;
  if new_date_of_birth is not null and new_date_of_birth > current_date then raise exception 'Date of birth cannot be in the future'; end if;

  update public.profiles set
    manager_name=clean_manager,
    country_code=clean_country,
    bio=nullif(trim(new_bio),''),
    avatar_url=nullif(trim(new_avatar_url),'')
  where id=current_user_id;
  if not found then raise exception 'Public profile not found'; end if;

  insert into public.profile_private (user_id,full_name,address,date_of_birth)
  values (current_user_id,clean_full_name,nullif(trim(new_address),''),new_date_of_birth)
  on conflict (user_id) do update set
    full_name=excluded.full_name,
    address=excluded.address,
    date_of_birth=excluded.date_of_birth,
    updated_at=now();

  return jsonb_build_object(
    'saved',true,'manager_name',clean_manager,'country_code',clean_country,
    'bio',nullif(trim(new_bio),''),'avatar_url',nullif(trim(new_avatar_url),''),
    'full_name',clean_full_name,'address',nullif(trim(new_address),''),
    'date_of_birth',new_date_of_birth,'saved_at',now()
  );
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
      'full_name',pp.full_name,'address',pp.address,'date_of_birth',pp.date_of_birth
    ) from public.profile_private pp where pp.user_id=(select auth.uid())),
    'memberships',coalesce((select jsonb_agg(rm.region_code order by rm.joined_at)
      from public.region_memberships rm where rm.user_id=(select auth.uid())),'[]'::jsonb)
  );
$$;

revoke all on function public.update_my_profile(text,text,text,text,text,text,date) from public,anon;
revoke all on function public.my_account_bootstrap() from public,anon;
grant execute on function public.update_my_profile(text,text,text,text,text,text,date) to authenticated;
grant execute on function public.my_account_bootstrap() to authenticated;

select
  to_regprocedure('public.update_my_profile(text,text,text,text,text,text,date)') is not null as atomic_profile_save_ready,
  to_regprocedure('public.my_account_bootstrap()') is not null as account_bootstrap_ready;
