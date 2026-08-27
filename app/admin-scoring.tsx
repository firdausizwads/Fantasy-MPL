'use client';

import { useEffect, useMemo, useState } from 'react';
import { supabase } from '../lib/supabase/client';

type Region = 'MY' | 'ID' | 'PH';

type WeekOption = { id: string; number: number; finalized: boolean };

type MatchRow = {
  id: string;
  scheduledAt: string;
  status: string;
  resultState: string;
  homeTeamId: string;
  awayTeamId: string;
  homeCode: string;
  awayCode: string;
  homeName: string;
  awayName: string;
  homeScore: number | null;
  awayScore: number | null;
};

type RosterPlayer = { id: string; handle: string; role: string; teamId: string };

type StatValues = { kills: string; deaths: string; assists: string };

type PlayerStatsState = {
  [playerId: string]: {
    total: StatValues;
    games: Record<number, StatValues>;
  };
};

type ActiveViewTab = 'totals' | 'game1' | 'game2' | 'game3';

function AdminIcon({ name }: { name: 'sync' | 'paste' | 'check' | 'clock' }) {
  const common = { fill: 'none', stroke: 'currentColor', strokeWidth: 2, strokeLinecap: 'round' as const, strokeLinejoin: 'round' as const };
  if (name === 'sync') {
    return (
      <svg width="13" height="13" viewBox="0 0 24 24" aria-hidden="true" {...common}>
        <path d="M21.5 2v6h-6M21.34 15.57a10 10 0 1 1-.57-8.38l5.67-5.67" />
      </svg>
    );
  }
  if (name === 'paste') {
    return (
      <svg width="13" height="13" viewBox="0 0 24 24" aria-hidden="true" {...common}>
        <rect x="8" y="2" width="8" height="4" rx="1" />
        <path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1 2-2h2" />
        <path d="M9 12h6M9 16h4" />
      </svg>
    );
  }
  if (name === 'check') {
    return (
      <svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true" {...common}>
        <polyline points="20 6 9 17 4 12" />
      </svg>
    );
  }
  if (name === 'clock') {
    return (
      <svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true" {...common}>
        <circle cx="12" cy="12" r="10" />
        <polyline points="12 6 12 12 16 14" />
      </svg>
    );
  }
  return null;
}

