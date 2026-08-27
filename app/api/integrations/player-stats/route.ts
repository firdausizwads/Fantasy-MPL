import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import type { Database } from '../../../../lib/supabase/database.types';

export const dynamic = 'force-dynamic';

interface PlayerGameStat {
  game: number;
  kills: number;
  deaths: number;
  assists: number;
}

interface PlayerResolvedStat {
  player_id: string;
  handle: string;
  role: string;
  team_id: string;
  team_code: string;
  is_starter: boolean;
  played: boolean;
  kills: number;
  deaths: number;
  assists: number;
  kda: string;
  games: PlayerGameStat[];
}

// Deterministic lane stats generator for starting 5 players only
function generateRealisticLaneStats(
  handle: string,
  role: string,
  teamWonGame: boolean,
  gameNumber: number,
  matchSeed: number
): PlayerGameStat {
  let hash = matchSeed * 31 + gameNumber * 17;
  for (let i = 0; i < handle.length; i++) {
    hash = (hash * 33 + handle.charCodeAt(i)) % 10000;
  }

  let kills = 0;
  let deaths = 0;
  let assists = 0;

  const roleUpper = (role || 'MID').toUpperCase();
  if (roleUpper === 'JUNGLE') {
    kills = teamWonGame ? 4 + (hash % 5) : 1 + (hash % 3);
    deaths = teamWonGame ? hash % 3 : 2 + (hash % 4);
    assists = 3 + (hash % 6);
  } else if (roleUpper === 'GOLD') {
    kills = teamWonGame ? 5 + (hash % 6) : 1 + (hash % 4);
    deaths = teamWonGame ? hash % 3 : 2 + (hash % 4);
    assists = 2 + (hash % 5);
  } else if (roleUpper === 'MID') {
    kills = teamWonGame ? 2 + (hash % 4) : hash % 3;
    deaths = teamWonGame ? 1 + (hash % 3) : 2 + (hash % 4);
    assists = teamWonGame ? 6 + (hash % 7) : 2 + (hash % 5);
  } else if (roleUpper === 'ROAM') {
    kills = hash % 2;
    deaths = teamWonGame ? 1 + (hash % 3) : 3 + (hash % 5);
    assists = teamWonGame ? 7 + (hash % 8) : 3 + (hash % 5);
  } else {
    // EXP
    kills = teamWonGame ? 2 + (hash % 4) : 1 + (hash % 3);
    deaths = teamWonGame ? 1 + (hash % 3) : 2 + (hash % 4);
    assists = 3 + (hash % 5);
  }

  return { game: gameNumber, kills, deaths, assists };
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json().catch(() => ({}));
    const matchId = body.match_id;

    if (!matchId) {
      return NextResponse.json({ error: 'match_id is required' }, { status: 400 });
    }

    const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;

    if (!url || !serviceRoleKey) {
      return NextResponse.json({ error: 'Supabase server configuration incomplete' }, { status: 503 });
    }

    const client = createClient<Database>(url, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false }
    });

    // 1. Fetch match info
    const { data: match, error: matchError } = await client
      .from('matches')
      .select('id,scheduled_at,best_of,status,home_score,away_score,home_team_id,away_team_id,home:teams!matches_home_team_id_fkey(code,name),away:teams!matches_away_team_id_fkey(code,name)')
      .eq('id', matchId)
      .maybeSingle();

    if (matchError || !match) {
      return NextResponse.json({ error: matchError?.message || 'Match not found' }, { status: 404 });
    }

    const homeTeam = Array.isArray(match.home) ? match.home[0] : match.home;
    const awayTeam = Array.isArray(match.away) ? match.away[0] : match.away;
    const homeCode = homeTeam?.code || 'HOME';
    const awayCode = awayTeam?.code || 'AWAY';

    // 2. Fetch active players for both teams
    const { data: rosters, error: rosterError } = await client
      .from('season_rosters')
      .select('player_id,role,team_id,players(id,handle)')
      .in('team_id', [match.home_team_id, match.away_team_id])
      .eq('active', true)
      .in('role', ['EXP', 'JUNGLE', 'MID', 'GOLD', 'ROAM']);

    if (rosterError || !rosters || rosters.length === 0) {
      return NextResponse.json({ error: 'Could not load team rosters for match' }, { status: 404 });
    }

    // Determine series score (use existing or standard Bo3)
    let homeScore = match.home_score ?? 2;
    let awayScore = match.away_score ?? 1;
    if (match.home_score === null && match.away_score === null) {
      homeScore = 2;
      awayScore = 1;
    }
    const totalGames = Math.max(2, Math.min(5, homeScore + awayScore));

    // Determine game winners based on scores
    const gameWinners: boolean[] = [];
    let hWins = 0;
    let aWins = 0;
    for (let g = 1; g <= totalGames; g++) {
      if (hWins < homeScore && aWins < awayScore) {
        const homeWinsThis = g % 2 === 1;
        gameWinners.push(homeWinsThis);
        if (homeWinsThis) hWins++; else aWins++;
      } else if (hWins < homeScore) {
        gameWinners.push(true);
        hWins++;
      } else {
        gameWinners.push(false);
        aWins++;
      }
    }

    const matchSeed = Math.abs(match.id.split('-').reduce((acc, part) => acc + parseInt(part, 16) || 1, 0));

    // CRITICAL: Filter exactly 5 starters per team (1 EXP, 1 JUNGLE, 1 MID, 1 GOLD, 1 ROAM).
    // Any bench/reserve players with duplicate roles MUST have played = false and 0 stats!
    const roleOrder = ['EXP', 'JUNGLE', 'MID', 'GOLD', 'ROAM'];

    const homeAssignedRoles = new Set<string>();
    const awayAssignedRoles = new Set<string>();

    const resolvedStats: PlayerResolvedStat[] = [];

    // Sort to prioritize consistent primary starter selection
    const sortedRosters = [...rosters].sort((a, b) => {
      const rA = roleOrder.indexOf(a.role);
      const rB = roleOrder.indexOf(b.role);
      if (rA !== rB) return rA - rB;
      return (a.players?.handle || '').localeCompare(b.players?.handle || '');
    });

    for (const r of sortedRosters) {
      const handle = r.players?.handle || 'PLAYER';
      const isHome = r.team_id === match.home_team_id;
      const teamCode = isHome ? homeCode : awayCode;
      const roleSet = isHome ? homeAssignedRoles : awayAssignedRoles;

      // Only the first player for each lane role is a starter
      const isStarter = !roleSet.has(r.role);
      if (isStarter) {
        roleSet.add(r.role);
      }

      if (isStarter) {
        // Starters get realistic game stats
        const games: PlayerGameStat[] = [];
        let totalKills = 0;
        let totalDeaths = 0;
        let totalAssists = 0;

        for (let g = 1; g <= totalGames; g++) {
          const teamWon = isHome ? gameWinners[g - 1] : !gameWinners[g - 1];
          const gStat = generateRealisticLaneStats(handle, r.role, teamWon, g, matchSeed);
          games.push(gStat);
          totalKills += gStat.kills;
          totalDeaths += gStat.deaths;
          totalAssists += gStat.assists;
        }

        const kdaRatio = totalDeaths === 0 
          ? `${(totalKills + totalAssists).toFixed(1)} (Perfect)` 
          : ((totalKills + totalAssists) / totalDeaths).toFixed(2);

        resolvedStats.push({
          player_id: r.player_id,
          handle,
          role: r.role,
          team_id: r.team_id,
          team_code: teamCode,
          is_starter: true,
          played: true,
          kills: totalKills,
          deaths: totalDeaths,
          assists: totalAssists,
          kda: kdaRatio,
          games
        });
      } else {
        // Bench/Substitute players: Strictly 0 stats / DNP!
        const games: PlayerGameStat[] = [];
        for (let g = 1; g <= totalGames; g++) {
          games.push({ game: g, kills: 0, deaths: 0, assists: 0 });
        }

        resolvedStats.push({
          player_id: r.player_id,
          handle,
          role: r.role,
          team_id: r.team_id,
          team_code: teamCode,
          is_starter: false,
          played: false, // Did Not Play
          kills: 0,
          deaths: 0,
          assists: 0,
          kda: 'DNP',
          games
        });
      }
    }

    return NextResponse.json({
      ok: true,
      match_id: match.id,
      home_code: homeCode,
      away_code: awayCode,
      home_score: homeScore,
      away_score: awayScore,
      total_games: totalGames,
      is_simulated: true,
      source: 'Official Starting 5 Preset (Substitutes Locked to 0 / DNP)',
      warning: 'Stats were generated from lane-role starting presets. Substitutes are set to 0 (DNP). Please verify against official post-match scoreboard before saving.',
      players: resolvedStats
    });
  } catch (error) {
    return NextResponse.json({
      error: error instanceof Error ? error.message : 'Failed to fetch player stats'
    }, { status: 500 });
  }
}
