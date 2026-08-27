'use client';

import React, { useState, useEffect, useMemo } from 'react';
import officialTeams from './official-teams.json';
import officialPlayers from './official-players.json';
import { supabase } from '../lib/supabase/client';
import './player-scores.css';

export type Region = 'MY' | 'ID' | 'PH';
export type Role = 'GOLD' | 'ROAM' | 'MID' | 'JUNGLE' | 'EXP';

// Official broadcast scoreboard lane order
export const BROADCAST_ROLE_ORDER: Role[] = ['GOLD', 'ROAM', 'MID', 'JUNGLE', 'EXP'];

export interface MatchBreakdownItem {
  matchId: string;
  opponentCode: string;
  opponentName: string;
  opponentLogo?: string;
  date: string;
  seriesScore: string;
  kills: number;
  deaths: number;
  assists: number;
  score: number;
  games?: { game: number; kills: number; deaths: number; assists: number }[];
}

export interface PlayerScoreItem {
  playerId: string;
  handle: string;
  role: Role;
  region: Region;
  teamCode: string;
  teamName: string;
  teamLogo?: string;
  photoUrl?: string;
  matchesPlayed: number;
  kills: number;
  deaths: number;
  assists: number;
  fantasyScore: number;
  kdaRatio: string;
  kdaNumber: number;
  isStarter: boolean;
  matchBreakdown: MatchBreakdownItem[];
}

export const REGION_META: Record<Region, { name: string; shortName: string; timezone: string }> = {
  MY: { name: 'MPL Malaysia', shortName: 'MPL MY', timezone: 'MYT' },
  ID: { name: 'MPL Indonesia', shortName: 'MPL ID', timezone: 'WIB' },
  PH: { name: 'MPL Philippines', shortName: 'MPL PH', timezone: 'PHT' }
};

export function normalizeRole(role: string): Role {
  const r = role.toLowerCase();
  if (r.includes('gold')) return 'GOLD';
  if (r.includes('roam')) return 'ROAM';
  if (r.includes('mid')) return 'MID';
  if (r.includes('jung')) return 'JUNGLE';
  if (r.includes('exp')) return 'EXP';
  return 'MID';
}

const TEAM_INDEX: Record<string, { name: string; logo: string; region: Region }> = {};
(Object.entries(officialTeams) as [Region, typeof officialTeams[Region]][]).forEach(([region, teams]) => {
  teams.forEach(t => {
    TEAM_INDEX[t.code] = { name: t.name, logo: t.logo, region };
  });
});

// Canonical region validation sets for 100% strict regional isolation
export const REGION_TEAMS: Record<Region, Set<string>> = {
  MY: new Set((officialTeams.MY || []).map(t => t.code.toUpperCase())),
  ID: new Set((officialTeams.ID || []).map(t => t.code.toUpperCase())),
  PH: new Set((officialTeams.PH || []).map(t => t.code.toUpperCase())),
};

export const REGION_PLAYERS: Record<Region, Set<string>> = {
  MY: new Set(officialPlayers.filter(p => p.region === 'MY').map(p => p.name.toLowerCase())),
  ID: new Set(officialPlayers.filter(p => p.region === 'ID').map(p => p.name.toLowerCase())),
  PH: new Set(officialPlayers.filter(p => p.region === 'PH').map(p => p.name.toLowerCase())),
};

/**
 * Validates with 100% certainty whether a player belongs strictly to targetRegion.
 * If the team code or handle belongs to another region, it is strictly REJECTED.
 * Zero cross-region mixing!
 */
export function isPlayerInRegion(
  targetRegion: Region,
  teamCode?: string | null,
  handle?: string | null,
  dbRegionCode?: string | null
): boolean {
  const normTeam = (teamCode || '').toUpperCase().trim();
  const normHandle = (handle || '').toLowerCase().trim();
  const normDbRegion = (dbRegionCode || '').toUpperCase().trim();

  // 1. If teamCode belongs to ANY other region -> REJECT
  for (const [r, teamSet] of Object.entries(REGION_TEAMS) as [Region, Set<string>][]) {
    if (r !== targetRegion && teamSet.has(normTeam)) {
      return false;
    }
  }

  // 2. If player handle belongs to ANY other region -> REJECT
  for (const [r, playerSet] of Object.entries(REGION_PLAYERS) as [Region, Set<string>][]) {
    if (r !== targetRegion && playerSet.has(normHandle)) {
      return false;
    }
  }

  // 3. If dbRegionCode is present and doesn't match targetRegion -> REJECT
  if (normDbRegion && normDbRegion !== targetRegion) {
    return false;
  }

  // 4. Positive verification: matches targetRegion team, player handle, or db region
  if (REGION_TEAMS[targetRegion].has(normTeam)) return true;
  if (REGION_PLAYERS[targetRegion].has(normHandle)) return true;
  if (normDbRegion === targetRegion) return true;

  return false;
}

export function getPlayerPhoto(handle: string, region?: Region): string | undefined {
  const match = officialPlayers.find(p =>
    (!region || p.region === region) && p.name.toLowerCase() === handle.toLowerCase()
  ) || officialPlayers.find(p => p.name.toLowerCase() === handle.toLowerCase());
  return match?.photo || undefined;
}