export default function AdminScoring({ region, notify }: { region: Region; notify: (message: string) => void }) {
  const [weeks, setWeeks] = useState<WeekOption[]>([]);
  const [weekId, setWeekId] = useState('');
  const [matches, setMatches] = useState<MatchRow[]>([]);
  const [roster, setRoster] = useState<RosterPlayer[]>([]);
  const [openMatch, setOpenMatch] = useState<MatchRow | null>(null);
  const [scores, setScores] = useState<{ home: string; away: string }>({ home: '', away: '' });
  const [stats, setStats] = useState<PlayerStatsState>({});
  const [activeStarters, setActiveStarters] = useState<Record<string, boolean>>({});
  const [activeTab, setActiveTab] = useState<ActiveViewTab>('totals');
  const [busy, setBusy] = useState(false);
  const [loading, setLoading] = useState(true);
  const [autoFilling, setAutoFilling] = useState(false);
  const [autoFillSourceNote, setAutoFillSourceNote] = useState<string | null>(null);
  const [showPasteBox, setShowPasteBox] = useState(false);
  const [pasteText, setPasteText] = useState('');
  const [lastRun, setLastRun] = useState<{ lineups: number; transactions: number } | null>(null);
  const [mvpPick, setMvpPick] = useState('');
  const [mvpSearch, setMvpSearch] = useState('');

  // 1. Initial Load: Seasons, Weeks, Roster
  useEffect(() => {
    let mounted = true;
    async function load() {
      if (!supabase) return;
      setLoading(true);
      const { data: season } = await supabase.from('seasons').select('id')
        .eq('region_code', region).eq('season_number', 18).maybeSingle();
      if (!season) { if (mounted) setLoading(false); return; }

      const [{ data: weekRows }, { data: rosterRows }] = await Promise.all([
        supabase.from('competition_weeks')
          .select('id,week_number,finalized_at')
          .eq('season_id', season.id).order('week_number'),
        supabase.from('season_rosters')
          .select('player_id,role,team_id,players(handle)')
          .eq('season_id', season.id).eq('active', true)
          .in('role', ['EXP', 'JUNGLE', 'MID', 'GOLD', 'ROAM'])
      ]);

      if (!mounted) return;
      const weekOptions = (weekRows || []).map((w) => ({
        id: w.id, number: w.week_number, finalized: Boolean(w.finalized_at)
      }));
      setWeeks(weekOptions);
      setWeekId(prev => prev || weekOptions[0]?.id || '');
      setRoster((rosterRows || []).map((r) => ({
        id: r.player_id, handle: r.players?.handle || 'PLAYER', role: r.role, teamId: r.team_id
      })));
      setLoading(false);
    }
    load();
    return () => { mounted = false; };
  }, [region]);

  // 2. Load Matches for Selected Week
  useEffect(() => {
    let mounted = true;
    async function load() {
      if (!supabase || !weekId) return;
      const { data } = await supabase.from('matches')
        .select('id,scheduled_at,status,result_state,home_team_id,away_team_id,home_score,away_score,home:teams!matches_home_team_id_fkey(code,name),away:teams!matches_away_team_id_fkey(code,name)')
        .eq('week_id', weekId).order('scheduled_at');
      if (!mounted) return;
      setMatches((data || []).map((m) => ({
        id: m.id,
        scheduledAt: m.scheduled_at,
        status: m.status,
        resultState: m.result_state,
        homeTeamId: m.home_team_id,
        awayTeamId: m.away_team_id,
        homeCode: m.home?.code || '—',
        awayCode: m.away?.code || '—',
        homeName: m.home?.name || 'HOME',
        awayName: m.away?.name || 'AWAY',
        homeScore: m.home_score,
        awayScore: m.away_score
      })));
    }
    load();
    return () => { mounted = false; };
  }, [weekId]);

  // Match Players split into Home & Away
  // Ordered to match the official MPL post-game scoreboard: GOLD -> ROAM -> MID -> JUNGLE -> EXP
  const homeAllPlayers = useMemo(() => {
    if (!openMatch) return [] as RosterPlayer[];
    const roleOrder = ['GOLD', 'ROAM', 'MID', 'JUNGLE', 'EXP'];
    return roster
      .filter(p => p.teamId === openMatch.homeTeamId)
      .sort((a, b) => roleOrder.indexOf(a.role) - roleOrder.indexOf(b.role) || a.handle.localeCompare(b.handle));
  }, [openMatch, roster]);

  const awayAllPlayers = useMemo(() => {
    if (!openMatch) return [] as RosterPlayer[];
    const roleOrder = ['GOLD', 'ROAM', 'MID', 'JUNGLE', 'EXP'];
    return roster
      .filter(p => p.teamId === openMatch.awayTeamId)
      .sort((a, b) => roleOrder.indexOf(a.role) - roleOrder.indexOf(b.role) || a.handle.localeCompare(b.handle));
  }, [openMatch, roster]);

  const homeStarters = useMemo(() => {
    return homeAllPlayers.filter(p => activeStarters[p.id]);
  }, [homeAllPlayers, activeStarters]);

  const homeBench = useMemo(() => {
    return homeAllPlayers.filter(p => !activeStarters[p.id]);
  }, [homeAllPlayers, activeStarters]);

  const awayStarters = useMemo(() => {
    return awayAllPlayers.filter(p => activeStarters[p.id]);
  }, [awayAllPlayers, activeStarters]);

  const awayBench = useMemo(() => {
    return awayAllPlayers.filter(p => !activeStarters[p.id]);
  }, [awayAllPlayers, activeStarters]);

  const matchPlayers = useMemo(() => {
    return [...homeAllPlayers, ...awayAllPlayers];
  }, [homeAllPlayers, awayAllPlayers]);

  // Open Result Editor Modal
  async function openResultEditor(match: MatchRow) {
    setOpenMatch(match);
    setScores({
      home: match.homeScore !== null ? String(match.homeScore) : '',
      away: match.awayScore !== null ? String(match.awayScore) : ''
    });
    setActiveTab('totals');
    setShowPasteBox(false);
    setPasteText('');
    setAutoFillSourceNote(null);

    // Initial Starter Mapping: Exactly 1 player per role (5 total starters per team)
    // Ordered to match official scoreboard: GOLD -> ROAM -> MID -> JUNGLE -> EXP
    const roleOrder = ['GOLD', 'ROAM', 'MID', 'JUNGLE', 'EXP'];
    const starterMap: Record<string, boolean> = {};
    const homeAssigned = new Set<string>();
    const awayAssigned = new Set<string>();

    const hList = roster.filter(p => p.teamId === match.homeTeamId)
      .sort((a, b) => roleOrder.indexOf(a.role) - roleOrder.indexOf(b.role));
    hList.forEach(p => {
      if (!homeAssigned.has(p.role)) {
        starterMap[p.id] = true;
        homeAssigned.add(p.role);
      } else {
        starterMap[p.id] = false; // Bench sub
      }
    });

    const aList = roster.filter(p => p.teamId === match.awayTeamId)
      .sort((a, b) => roleOrder.indexOf(a.role) - roleOrder.indexOf(b.role));
    aList.forEach(p => {
      if (!awayAssigned.has(p.role)) {
        starterMap[p.id] = true;
        awayAssigned.add(p.role);
      } else {
        starterMap[p.id] = false; // Bench sub
      }
    });

    if (!supabase) {
      setActiveStarters(starterMap);
      return;
    }

    // Fetch existing stats with deaths & games (graceful fallback if column not yet added)
    let data: any[] | null = null;
    const res1 = await supabase.from('player_match_stats')
      .select('player_id,kills,assists,deaths,games')
      .eq('match_id', match.id);

    if (!res1.error && res1.data) {
      data = res1.data;
    } else {
      const res2 = await supabase.from('player_match_stats')
        .select('player_id,kills,assists')
        .eq('match_id', match.id);
      data = res2.data;
    }

    const draft: PlayerStatsState = {};
    (data || []).forEach((s) => {
      // If player had recorded non-zero stats, confirm them as starter
      if ((s.kills > 0 || s.assists > 0) && starterMap[s.player_id] === false) {
        starterMap[s.player_id] = true;
      }

      const gamesObj: Record<number, StatValues> = {};
      if (Array.isArray(s.games)) {
        s.games.forEach((g: any) => {
          if (g && g.game) {
            gamesObj[g.game] = {
              kills: String(g.kills ?? ''),
              deaths: String(g.deaths ?? ''),
              assists: String(g.assists ?? '')
            };
          }
        });
      }
      draft[s.player_id] = {
        total: {
          kills: String(s.kills ?? '0'),
          deaths: String(s.deaths ?? '0'),
          assists: String(s.assists ?? '0')
        },
        games: gamesObj
      };
    });

    setActiveStarters(starterMap);
    setStats(draft);
  }

  // Toggle or swap bench player to active starter
  function swapBenchToStarter(player: RosterPlayer) {
    setActiveStarters(prev => {
      const currentStatus = prev[player.id];
      if (!currentStatus) {
        // Find existing starter with the same role and swap
        const teamPlayers = roster.filter(p => p.teamId === player.teamId && p.role === player.role);
        const nextMap = { ...prev };
        teamPlayers.forEach(p => { nextMap[p.id] = false; });
        nextMap[player.id] = true;
        return nextMap;
      } else {
        return { ...prev, [player.id]: false };
      }
    });
    notify(`${player.handle} (${player.role}) is now active in the lineup.`);
  }

  // Update stat value in state (handles per-game and series totals)
  function updateStat(playerId: string, field: 'kills' | 'deaths' | 'assists', value: string) {
    setStats(prev => {
      const current = prev[playerId] || {
        total: { kills: '0', deaths: '0', assists: '0' },
        games: {}
      };

      if (activeTab === 'totals') {
        return {
          ...prev,
          [playerId]: {
            ...current,
            total: {
              ...current.total,
              [field]: value
            }
          }
        };
      }

      const gNum = activeTab === 'game1' ? 1 : activeTab === 'game2' ? 2 : 3;
      const gameStat = current.games[gNum] || { kills: '', deaths: '', assists: '' };
      const updatedGames = {
        ...current.games,
        [gNum]: {
          ...gameStat,
          [field]: value
        }
      };

      let sumK = 0, sumD = 0, sumA = 0;
      let hasAnyGameInput = false;
      for (let g = 1; g <= 3; g++) {
        const item = updatedGames[g];
        if (item) {
          if (item.kills !== '' || item.deaths !== '' || item.assists !== '') {
            hasAnyGameInput = true;
          }
          sumK += parseInt(item.kills || '0', 10) || 0;
          sumD += parseInt(item.deaths || '0', 10) || 0;
          sumA += parseInt(item.assists || '0', 10) || 0;
        }
      }

      return {
        ...prev,
        [playerId]: {
          games: updatedGames,
          total: hasAnyGameInput
            ? { kills: String(sumK), deaths: String(sumD), assists: String(sumA) }
            : current.total
        }
      };
    });
  }

  // Helper to get stat value for currently active tab
  function getStatValue(playerId: string, field: 'kills' | 'deaths' | 'assists'): string {
    const current = stats[playerId];
    if (!current) return '';
    if (activeTab === 'totals') {
      return current.total[field] || '';
    }
    const gNum = activeTab === 'game1' ? 1 : activeTab === 'game2' ? 2 : 3;
    return current.games[gNum]?.[field] || '';
  }

  // Helper to compute KDA ratio
  function calculateKda(kStr: string, dStr: string, aStr: string): string {
    const k = parseInt(kStr || '0', 10) || 0;
    const d = parseInt(dStr || '0', 10) || 0;
    const a = parseInt(aStr || '0', 10) || 0;
    if (k === 0 && d === 0 && a === 0) return '—';
    if (d === 0) return `${(k + a).toFixed(1)} (Perfect)`;
    return ((k + a) / d).toFixed(2);
  }

  // 1-Click Automated Ingestion from API
  async function autoFillFromApi() {
    if (!openMatch) return;
    setAutoFilling(true);
    try {
      const res = await fetch('/api/integrations/player-stats', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ match_id: openMatch.id })
      });
      const result = await res.json();
      if (!res.ok || result.error) {
        notify(result.error || 'Failed to auto-fetch stats.');
        setAutoFilling(false);
        return;
      }

      if (result.home_score !== undefined && result.away_score !== undefined) {
        setScores({
          home: String(result.home_score),
          away: String(result.away_score)
        });
      }

      const starterMap: Record<string, boolean> = { ...activeStarters };
      const draft: PlayerStatsState = { ...stats };

      (result.players || []).forEach((p: any) => {
        starterMap[p.player_id] = Boolean(p.is_starter);

        const gamesObj: Record<number, StatValues> = {};
        (p.games || []).forEach((g: any) => {
          gamesObj[g.game] = {
            kills: String(g.kills),
            deaths: String(g.deaths),
            assists: String(g.assists)
          };
        });

        draft[p.player_id] = {
          total: {
            kills: String(p.kills),
            deaths: String(p.deaths),
            assists: String(p.assists)
          },
          games: gamesObj
        };
      });

      setActiveStarters(starterMap);
      setStats(draft);
      setAutoFillSourceNote('Notice: Auto-Fill applied lane-role stats to the 5 starters. All bench substitutes are strictly locked to 0 (DNP). Please review before verifying.');
      notify('Stats populated for the starting 5. Substitutes locked to 0.');
    } catch (err) {
      notify('Failed to connect to stats ingestion endpoint.');
    } finally {
      setAutoFilling(false);
    }
  }

  // Smart Paste Parser
  function parseAndApplyPaste() {
    if (!pasteText.trim() || !openMatch) return;
    const lines = pasteText.split(/[\n,;]+/);
    let matched = 0;
    const draft = { ...stats };
    const starterMap = { ...activeStarters };

    matchPlayers.forEach(p => {
      const handleLower = p.handle.toLowerCase();
      for (const line of lines) {
        if (line.toLowerCase().includes(handleLower)) {
          // Look for 3 numbers separated by /, -, or spaces (K/D/A)
          const numMatch = line.match(/(\d+)\s*[/:-]\s*(\d+)\s*[/:-]\s*(\d+)/) ||
                           line.match(/(\d+)\s+(\d+)\s+(\d+)/);
          if (numMatch) {
            const k = numMatch[1];
            const d = numMatch[2];
            const a = numMatch[3];

            // If player appears in paste text, confirm them as a played starter
            starterMap[p.id] = true;

            const current = draft[p.id] || {
              total: { kills: '0', deaths: '0', assists: '0' },
              games: {}
            };

            if (activeTab !== 'totals') {
              const gNum = activeTab === 'game1' ? 1 : activeTab === 'game2' ? 2 : 3;
              const updatedGames = {
                ...current.games,
                [gNum]: { kills: k, deaths: d, assists: a }
              };
              let sumK = 0, sumD = 0, sumA = 0;
              Object.values(updatedGames).forEach(g => {
                sumK += parseInt(g.kills || '0', 10) || 0;
                sumD += parseInt(g.deaths || '0', 10) || 0;
                sumA += parseInt(g.assists || '0', 10) || 0;
              });
              draft[p.id] = {
                games: updatedGames,
                total: { kills: String(sumK), deaths: String(sumD), assists: String(sumA) }
              };
            } else {
              draft[p.id] = {
                ...current,
                total: { kills: k, deaths: d, assists: a }
              };
            }
            matched++;
            break;
          }
        }
      }
    });

    if (matched > 0) {
      setActiveStarters(starterMap);
      setStats(draft);
      notify(`Parsed and matched ${matched} player KDA records.`);
      setShowPasteBox(false);
      setPasteText('');
    } else {
      notify('No matching player names found in text. Check handles and try again.');
    }
  }

  // Save Verified Result and Stats
  async function saveResult() {
    if (!supabase || !openMatch) return;
    const home = parseInt(scores.home, 10);
    const away = parseInt(scores.away, 10);
    if (isNaN(home) || isNaN(away)) {
      notify('Please enter both series scores (e.g. 2 - 1).');
      return;
    }
    setBusy(true);

    const { error: resultError } = await supabase.rpc('admin_set_match_result', {
      target_match: openMatch.id,
      home_score: home,
      away_score: away
    });
    if (resultError) {
      notify(resultError.message);
      setBusy(false);
      return;
    }

    let statErrors = 0;
    for (const player of matchPlayers) {
      const isStarter = activeStarters[player.id];

      // CRITICAL: Bench players who Did Not Play (DNP) must receive ZERO points
      if (!isStarter) {
        const { error: dnpError } = await supabase.rpc('admin_upsert_player_stat', {
          target_match: openMatch.id,
          target_player: player.id,
          target_team: player.teamId,
          kill_count: 0,
          assist_count: 0,
          death_count: 0,
          games_breakdown: []
        });
        if (dnpError) {
          await supabase.rpc('admin_upsert_player_stat', {
            target_match: openMatch.id,
            target_player: player.id,
            target_team: player.teamId,
            kill_count: 0,
            assist_count: 0
          });
        }
        continue;
      }

      const pStat = stats[player.id];
      if (!pStat) continue;

      const killCount = parseInt(pStat.total.kills || '0', 10) || 0;
      const deathCount = parseInt(pStat.total.deaths || '0', 10) || 0;
      const assistCount = parseInt(pStat.total.assists || '0', 10) || 0;

      // Convert games to structured JSON
      const gamesBreakdown = Object.entries(pStat.games || {})
        .map(([gNum, g]) => ({
          game: parseInt(gNum, 10),
          kills: parseInt(g.kills || '0', 10) || 0,
          deaths: parseInt(g.deaths || '0', 10) || 0,
          assists: parseInt(g.assists || '0', 10) || 0
        }))
        .sort((a, b) => a.game - b.game);

      const { error: upsertError } = await supabase.rpc('admin_upsert_player_stat', {
        target_match: openMatch.id,
        target_player: player.id,
        target_team: player.teamId,
        kill_count: killCount,
        assist_count: assistCount,
        death_count: deathCount,
        games_breakdown: gamesBreakdown
      });

      if (upsertError) {
        const { error: fallbackError } = await supabase.rpc('admin_upsert_player_stat', {
          target_match: openMatch.id,
          target_player: player.id,
          target_team: player.teamId,
          kill_count: killCount,
          assist_count: assistCount
        });
        if (fallbackError) {
          statErrors += 1;
        }
      }
    }

    setBusy(false);
    setOpenMatch(null);
    setMatches(prev => prev.map(m => m.id === openMatch.id
      ? { ...m, homeScore: home, awayScore: away, status: 'completed', resultState: 'verified' }
      : m));
    notify(statErrors ? `Match saved · ${statErrors} player stat rows had issues.` : 'Match result & player KDAs verified and saved.');
  }

  // Fantasy Scoring Calculation Engine
  async function runScoring() {
    if (!supabase || !weekId) return;
    setBusy(true);
    if (mvpPick) {
      const { error: mvpError } = await supabase.rpc('admin_set_weekly_mvp', {
        target_week: weekId, target_player: mvpPick
      });
      if (mvpError) { notify(mvpError.message); setBusy(false); return; }
    }
    const [fantasyRes, regionalFantasyRes, predictionRes, metaRes] = await Promise.all([
      supabase.rpc('score_week_fantasy', { target_week: weekId }),
      supabase.rpc('score_week_regional_fantasy', { target_week: weekId }),
      supabase.rpc('score_week_predictions', { target_week: weekId }),
      supabase.rpc('score_week_meta', { target_week: weekId })
    ]);
    if (fantasyRes.error) { notify(fantasyRes.error.message); setBusy(false); return; }
    if (regionalFantasyRes.error) { notify(regionalFantasyRes.error.message); setBusy(false); return; }
    if (predictionRes.error) { notify(predictionRes.error.message); setBusy(false); return; }
    if (metaRes.error) { notify(metaRes.error.message); setBusy(false); return; }
    const [overallSnapshot, weekSnapshot] = await Promise.all([
      supabase.rpc('admin_refresh_leaderboard_snapshots', { target_region: region }),
      supabase.rpc('admin_refresh_leaderboard_snapshots', { target_region: region, target_week: weekId })
    ]);
    setBusy(false);
    if (overallSnapshot.error || weekSnapshot.error) {
      notify(`Scoring completed, but leaderboard refresh failed: ${overallSnapshot.error?.message || weekSnapshot.error?.message}`);
      return;
    }
    const f = Array.isArray(fantasyRes.data) ? fantasyRes.data[0] : fantasyRes.data;
    const rf = Array.isArray(regionalFantasyRes.data) ? regionalFantasyRes.data[0] : regionalFantasyRes.data;
    const p = Array.isArray(predictionRes.data) ? predictionRes.data[0] : predictionRes.data;
    const mt = Array.isArray(metaRes.data) ? metaRes.data[0] : metaRes.data;
    const lineupTotal = (f?.lineups_scored ?? 0) + (rf?.lineups_scored ?? 0);
    const transactionTotal = (f?.transactions_created ?? 0) + (rf?.transactions_created ?? 0) + (p?.transactions_created ?? 0) + (mt?.transactions_created ?? 0);
    setLastRun({ lineups: lineupTotal, transactions: transactionTotal });
    notify(`Scoring complete — ${lineupTotal} lineups, ${p?.predictions_scored ?? 0} predictions, ${transactionTotal} transactions.`);
  }

  if (loading) {
    return (
      <section className="panel adminCloudPanel adminPanelModern">
        <div className="cloudLoading">LOADING VERIFIED COMPETITION DATA…</div>
      </section>
    );
  }

  const verified = matches.filter(m => m.resultState === 'verified' || m.resultState === 'finalized').length;
  const pending = matches.length - verified;
  const week = weeks.find(w => w.id === weekId);

  return (
    <section className="panel adminCloudPanel adminPanelModern">
      {/* 1. Header & Quick Controls */}
      <div className="adminScoringHead">
        <div>
          <div className="adminScoringBadges">
            <span className="adminCloudTag">REGIONAL SCORING ENGINE</span>
            <span className="adminSeasonPill">{region} · SEASON 18</span>
          </div>
          <h2>Official Results & Player KDA Verification</h2>
          <p>
            Verify match series scores, auto-fill official player KDAs (Game 1, Game 2, Game 3), and calculate fantasy ledgers.
          </p>
        </div>

        <div className="adminWeekSelector">
          <label htmlFor="weekSelector">
            <small>COMPETITION WEEK</small>
            <select
              id="weekSelector"
              value={weekId}
              onChange={e => setWeekId(e.target.value)}
            >
              {weeks.map(w => (
                <option key={w.id} value={w.id}>
                  WEEK {w.number}{w.finalized ? ' · FINALIZED' : ''}
                </option>
              ))}
            </select>
          </label>
        </div>
      </div>

      {/* 2. Top Summary KPI Cards */}
      <div className="adminScoringKpis">
        <div className="scoringKpiCard">
          <small>FIXTURES SCHEDULED</small>
          <strong>{matches.length}</strong>
          <span>Week {week?.number ?? '1'} Matches</span>
        </div>
        <div className="scoringKpiCard ok">
          <small>RESULTS VERIFIED</small>
          <strong>{verified}</strong>
          <span>Ready for Scoring</span>
        </div>
        <div className={`scoringKpiCard ${pending > 0 ? 'warn' : ''}`}>
          <small>PENDING VERIFICATION</small>
          <strong>{pending}</strong>
          <span>{pending === 0 ? 'All Matches Complete' : 'Action Required'}</span>
        </div>
        <div className="scoringKpiCard">
          <small>OFFICIAL WEEKLY MVP</small>
          <strong>{mvpPick ? roster.find(p => p.id === mvpPick)?.handle || 'SELECTED' : 'NOT SET'}</strong>
          <span>{mvpPick ? 'Ready to Award' : 'Pending Selection'}</span>
        </div>
      </div>

      {/* 3. Match List Cards */}
      <div className="adminMatchesGrid">
        <div className="adminMatchesHeader">
          <h3>MATCH FIXTURES & RESULTS</h3>
          <span>Select &apos;Enter Result&apos; to view or auto-populate Game 1 / Game 2 KDAs</span>
        </div>

        {matches.length === 0 && (
          <div className="adminEmptyNote">No matches found for this competition week.</div>
        )}

        <div className="adminMatchCards">
          {matches.map(m => {
            const isVerified = m.resultState === 'verified' || m.resultState === 'finalized';
            return (
              <div className={`matchScoringCard ${isVerified ? 'verified' : 'pending'}`} key={m.id}>
                <div className="matchCardTop">
                  <span className="matchTime">
                    {new Date(m.scheduledAt).toLocaleString(undefined, {
                      weekday: 'short',
                      month: 'short',
                      day: 'numeric',
                      hour: '2-digit',
                      minute: '2-digit'
                    })}
                  </span>
                  <span className="matchBestOf">BEST OF 3</span>
                  <span className={`matchStatusPill ${isVerified ? 'verified' : 'pending'}`}>
                    <AdminIcon name={isVerified ? 'check' : 'clock'} />
                    {isVerified ? 'VERIFIED' : 'PENDING REVIEW'}
                  </span>
                </div>

                <div className="matchCardVersus">
                  <div className="teamBlock home">
                    <span className="teamCodeBadge">{m.homeCode}</span>
                    <b className="teamName">{m.homeName}</b>
                  </div>

                  <div className="scoreBlock">
                    <strong>
                      {m.homeScore !== null && m.awayScore !== null
                        ? `${m.homeScore} – ${m.awayScore}`
                        : 'VS'}
                    </strong>
                  </div>

                  <div className="teamBlock away">
                    <span className="teamCodeBadge">{m.awayCode}</span>
                    <b className="teamName">{m.awayName}</b>
                  </div>
                </div>

                <div className="matchCardActions">
                  <button
                    type="button"
                    className="actionBtn"
                    onClick={() => openResultEditor(m)}
                  >
                    {m.homeScore !== null ? 'Edit Result & KDA' : 'Enter Result & KDA'}
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* 4. Weekly MVP Picker */}
      <div className="adminMvpSection">
        <div className="mvpSectionTitle">
          <b>OFFICIAL WEEKLY MVP SELECTION</b>
          <p>Confirm the regional league&apos;s official MVP before executing scoring — correct user predictions earn +100.</p>
        </div>
        <div className="mvpControls">
          <input
            value={mvpSearch}
            onChange={e => setMvpSearch(e.target.value)}
            placeholder="Search player handle…"
          />
          <select value={mvpPick} onChange={e => setMvpPick(e.target.value)}>
            <option value="">-- SELECT OFFICIAL MVP --</option>
            {roster
              .filter(p => !mvpSearch || p.handle.toLowerCase().includes(mvpSearch.toLowerCase()))
              .slice(0, 40)
              .map(p => (
                <option key={p.id} value={p.id}>
                  {p.handle} · {p.role}
                </option>
              ))}
          </select>
        </div>
      </div>

      {/* 5. Bottom Scoring Execution Bar */}
      <div className="adminScoringExecution">
        <div>
          <b>{verified} / {matches.length} MATCHES VERIFIED</b>
          <p>
            {lastRun
              ? `Last run: ${lastRun.lineups} lineups scored · ${lastRun.transactions} transactions recorded in ledger.`
              : 'Official Scoring: Kills +3 · Assists +1 · Captain 2× multiplier. Immutable transaction ledger.'}
          </p>
        </div>
        <button
          type="button"
          className="primary runScoringBtn"
          disabled={busy || verified === 0}
          onClick={runScoring}
        >
          {busy ? 'PROCESSING SCORES…' : `RUN WEEK ${week?.number ?? ''} FANTASY SCORING`}
        </button>
      </div>

      {/* =========================================================================
          6. MODAL: Match Result & Divided Game KDAs (Game 1, Game 2, Game 3, Totals)
         ========================================================================= */}
      {openMatch && (
        <div className="modalShade" onClick={() => setOpenMatch(null)}>
          <div
            className="modalCard adminResultModal modernResultModal"
            onClick={e => e.stopPropagation()}
          >
            <button
              type="button"
              className="close"
              onClick={() => setOpenMatch(null)}
              aria-label="Close modal"
            >
              ×
            </button>

            <div className="modalTopBadge">
              <span className="seasonTag">OFFICIAL MATCH RESULT & KDA VERIFICATION</span>
            </div>

            {/* Modal Matchup & Series Score */}
            <div className="modalMatchHeader">
              <div className="modalTeamIdentity">
                <span className="teamPill">{openMatch.homeCode}</span>
                <h2>{openMatch.homeName}</h2>
              </div>
              <div className="modalSeriesScore">
                <input
                  type="number"
                  min={0}
                  max={3}
                  value={scores.home}
                  placeholder="0"
                  onChange={e => setScores(s => ({ ...s, home: e.target.value }))}
                />
                <span>:</span>
                <input
                  type="number"
                  min={0}
                  max={3}
                  value={scores.away}
                  placeholder="0"
                  onChange={e => setScores(s => ({ ...s, away: e.target.value }))}
                />
              </div>
              <div className="modalTeamIdentity away">
                <span className="teamPill">{openMatch.awayCode}</span>
                <h2>{openMatch.awayName}</h2>
              </div>
            </div>

            {/* Quick Score Presets */}
            <div className="quickScorePresets">
              <small>QUICK PRESETS:</small>
              <button type="button" onClick={() => setScores({ home: '2', away: '0' })}>2 – 0</button>
              <button type="button" onClick={() => setScores({ home: '2', away: '1' })}>2 – 1</button>
              <button type="button" onClick={() => setScores({ home: '1', away: '2' })}>1 – 2</button>
              <button type="button" onClick={() => setScores({ home: '0', away: '2' })}>0 – 2</button>
            </div>

            {/* Automation Toolbar: Auto-Fill & Quick Paste */}
            <div className="modalAutomationBar">
              <div className="automationLeft">
                <button
                  type="button"
                  className="autoFillBtn"
                  disabled={autoFilling || busy}
                  onClick={autoFillFromApi}
                >
                  <AdminIcon name="sync" />
                  {autoFilling ? 'FETCHING STARTING 5 STATS…' : 'AUTO-FILL STARTING 5 STATS'}
                </button>
                <button
                  type="button"
                  className="pasteToggleBtn"
                  onClick={() => setShowPasteBox(!showPasteBox)}
                >
                  <AdminIcon name="paste" />
                  {showPasteBox ? 'Hide Paste Tool' : 'Quick Paste Scoreboard'}
                </button>
              </div>
              <span className="automationHint">Only Active Starters Receive Fantasy Points</span>
            </div>

            {/* Notice Banner when Auto-Fill is applied */}
            {autoFillSourceNote && (
              <div className="autoFillNoticeBanner">
                <span>PRESET</span>
                <p>{autoFillSourceNote}</p>
              </div>
            )}

            {/* Quick Paste Scoreboard Box */}
            {showPasteBox && (
              <div className="quickPasteBox">
                <p>
                  Paste scoreboard text from broadcast, stream recap, or Liquipedia (e.g. <i>Alberttt 8/1/6, Sanz 4/0/11</i>):
                </p>
                <textarea
                  rows={3}
                  value={pasteText}
                  onChange={e => setPasteText(e.target.value)}
                  placeholder="Paste player KDAs here (e.g. Sekys 6/1/5, Innocent 7/0/8)..."
                />
                <div className="quickPasteActions">
                  <button type="button" className="applyPasteBtn" onClick={parseAndApplyPaste}>
                    Parse & Apply to Active Players
                  </button>
                  <button type="button" className="cancelPasteBtn" onClick={() => setShowPasteBox(false)}>
                    Cancel
                  </button>
                </div>
              </div>
            )}

            {/* Game Navigation Tabs: Game 1, Game 2, Game 3, Series Totals */}
            <div className="gameTabSelector">
              <button
                type="button"
                className={activeTab === 'totals' ? 'active' : ''}
                onClick={() => setActiveTab('totals')}
              >
                SERIES TOTALS (SUM)
              </button>
              <button
                type="button"
                className={activeTab === 'game1' ? 'active' : ''}
                onClick={() => setActiveTab('game1')}
              >
                GAME 1
              </button>
              <button
                type="button"
                className={activeTab === 'game2' ? 'active' : ''}
                onClick={() => setActiveTab('game2')}
              >
                GAME 2
              </button>
              <button
                type="button"
                className={activeTab === 'game3' ? 'active' : ''}
                onClick={() => setActiveTab('game3')}
              >
                GAME 3
              </button>
            </div>

            <div className="tabExplanation">
              {activeTab === 'totals' ? (
                <span>Aggregated Series Totals (Sum of all games played). Only active starters receive points.</span>
              ) : (
                <span>
                  Editing <b>{activeTab.toUpperCase()}</b> stats. Entering kills/deaths/assists here automatically sums into Series Totals!
                </span>
              )}
            </div>

            {/* Divided Teams Table: Home Team & Away Team */}
            <div className="modalTeamsSplit">
              {/* HOME TEAM */}
              <div className="teamColumnBlock">
                <div className="teamColumnHead">
                  <span className="teamCodeBadge">{openMatch.homeCode}</span>
                  <b>{openMatch.homeName}</b>
                  <small>{homeStarters.length} STARTERS PLAYED</small>
                </div>

                <div className="kdaSectionLabel">
                  <span>ACTIVE LINEUP (SCORED)</span>
                  <small>GOLD · ROAM · MID · JGL · EXP</small>
                </div>

                <div className="kdaTableHeader">
                  <span className="colPlayer">PLAYER & ROLE</span>
                  <span className="colStat">K</span>
                  <span className="colStat">D</span>
                  <span className="colStat">A</span>
                  <span className="colKda">KDA</span>
                </div>

                <div className="kdaRows">
                  {homeStarters.map(p => {
                    const k = getStatValue(p.id, 'kills');
                    const d = getStatValue(p.id, 'deaths');
                    const a = getStatValue(p.id, 'assists');
                    const kdaStr = calculateKda(k, d, a);
                    return (
                      <div className="kdaRow" key={p.id}>
                        <div className="playerMeta">
                          <span className={`roleBadge role-${p.role.toLowerCase()}`}>{p.role}</span>
                          <b>{p.handle}</b>
                        </div>
                        <input
                          type="number"
                          min={0}
                          placeholder="0"
                          value={k}
                          onChange={e => updateStat(p.id, 'kills', e.target.value)}
                        />
                        <input
                          type="number"
                          min={0}
                          placeholder="0"
                          value={d}
                          onChange={e => updateStat(p.id, 'deaths', e.target.value)}
                        />
                        <input
                          type="number"
                          min={0}
                          placeholder="0"
                          value={a}
                          onChange={e => updateStat(p.id, 'assists', e.target.value)}
                        />
                        <span className="kdaRatioPill">{kdaStr}</span>
                      </div>
                    );
                  })}
                </div>

                {/* Home Bench / Reserves (DNP - 0 points) */}
                {homeBench.length > 0 && (
                  <div className="benchContainer">
                    <div className="benchNotice">
                      BENCH / SUBSTITUTES (DID NOT PLAY — 0 FANTASY POINTS)
                    </div>
                    <div className="kdaRows">
                      {homeBench.map(p => (
                        <div className="kdaRow benchRow" key={p.id}>
                          <div className="playerMeta">
                            <span className="benchBadge">BENCH</span>
                            <b>{p.handle}</b>
                            <small>{p.role}</small>
                          </div>
                          <span className="kdaRatioPill">DNP (0 PTS)</span>
                          <button
                            type="button"
                            className="subSwapBtn"
                            onClick={() => swapBenchToStarter(p)}
                            title="Swap this substitute into the active lineup"
                          >
                            Sub In
                          </button>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>

              {/* AWAY TEAM */}
              <div className="teamColumnBlock">
                <div className="teamColumnHead">
                  <span className="teamCodeBadge">{openMatch.awayCode}</span>
                  <b>{openMatch.awayName}</b>
                  <small>{awayStarters.length} STARTERS PLAYED</small>
                </div>

                <div className="kdaSectionLabel">
                  <span>ACTIVE LINEUP (SCORED)</span>
                  <small>GOLD · ROAM · MID · JGL · EXP</small>
                </div>

                <div className="kdaTableHeader">
                  <span className="colPlayer">PLAYER & ROLE</span>
                  <span className="colStat">K</span>
                  <span className="colStat">D</span>
                  <span className="colStat">A</span>
                  <span className="colKda">KDA</span>
                </div>

                <div className="kdaRows">
                  {awayStarters.map(p => {
                    const k = getStatValue(p.id, 'kills');
                    const d = getStatValue(p.id, 'deaths');
                    const a = getStatValue(p.id, 'assists');
                    const kdaStr = calculateKda(k, d, a);
                    return (
                      <div className="kdaRow" key={p.id}>
                        <div className="playerMeta">
                          <span className={`roleBadge role-${p.role.toLowerCase()}`}>{p.role}</span>
                          <b>{p.handle}</b>
                        </div>
                        <input
                          type="number"
                          min={0}
                          placeholder="0"
                          value={k}
                          onChange={e => updateStat(p.id, 'kills', e.target.value)}
                        />
                        <input
                          type="number"
                          min={0}
                          placeholder="0"
                          value={d}
                          onChange={e => updateStat(p.id, 'deaths', e.target.value)}
                        />
                        <input
                          type="number"
                          min={0}
                          placeholder="0"
                          value={a}
                          onChange={e => updateStat(p.id, 'assists', e.target.value)}
                        />
                        <span className="kdaRatioPill">{kdaStr}</span>
                      </div>
                    );
                  })}
                </div>

                {/* Away Bench / Reserves (DNP - 0 points) */}
                {awayBench.length > 0 && (
                  <div className="benchContainer">
                    <div className="benchNotice">
                      BENCH / SUBSTITUTES (DID NOT PLAY — 0 FANTASY POINTS)
                    </div>
                    <div className="kdaRows">
                      {awayBench.map(p => (
                        <div className="kdaRow benchRow" key={p.id}>
                          <div className="playerMeta">
                            <span className="benchBadge">BENCH</span>
                            <b>{p.handle}</b>
                            <small>{p.role}</small>
                          </div>
                          <span className="kdaRatioPill">DNP (0 PTS)</span>
                          <button
                            type="button"
                            className="subSwapBtn"
                            onClick={() => swapBenchToStarter(p)}
                            title="Swap this substitute into the active lineup"
                          >
                            Sub In
                          </button>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            </div>

            {/* Modal Bottom Save Bar */}
            <div className="modalSaveBar">
              <div className="modalSaveInfo">
                <span>VERIFICATION SAFETY GUARANTEE</span>
                <p>Only active starters receive fantasy points. Bench players are confirmed as 0 (DNP).</p>
              </div>
              <button
                type="button"
                className="primary saveConfirmBtn"
                disabled={busy}
                onClick={saveResult}
              >
                {busy ? 'SAVING VERIFIED STATS…' : 'VERIFY & SAVE RESULT'}
              </button>
            </div>
          </div>
        </div>
      )}
    </section>
  );
}
