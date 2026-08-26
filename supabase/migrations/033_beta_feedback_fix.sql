-- Migration 033: Beta Feedback Function Drop and Replace
-- Fixes PostgreSQL error 42P13 by dropping existing function signature before recreating it.

drop function if exists public.submit_beta_feedback(text, text, text, text, text, text, text, text, text, boolean) cascade;
drop function if exists public.submit_beta_feedback(text, integer, text, text, text) cascade;
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
returns jsonb
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

  return jsonb_build_object('status', 'success', 'id', v_id);
end;
$$;

revoke all on function public.submit_beta_feedback(text, text, text, text, text, text, text, text, text, boolean) from public, anon;
grant execute on function public.submit_beta_feedback(text, text, text, text, text, text, text, text, text, boolean) to authenticated;

select
  to_regprocedure('public.submit_beta_feedback(text,text,text,text,text,text,text,text,text,boolean)') is not null as feedback_rpc_ready;
