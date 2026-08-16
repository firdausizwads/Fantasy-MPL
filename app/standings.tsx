'use client';

import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase/client';

type Region = 'MY' | 'ID' | 'PH';

type LeagueOption = { id: string; name: string };

type StandingRow = {
  user_id: string;
  manager_name: string;
  country_code: string;
  total_points: number;
  weeks_scored: number;
};

type WeekPoints = { description: string; points: number; created_at: string };

export default function LeagueStandings({ region, userId, notify }: { region: Region; userId: string; notify: (message: string) => void }) {
  const [leagues, setLeagues] = useState<LeagueOption[]>([]);
  const [leagueId, setLeagueId] = useState('');
  const [rows, setRows] = useState<StandingRow[]>([]);
  const [myBreakdown, setMyBreakdown] = useState<WeekPoints[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let mounted = true;
    async function load() {
      if (!supabase) return;
      const { data: season } = await supabase.from('seasons').select('id')
        .eq('region_code', region).eq('season_number', 18).maybeSingle();
      if (!season) { if (mounted) setLoading(false); return; }

      const { data: memberships } = await supabase.from('league_members')
        .select('league_id').eq('user_id', userId).eq('status', 'active');
      const ids = (memberships || []).map((m) => m.league_id);
      if (!ids.length) { if (mounted) { setLeagues([]); setLoading(false); } return; }

      const { data: leagueRows } = await supabase.from('fantasy_leagues')
        .select('id,name').in('id', ids).eq('season_id', season.id);
      if (!mounted) return;
      const options = (leagueRows || []).map((l) => ({ id: l.id, name: l.name }));
      setLeagues(options);
      setLeagueId(prev => prev || options[0]?.id || '');
      setLoading(false);
    }
    load();
    return () => { mounted = false; };
  }, [region, userId]);

  useEffect(() => {
    let mounted = true;
    async function load() {
      if (!supabase || !leagueId) { setRows([]); setMyBreakdown([]); return; }
      const [{ data: standing, error }, { data: mine }] = await Promise.all([
        supabase.rpc('league_standings', { target_league: leagueId }),
        supabase.from('score_transactions')
          .select('description,points,created_at')
          .eq('league_id', leagueId).eq('user_id', userId).eq('category', 'fantasy')
          .order('created_at', { ascending: false }).limit(12)
      ]);
      if (!mounted) return;
      if (error) { notify(error.message); return; }
      setRows((standing as StandingRow[]) || []);
      setMyBreakdown((mine as WeekPoints[]) || []);
    }
    load();
    return () => { mounted = false; };
  }, [leagueId, userId]);

  if (loading) return <section className="panel standingsPanel"><div className="cloudLoading">LOADING LEAGUE STANDINGS…</div></section>;
  if (!leagues.length) return null;

  return <section className="panel standingsPanel">
    <div className="standingsHead">
      <div>
        <span className="adminCloudTag">● REAL POINTS · SCORED FROM OFFICIAL RESULTS</span>
        <h2>League standings</h2>
      </div>
      {leagues.length > 1 && <select value={leagueId} onChange={e => setLeagueId(e.target.value)}>
        {leagues.map(l => <option key={l.id} value={l.id}>{l.name}</option>)}
      </select>}
    </div>

    {rows.length === 0
      ? <p className="adminEmptyNote">No scored weeks yet. Standings appear after the first scoring run.</p>
      : <div className="standingsTable">
          <div className="standingsHeader"><span>#</span><span>MANAGER</span><span>WEEKS</span><span>POINTS</span></div>
          {rows.map((r, i) => <div className={`standingsRow ${r.user_id === userId ? 'me' : ''}`} key={r.user_id}>
            <span className={`standRank r${i + 1}`}>{i + 1}</span>
            <b>{r.manager_name}{r.user_id === userId ? ' · YOU' : ''}</b>
            <em>{r.weeks_scored}</em>
            <strong>{Number(r.total_points).toLocaleString()} PTS</strong>
          </div>)}
        </div>}

    {myBreakdown.length > 0 && <>
      <h3 className="breakdownTitle">Your recent point transactions</h3>
      <div className="breakdownList">
        {myBreakdown.map((t, i) => <div className="breakdownRow" key={i}>
          <span>{new Date(t.created_at).toLocaleDateString()}</span>
          <p>{t.description}</p>
          <b className={Number(t.points) >= 0 ? 'gain' : 'loss'}>{Number(t.points) >= 0 ? '+' : ''}{Number(t.points)}</b>
        </div>)}
      </div>
    </>}
  </section>;
}
