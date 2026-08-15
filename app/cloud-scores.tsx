'use client';

import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase/client';

type Region = 'MY' | 'ID' | 'PH';

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
      const { data } = await supabase.rpc('regional_leaderboard', {
        target_region: region, target_season: null, max_rows: 100
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
      const options = (weekRows || []).map((w: any) => ({ id: w.id, number: w.week_number }));
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
