'use client';

import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase/client';

type Region = 'MY' | 'ID' | 'PH';

type DashboardSummary = {
  season_id: string | null;
  season_number: number | null;
  week_number: number | null;
  week_id: string | null;
  total_points: number | null;
  prediction_points: number | null;
  fantasy_points: number | null;
  regional_rank: number | null;
  ranked_managers: number;
  submitted_predictions: number;
  available_matches: number;
  mvp_submitted: boolean;
  finalized_predictions: number;
  correct_predictions: number;
  prediction_accuracy: number | null;
};

type DashboardTeam = { code: string; name: string; logo_url: string | null };
type DashboardMatch = {
  id: string;
  scheduled_at: string;
  status: string;
  home_team_id: string;
  away_team_id: string;
  home_team: DashboardTeam | DashboardTeam[];
  away_team: DashboardTeam | DashboardTeam[];
};
type DashboardPrediction = {
  match_id: string;
  predicted_winner_team_id: string;
  predicted_home_score: number;
  predicted_away_score: number;
};

function valueOrDash(value: number | null, suffix = '') {
  return value == null ? '—' : `${Number(value).toLocaleString()}${suffix}`;
}

export function CloudDashboard({
  region,
  userId,
  countryOf,
  onPredictions,
  onLeaderboard
}: {
  region: Region;
  userId: string;
  countryOf: (code: string) => React.ReactNode;
  onPredictions: () => void;
  onLeaderboard: () => void;
}) {
  const [summary, setSummary] = useState<DashboardSummary | null>(null);
  const [matches, setMatches] = useState<DashboardMatch[]>([]);
  const [predictions, setPredictions] = useState<DashboardPrediction[]>([]);
  const [leaders, setLeaders] = useState<BoardRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState('');

  useEffect(() => {
    let mounted = true;
    async function load() {
      if (!supabase) return;
      setLoading(true); setLoadError('');
      const { data: rawSummary, error: summaryError } = await supabase.rpc('my_dashboard_summary', { target_region: region });
      if (summaryError) {
        if (mounted) { setLoadError(summaryError.message); setLoading(false); }
        return;
      }
      const nextSummary = rawSummary as unknown as DashboardSummary;
      const leaderboardRequest = supabase.rpc('regional_leaderboard_snapshot', { target_region: region, target_season: nextSummary.season_id || undefined, max_rows: 5 });
      const matchRequest = nextSummary.week_id
        ? supabase.from('matches').select('id,scheduled_at,status,home_team_id,away_team_id,home_team:teams!matches_home_team_id_fkey(code,name,logo_url),away_team:teams!matches_away_team_id_fkey(code,name,logo_url)').eq('week_id', nextSummary.week_id).neq('status', 'cancelled').order('scheduled_at').limit(4)
        : Promise.resolve({ data: [], error: null });
      const [{ data: boardRows, error: boardError }, { data: matchRows, error: matchError }] = await Promise.all([leaderboardRequest, matchRequest]);
      if (!mounted) return;
      if (boardError || matchError) {
        setLoadError(boardError?.message || matchError?.message || 'Unable to load dashboard data.');
        setLoading(false); return;
      }
      const typedMatches = (matchRows || []) as unknown as DashboardMatch[];
      const ids = typedMatches.map(match => match.id);
      let predictionRows: DashboardPrediction[] = [];
      if (ids.length) {
        const { data, error } = await supabase.from('match_predictions').select('match_id,predicted_winner_team_id,predicted_home_score,predicted_away_score').eq('user_id', userId).in('match_id', ids);
        if (error) { setLoadError(error.message); setLoading(false); return; }
        predictionRows = (data || []) as DashboardPrediction[];
      }
      if (!mounted) return;
      setSummary(nextSummary);
      setMatches(typedMatches);
      setPredictions(predictionRows);
      setLeaders((boardRows as BoardRow[]) || []);
      setLoading(false);
    }
    load();
    return () => { mounted = false; };
  }, [region, userId]);

  if (loading) return <div className="realDashboardLoading">LOADING YOUR VERIFIED DASHBOARD…</div>;
  if (loadError) return <section className="realDashboardError"><b>DASHBOARD DATA UNAVAILABLE</b><p>{loadError}</p></section>;
  if (!summary) return null;

  const accuracyNote = summary.finalized_predictions > 0
    ? `${summary.correct_predictions} OF ${summary.finalized_predictions} FINALIZED WINNERS`
    : 'AWAITING FINALIZED RESULTS';
  const predictionProgress = `${summary.submitted_predictions} / ${summary.available_matches}`;
  const myRank = summary.regional_rank == null ? '—' : `#${summary.regional_rank}`;

  return <>
    <div className="stats realDashboardStats">
      <div className="stat"><small>REGIONAL POINTS</small><strong>{valueOrDash(summary.total_points)}</strong><span>{summary.total_points == null ? 'AWAITING FIRST SCORING RUN' : `${valueOrDash(summary.prediction_points)} PRED · ${valueOrDash(summary.fantasy_points)} FANTASY`}</span></div>
      <div className="stat"><small>REGIONAL RANK</small><strong>{myRank}</strong><span>{summary.regional_rank == null ? 'NOT RANKED YET' : `${summary.ranked_managers} RANKED MANAGERS`}</span></div>
      <div className="stat"><small>PREDICTION ACCURACY</small><strong>{valueOrDash(summary.prediction_accuracy, '%')}</strong><em>{accuracyNote}</em></div>
      <div className="stat"><small>WEEK {summary.week_number ?? '—'} PREDICTIONS</small><strong>{predictionProgress}</strong><span>{summary.mvp_submitted ? 'MVP PICK SUBMITTED' : 'MVP PICK NOT SUBMITTED'}</span></div>
    </div>

    <div className="dashboardGrid realDashboardGrid">
      <section className="panel realUpcomingPanel">
        <div className="panelHead"><div><h2>Upcoming predictions</h2><p>{summary.week_number ? `Week ${summary.week_number} · verified cloud fixtures` : 'Competition schedule pending'}</p></div><button className="textBtn" onClick={onPredictions}>VIEW ALL</button></div>
        {matches.length === 0
          ? <div className="realEmptyState"><span>◷</span><h3>NO UPCOMING FIXTURES</h3><p>VERIFIED MATCHES WILL APPEAR HERE AFTER THE REGIONAL SCHEDULE IS PUBLISHED.</p></div>
          : matches.map(match => {
              const home = Array.isArray(match.home_team) ? match.home_team[0] : match.home_team;
              const away = Array.isArray(match.away_team) ? match.away_team[0] : match.away_team;
              const prediction = predictions.find(item => item.match_id === match.id);
              const winner = prediction?.predicted_winner_team_id === match.home_team_id ? home.code : prediction ? away.code : '';
              const score = prediction ? `${prediction.predicted_home_score}–${prediction.predicted_away_score}` : '';
              return <article className="realFixtureCard" key={match.id}>
                <div className="realFixtureTime"><b>{new Date(match.scheduled_at).toLocaleDateString(undefined,{weekday:'short',day:'numeric',month:'short'}).toUpperCase()}</b><span>{new Date(match.scheduled_at).toLocaleTimeString(undefined,{hour:'2-digit',minute:'2-digit'})}</span></div>
                <div className="realFixtureTeams"><span>{home.logo_url && <img src={home.logo_url} alt=""/>}<b>{home.name.toUpperCase()}</b></span><i>VS</i><span>{away.logo_url && <img src={away.logo_url} alt=""/>}<b>{away.name.toUpperCase()}</b></span></div>
                <div className="realFixturePick"><small>YOUR PREDICTION</small><strong>{prediction ? `${winner} TO WIN · ${score}` : 'NOT SUBMITTED'}</strong></div>
                <button onClick={onPredictions}>{prediction ? 'EDIT' : 'PREDICT'} →</button>
              </article>;
            })}
      </section>

      <section className="panel realLeaderPreview">
        <div className="panelHead"><div><h2>Regional leaderboard</h2><p>Official score ledger</p></div><button className="textBtn" onClick={onLeaderboard}>VIEW ALL</button></div>
        {leaders.length === 0
          ? <div className="realEmptyState leaderboardEmpty"><span>—</span><h3>NO SCORED RESULTS YET</h3><p>RANKINGS WILL APPEAR AFTER THE FIRST OFFICIAL RESULTS ARE VERIFIED.</p></div>
          : <div className="realLeaderRows">{leaders.map((row, index) => <div className={row.user_id === userId ? 'you' : ''} key={row.user_id}><strong>#{index + 1}</strong><span>{row.avatar_url ? <img src={row.avatar_url} alt=""/> : <i>{row.manager_name.slice(0,2).toUpperCase()}</i>}<b>{countryOf(row.country_code)} {row.manager_name}{row.user_id === userId ? ' · YOU' : ''}</b></span><em>{Number(row.total_points).toLocaleString()} PTS</em></div>)}</div>}
        <footer>MY · ID · PH LEADERBOARDS REMAIN COMPLETELY SEPARATE</footer>
      </section>
    </div>
    <p className="realDataFoot">LIVE ACCOUNT DATA · SCORES APPEAR ONLY AFTER VERIFIED ADMIN SCORING</p>
  </>;
}

// ---------------------------------------------------------------------------
// Regional leaderboard fed by the score_transactions ledger
// ---------------------------------------------------------------------------

type BoardRow = {
  user_id: string;
  manager_name: string;
  country_code: string;
  avatar_url: string | null;
  total_points: number;
  prediction_points: number | null;
  fantasy_points: number | null;
};

export function CloudLeaderboard({
  region,
  userId,
  countryOf
}: {
  region: Region;
  userId: string;
  countryOf: (code: string) => React.ReactNode;
}) {
  const [rows, setRows] = useState<BoardRow[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let mounted = true;
    async function load() {
      if (!supabase) return;
      setLoading(true);
      const { data: season } = await supabase.from('seasons').select('id')
        .eq('region_code', region).in('status', ['published', 'active', 'completed'])
        .order('season_number', { ascending: false }).limit(1).maybeSingle();
      const { data } = await supabase.rpc('regional_leaderboard_snapshot', {
        target_region: region, target_season: season?.id, max_rows: 100
      });
      if (!mounted) return;
      setRows((data as BoardRow[]) || []);
      setLoading(false);
    }
    load();
    return () => { mounted = false; };
  }, [region]);

  if (loading) return <section className="panel standingsPanel"><div className="cloudLoading">LOADING REGIONAL LEADERBOARD…</div></section>;

  const myIndex = rows.findIndex(r => r.user_id === userId);

  return <section className="panel standingsPanel">
    <div className="standingsHead">
      <div>
        <span className="adminCloudTag">● OFFICIAL LEDGER · EVERY POINT TRACEABLE</span>
        <h2>Regional leaderboard</h2>
      </div>
      {myIndex >= 0 && <span className="myRankPill">YOUR RANK · #{myIndex + 1}</span>}
    </div>
    {rows.length === 0
      ? <p className="adminEmptyNote">No scored results yet. The board fills after the first admin scoring run.</p>
      : <div className="standingsTable">
          <div className="standingsHeader boardCols"><span>#</span><span>MANAGER</span><span>PRED</span><span>FANTASY</span><span>TOTAL</span></div>
          {rows.map((r, i) => <div className={`standingsRow boardCols ${r.user_id === userId ? 'me' : ''}`} key={r.user_id}>
            <span className={`standRank r${i + 1}`}>{i + 1}</span>
            <b>{countryOf(r.country_code)} {r.manager_name}{r.user_id === userId ? ' · YOU' : ''}</b>
            <em>{Number(r.prediction_points || 0).toLocaleString()}</em>
            <em>{Number(r.fantasy_points || 0).toLocaleString()}</em>
            <strong>{Number(r.total_points).toLocaleString()}</strong>
          </div>)}
        </div>}
  </section>;
}

// ---------------------------------------------------------------------------
// Real per-week point history for the Predictions page
// ---------------------------------------------------------------------------

type WeekOption = { id: string; number: number };
type PointRow = { category: string; reason_code: string; description: string; points: number; created_at: string };

export function CloudPointHistory({ region }: { region: Region }) {
  const [weeks, setWeeks] = useState<WeekOption[]>([]);
  const [weekId, setWeekId] = useState('');
  const [rows, setRows] = useState<PointRow[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let mounted = true;
    async function load() {
      if (!supabase) return;
      const { data: season } = await supabase.from('seasons').select('id')
        .eq('region_code', region).eq('season_number', 18).maybeSingle();
      if (!season) { if (mounted) setLoading(false); return; }
      const { data: weekRows } = await supabase.from('competition_weeks')
        .select('id,week_number').eq('season_id', season.id).order('week_number');
      if (!mounted) return;
      const options = (weekRows || []).map((w) => ({ id: w.id, number: w.week_number }));
      setWeeks(options);
      setWeekId(prev => prev || options[0]?.id || '');
      setLoading(false);
    }
    load();
    return () => { mounted = false; };
  }, [region]);

  useEffect(() => {
    let mounted = true;
    async function load() {
      if (!supabase || !weekId) return;
      const { data } = await supabase.rpc('my_week_points', { target_week: weekId });
      if (mounted) setRows((data as PointRow[]) || []);
    }
    load();
    return () => { mounted = false; };
  }, [weekId]);

  if (loading) return <div className="historyWrap"><section className="panel"><div className="cloudLoading">LOADING YOUR POINT LEDGER…</div></section></div>;

  const total = rows.reduce((sum, r) => sum + Number(r.points), 0);
  const predictionRows = rows.filter(r => r.category === 'prediction');
  const week = weeks.find(w => w.id === weekId);

  return <div className="historyWrap">
    <div className="historySummary">
      <div><small>WEEK {week?.number ?? '—'} POINTS</small><strong>{total.toLocaleString()}</strong><span>pts</span></div>
      <div><small>PREDICTION AWARDS</small><strong>{predictionRows.length}</strong></div>
      <div><small>WEEK</small>
        <select className="historyWeekPick" value={weekId} onChange={e => setWeekId(e.target.value)}>
          {weeks.map(w => <option key={w.id} value={w.id}>WEEK {w.number}</option>)}
        </select>
      </div>
    </div>
    <section className="panel">
      <div className="panelHead">
        <div><h2>Week {week?.number ?? ''} point ledger</h2><p>Awarded from verified official results</p></div>
        <span className="finalized">{rows.length ? '✓ FROM LEDGER' : 'NO AWARDS YET'}</span>
      </div>
      {rows.length === 0
        ? <p className="adminEmptyNote" style={{ margin: 16 }}>No points recorded for this week yet. Points appear after an administrator verifies results and runs scoring.</p>
        : <div className="historyTable">
            <div className="historyHead"><span>TYPE</span><span>DETAIL</span><span>WHEN</span><span>POINTS</span></div>
            {rows.map((r, i) => <div className="historyRow" key={i}>
              <span>{r.reason_code.replace('prediction_', '').replace('fantasy_', 'fantasy ').replace('_', ' ').toUpperCase()}</span>
              <b>{r.description}</b>
              <em className="correct">{new Date(r.created_at).toLocaleDateString()}</em>
              <strong className={Number(r.points) > 0 ? 'earned' : ''}>{Number(r.points) > 0 ? `+${Number(r.points)}` : Number(r.points)}</strong>
            </div>)}
          </div>}
    </section>
    <div className="pointsExplain"><span>i</span><p><b>Every point is traceable.</b> This ledger is append-only — corrections create reversing transactions instead of editing history.</p></div>
  </div>;
}
