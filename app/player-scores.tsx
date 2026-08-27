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

const REGION_META: Record<Region, { name: string; flagFile: string; timezone: string }> = {
  MY: { name: 'MPL Malaysia', flagFile: 'my.svg', timezone: 'MYT' },
  ID: { name: 'MPL Indonesia', flagFile: 'id.svg', timezone: 'WIB' },
  PH: { name: 'MPL Philippines', flagFile: 'ph.svg', timezone: 'PHT' }
};

function normalizeRole(role: string): Role {
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

function getPlayerPhoto(handle: string, region?: Region): string | undefined {
  const match = officialPlayers.find(p =>
    (!region || p.region === region) && p.name.toLowerCase() === handle.toLowerCase()
  ) || officialPlayers.find(p => p.name.toLowerCase() === handle.toLowerCase());
  return match?.photo || undefined;
}

// Generate realistic starter stats for preview/fallback mode
function generatePreviewStats(): PlayerScoreItem[] {
  const items: PlayerScoreItem[] = [];

  const REGIONS_LIST: Region[] = ['MY', 'ID', 'PH'];

  REGIONS_LIST.forEach(region => {
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

      sortedRoster.forEach((p, idx) => {
        const normRole = normalizeRole(p.role);
        const isStarter = !assignedRoles.has(normRole);
        if (isStarter) assignedRoles.add(normRole);

        if (isStarter) {
          // Starter earns points based on role and hash
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

          // Formula: Kills * 3 + Assists * 1
          const fantasyScore = (kills * 3) + (assists * 1);
          const kdaNum = deaths === 0 ? (kills + assists) : Number(((kills + assists) / deaths).toFixed(2));
          const kdaRatio = deaths === 0 ? `${kills + assists}.0 (Perfect)` : kdaNum.toFixed(2);

          const breakdown: MatchBreakdownItem[] = [
            {
              matchId: `prev-${region}-${team.code}-1`,
              opponentCode: 'OPP',
              opponentName: 'MPL Opponent',
              opponentLogo: '/leagues/thumb/mpl-my.webp',
              date: '16 Aug 2026',
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
              opponentName: 'MPL Rival',
              opponentLogo: '/leagues/thumb/mpl-id.webp',
              date: '17 Aug 2026',
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
  });

  return items;
}

export default function PlayerScores({
  region: initialRegion,
  PageBanner,
  onNavigate
}: {
  region: Region;
  PageBanner?: React.ComponentType<{ tag: string; title: string; copy: string; side: React.ReactNode; sideLabel: string }>;
  onNavigate?: (view: any) => void;
}) {
  const [selectedRegion, setSelectedRegion] = useState<Region | 'ALL'>(initialRegion);
  const [selectedWeek, setSelectedWeek] = useState<string>('ALL');
  const [selectedRole, setSelectedRole] = useState<Role | 'ALL'>('ALL');
  const [searchQuery, setSearchQuery] = useState('');
  const [sortBy, setSortBy] = useState<'score' | 'kills' | 'assists' | 'kda' | 'matches'>('score');
  const [hideBench, setHideBench] = useState(true);
  const [loading, setLoading] = useState(true);
  const [isLiveCloud, setIsLiveCloud] = useState(false);
  const [playerScores, setPlayerScores] = useState<PlayerScoreItem[]>([]);
  const [activeModalPlayer, setActiveModalPlayer] = useState<PlayerScoreItem | null>(null);

  // Sync if initialRegion changes
  useEffect(() => {
    setSelectedRegion(initialRegion);
  }, [initialRegion]);

  // Load data from Supabase or generate realistic fallback
  useEffect(() => {
    let mounted = true;

    async function loadData() {
      setLoading(true);

      if (!supabase) {
        if (mounted) {
          setPlayerScores(generatePreviewStats());
          setIsLiveCloud(false);
          setLoading(false);
        }
        return;
      }

      try {
        // 1. Try get_player_scores_leaderboard RPC if available
        const targetRegionParam = selectedRegion === 'ALL' ? null : selectedRegion;
        const { data: rpcRows, error: rpcErr } = await (supabase as any).rpc('get_player_scores_leaderboard', {
          target_region: targetRegionParam,
          target_week: null
        });

        if (!rpcErr && Array.isArray(rpcRows) && rpcRows.length > 0) {
          // Format RPC rows
          const formatted: PlayerScoreItem[] = rpcRows.map((r: any) => {
            const role = normalizeRole(r.role || 'MID');
            const teamMeta = TEAM_INDEX[r.team_code] || { name: r.team_name, logo: r.team_logo_url, region: r.region_code as Region };
            const photo = r.photo_url || getPlayerPhoto(r.handle, r.region_code);
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
              region: (r.region_code as Region) || 'MY',
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

        // 2. Direct Supabase Table Query Fallback
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
          // Aggregate by player_id
          const playerMap = new Map<string, PlayerScoreItem>();

          // Build roster lookup
          const rosterMap = new Map<string, any>();
          (rostersData || []).forEach((r: any) => {
            if (r.player_id) {
              const reg = r.season?.region_code as Region || 'MY';
              rosterMap.set(r.player_id, {
                handle: r.player?.handle || 'PLAYER',
                role: normalizeRole(r.role || 'MID'),
                region: reg,
                teamCode: r.team?.code || '',
                teamName: r.team?.name || '',
                teamLogo: r.team?.logo_url || TEAM_INDEX[r.team?.code]?.logo,
                photoUrl: r.player?.photo_url || getPlayerPhoto(r.player?.handle || '', reg)
              });
            }
          });

          // Match lookup
          const matchMap = new Map<string, any>();
          (matchesData || []).forEach((m: any) => {
            matchMap.set(m.id, m);
          });

          statsData.forEach((st: any) => {
            const info = rosterMap.get(st.player_id) || {
              handle: 'PLAYER',
              role: 'MID' as Role,
              region: 'MY' as Region,
              teamCode: '',
              teamName: '',
              teamLogo: undefined,
              photoUrl: undefined
            };

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
                region: info.region,
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

          // Finalize KDA ratios
          const finalRows = Array.from(playerMap.values()).map(p => {
            const kdaNum = p.deaths === 0 ? (p.kills + p.assists) : Number(((p.kills + p.assists) / p.deaths).toFixed(2));
            const kdaRatio = p.deaths === 0 ? `${p.kills + p.assists}.0 (Perfect)` : kdaNum.toFixed(2);
            return {
              ...p,
              kdaNumber: kdaNum,
              kdaRatio
            };
          });

          if (mounted) {
            setPlayerScores(finalRows);
            setIsLiveCloud(true);
            setLoading(false);
          }
          return;
        }

        // 3. Fallback to preview stats if database has no rows
        if (mounted) {
          setPlayerScores(generatePreviewStats());
          setIsLiveCloud(false);
          setLoading(false);
        }
      } catch (e) {
        if (mounted) {
          setPlayerScores(generatePreviewStats());
          setIsLiveCloud(false);
          setLoading(false);
        }
      }
    }

    loadData();
    return () => { mounted = false; };
  }, [selectedRegion]);

  // Filter and sort items
  const filteredItems = useMemo(() => {
    return playerScores
      .filter(item => {
        // Region filter
        if (selectedRegion !== 'ALL' && item.region !== selectedRegion) return false;
        // Role filter
        if (selectedRole !== 'ALL' && item.role !== selectedRole) return false;
        // Bench filter
        if (hideBench && !item.isStarter && item.fantasyScore === 0) return false;
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
  }, [playerScores, selectedRegion, selectedRole, hideBench, searchQuery, sortBy]);

  // Top 3 Podium standouts
  const podiumTop3 = useMemo(() => {
    return filteredItems.slice(0, 3);
  }, [filteredItems]);

  const topScorer = filteredItems[0];
  const totalScoredPoints = useMemo(() => {
    return filteredItems.reduce((acc, p) => acc + p.fantasyScore, 0);
  }, [filteredItems]);

  return (
    <div className="page playerScoresWrap">
      {PageBanner ? (
        <PageBanner
          tag="VERIFIED KDA · FANTASY LEADERBOARD"
          title="Player Scores"
          copy="Leaderboard ranking official pro players by fantasy points earned: +3 pts per Kill, +1 pt per Assist. Bench substitutes receive 0 pts."
          side={topScorer ? `${topScorer.handle} · ${topScorer.fantasyScore} PTS` : '—'}
          sideLabel="CURRENT TOP SCORER"
        />
      ) : (
        <section className="pageBanner">
          <div>
            <span className="seasonTag">● VERIFIED KDA · FANTASY LEADERBOARD</span>
            <h1>Player Scores</h1>
            <p>Leaderboard ranking official pro players by fantasy points earned: +3 pts per Kill, +1 pt per Assist. Bench substitutes receive 0 pts.</p>
          </div>
          <div className="bannerSide">
            <small>CURRENT TOP SCORER</small>
            <strong>{topScorer ? `${topScorer.handle} · ${topScorer.fantasyScore} PTS` : '—'}</strong>
          </div>
        </section>
      )}

      {/* Tabs between Manager Leaderboard and Player Scores */}
      <div className="leaderboardTypeTabs">
        <button
          onClick={() => onNavigate && onNavigate('leaderboard')}
        >
          MANAGER RANKINGS
        </button>
        <button className="active">
          PLAYER SCORES
        </button>
      </div>

      {/* Live Ledger Status Bar */}
      <div className="scoresSourceBar">
        <span className={`sourcePill ${isLiveCloud ? 'live' : 'preview'}`}>
          <i className="pulseDot" />
          {isLiveCloud ? 'OFFICIAL VERIFIED LEDGER · REAL POST-MATCH DATA' : 'LOCAL VERIFIED STARTERS PREVIEW'}
        </span>
        <span className="scoresFormulaNote">
          SCORING RULE: KILLS × 3 + ASSISTS × 1 · BENCH PLAYERS DNP (0 PTS)
        </span>
      </div>

      {/* Podium Showcase (Top 3 Players) */}
      {podiumTop3.length >= 3 && (
        <section className="podiumGrid">
          {/* #2 Rank Card */}
          <div className="podiumCard rank2" onClick={() => setActiveModalPlayer(podiumTop3[1])}>
            <span className="podiumRankBadge">#2 SILVER</span>
            <div className="podiumAvatarWrap">
              {podiumTop3[1].photoUrl ? (
                <img className="podiumAvatar" src={podiumTop3[1].photoUrl} alt={podiumTop3[1].handle} />
              ) : (
                <div className="podiumAvatar" style={{ display: 'grid', placeItems: 'center', fontWeight: 900, color: 'var(--muted)' }}>
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
              <span style={{ fontSize: '9px', fontWeight: 800, color: 'var(--muted)' }}>{podiumTop3[1].teamCode}</span>
            </div>
            <div className="podiumScorePill">
              <strong>{podiumTop3[1].fantasyScore}</strong>
              <small>FANTASY PTS</small>
            </div>
            <div className="podiumKDA">
              K: {podiumTop3[1].kills} · D: {podiumTop3[1].deaths} · A: {podiumTop3[1].assists} ({podiumTop3[1].kdaRatio})
            </div>
          </div>

          {/* #1 Rank Card (Gold) */}
          <div className="podiumCard rank1" onClick={() => setActiveModalPlayer(podiumTop3[0])}>
            <span className="podiumRankBadge">#1 GOLD · MVP</span>
            <div className="podiumAvatarWrap">
              {podiumTop3[0].photoUrl ? (
                <img className="podiumAvatar" src={podiumTop3[0].photoUrl} alt={podiumTop3[0].handle} />
              ) : (
                <div className="podiumAvatar" style={{ display: 'grid', placeItems: 'center', fontWeight: 900, color: 'var(--muted)' }}>
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
              <span style={{ fontSize: '9px', fontWeight: 800, color: 'var(--muted)' }}>{podiumTop3[0].teamCode}</span>
            </div>
            <div className="podiumScorePill">
              <strong style={{ color: '#e5b325', fontSize: '22px' }}>{podiumTop3[0].fantasyScore}</strong>
              <small>FANTASY PTS</small>
            </div>
            <div className="podiumKDA">
              K: {podiumTop3[0].kills} · D: {podiumTop3[0].deaths} · A: {podiumTop3[0].assists} ({podiumTop3[0].kdaRatio})
            </div>
          </div>

          {/* #3 Rank Card */}
          <div className="podiumCard rank3" onClick={() => setActiveModalPlayer(podiumTop3[2])}>
            <span className="podiumRankBadge">#3 BRONZE</span>
            <div className="podiumAvatarWrap">
              {podiumTop3[2].photoUrl ? (
                <img className="podiumAvatar" src={podiumTop3[2].photoUrl} alt={podiumTop3[2].handle} />
              ) : (
                <div className="podiumAvatar" style={{ display: 'grid', placeItems: 'center', fontWeight: 900, color: 'var(--muted)' }}>
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
              <span style={{ fontSize: '9px', fontWeight: 800, color: 'var(--muted)' }}>{podiumTop3[2].teamCode}</span>
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

      {/* Interactive Controls & Filters */}
      <section className="scoresToolbar">
        {/* Top Row: Region & Role Filters */}
        <div className="toolbarRow">
          {/* Region selector */}
          <div className="filterGroup">
            <span className="filterGroupLabel">REGION</span>
            <button
              className={`filterPill ${selectedRegion === 'ALL' ? 'active' : ''}`}
              onClick={() => setSelectedRegion('ALL')}
            >
              ALL REGIONS
            </button>
            {(['MY', 'ID', 'PH'] as Region[]).map(reg => (
              <button
                key={reg}
                className={`filterPill ${selectedRegion === reg ? 'active' : ''}`}
                onClick={() => setSelectedRegion(reg)}
              >
                <img src={`/flags/${REGION_META[reg].flagFile}`} alt="" width={14} height={10} style={{ borderRadius: 2 }} />
                {reg}
              </button>
            ))}
          </div>

          {/* Role selector in official broadcast order: GOLD, ROAM, MID, JUNGLE, EXP */}
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
        </div>

        {/* Bottom Row: Search, Sort, Bench Toggle */}
        <div className="toolbarRow">
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
              placeholder="Search player handle or team code..."
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

          {/* Bench filter pill */}
          <button
            className={`filterPill ${hideBench ? 'active' : ''}`}
            onClick={() => setHideBench(!hideBench)}
            title="Substitutes receive strictly 0 pts and do not dilute starter scores"
          >
            {hideBench ? 'ACTIVE STARTERS ONLY' : 'SHOWING BENCH SUBS (0 PTS)'}
          </button>
        </div>
      </section>

      {/* Main Leaderboard Table */}
      <section className="playerScoresTableWrap">
        <div className="playerScoresTableHead">
          <span>#</span>
          <span>PLAYER</span>
          <span>ROLE</span>
          <span>TEAM</span>
          <span>MATCHES</span>
          <span>K</span>
          <span>D</span>
          <span>A</span>
          <span>KDA</span>
          <span>SCORE</span>
          <span>BREAKDOWN</span>
        </div>

        {loading ? (
          <div className="scoresEmptyState">
            <span>⋯</span>
            <h3>Loading verified scores…</h3>
            <p>Fetching official KDA entries and compiling regional player rankings.</p>
          </div>
        ) : filteredItems.length === 0 ? (
          <div className="scoresEmptyState">
            <span>∅</span>
            <h3>No players matched</h3>
            <p>Try adjusting your search query, role filter, or region selection.</p>
          </div>
        ) : (
          filteredItems.map((item, index) => {
            const rank = index + 1;
            const rankClass = rank === 1 ? 'r1' : rank === 2 ? 'r2' : rank === 3 ? 'r3' : '';

            return (
              <div
                className="playerScoresRow"
                key={item.playerId}
                onClick={() => setActiveModalPlayer(item)}
              >
                {/* 1. Rank */}
                <div className={`rowRank ${rankClass}`}>
                  {rank}
                </div>

                {/* 2. Player Profile Picture & Handle */}
                <div className="rowPlayerCell">
                  <div className="rowAvatarWrap">
                    {item.photoUrl ? (
                      <img className="rowAvatar" src={item.photoUrl} alt={item.handle} />
                    ) : (
                      <div className="rowAvatarPending">
                        {item.handle.slice(0, 2).toUpperCase()}
                      </div>
                    )}
                  </div>
                  <div className="rowPlayerInfo">
                    <b>{item.handle}</b>
                    <small>{item.teamName}</small>
                  </div>
                </div>

                {/* 3. Role Badge */}
                <div>
                  <span className={`rolePill role-${item.role.toLowerCase()}`}>
                    {item.role}
                  </span>
                </div>

                {/* 4. Team Logo and Code */}
                <div className="rowTeamCell">
                  {item.teamLogo && (
                    <img className="rowTeamLogo" src={item.teamLogo} alt={item.teamCode} />
                  )}
                  <b>{item.teamCode}</b>
                </div>

                {/* 5. Matches Played */}
                <div className="statCell">
                  {item.matchesPlayed}
                </div>

                {/* 6. Kills */}
                <div className="statCell kills">
                  {item.kills}
                </div>

                {/* 7. Deaths */}
                <div className="statCell deaths">
                  {item.deaths}
                </div>

                {/* 8. Assists */}
                <div className="statCell assists">
                  {item.assists}
                </div>

                {/* 9. KDA Ratio */}
                <div className="statCell kda">
                  {item.kdaRatio}
                </div>

                {/* 10. Fantasy Score */}
                <div className="rowScorePill">
                  <strong>{item.fantasyScore}</strong>
                </div>

                {/* 11. Details button */}
                <div>
                  <button
                    className="rowBreakdownBtn"
                    onClick={(e) => {
                      e.stopPropagation();
                      setActiveModalPlayer(item);
                    }}
                  >
                    DETAILS →
                  </button>
                </div>
              </div>
            );
          })
        )}
      </section>

      {/* Match Breakdown Modal */}
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
                <div className="breakdownModalAvatar" style={{ display: 'grid', placeItems: 'center', fontWeight: 900 }}>
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
                    <img src={activeModalPlayer.teamLogo} alt="" width={16} height={16} />
                  )}
                  <b>{activeModalPlayer.teamName} ({activeModalPlayer.teamCode})</b>
                  <span>· {activeModalPlayer.region}</span>
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

            {/* KDA Summary Overview */}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '10px', textAlign: 'center' }}>
              <div style={{ background: 'rgba(0,0,0,0.04)', padding: '10px', borderRadius: '8px', border: '1px solid var(--line)' }}>
                <small style={{ fontSize: '7px', color: 'var(--muted)', fontWeight: 900, textTransform: 'uppercase' }}>KILLS</small>
                <div style={{ fontSize: '14px', fontWeight: 900, color: '#ff536b' }}>{activeModalPlayer.kills}</div>
              </div>
              <div style={{ background: 'rgba(0,0,0,0.04)', padding: '10px', borderRadius: '8px', border: '1px solid var(--line)' }}>
                <small style={{ fontSize: '7px', color: 'var(--muted)', fontWeight: 900, textTransform: 'uppercase' }}>DEATHS</small>
                <div style={{ fontSize: '14px', fontWeight: 900, color: 'var(--muted)' }}>{activeModalPlayer.deaths}</div>
              </div>
              <div style={{ background: 'rgba(0,0,0,0.04)', padding: '10px', borderRadius: '8px', border: '1px solid var(--line)' }}>
                <small style={{ fontSize: '7px', color: 'var(--muted)', fontWeight: 900, textTransform: 'uppercase' }}>ASSISTS</small>
                <div style={{ fontSize: '14px', fontWeight: 900, color: '#60baff' }}>{activeModalPlayer.assists}</div>
              </div>
              <div style={{ background: 'rgba(0,0,0,0.04)', padding: '10px', borderRadius: '8px', border: '1px solid var(--line)' }}>
                <small style={{ fontSize: '7px', color: 'var(--muted)', fontWeight: 900, textTransform: 'uppercase' }}>KDA RATIO</small>
                <div style={{ fontSize: '14px', fontWeight: 900, color: 'var(--ink)' }}>{activeModalPlayer.kdaRatio}</div>
              </div>
            </div>

            {/* Match Breakdown List */}
            <div className="breakdownMatchesList">
              <span style={{ fontSize: '9px', fontWeight: 900, letterSpacing: '0.6px', color: 'var(--muted)', textTransform: 'uppercase' }}>
                MATCH BY MATCH BREAKDOWN ({activeModalPlayer.matchBreakdown.length} MATCHES)
              </span>

              {activeModalPlayer.matchBreakdown.length === 0 ? (
                <p style={{ fontSize: '9px', color: 'var(--muted)' }}>
                  Detailed game logs will be linked as series results are recorded.
                </p>
              ) : (
                activeModalPlayer.matchBreakdown.map((m, idx) => (
                  <div className="breakdownMatchCard" key={m.matchId || idx}>
                    <div className="breakdownMatchTop">
                      <div className="breakdownOpponent">
                        {m.opponentLogo && <img src={m.opponentLogo} alt="" />}
                        <span>vs {m.opponentName} ({m.opponentCode})</span>
                        <small style={{ color: 'var(--muted)', fontSize: '8px' }}>· {m.seriesScore}</small>
                      </div>
                      <span className="breakdownMatchScore">+{m.score} PTS</span>
                    </div>

                    <div className="breakdownMatchStatsRow">
                      <span>Kills: <b>{m.kills}</b></span>
                      <span>Deaths: <b>{m.deaths}</b></span>
                      <span>Assists: <b>{m.assists}</b></span>
                      <span>Date: <b>{m.date}</b></span>
                    </div>

                    {/* Per-game stats if available */}
                    {Array.isArray(m.games) && m.games.length > 0 && (
                      <div style={{ display: 'flex', gap: '8px', marginTop: '4px', flexWrap: 'wrap' }}>
                        {m.games.map(g => (
                          <span
                            key={g.game}
                            style={{
                              fontSize: '8px',
                              background: 'rgba(0,0,0,0.06)',
                              padding: '2px 6px',
                              borderRadius: '4px',
                              border: '1px solid var(--line)'
                            }}
                          >
                            Game {g.game}: {g.kills}/{g.deaths}/{g.assists}
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
