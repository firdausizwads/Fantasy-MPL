-- Migration 035: Player Scores Leaderboard RPC
-- Aggregates verified player statistics (KDA and games) to rank pro players by fantasy points.
-- Official scoring rule: Kills * 3 + Assists * 1.
-- Bench substitutes who Did Not Play (DNP) remain strictly at 0 fantasy points.

drop function if exists public.get_player_scores_leaderboard(text, uuid);

create or replace function public.get_player_scores_leaderboard(
  target_region text default null,
  target_week uuid default null
)
returns table (
  player_id uuid,
  handle text,
  photo_url text,
  role text,
  team_id uuid,
  team_code text,
  team_name text,
  team_logo_url text,
  region_code text,
  matches_played bigint,
  kills bigint,
  deaths bigint,
  assists bigint,
  fantasy_score bigint,
  kda_ratio numeric
)
language sql
stable
security definer
set search_path = ''
as $func$
  select
    p.id as player_id,
    p.handle,
    p.photo_url,
    coalesce(sr.role, 'FLEX') as role,
    t.id as team_id,
    t.code as team_code,
    t.name as team_name,
    t.logo_url as team_logo_url,
    s.region_code,
    count(distinct pms.match_id) as matches_played,
    coalesce(sum(pms.kills), 0)::bigint as kills,
    coalesce(sum(pms.deaths), 0)::bigint as deaths,
    coalesce(sum(pms.assists), 0)::bigint as assists,
    coalesce(sum((pms.kills * 3) + (pms.assists * 1)), 0)::bigint as fantasy_score,
    case
      when coalesce(sum(pms.deaths), 0) = 0 then
        round(coalesce(sum(pms.kills + pms.assists), 0)::numeric, 2)
      else
        round((coalesce(sum(pms.kills + pms.assists), 0)::numeric / nullif(sum(pms.deaths), 0)::numeric), 2)
    end as kda_ratio
  from public.player_match_stats pms
  join public.matches m on m.id = pms.match_id
  join public.seasons s on s.id = m.season_id
  join public.players p on p.id = pms.player_id
  join public.teams t on t.id = pms.team_id
  left join public.season_rosters sr on sr.season_id = s.id and sr.player_id = p.id and sr.team_id = t.id
  where
    (target_region is null or s.region_code = target_region)
    and (target_week is null or m.week_id = target_week)
  group by
    p.id,
    p.handle,
    p.photo_url,
    sr.role,
    t.id,
    t.code,
    t.name,
    t.logo_url,
    s.region_code
  having
    coalesce(sum((pms.kills * 3) + (pms.assists * 1)), 0) > 0 or count(distinct pms.match_id) > 0
  order by
    fantasy_score desc,
    kills desc,
    assists desc,
    handle asc;
$func$;

grant execute on function public.get_player_scores_leaderboard(text, uuid) to anon, authenticated;