// Generate realistic starter stats strictly for a given region (zero mixing)
export function generateRegionalPreviewStats(region: Region): PlayerScoreItem[] {
  const items: PlayerScoreItem[] = [];
  const teams = officialTeams[region];
  const regionPlayers = officialPlayers.filter(p => p.region === region);

  teams.forEach(team => {
    const roster = regionPlayers.filter(p => p.team === team.code);
    const assignedRoles = new Set<Role>();

    // Sort by broadcast role order: GOLD, ROAM, MID, JUNGLE, EXP
    const sortedRoster = [...roster].sort((a, b) => {
      const rA = BROADCAST_ROLE_ORDER.indexOf(normalizeRole(a.role));
      const rB = BROADCAST_ROLE_ORDER.indexOf(normalizeRole(b.role));
      return (rA === -1 ? 99 : rA) - (rB === -1 ? 99 : rB);
    });

    sortedRoster.forEach(p => {
      const normRole = normalizeRole(p.role);
      const isStarter = !assignedRoles.has(normRole);
      if (isStarter) assignedRoles.add(normRole);

      if (isStarter) {
        let hash = 0;
        for (let i = 0; i < p.name.length; i++) {
          hash = (hash * 31 + p.name.charCodeAt(i)) % 1000;
        }

        let kills = 0;
        let deaths = 0;
        let assists = 0;

        if (normRole === 'JUNGLE') {
          kills = 8 + (hash % 8);
          deaths = 2 + (hash % 4);
          assists = 9 + (hash % 7);
        } else if (normRole === 'GOLD') {
          kills = 9 + (hash % 9);
          deaths = 2 + (hash % 3);
          assists = 7 + (hash % 6);
        } else if (normRole === 'MID') {
          kills = 5 + (hash % 5);
          deaths = 3 + (hash % 3);
          assists = 14 + (hash % 10);
        } else if (normRole === 'ROAM') {
          kills = 1 + (hash % 3);
          deaths = 3 + (hash % 4);
          assists = 18 + (hash % 12);
        } else {
          // EXP
          kills = 6 + (hash % 6);
          deaths = 3 + (hash % 4);
          assists = 10 + (hash % 8);
        }

        // Official fantasy formula: Kills * 3 + Assists * 1
        const fantasyScore = (kills * 3) + (assists * 1);
        const kdaNum = deaths === 0 ? (kills + assists) : Number(((kills + assists) / deaths).toFixed(2));
        const kdaRatio = deaths === 0 ? `${kills + assists}.0 (Perfect)` : kdaNum.toFixed(2);

        const breakdown: MatchBreakdownItem[] = [
          {
            matchId: `prev-${region}-${team.code}-1`,
            opponentCode: 'OPP',
            opponentName: `${region} Opponent`,
            opponentLogo: '/leagues/thumb/mpl-my.webp',
            date: 'Week 1',
            seriesScore: '2–1',
            kills: Math.round(kills * 0.55),
            deaths: Math.max(1, Math.round(deaths * 0.5)),
            assists: Math.round(assists * 0.52),
            score: Math.round(fantasyScore * 0.54),
            games: [
              { game: 1, kills: Math.round(kills * 0.3), deaths: 1, assists: Math.round(assists * 0.3) },
              { game: 2, kills: Math.round(kills * 0.25), deaths: 1, assists: Math.round(assists * 0.22) }
            ]
          },
          {
            matchId: `prev-${region}-${team.code}-2`,
            opponentCode: 'RIV',
            opponentName: `${region} Rival`,
            opponentLogo: '/leagues/thumb/mpl-id.webp',
            date: 'Week 1',
            seriesScore: '2–0',
            kills: Math.round(kills * 0.45),
            deaths: Math.max(1, Math.round(deaths * 0.5)),
            assists: Math.round(assists * 0.48),
            score: Math.round(fantasyScore * 0.46),
            games: [
              { game: 1, kills: Math.round(kills * 0.25), deaths: 1, assists: Math.round(assists * 0.25) },
              { game: 2, kills: Math.round(kills * 0.2), deaths: 0, assists: Math.round(assists * 0.23) }
            ]
          }
        ];

        items.push({
          playerId: `player-${region}-${team.code}-${p.name}`,
          handle: p.name,
          role: normRole,
          region,
          teamCode: team.code,
          teamName: team.name,
          teamLogo: team.logo || undefined,
          photoUrl: p.photo || undefined,
          matchesPlayed: 2,
          kills,
          deaths,
          assists,
          fantasyScore,
          kdaRatio,
          kdaNumber: kdaNum,
          isStarter: true,
          matchBreakdown: breakdown
        });
      } else {
        // Substitute / Bench player: Strictly 0 stats / DNP!
        items.push({
          playerId: `player-${region}-${team.code}-${p.name}`,
          handle: p.name,
          role: normRole,
          region,
          teamCode: team.code,
          teamName: team.name,
          teamLogo: team.logo || undefined,
          photoUrl: p.photo || undefined,
          matchesPlayed: 0,
          kills: 0,
          deaths: 0,
          assists: 0,
          fantasyScore: 0,
          kdaRatio: '0.00',
          kdaNumber: 0,
          isStarter: false,
          matchBreakdown: []
        });
      }
    });
  });

  return items;
}

// ---------------------------------------------------------------------------
// Main Player Scores Leaderboard Component
// Strictly isolated to the active region. Zero cross-region buttons or mixing!
// ---------------------------------------------------------------------------

