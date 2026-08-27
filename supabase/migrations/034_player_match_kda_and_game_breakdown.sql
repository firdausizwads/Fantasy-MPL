-- Migration 034: Add Deaths and Game-by-Game Breakdown to Player Match Statistics
-- Enables full KDA (Kills, Deaths, Assists) tracking and per-game series breakdown (Game 1, Game 2, Game 3)

-- 1. Add columns to public.player_match_stats if they do not exist
alter table public.player_match_stats 
  add column if not exists deaths integer not null default 0 check (deaths >= 0);

alter table public.player_match_stats 
  add column if not exists games jsonb default '[]'::jsonb;

comment on column public.player_match_stats.deaths is 'Total deaths accumulated across the match series';
comment on column public.player_match_stats.games is 'Per-game breakdown JSON array containing game number, kills, deaths, assists, and hero played';

-- 2. Enhanced admin_upsert_player_stat function supporting death_count and games_breakdown
create or replace function public.admin_upsert_player_stat(
  target_match uuid,
  target_player uuid,
  target_team uuid,
  kill_count integer,
  assist_count integer,
  death_count integer default 0,
  games_breakdown jsonb default '[]'::jsonb
)
returns public.player_match_stats
language plpgsql
security definer
set search_path = ''
as $$
declare
  m public.matches;
  result public.player_match_stats;
begin
  if not public.is_platform_admin() then
    raise exception 'Not authorized';
  end if;

  select * into m from public.matches where id = target_match;
  if not found then raise exception 'Match not found'; end if;
  if target_team not in (m.home_team_id, m.away_team_id) then
    raise exception 'Team did not play in this match';
  end if;

  insert into public.player_match_stats
    (match_id, player_id, team_id, kills, assists, deaths, games, entered_by)
  values
    (target_match, target_player, target_team, kill_count, assist_count, coalesce(death_count, 0), coalesce(games_breakdown, '[]'::jsonb), (select auth.uid()))
  on conflict (match_id, player_id) do update set
    team_id = excluded.team_id,
    kills = excluded.kills,
    assists = excluded.assists,
    deaths = excluded.deaths,
    games = excluded.games,
    entered_by = excluded.entered_by
  returning * into result;

  return result;
end;
$$;

-- 3. Overloaded wrapper preserving backward compatibility with 5-parameter callers
create or replace function public.admin_upsert_player_stat(
  target_match uuid,
  target_player uuid,
  target_team uuid,
  kill_count integer,
  assist_count integer
)
returns public.player_match_stats
language plpgsql
security definer
set search_path = ''
as $$
begin
  return public.admin_upsert_player_stat(
    target_match,
    target_player,
    target_team,
    kill_count,
    assist_count,
    0,
    '[]'::jsonb
  );
end;
$$;
