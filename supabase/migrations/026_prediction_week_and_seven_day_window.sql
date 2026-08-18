-- Fantasy MPL — nearest competition week and seven-day match windows
-- Run after 025_live_admin_overview_and_mvp.sql

create or replace function public.validate_match_prediction_window()
returns trigger language plpgsql security invoker set search_path='' as $$
declare fixture public.matches;
begin
 select * into fixture from public.matches where id=new.match_id;
 if not found then raise exception 'Match not found'; end if;
 if fixture.status<>'scheduled' then raise exception 'Predictions are unavailable for this match'; end if;
 if now()<fixture.scheduled_at-interval '7 days' then raise exception 'Predictions open seven days before match time'; end if;
 if now()>=fixture.scheduled_at then raise exception 'Predictions are locked for this match'; end if;
 return new;
end $$;

drop policy if exists "users create unlocked match predictions" on public.match_predictions;
create policy "users create unlocked match predictions" on public.match_predictions for insert to authenticated with check(
 (select auth.uid())=user_id and exists(select 1 from public.matches m where m.id=match_id and m.status='scheduled'
 and now()>=m.scheduled_at-interval '7 days' and now()<m.scheduled_at
 and predicted_winner_team_id in(m.home_team_id,m.away_team_id)));

drop policy if exists "users update unlocked match predictions" on public.match_predictions;
create policy "users update unlocked match predictions" on public.match_predictions for update to authenticated using(
 (select auth.uid())=user_id and exists(select 1 from public.matches m where m.id=match_id and m.status='scheduled'
 and now()>=m.scheduled_at-interval '7 days' and now()<m.scheduled_at)) with check(
 (select auth.uid())=user_id and exists(select 1 from public.matches m where m.id=match_id and m.status='scheduled'
 and now()>=m.scheduled_at-interval '7 days' and now()<m.scheduled_at
 and predicted_winner_team_id in(m.home_team_id,m.away_team_id)));

select to_regprocedure('public.validate_match_prediction_window()') is not null as seven_day_window_ready;