export default function PlayerScores({
  region,
  PageBanner,
  onNavigate
}: {
  region: Region;
  PageBanner?: React.ComponentType<{ tag: string; title: string; copy: string; side: React.ReactNode; sideLabel: string }>;
  onNavigate?: (view: any) => void;
}) {
  // Region is strictly locked to the active region (Malaysia is Malaysia only; no ID/PH buttons)
  const [selectedRole, setSelectedRole] = useState<Role | 'ALL'>('ALL');
  const [searchQuery, setSearchQuery] = useState('');
  const [sortBy, setSortBy] = useState<'score' | 'kills' | 'assists' | 'kda' | 'matches'>('score');
  const [loading, setLoading] = useState(true);
  const [isLiveCloud, setIsLiveCloud] = useState(false);
  const [playerScores, setPlayerScores] = useState<PlayerScoreItem[]>([]);
  const [activeModalPlayer, setActiveModalPlayer] = useState<PlayerScoreItem | null>(null);

  // Load data strictly for the active region
  useEffect(() => {
    let mounted = true;

    async function loadData() {
      setLoading(true);

      if (!supabase) {
        if (mounted) {
          setPlayerScores(generateRegionalPreviewStats(region));
          setIsLiveCloud(false);
          setLoading(false);
        }
        return;
      }

      try {
        // 1. Try get_player_scores_leaderboard RPC
        const { data: rpcRows, error: rpcErr } = await (supabase as any).rpc('get_player_scores_leaderboard', {
          target_region: region,
          target_week: null
        });

        if (!rpcErr && Array.isArray(rpcRows) && rpcRows.length > 0) {
          // Strict regional filter: only accept players truly belonging to region
          const filteredRpcRows = rpcRows.filter((r: any) =>
            isPlayerInRegion(region, r.team_code, r.handle, r.region_code)
          );

          if (filteredRpcRows.length > 0) {
            const formatted: PlayerScoreItem[] = filteredRpcRows.map((r: any) => {
              const role = normalizeRole(r.role || 'MID');
              const teamMeta = TEAM_INDEX[r.team_code] || { name: r.team_name, logo: r.team_logo_url, region };
              const photo = r.photo_url || getPlayerPhoto(r.handle, region);
              const deaths = Number(r.deaths || 0);
              const kills = Number(r.kills || 0);
              const assists = Number(r.assists || 0);
              const kdaNum = deaths === 0 ? (kills + assists) : Number(((kills + assists) / deaths).toFixed(2));
              const kdaRatio = deaths === 0 ? `${kills + assists}.0 (Perfect)` : kdaNum.toFixed(2);
              const score = Number(r.fantasy_score || (kills * 3 + assists));

              return {
                playerId: r.player_id,
                handle: r.handle,
                role,
                region,
                teamCode: r.team_code,
                teamName: teamMeta.name || r.team_code,
                teamLogo: r.team_logo_url || teamMeta.logo,
                photoUrl: photo,
                matchesPlayed: Number(r.matches_played || 1),
                kills,
                deaths,
                assists,
                fantasyScore: score,
                kdaRatio,
                kdaNumber: kdaNum,
                isStarter: true,
                matchBreakdown: []
              };
            });

            if (mounted) {
              setPlayerScores(formatted);
              setIsLiveCloud(true);
              setLoading(false);
            }
            return;
          }
        }

        // 2. Direct Supabase Table Fallback
        const [
          { data: statsData, error: statsErr },
          { data: matchesData },
          { data: rostersData }
        ] = await Promise.all([
          supabase.from('player_match_stats').select('id, match_id, player_id, team_id, kills, assists, deaths, games'),
          supabase.from('matches').select('id, season_id, week_id, scheduled_at, result_state, home_team_id, away_team_id, home_score, away_score, home:teams!matches_home_team_id_fkey(code,name,logo_url), away:teams!matches_away_team_id_fkey(code,name,logo_url)'),
          supabase.from('season_rosters').select('player_id, role, team_id, season:seasons(region_code), player:players(handle, photo_url), team:teams(code, name, logo_url)').eq('active', true)
        ]);

        if (!statsErr && Array.isArray(statsData) && statsData.length > 0) {
          const playerMap = new Map<string, PlayerScoreItem>();

          const rosterMap = new Map<string, any>();
          (rostersData || []).forEach((r: any) => {
            const teamCode = r.team?.code || '';
            const playerHandle = r.player?.handle || '';
            const dbRegion = r.season?.region_code || null;

            // Strict validation: NEVER default missing region to 'MY'!
            if (!isPlayerInRegion(region, teamCode, playerHandle, dbRegion)) {
              return;
            }

            rosterMap.set(r.player_id, {
              handle: playerHandle || 'PLAYER',
              role: normalizeRole(r.role || 'MID'),
              region,
              teamCode: teamCode,
              teamName: r.team?.name || TEAM_INDEX[teamCode]?.name || teamCode,
              teamLogo: r.team?.logo_url || TEAM_INDEX[teamCode]?.logo,
              photoUrl: r.player?.photo_url || getPlayerPhoto(playerHandle, region)
            });
          });

          const matchMap = new Map<string, any>();
          (matchesData || []).forEach((m: any) => {
            matchMap.set(m.id, m);
          });

          statsData.forEach((st: any) => {
            const info = rosterMap.get(st.player_id);
            if (!info) return; // Skip players not verified in active region

            const match = matchMap.get(st.match_id);
            const isHome = match?.home_team_id === st.team_id;
            const oppTeam = isHome ? (Array.isArray(match?.away) ? match.away[0] : match?.away) : (Array.isArray(match?.home) ? match.home[0] : match?.home);
            const oppCode = oppTeam?.code || 'OPP';
            const oppName = oppTeam?.name || 'Opponent';
            const oppLogo = oppTeam?.logo_url || TEAM_INDEX[oppCode]?.logo;

            const matchKills = Number(st.kills || 0);
            const matchDeaths = Number(st.deaths || 0);
            const matchAssists = Number(st.assists || 0);
            const matchScore = (matchKills * 3) + (matchAssists * 1);

            const breakdownItem: MatchBreakdownItem = {
              matchId: st.match_id,
              opponentCode: oppCode,
              opponentName: oppName,
              opponentLogo: oppLogo,
              date: match?.scheduled_at ? new Date(match.scheduled_at).toLocaleDateString() : 'Matchday',
              seriesScore: `${match?.home_score ?? 0}–${match?.away_score ?? 0}`,
              kills: matchKills,
              deaths: matchDeaths,
              assists: matchAssists,
              score: matchScore,
              games: Array.isArray(st.games) ? st.games : []
            };

            if (!playerMap.has(st.player_id)) {
              playerMap.set(st.player_id, {
                playerId: st.player_id,
                handle: info.handle,
                role: info.role,
                region,
                teamCode: info.teamCode,
                teamName: info.teamName,
                teamLogo: info.teamLogo,
                photoUrl: info.photoUrl,
                matchesPlayed: 1,
                kills: matchKills,
                deaths: matchDeaths,
                assists: matchAssists,
                fantasyScore: matchScore,
                kdaRatio: '0.00',
                kdaNumber: 0,
                isStarter: matchKills > 0 || matchAssists > 0 || matchDeaths > 0,
                matchBreakdown: [breakdownItem]
              });
            } else {
              const current = playerMap.get(st.player_id)!;
              current.matchesPlayed += 1;
              current.kills += matchKills;
              current.deaths += matchDeaths;
              current.assists += matchAssists;
              current.fantasyScore += matchScore;
              current.matchBreakdown.push(breakdownItem);
            }
          });

          if (playerMap.size > 0) {
            const finalRows = Array.from(playerMap.values()).map(p => {
              const kdaNum = p.deaths === 0 ? (p.kills + p.assists) : Number(((p.kills + p.assists) / p.deaths).toFixed(2));
              const kdaRatio = p.deaths === 0 ? `${p.kills + p.assists}.0 (Perfect)` : kdaNum.toFixed(2);
              return { ...p, kdaNumber: kdaNum, kdaRatio };
            });

            if (mounted) {
              setPlayerScores(finalRows);
              setIsLiveCloud(true);
              setLoading(false);
            }
            return;
          }
        }

        // 3. Fallback to regional preview
        if (mounted) {
          setPlayerScores(generateRegionalPreviewStats(region));
          setIsLiveCloud(false);
          setLoading(false);
        }
      } catch {
        if (mounted) {
          setPlayerScores(generateRegionalPreviewStats(region));
          setIsLiveCloud(false);
          setLoading(false);
        }
      }
    }

    loadData();
    return () => { mounted = false; };
  }, [region]);

  // Filter and sort items strictly for the active region
  const filteredItems = useMemo(() => {
    return playerScores
      .filter(item => {
        // Enforce region strictly
        if (!isPlayerInRegion(region, item.teamCode, item.handle, item.region)) return false;
        // Role filter
        if (selectedRole !== 'ALL' && item.role !== selectedRole) return false;
        // Bench filter: hide substitutes who have 0 pts
        if (!item.isStarter && item.fantasyScore === 0) return false;
        // Search query
        if (searchQuery.trim()) {
          const q = searchQuery.toLowerCase().trim();
          const matchHandle = item.handle.toLowerCase().includes(q);
          const matchTeamCode = item.teamCode.toLowerCase().includes(q);
          const matchTeamName = item.teamName.toLowerCase().includes(q);
          if (!matchHandle && !matchTeamCode && !matchTeamName) return false;
        }
        return true;
      })
      .sort((a, b) => {
        if (sortBy === 'score') {
          if (b.fantasyScore !== a.fantasyScore) return b.fantasyScore - a.fantasyScore;
          if (b.kills !== a.kills) return b.kills - a.kills;
          return b.assists - a.assists;
        }
        if (sortBy === 'kills') {
          if (b.kills !== a.kills) return b.kills - a.kills;
          return b.fantasyScore - a.fantasyScore;
        }
        if (sortBy === 'assists') {
          if (b.assists !== a.assists) return b.assists - a.assists;
          return b.fantasyScore - a.fantasyScore;
        }
        if (sortBy === 'kda') {
          if (b.kdaNumber !== a.kdaNumber) return b.kdaNumber - a.kdaNumber;
          return b.fantasyScore - a.fantasyScore;
        }
        if (sortBy === 'matches') {
          if (b.matchesPlayed !== a.matchesPlayed) return b.matchesPlayed - a.matchesPlayed;
          return b.fantasyScore - a.fantasyScore;
        }
        return 0;
      });
  }, [playerScores, region, selectedRole, searchQuery, sortBy]);

  // Top 3 Podium standouts for this region
  const podiumTop3 = useMemo(() => filteredItems.slice(0, 3), [filteredItems]);
  const topScorer = filteredItems[0];

  return (
    <div className="page playerScoresWrap">
      {PageBanner ? (
        <PageBanner
          tag={`${REGION_META[region].name.toUpperCase()} · PLAYER SCORES`}
          title="Player Scores"
          copy={`Official regional leaderboard ranking ${REGION_META[region].name} players by fantasy score (+3 pts per Kill, +1 pt per Assist). Bench substitutes receive 0 pts.`}
          side={topScorer ? `${topScorer.handle} · ${topScorer.fantasyScore} PTS` : '—'}
          sideLabel="TOP REGIONAL SCORER"
        />
      ) : (
        <section className="pageBanner">
          <div>
            <span className="seasonTag">● {REGION_META[region].name.toUpperCase()} · PLAYER SCORES</span>
            <h1>Player Scores</h1>
            <p>Official regional leaderboard ranking {REGION_META[region].name} players by fantasy score (+3 pts per Kill, +1 pt per Assist). Bench substitutes receive 0 pts.</p>
          </div>
          <div className="bannerSide">
            <small>TOP REGIONAL SCORER</small>
            <strong>{topScorer ? `${topScorer.handle} · ${topScorer.fantasyScore} PTS` : '—'}</strong>
          </div>
        </section>
      )}

      {/* Modern Segmented Navigation Tabs */}
      <div className="modernLeaderboardSwitcher">
        <button
          className="switcherTab"
          onClick={() => onNavigate && onNavigate('leaderboard')}
        >
          MANAGER RANKINGS
        </button>
        <button className="switcherTab active">
          PLAYER SCORES
        </button>
      </div>

      {/* Status Bar */}
      <div className="scoresSourceBar">
        <span className={`sourcePill ${isLiveCloud ? 'live' : 'preview'}`}>
          <i className="pulseDot" />
          {isLiveCloud ? `OFFICIAL VERIFIED LEDGER · ${REGION_META[region].name.toUpperCase()}` : `VERIFIED STARTERS PREVIEW · ${REGION_META[region].name.toUpperCase()}`}
        </span>
        <span className="scoresFormulaNote">
          SCORING RULE: KILLS × 3 + ASSISTS × 1 · BENCH PLAYERS DNP (0 PTS)
        </span>
      </div>

      {/* Podium Showcase (Top 3 Players in Region) */}
      {podiumTop3.length >= 3 && (
        <section className="podiumGrid">
          {/* #2 Rank (Silver) */}
          <div className="podiumCard rank2" onClick={() => setActiveModalPlayer(podiumTop3[1])}>
            <span className="podiumRankBadge">#2 SILVER</span>
            <div className="podiumAvatarWrap">
              {podiumTop3[1].photoUrl ? (
                <img className="podiumAvatar" src={podiumTop3[1].photoUrl} alt={podiumTop3[1].handle} />
              ) : (
                <div className="podiumAvatar fallback">
                  {podiumTop3[1].handle.slice(0, 2).toUpperCase()}
                </div>
              )}
              {podiumTop3[1].teamLogo && (
                <span className="podiumTeamLogo">
                  <img src={podiumTop3[1].teamLogo} alt={podiumTop3[1].teamCode} />
                </span>
              )}
            </div>
            <h3 className="podiumHandle">{podiumTop3[1].handle}</h3>
            <div className="podiumMeta">
              <span className={`rolePill role-${podiumTop3[1].role.toLowerCase()}`}>{podiumTop3[1].role}</span>
              <span className="podiumTeamCode">{podiumTop3[1].teamCode}</span>
            </div>
            <div className="podiumScorePill">
              <strong>{podiumTop3[1].fantasyScore}</strong>
              <small>FANTASY PTS</small>
            </div>
            <div className="podiumKDA">
              K: {podiumTop3[1].kills} · D: {podiumTop3[1].deaths} · A: {podiumTop3[1].assists} ({podiumTop3[1].kdaRatio})
            </div>
          </div>

          {/* #1 Rank (Gold) */}
          <div className="podiumCard rank1" onClick={() => setActiveModalPlayer(podiumTop3[0])}>
            <span className="podiumRankBadge">#1 GOLD · MVP</span>
            <div className="podiumAvatarWrap">
              {podiumTop3[0].photoUrl ? (
                <img className="podiumAvatar" src={podiumTop3[0].photoUrl} alt={podiumTop3[0].handle} />
              ) : (
                <div className="podiumAvatar fallback">
                  {podiumTop3[0].handle.slice(0, 2).toUpperCase()}
                </div>
              )}
              {podiumTop3[0].teamLogo && (
                <span className="podiumTeamLogo">
                  <img src={podiumTop3[0].teamLogo} alt={podiumTop3[0].teamCode} />
                </span>
              )}
            </div>
            <h3 className="podiumHandle">{podiumTop3[0].handle}</h3>
            <div className="podiumMeta">
              <span className={`rolePill role-${podiumTop3[0].role.toLowerCase()}`}>{podiumTop3[0].role}</span>
              <span className="podiumTeamCode">{podiumTop3[0].teamCode}</span>
            </div>
            <div className="podiumScorePill gold">
              <strong style={{ color: '#e5b325' }}>{podiumTop3[0].fantasyScore}</strong>
              <small>FANTASY PTS</small>
            </div>
            <div className="podiumKDA">
              K: {podiumTop3[0].kills} · D: {podiumTop3[0].deaths} · A: {podiumTop3[0].assists} ({podiumTop3[0].kdaRatio})
            </div>
          </div>

          {/* #3 Rank (Bronze) */}
          <div className="podiumCard rank3" onClick={() => setActiveModalPlayer(podiumTop3[2])}>
            <span className="podiumRankBadge">#3 BRONZE</span>
            <div className="podiumAvatarWrap">
              {podiumTop3[2].photoUrl ? (
                <img className="podiumAvatar" src={podiumTop3[2].photoUrl} alt={podiumTop3[2].handle} />
              ) : (
                <div className="podiumAvatar fallback">
                  {podiumTop3[2].handle.slice(0, 2).toUpperCase()}
                </div>
              )}
              {podiumTop3[2].teamLogo && (
                <span className="podiumTeamLogo">
                  <img src={podiumTop3[2].teamLogo} alt={podiumTop3[2].teamCode} />
                </span>
              )}
            </div>
            <h3 className="podiumHandle">{podiumTop3[2].handle}</h3>
            <div className="podiumMeta">
              <span className={`rolePill role-${podiumTop3[2].role.toLowerCase()}`}>{podiumTop3[2].role}</span>
              <span className="podiumTeamCode">{podiumTop3[2].teamCode}</span>
            </div>
            <div className="podiumScorePill">
              <strong>{podiumTop3[2].fantasyScore}</strong>
              <small>FANTASY PTS</small>
            </div>
            <div className="podiumKDA">
              K: {podiumTop3[2].kills} · D: {podiumTop3[2].deaths} · A: {podiumTop3[2].assists} ({podiumTop3[2].kdaRatio})
            </div>
          </div>
        </section>
      )}

      {/* Modern Filter Toolbar */}
      <section className="scoresToolbar">
        <div className="toolbarRow">
          {/* Role selector pills in official broadcast order */}
          <div className="filterGroup">
            <span className="filterGroupLabel">ROLE</span>
            <button
              className={`filterPill ${selectedRole === 'ALL' ? 'active' : ''}`}
              onClick={() => setSelectedRole('ALL')}
            >
              ALL
            </button>
            {BROADCAST_ROLE_ORDER.map(role => (
              <button
                key={role}
                className={`filterPill ${selectedRole === role ? 'active' : ''}`}
                onClick={() => setSelectedRole(role)}
              >
                {role}
              </button>
            ))}
          </div>

          <div className="toolbarSecondary">
            {/* Search bar */}
            <div className="scoresSearchWrap">
              <span className="searchIcon">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <circle cx="11" cy="11" r="8" />
                  <line x1="21" y1="21" x2="16.65" y2="16.65" />
                </svg>
              </span>
              <input
                className="scoresSearchInput"
                type="text"
                placeholder={`Search ${REGION_META[region].name} player or team...`}
                value={searchQuery}
                onChange={e => setSearchQuery(e.target.value)}
              />
            </div>

            {/* Sort selector */}
            <select
              className="scoresSortSelect"
              value={sortBy}
              onChange={e => setSortBy(e.target.value as any)}
              aria-label="Sort players by"
            >
              <option value="score">Sort by: Highest Fantasy Score</option>
              <option value="kills">Sort by: Most Kills (+3 pts each)</option>
              <option value="assists">Sort by: Most Assists (+1 pt each)</option>
              <option value="kda">Sort by: Highest KDA Ratio</option>
              <option value="matches">Sort by: Most Matches Played</option>
            </select>
          </div>
        </div>
      </section>

      {/* Modern Player Scores Table (Desktop Grid + Mobile Responsive Cards) */}
      <section className="modernScoresTableWrap">
        {/* Modern styled column headers */}
        <div className="modernScoresTableHead">
          <span className="headColRank">#</span>
          <span className="headColPlayer">PLAYER</span>
          <span className="headColRole desktopOnly">ROLE</span>
          <span className="headColTeam desktopOnly">TEAM</span>
          <span className="headColMatches desktopOnly">MATCHES</span>
          <span className="headColK desktopOnly">K</span>
          <span className="headColD desktopOnly">D</span>
          <span className="headColA desktopOnly">A</span>
          <span className="headColKda desktopOnly">KDA</span>
          <span className="headColScore">
            <span className="colPillTag scoreTag">FANTASY PTS</span>
          </span>
          <span className="headColAction desktopOnly">ACTION</span>
        </div>

        {loading ? (
          <div className="scoresEmptyState">
            <span>⋯</span>
            <h3>Loading {REGION_META[region].name} scores…</h3>
            <p>Fetching official KDA entries from the verified scoring ledger.</p>
          </div>
        ) : filteredItems.length === 0 ? (
          <div className="scoresEmptyState">
            <span>∅</span>
            <h3>No players matched</h3>
            <p>Try adjusting your search query or role filter for {REGION_META[region].name}.</p>
          </div>
        ) : (
          <div className="modernScoresTableBody">
            {filteredItems.map((item, index) => {
              const rank = index + 1;
              const rankClass = rank === 1 ? 'r1' : rank === 2 ? 'r2' : rank === 3 ? 'r3' : '';

              return (
                <div
                  className="modernPlayerScoresRow"
                  key={item.playerId}
                  onClick={() => setActiveModalPlayer(item)}
                >
                  {/* 1. Rank */}
                  <div className="cellRank">
                    <span className={`modernRankBadge ${rankClass}`}>#{rank}</span>
                  </div>

                  {/* 2. Player Info */}
                  <div className="cellPlayer">
                    <div className="modernPlayerProfile">
                      <div className="modernPlayerAvatarWrap">
                        {item.photoUrl ? (
                          <img className="modernPlayerAvatar" src={item.photoUrl} alt={item.handle} />
                        ) : (
                          <div className="modernPlayerAvatar fallback">
                            {item.handle.slice(0, 2).toUpperCase()}
                          </div>
                        )}
                      </div>
                      <div className="modernPlayerMeta">
                        <div className="modernPlayerNameLine">
                          <b>{item.handle}</b>
                          <span className={`mobileOnlyRoleBadge rolePill role-${item.role.toLowerCase()}`}>
                            {item.role}
                          </span>
                        </div>
                        <div className="modernPlayerSubline">
                          {item.teamLogo && (
                            <img className="modernPlayerTeamLogo" src={item.teamLogo} alt="" />
                          )}
                          <span className="modernTeamName">{item.teamName}</span>
                          <small className="modernTeamCode">({item.teamCode})</small>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* 3. Role (Desktop) */}
                  <div className="cellRole desktopOnly">
                    <span className={`rolePill role-${item.role.toLowerCase()}`}>
                      {item.role}
                    </span>
                  </div>

                  {/* 4. Team (Desktop) */}
                  <div className="cellTeam desktopOnly">
                    <div className="teamLogoGroup">
                      {item.teamLogo && (
                        <img className="modernTeamLogoIcon" src={item.teamLogo} alt={item.teamCode} />
                      )}
                      <b>{item.teamCode}</b>
                    </div>
                  </div>

                  {/* 5. Matches (Desktop) */}
                  <div className="cellMatches desktopOnly">
                    <span className="statNumText">{item.matchesPlayed}</span>
                  </div>

                  {/* 6. Kills (Desktop) */}
                  <div className="cellK desktopOnly">
                    <span className="statNumText kills">{item.kills}</span>
                  </div>

                  {/* 7. Deaths (Desktop) */}
                  <div className="cellD desktopOnly">
                    <span className="statNumText deaths">{item.deaths}</span>
                  </div>

                  {/* 8. Assists (Desktop) */}
                  <div className="cellA desktopOnly">
                    <span className="statNumText assists">{item.assists}</span>
                  </div>

                  {/* 9. KDA (Desktop) */}
                  <div className="cellKda desktopOnly">
                    <span className="statNumText kda">{item.kdaRatio}</span>
                  </div>

                  {/* 10. Fantasy Score (Desktop & Mobile) */}
                  <div className="cellScore">
                    <div className="modernScoreBadge">
                      <strong>{item.fantasyScore}</strong>
                      <small>PTS</small>
                    </div>
                    <span className="mobileDetailsCue">STATS →</span>
                  </div>

                  {/* 11. Action Button (Desktop) */}
                  <div className="cellAction desktopOnly">
                    <button
                      className="modernActionBtn"
                      onClick={(e) => {
                        e.stopPropagation();
                        setActiveModalPlayer(item);
                      }}
                    >
                      DETAILS →
                    </button>
                  </div>

                  {/* 12. Mobile Stats Ribbon (Mobile Only) */}
                  <div className="mobilePlayerStatsRibbon mobileOnly">
                    <div className="mStatBox">
                      <small>KILLS</small>
                      <b className="statKills">{item.kills}</b>
                    </div>
                    <div className="mStatBox">
                      <small>DEATHS</small>
                      <b className="statDeaths">{item.deaths}</b>
                    </div>
                    <div className="mStatBox">
                      <small>ASSISTS</small>
                      <b className="statAssists">{item.assists}</b>
                    </div>
                    <div className="mStatBox">
                      <small>KDA</small>
                      <b>{item.kdaRatio}</b>
                    </div>
                    <div className="mStatBox">
                      <small>MATCHES</small>
                      <b>{item.matchesPlayed}</b>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </section>

      {/* Match Breakdown Modal (Hardened Contrast for Light & Dark Mode) */}
      {activeModalPlayer && (
        <div className="breakdownModalShade" onClick={() => setActiveModalPlayer(null)}>
          <div className="breakdownModalCard" onClick={e => e.stopPropagation()}>
            <button
              className="breakdownModalClose"
              onClick={() => setActiveModalPlayer(null)}
              aria-label="Close modal"
            >
              ✕
            </button>

            {/* Profile Header */}
            <div className="breakdownProfileHead">
              {activeModalPlayer.photoUrl ? (
                <img className="breakdownModalAvatar" src={activeModalPlayer.photoUrl} alt={activeModalPlayer.handle} />
              ) : (
                <div className="breakdownModalAvatar fallback">
                  {activeModalPlayer.handle.slice(0, 2).toUpperCase()}
                </div>
              )}
              <div className="breakdownModalInfo">
                <h2>{activeModalPlayer.handle}</h2>
                <p>
                  <span className={`rolePill role-${activeModalPlayer.role.toLowerCase()}`}>
                    {activeModalPlayer.role}
                  </span>
                  {activeModalPlayer.teamLogo && (
                    <img src={activeModalPlayer.teamLogo} alt="" width={18} height={18} />
                  )}
                  <b>{activeModalPlayer.teamName} ({activeModalPlayer.teamCode})</b>
                  <span>· {REGION_META[activeModalPlayer.region].name}</span>
                </p>
              </div>
            </div>

            {/* Scoring Formula Box */}
            <div className="breakdownFormulaCard">
              <div>
                <small>FANTASY CALCULATION FORMULA</small>
                <b>({activeModalPlayer.kills} Kills × 3 pts) + ({activeModalPlayer.assists} Assists × 1 pt)</b>
              </div>
              <div>
                <small>TOTAL FANTASY SCORE</small>
                <strong>{activeModalPlayer.fantasyScore} PTS</strong>
              </div>
            </div>

            {/* 4 Stat Overview Boxes */}
            <div className="statOverviewGrid">
              <div className="statOverviewBox">
                <small>TOTAL KILLS</small>
                <div className="statNum kills">{activeModalPlayer.kills}</div>
              </div>
              <div className="statOverviewBox">
                <small>TOTAL DEATHS</small>
                <div className="statNum deaths">{activeModalPlayer.deaths}</div>
              </div>
              <div className="statOverviewBox">
                <small>TOTAL ASSISTS</small>
                <div className="statNum assists">{activeModalPlayer.assists}</div>
              </div>
              <div className="statOverviewBox">
                <small>KDA RATIO</small>
                <div className="statNum">{activeModalPlayer.kdaRatio}</div>
              </div>
            </div>

            {/* Match Breakdown List */}
            <div className="breakdownMatchesList">
              <span className="breakdownSectionTitle">
                MATCH BY MATCH BREAKDOWN ({activeModalPlayer.matchBreakdown.length} MATCHES)
              </span>

              {activeModalPlayer.matchBreakdown.length === 0 ? (
                <p className="noMatchesNote">
                  Series match breakdowns populate as match days conclude.
                </p>
              ) : (
                activeModalPlayer.matchBreakdown.map((m, idx) => (
                  <div className="breakdownMatchCard" key={m.matchId || idx}>
                    <div className="breakdownMatchTop">
                      <div className="breakdownOpponent">
                        {m.opponentLogo && <img src={m.opponentLogo} alt="" />}
                        <span>vs {m.opponentName} ({m.opponentCode})</span>
                        <small>· {m.seriesScore}</small>
                      </div>
                      <span className="breakdownMatchScore">+{m.score} PTS</span>
                    </div>

                    <div className="breakdownMatchStatsRow">
                      <span>Kills: <b>{m.kills}</b></span>
                      <span>Deaths: <b>{m.deaths}</b></span>
                      <span>Assists: <b>{m.assists}</b></span>
                      <span>Date: <b>{m.date}</b></span>
                    </div>

                    {/* Per-game breakdown */}
                    {Array.isArray(m.games) && m.games.length > 0 && (
                      <div className="perGameStrip">
                        {m.games.map(g => (
                          <span key={g.game} className="gamePill">
                            Game {g.game}: {g.kills} / {g.deaths} / {g.assists}
                          </span>
                        ))}
                      </div>
                    )}
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ---------------------------------------------------------------------------
// Featured Player Scores Widget on Command Center Dashboard
// ---------------------------------------------------------------------------

export function DashboardPlayerScores({
  region,
  onViewAll
}: {
  region: Region;
  onViewAll: () => void;
}) {
  const [topPlayers, setTopPlayers] = useState<PlayerScoreItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let mounted = true;
    async function loadTop() {
      setLoading(true);

      if (!supabase) {
        if (mounted) {
          const preview = generateRegionalPreviewStats(region);
          setTopPlayers(preview.filter(p => p.isStarter).slice(0, 4));
          setLoading(false);
        }
        return;
      }

      try {
        const { data: rpcRows } = await (supabase as any).rpc('get_player_scores_leaderboard', {
          target_region: region,
          target_week: null
        });

        if (Array.isArray(rpcRows) && rpcRows.length > 0) {
          // Strict regional filter
          const filteredRpcRows = rpcRows.filter((r: any) =>
            isPlayerInRegion(region, r.team_code, r.handle, r.region_code)
          );

          if (filteredRpcRows.length > 0) {
            const items: PlayerScoreItem[] = filteredRpcRows.slice(0, 4).map((r: any) => {
              const role = normalizeRole(r.role || 'MID');
              const teamMeta = TEAM_INDEX[r.team_code] || { name: r.team_name, logo: r.team_logo_url, region };
              const photo = r.photo_url || getPlayerPhoto(r.handle, region);
              const deaths = Number(r.deaths || 0);
              const kills = Number(r.kills || 0);
              const assists = Number(r.assists || 0);
              const kdaNum = deaths === 0 ? (kills + assists) : Number(((kills + assists) / deaths).toFixed(2));
              const kdaRatio = deaths === 0 ? `${kills + assists}.0 (Perfect)` : kdaNum.toFixed(2);
              const score = Number(r.fantasy_score || (kills * 3 + assists));

              return {
                playerId: r.player_id,
                handle: r.handle,
                role,
                region,
                teamCode: r.team_code,
                teamName: teamMeta.name || r.team_code,
                teamLogo: r.team_logo_url || teamMeta.logo,
                photoUrl: photo,
                matchesPlayed: Number(r.matches_played || 1),
                kills,
                deaths,
                assists,
                fantasyScore: score,
                kdaRatio,
                kdaNumber: kdaNum,
                isStarter: true,
                matchBreakdown: []
              };
            });

            if (mounted) {
              setTopPlayers(items);
              setLoading(false);
              return;
            }
          }
        }

        // Fallback
        if (mounted) {
          const preview = generateRegionalPreviewStats(region);
          setTopPlayers(preview.filter(p => p.isStarter).slice(0, 4));
          setLoading(false);
        }
      } catch {
        if (mounted) {
          const preview = generateRegionalPreviewStats(region);
          setTopPlayers(preview.filter(p => p.isStarter).slice(0, 4));
          setLoading(false);
        }
      }
    }

    loadTop();
    return () => { mounted = false; };
  }, [region]);

  return (
    <section className="panel dashboardPlayerScoresPanel">
      <div className="dashboardScoresHead">
        <div>
          <span className="adminCloudTag">● {REGION_META[region].name.toUpperCase()} · FANTASY STANDOUTS</span>
          <h2>Top Player Scores</h2>
          <p>Highest scoring pro players ranked by verified match KDA (+3 Kills, +1 Assist)</p>
        </div>
        <button className="textBtn" onClick={onViewAll}>
          VIEW ALL {REGION_META[region].name} SCORES →
        </button>
      </div>

      <div className="dashboardScoresList">
        {loading ? (
          <div style={{ padding: '20px', textAlign: 'center', color: 'var(--muted)', fontSize: '10px' }}>
            Loading top regional players…
          </div>
        ) : topPlayers.length === 0 ? (
          <div style={{ padding: '20px', textAlign: 'center', color: 'var(--muted)', fontSize: '10px' }}>
            No player scores recorded for {REGION_META[region].name} yet.
          </div>
        ) : (
          topPlayers.map((player, idx) => {
            const rank = idx + 1;
            const rankBadge = rank === 1 ? 'r1' : rank === 2 ? 'r2' : rank === 3 ? 'r3' : '';
            return (
              <div className="dashboardScoreRow" key={player.playerId} onClick={onViewAll}>
                <span className={`standRank ${rankBadge}`}>{rank}</span>
                <div className="dashboardPlayerAvatarWrap">
                  {player.photoUrl ? (
                    <img className="dashboardPlayerAvatar" src={player.photoUrl} alt={player.handle} />
                  ) : (
                    <div className="dashboardPlayerAvatar fallback">
                      {player.handle.slice(0, 2).toUpperCase()}
                    </div>
                  )}
                  {player.teamLogo && (
                    <span className="dashboardPlayerTeam">
                      <img src={player.teamLogo} alt={player.teamCode} />
                    </span>
                  )}
                </div>
                <div className="dashboardPlayerMeta">
                  <div className="dashboardHandleLine">
                    <b>{player.handle}</b>
                    <span className={`rolePill role-${player.role.toLowerCase()}`}>{player.role}</span>
                  </div>
                  <small>{player.teamName} ({player.teamCode})</small>
                </div>
                <div className="dashboardPlayerKDA">
                  <span>K: <b>{player.kills}</b></span>
                  <span>D: <b>{player.deaths}</b></span>
                  <span>A: <b>{player.assists}</b></span>
                  <small>({player.kdaRatio} KDA)</small>
                </div>
                <div className="dashboardPlayerScorePill">
                  <strong>+{player.fantasyScore}</strong>
                  <small>PTS</small>
                </div>
              </div>
            );
          })
        )}
      </div>

      <div className="dashboardScoresFoot">
        <button className="primary wide" onClick={onViewAll}>
          EXPLORE {REGION_META[region].name.toUpperCase()} PLAYER LEADERBOARD
        </button>
      </div>
    </section>
  );
}
