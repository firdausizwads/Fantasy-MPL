-- Fantasy MPL — official regional weekly fantasy contest
-- Run after 026_prediction_week_and_seven_day_window.sql

create table if not exists public.regional_fantasy_lineups(
 id uuid primary key default gen_random_uuid(),user_id uuid not null references auth.users(id) on delete cascade,
 week_id uuid not null references public.competition_weeks(id) on delete cascade,captain_player_id uuid references public.players(id),
 status text not null default 'draft' check(status in('draft','submitted','locked','scored')),submitted_at timestamptz,locked_at timestamptz,
 created_at timestamptz not null default now(),updated_at timestamptz not null default now(),unique(user_id,week_id));
create table if not exists public.regional_fantasy_lineup_players(
 id uuid primary key default gen_random_uuid(),lineup_id uuid not null references public.regional_fantasy_lineups(id) on delete cascade,
 player_id uuid not null references public.players(id),team_id uuid not null references public.teams(id),slot_role text not null check(slot_role in('EXP','JUNGLE','MID','GOLD','ROAM')),
 created_at timestamptz not null default now(),unique(lineup_id,player_id),unique(lineup_id,team_id),unique(lineup_id,slot_role));
alter table public.regional_fantasy_lineups enable row level security;alter table public.regional_fantasy_lineup_players enable row level security;
create policy "users read own regional fantasy lineup" on public.regional_fantasy_lineups for select to authenticated using((select auth.uid())=user_id);
create policy "users read own regional fantasy players" on public.regional_fantasy_lineup_players for select to authenticated using(exists(select 1 from public.regional_fantasy_lineups l where l.id=lineup_id and l.user_id=(select auth.uid())));
create policy "admins read regional fantasy lineups" on public.regional_fantasy_lineups for select to authenticated using((select public.is_platform_admin()));
create policy "admins read regional fantasy players" on public.regional_fantasy_lineup_players for select to authenticated using((select public.is_platform_admin()));
grant select on public.regional_fantasy_lineups,public.regional_fantasy_lineup_players to authenticated;

create or replace function public.current_regional_fantasy_week(target_region text)
returns uuid language sql stable security definer set search_path='' as $$
 select coalesce(
  (select m.week_id from public.matches m join public.seasons s on s.id=m.season_id where s.region_code=target_region and s.season_number=18 and m.status='scheduled' and m.scheduled_at>=now() order by m.scheduled_at limit 1),
  (select w.id from public.competition_weeks w join public.seasons s on s.id=w.season_id where s.region_code=target_region and s.season_number=18 order by w.starts_at desc limit 1)
 );
$$;
create or replace function public.save_regional_fantasy_lineup(target_week uuid,target_captain uuid,selections jsonb)
returns uuid language plpgsql security definer set search_path='' as $$
declare uid uuid:=(select auth.uid());lineup_uuid uuid;item jsonb;season_uuid uuid;deadline timestamptz;player_team uuid;player_role text;roles text[]:='{}';teams uuid[]:='{}';players uuid[]:='{}';
begin
 if uid is null then raise exception 'Authentication required';end if;if jsonb_typeof(selections)<>'array' or jsonb_array_length(selections)<>5 then raise exception 'Exactly five players are required';end if;
 select season_id into season_uuid from public.competition_weeks where id=target_week;if season_uuid is null then raise exception 'Week not found';end if;
 select min(scheduled_at) into deadline from public.matches where week_id=target_week and status<>'cancelled';if deadline is null then raise exception 'Fantasy deadline unavailable';end if;if now()>=deadline then raise exception 'Fantasy lineup is locked';end if;
 for item in select value from jsonb_array_elements(selections) loop
  select sr.team_id,sr.role into player_team,player_role from public.season_rosters sr where sr.season_id=season_uuid and sr.player_id=(item->>'player_id')::uuid and sr.active=true limit 1;
  if player_team is null or player_role<>(item->>'role') then raise exception 'Player role or team is invalid';end if;
  if player_role=any(roles) or player_team=any(teams) or (item->>'player_id')::uuid=any(players) then raise exception 'Roles, teams and players must be unique';end if;
  roles:=array_append(roles,player_role);teams:=array_append(teams,player_team);players:=array_append(players,(item->>'player_id')::uuid);
 end loop;
 if not target_captain=any(players) then raise exception 'Captain must be selected in the lineup';end if;
 insert into public.regional_fantasy_lineups(user_id,week_id,captain_player_id,status,submitted_at)
 values(uid,target_week,target_captain,'submitted',now()) on conflict(user_id,week_id) do update set captain_player_id=excluded.captain_player_id,status='submitted',submitted_at=now(),updated_at=now() returning id into lineup_uuid;
 delete from public.regional_fantasy_lineup_players where lineup_id=lineup_uuid;
 for item in select value from jsonb_array_elements(selections) loop
  select team_id into player_team from public.season_rosters where season_id=season_uuid and player_id=(item->>'player_id')::uuid and active=true limit 1;
  insert into public.regional_fantasy_lineup_players(lineup_id,player_id,team_id,slot_role) values(lineup_uuid,(item->>'player_id')::uuid,player_team,item->>'role');
 end loop;return lineup_uuid;
end $$;

create or replace function public.score_week_regional_fantasy(target_week uuid)
returns table(lineups_scored integer,transactions_created integer) language plpgsql security definer set search_path='' as $$
declare w public.competition_weeks;s public.seasons;l record;p record;base numeric;pts numeric;killp numeric;assistp numeric;mult numeric;lc integer:=0;tc integer:=0;
begin
 if not public.is_platform_admin() then raise exception 'Not authorized';end if;select * into w from public.competition_weeks where id=target_week;select * into s from public.seasons where id=w.season_id;
 killp:=public.fantasy_rule(s.id,'kill',3);assistp:=public.fantasy_rule(s.id,'assist',1);mult:=public.fantasy_rule(s.id,'captain_multiplier',2);
 for l in select * from public.regional_fantasy_lineups where week_id=target_week and status in('submitted','locked') loop
  for p in select lp.*,pl.handle from public.regional_fantasy_lineup_players lp join public.players pl on pl.id=lp.player_id where lp.lineup_id=l.id loop
   select coalesce(sum(st.kills*killp+st.assists*assistp),0) into base from public.player_match_stats st join public.matches m on m.id=st.match_id where st.player_id=p.player_id and m.week_id=target_week and m.result_state in('verified','finalized');pts:=case when l.captain_player_id=p.player_id then base*mult else base end;
   if pts<>0 and not exists(select 1 from public.score_transactions where source_table='regional_fantasy_lineup_players' and source_id=p.id) then insert into public.score_transactions(user_id,season_id,region_code,week_id,category,points,reason_code,description,source_table,source_id) values(l.user_id,s.id,s.region_code,target_week,'fantasy',pts,case when l.captain_player_id=p.player_id then 'fantasy_captain' else 'fantasy_player' end,p.slot_role||' · '||p.handle,'regional_fantasy_lineup_players',p.id);tc:=tc+1;end if;
  end loop;update public.regional_fantasy_lineups set status='scored',locked_at=coalesce(locked_at,now()),updated_at=now() where id=l.id;lc:=lc+1;
 end loop;return query select lc,tc;
end $$;

grant execute on function public.current_regional_fantasy_week(text) to authenticated;
grant execute on function public.save_regional_fantasy_lineup(uuid,uuid,jsonb) to authenticated;
grant execute on function public.score_week_regional_fantasy(uuid) to authenticated;
select to_regprocedure('public.save_regional_fantasy_lineup(uuid,uuid,jsonb)') is not null as regional_fantasy_ready;
