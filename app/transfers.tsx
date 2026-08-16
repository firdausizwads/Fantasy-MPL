'use client';

import { useEffect, useMemo, useState } from 'react';
import { supabase } from '../lib/supabase/client';

type Region = 'MY' | 'ID' | 'PH';

type LeagueOption = { id: string; name: string; seasonId: string; transferLimit: number; status: string };

type PoolPlayer = {
  id: string;
  handle: string;
  role: string;
  teamId: string;
  teamCode: string;
  teamName: string;
  photo?: string;
  owned: boolean;
  ownerIsMe: boolean;
};

export default function CloudTransfers({
  region,
  userId,
  notify
}: {
  region: Region;
  userId: string;
  notify: (message: string) => void;
}) {
  const [leagues, setLeagues] = useState<LeagueOption[]>([]);
  const [leagueId, setLeagueId] = useState('');
  const [pool, setPool] = useState<PoolPlayer[]>([]);
  const [used, setUsed] = useState(0);
  const [outId, setOutId] = useState('');
  const [inId, setInId] = useState('');
  const [busy, setBusy] = useState(false);
  const [loading, setLoading] = useState(true);
  const [reloadKey, setReloadKey] = useState(0);

  const league = leagues.find(l => l.id === leagueId);
  const remaining = Math.max(0, (league?.transferLimit ?? 3) - used);

  useEffect(() => {
    let mounted = true;
    async function load() {
      if (!supabase) return;
      setLoading(true);
      const { data: season } = await supabase.from('seasons').select('id')
        .eq('region_code', region).eq('season_number', 18).maybeSingle();
      if (!season) { if (mounted) setLoading(false); return; }

      const { data: memberships } = await supabase.from('league_members')
        .select('league_id').eq('user_id', userId).eq('status', 'active');
      const ids = (memberships || []).map((m) => m.league_id);
      if (!ids.length) { if (mounted) { setLeagues([]); setLoading(false); } return; }

      const { data: leagueRows } = await supabase.from('fantasy_leagues')
        .select('id,name,season_id,transfer_limit,status')
        .in('id', ids).eq('season_id', season.id).eq('status', 'active');
      if (!mounted) return;
      const options = (leagueRows || []).map((l) => ({
        id: l.id, name: l.name, seasonId: l.season_id,
        transferLimit: l.transfer_limit, status: l.status
      }));
      setLeagues(options);
      setLeagueId(prev => options.some(o => o.id === prev) ? prev : options[0]?.id || '');
      setLoading(false);
    }
    load();
    return () => { mounted = false; };
  }, [region, userId]);

  useEffect(() => {
    let mounted = true;
    async function load() {
      if (!supabase || !leagueId || !league) return;
      const [{ data: rosterRows }, { data: ownershipRows }, { data: usedCount }] = await Promise.all([
        supabase.from('season_rosters')
          .select('player_id,role,team_id,players(handle,photo_url),teams(code,name)')
          .eq('season_id', league.seasonId).eq('active', true)
          .in('role', ['EXP', 'JUNGLE', 'MID', 'GOLD', 'ROAM']),
        supabase.from('player_ownership')
          .select('player_id,user_id')
          .eq('league_id', leagueId).is('released_at', null),
        supabase.rpc('transfers_used', { target_league: leagueId, target_user: userId })
      ]);
      if (!mounted) return;
      const ownership: Record<string, string> = {};
      (ownershipRows || []).forEach((o) => { ownership[o.player_id] = o.user_id; });
      setPool((rosterRows || []).map((r) => ({
        id: r.player_id,
        handle: r.players?.handle || 'PLAYER',
        role: r.role,
        teamId: r.team_id,
        teamCode: r.teams?.code || '—',
        teamName: r.teams?.name || 'TEAM',
        photo: r.players?.photo_url || undefined,
        owned: Boolean(ownership[r.player_id]),
        ownerIsMe: ownership[r.player_id] === userId
      })));
      setUsed(typeof usedCount === 'number' ? usedCount : 0);
      setOutId('');
      setInId('');
    }
    load();
    return () => { mounted = false; };
  }, [leagueId, league?.seasonId, userId, reloadKey]);

  const myRoster = useMemo(() => pool.filter(p => p.ownerIsMe), [pool]);
  const outPlayer = pool.find(p => p.id === outId);
  const myTeamIds = useMemo(
    () => new Set(myRoster.filter(p => p.id !== outId).map(p => p.teamId)),
    [myRoster, outId]
  );
  const available = useMemo(() => {
    if (!outPlayer) return [] as PoolPlayer[];
    return pool
      .filter(p => !p.owned && p.role === outPlayer.role && !myTeamIds.has(p.teamId))
      .sort((a, b) => a.teamCode.localeCompare(b.teamCode) || a.handle.localeCompare(b.handle));
  }, [pool, outPlayer, myTeamIds]);

  async function confirm() {
    if (!supabase || !outId || !inId) return;
    setBusy(true);
    const { error } = await supabase.rpc('make_transfer', {
      target_league: leagueId, player_out: outId, player_in: inId
    });
    setBusy(false);
    if (error) { notify(error.message); return; }
    const inName = pool.find(p => p.id === inId)?.handle || 'Player';
    const outName = outPlayer?.handle || 'player';
    notify(`${inName} transferred in for ${outName}.`);
    setReloadKey(k => k + 1);
  }

  if (loading) return <section className="panel transfersPanel"><div className="cloudLoading">LOADING TRANSFER MARKET…</div></section>;
  if (!leagues.length) return null;

  return <section className="panel transfersPanel">
    <div className="standingsHead">
      <div>
        <span className="adminCloudTag">● SERVER-ENFORCED FREE AGENCY</span>
        <h2>Transfer market</h2>
      </div>
      <div className="transferMeta">
        {leagues.length > 1 && <select value={leagueId} onChange={e => setLeagueId(e.target.value)}>
          {leagues.map(l => <option key={l.id} value={l.id}>{l.name}</option>)}
        </select>}
        <span className={`transferPill ${remaining === 0 ? 'spent' : ''}`}>
          {remaining} / {league?.transferLimit ?? 3} TRANSFERS LEFT
        </span>
      </div>
    </div>

    <div className="transferColumns">
      <div>
        <h3>1 · Release from your roster</h3>
        <div className="transferList">
          {myRoster.map(p => <button key={p.id} className={outId === p.id ? 'selected' : ''} disabled={remaining === 0} onClick={() => { setOutId(p.id); setInId(''); }}>
            <i>{p.photo ? <img src={p.photo} alt={`${p.handle} profile`} /> : <b>PP</b>}</i>
            <span><strong>{p.handle}</strong><small>{p.role} · {p.teamName}</small></span>
            <em>{outId === p.id ? '✓ OUT' : 'SELECT'}</em>
          </button>)}
        </div>
      </div>
      <div>
        <h3>2 · Sign a free agent {outPlayer ? `· ${outPlayer.role}` : ''}</h3>
        {!outPlayer
          ? <p className="adminEmptyNote">Select a player to release first. Free agents of the same role appear here.</p>
          : available.length === 0
            ? <p className="adminEmptyNote">No eligible free agents — everyone in this role is owned or conflicts with your team rule.</p>
            : <div className="transferList">
                {available.map(p => <button key={p.id} className={inId === p.id ? 'selected' : ''} onClick={() => setInId(p.id)}>
                  <i>{p.photo ? <img src={p.photo} alt={`${p.handle} profile`} /> : <b>PP</b>}</i>
                  <span><strong>{p.handle}</strong><small>{p.role} · {p.teamName}</small></span>
                  <em>{inId === p.id ? '✓ IN' : 'SIGN'}</em>
                </button>)}
              </div>}
      </div>
    </div>

    <div className="lineupFooter">
      <div className="lineupFooterInfo">
        <span className={outId && inId ? 'ready' : 'pending'}>{outId && inId ? '✓' : '!'}</span>
        <p>{remaining === 0
          ? 'No transfers remaining this split.'
          : outId && inId
            ? `${pool.find(p => p.id === outId)?.handle} → ${pool.find(p => p.id === inId)?.handle} — confirmed server-side, announced in league chat.`
            : 'Pick one player out and one free agent in. Role-for-role, one player per pro team.'}</p>
      </div>
      <button className="primary" disabled={!outId || !inId || busy || remaining === 0} onClick={confirm}>
        {busy ? 'PROCESSING…' : 'CONFIRM TRANSFER'}
      </button>
    </div>
  </section>;
}
