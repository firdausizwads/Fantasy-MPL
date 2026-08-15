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

type StatDraft = { kills: string; assists: string };

export default function AdminScoring({ region, notify }: { region: Region; notify: (message: string) => void }) {
  const [weeks, setWeeks] = useState<WeekOption[]>([]);
  const [weekId, setWeekId] = useState('');
  const [matches, setMatches] = useState<MatchRow[]>([]);
  const [roster, setRoster] = useState<RosterPlayer[]>([]);
  const [openMatch, setOpenMatch] = useState<MatchRow | null>(null);
  const [scores, setScores] = useState<{ home: string; away: string }>({ home: '', away: '' });
  const [stats, setStats] = useState<Record<string, StatDraft>>({});
  const [busy, setBusy] = useState(false);
  const [loading, setLoading] = useState(true);
  const [lastRun, setLastRun] = useState<{ lineups: number; transactions: number } | null>(null);
  const [mvpPick, setMvpPick] = useState('');
  const [mvpSearch, setMvpSearch] = useState('');

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
      const weekOptions = (weekRows || []).map((w: any) => ({
        id: w.id, number: w.week_number, finalized: Boolean(w.finalized_at)
      }));
      setWeeks(weekOptions);
      setWeekId(prev => prev || weekOptions[0]?.id || '');
      setRoster((rosterRows || []).map((r: any) => ({
        id: r.player_id, handle: r.players?.handle || 'PLAYER', role: r.role, teamId: r.team_id
      })));
      setLoading(false);
    }
    load();
    return () => { mounted = false; };
  }, [region]);

  useEffect(() => {
    let mounted = true;
    async function load() {
      if (!supabase || !weekId) return;
      const { data } = await supabase.from('matches')
        .select('id,scheduled_at,status,result_state,home_team_id,away_team_id,home_score,away_score,home:teams!matches_home_team_id_fkey(code,name),away:teams!matches_away_team_id_fkey(code,name)')
        .eq('week_id', weekId).order('scheduled_at');
      if (!mounted) return;
      setMatches((data || []).map((m: any) => ({
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

  const matchPlayers = useMemo(() => {
    if (!openMatch) return [] as RosterPlayer[];
    return roster
      .filter(p => p.teamId === openMatch.homeTeamId || p.teamId === openMatch.awayTeamId)
      .sort((a, b) => a.teamId.localeCompare(b.teamId) || a.role.localeCompare(b.role));
  }, [openMatch, roster]);

  async function openResultEditor(match: MatchRow) {
    setOpenMatch(match);
    setScores({ home: match.homeScore?.toString() || '', away: match.awayScore?.toString() || '' });
    if (!supabase) return;
    const { data } = await supabase.from('player_match_stats')
      .select('player_id,kills,assists').eq('match_id', match.id);
    const draft: Record<string, StatDraft> = {};
    (data || []).forEach((s: any) => { draft[s.player_id] = { kills: String(s.kills), assists: String(s.assists) }; });
    setStats(draft);
  }

  async function saveResult() {
    if (!supabase || !openMatch) return;
    const home = parseInt(scores.home, 10);
    const away = parseInt(scores.away, 10);
    if (isNaN(home) || isNaN(away)) { notify('Enter both series scores.'); return; }
    setBusy(true);

    const { error: resultError } = await supabase.rpc('admin_set_match_result', {
      target_match: openMatch.id, home_score: home, away_score: away
    });
    if (resultError) { notify(resultError.message); setBusy(false); return; }

    let statErrors = 0;
    for (const player of matchPlayers) {
      const draft = stats[player.id];
      if (!draft || (draft.kills === '' && draft.assists === '')) continue;
      const { error } = await supabase.rpc('admin_upsert_player_stat', {
        target_match: openMatch.id,
        target_player: player.id,
        target_team: player.teamId,
        kill_count: parseInt(draft.kills || '0', 10) || 0,
        assist_count: parseInt(draft.assists || '0', 10) || 0
      });
      if (error) { statErrors += 1; }
    }

    setBusy(false);
    setOpenMatch(null);
    setMatches(prev => prev.map(m => m.id === openMatch.id
      ? { ...m, homeScore: home, awayScore: away, status: 'completed', resultState: 'verified' }
      : m));
    notify(statErrors ? `Result saved · ${statErrors} stat rows failed.` : 'Result and player statistics saved.');
  }

  async function runScoring() {
    if (!supabase || !weekId) return;
    setBusy(true);
    if (mvpPick) {
      const { error: mvpError } = await supabase.rpc('admin_set_weekly_mvp', {
        target_week: weekId, target_player: mvpPick
      });
      if (mvpError) { notify(mvpError.message); setBusy(false); return; }
    }
    const [fantasyRes, predictionRes] = await Promise.all([
      supabase.rpc('score_week_fantasy', { target_week: weekId }),
      supabase.rpc('score_week_predictions', { target_week: weekId })
    ]);
    setBusy(false);
    if (fantasyRes.error) { notify(fantasyRes.error.message); return; }
    if (predictionRes.error) { notify(predictionRes.error.message); return; }
    const f = Array.isArray(fantasyRes.data) ? fantasyRes.data[0] : fantasyRes.data;
    const p = Array.isArray(predictionRes.data) ? predictionRes.data[0] : predictionRes.data;
    setLastRun({
      lineups: f?.lineups_scored ?? 0,
      transactions: (f?.transactions_created ?? 0) + (p?.transactions_created ?? 0)
    });
    notify(`Scoring complete — ${f?.lineups_scored ?? 0} lineups, ${p?.predictions_scored ?? 0} predictions, ${(f?.transactions_created ?? 0) + (p?.transactions_created ?? 0)} transactions.`);
  }

  if (loading) return <section className="panel adminCloudPanel"><div className="cloudLoading">LOADING VERIFIED COMPETITION DATA…</div></section>;

  const verified = matches.filter(m => m.resultState === 'verified' || m.resultState === 'finalized').length;
  const week = weeks.find(w => w.id === weekId);

  return <section className="panel adminCloudPanel">
    <div className="adminCloudHead">
      <div>
        <span className="adminCloudTag">● LIVE CLOUD SCORING · SUPABASE</span>
        <h2>Official results & fantasy scoring</h2>
        <p>Enter verified series scores and player statistics, then run the scoring engine.</p>
      </div>
      <label className="adminWeekPick"><small>WEEK</small>
        <select value={weekId} onChange={e => setWeekId(e.target.value)}>
          {weeks.map(w => <option key={w.id} value={w.id}>WEEK {w.number}{w.finalized ? ' · FINAL' : ''}</option>)}
        </select>
      </label>
    </div>

    <div className="adminMatchList">
      {matches.length === 0 && <p className="adminEmptyNote">No matches found for this week.</p>}
      {matches.map(m => <div className={`adminMatchRow ${m.resultState}`} key={m.id}>
        <span className="adminMatchTime">{new Date(m.scheduledAt).toLocaleString(undefined, { weekday: 'short', hour: '2-digit', minute: '2-digit' })}</span>
        <b>{m.homeCode}</b>
        <strong>{m.homeScore !== null && m.awayScore !== null ? `${m.homeScore} – ${m.awayScore}` : 'VS'}</strong>
        <b>{m.awayCode}</b>
        <em className={m.resultState === 'verified' || m.resultState === 'finalized' ? 'ok' : ''}>
          {m.resultState === 'verified' || m.resultState === 'finalized' ? '✓ VERIFIED' : 'PENDING'}
        </em>
        <button className="secondary" onClick={() => openResultEditor(m)}>{m.homeScore !== null ? 'Edit result' : 'Enter result'}</button>
      </div>)}
    </div>

    <div className="adminMvpPick">
      <div>
        <b>OFFICIAL WEEKLY MVP</b>
        <p>Verify the league's official MVP before scoring — correct picks earn +100.</p>
      </div>
      <input value={mvpSearch} onChange={e => setMvpSearch(e.target.value)} placeholder="SEARCH PLAYER…" />
      <select value={mvpPick} onChange={e => setMvpPick(e.target.value)}>
        <option value="">NOT SET</option>
        {roster
          .filter(p => !mvpSearch || p.handle.toLowerCase().includes(mvpSearch.toLowerCase()))
          .slice(0, 40)
          .map(p => <option key={p.id} value={p.id}>{p.handle} · {p.role}</option>)}
      </select>
    </div>

    <div className="adminScoreBar">
      <div>
        <b>{verified} / {matches.length} MATCH RESULTS VERIFIED</b>
        <p>{lastRun
          ? `Last run · ${lastRun.lineups} lineups scored · ${lastRun.transactions} transactions`
          : 'Kill +3 · Assist +1 · Captain 2× — recorded in the append-only score ledger.'}</p>
      </div>
      <button className="primary" disabled={busy || verified === 0} onClick={runScoring}>
        {busy ? 'WORKING…' : `RUN WEEK ${week?.number ?? ''} FANTASY SCORING`}
      </button>
    </div>

    {openMatch && <div className="modalShade" onClick={() => setOpenMatch(null)}>
      <div className="modalCard adminResultModal" onClick={e => e.stopPropagation()}>
        <button className="close" onClick={() => setOpenMatch(null)}>×</button>
        <span className="seasonTag"><i /> OFFICIAL RESULT ENTRY</span>
        <h2>{openMatch.homeName} vs {openMatch.awayName}</h2>
        <div className="resultScoreRow">
          <label>{openMatch.homeCode}
            <input type="number" min={0} max={3} value={scores.home} onChange={e => setScores(s => ({ ...s, home: e.target.value }))} />
          </label>
          <b>SERIES</b>
          <label>{openMatch.awayCode}
            <input type="number" min={0} max={3} value={scores.away} onChange={e => setScores(s => ({ ...s, away: e.target.value }))} />
          </label>
        </div>
        <h3>Player statistics · kills & assists</h3>
        <div className="statTable">
          <div className="statHead"><span>PLAYER</span><span>K</span><span>A</span></div>
          {matchPlayers.map(p => <div className="statRow" key={p.id}>
            <span><b>{p.handle}</b><small>{p.role} · {p.teamId === openMatch.homeTeamId ? openMatch.homeCode : openMatch.awayCode}</small></span>
            <input type="number" min={0} placeholder="0" value={stats[p.id]?.kills || ''} onChange={e => setStats(s => ({ ...s, [p.id]: { kills: e.target.value, assists: s[p.id]?.assists || '' } }))} />
            <input type="number" min={0} placeholder="0" value={stats[p.id]?.assists || ''} onChange={e => setStats(s => ({ ...s, [p.id]: { kills: s[p.id]?.kills || '', assists: e.target.value } }))} />
          </div>)}
        </div>
        <button className="primary wide" disabled={busy} onClick={saveResult}>{busy ? 'SAVING…' : 'SAVE VERIFIED RESULT & STATS'}</button>
      </div>
    </div>}
  </section>;
}
