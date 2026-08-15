'use client';

import { useEffect, useMemo, useState } from 'react';
import { supabase } from '../lib/supabase/client';

type Region = 'MY' | 'ID' | 'PH';

type LeagueOption = {
  id: string;
  name: string;
  seasonId: string;
  format: string;
  lineupLocksAt: string | null;
};

type WeekOption = {
  id: string;
  number: number;
  name: string;
  startsAt: string;
  finalized: boolean;
};

type OwnedPlayer = {
  id: string;
  handle: string;
  role: string;
  teamId: string;
  teamCode: string;
  teamName: string;
  photo?: string;
};

type LineupRow = {
  id: string;
  captain_player_id: string | null;
  status: 'draft' | 'submitted' | 'locked' | 'scored';
  submitted_at: string | null;
};

type SlotRow = { id: string; player_id: string; slot_role: string };

const ROLE_SLOTS = ['EXP', 'JUNGLE', 'MID', 'GOLD', 'ROAM'] as const;

export default function CloudLineup({
  region,
  userId,
  notify
}: {
  region: Region;
  userId: string;
  notify: (message: string) => void;
}) {
  const [loading, setLoading] = useState(true);
  const [leagues, setLeagues] = useState<LeagueOption[]>([]);
  const [leagueId, setLeagueId] = useState('');
  const [weeks, setWeeks] = useState<WeekOption[]>([]);
  const [weekId, setWeekId] = useState('');
  const [owned, setOwned] = useState<OwnedPlayer[]>([]);
  const [lineup, setLineup] = useState<LineupRow | null>(null);
  const [slots, setSlots] = useState<SlotRow[]>([]);
  const [busy, setBusy] = useState(false);

  const league = leagues.find(l => l.id === leagueId);
  const week = weeks.find(w => w.id === weekId);
  const deadlinePassed = Boolean(
    league?.lineupLocksAt && Date.now() >= new Date(league.lineupLocksAt).getTime()
  );
  const locked = deadlinePassed || lineup?.status === 'locked' || lineup?.status === 'scored';

  const playerById = useMemo(() => {
    const map: Record<string, OwnedPlayer> = {};
    owned.forEach(p => { map[p.id] = p; });
    return map;
  }, [owned]);

  // ---- Load my drafted leagues for this region ------------------------------

  useEffect(() => {
    let mounted = true;
    async function load() {
      if (!supabase) return;
      setLoading(true);

      const { data: season } = await supabase
        .from('seasons').select('id')
        .eq('region_code', region).eq('season_number', 18).maybeSingle();
      if (!season) { if (mounted) { setLeagues([]); setLoading(false); } return; }

      const { data: myOwnership } = await supabase
        .from('player_ownership')
        .select('league_id')
        .eq('user_id', userId)
        .is('released_at', null);

      const leagueIds = Array.from(new Set((myOwnership || []).map((r: any) => r.league_id)));
      if (!leagueIds.length) { if (mounted) { setLeagues([]); setLoading(false); } return; }

      const [{ data: leagueRows }, { data: weekRows }] = await Promise.all([
        supabase.from('fantasy_leagues')
          .select('id,name,season_id,format,lineup_locks_at,status')
          .in('id', leagueIds)
          .eq('season_id', season.id),
        supabase.from('competition_weeks')
          .select('id,week_number,name,starts_at,finalized_at')
          .eq('season_id', season.id)
          .order('week_number')
      ]);

      if (!mounted) return;
      const options = (leagueRows || []).map((l: any) => ({
        id: l.id, name: l.name, seasonId: l.season_id,
        format: l.format, lineupLocksAt: l.lineup_locks_at
      }));
      const weekOptions = (weekRows || []).map((w: any) => ({
        id: w.id, number: w.week_number, name: w.name,
        startsAt: w.starts_at, finalized: Boolean(w.finalized_at)
      }));
      setLeagues(options);
      setWeeks(weekOptions);
      setLeagueId(prev => prev || options[0]?.id || '');
      const upcoming = weekOptions.find(w => !w.finalized) || weekOptions[weekOptions.length - 1];
      setWeekId(prev => prev || upcoming?.id || '');
      setLoading(false);
    }
    load();
    return () => { mounted = false; };
  }, [region, userId]);

  // ---- Load roster + lineup for the selected league/week --------------------

  useEffect(() => {
    let mounted = true;
    async function load() {
      if (!supabase || !leagueId || !weekId || !league) return;

      const { data: ownership } = await supabase
        .from('player_ownership')
        .select('player_id')
        .eq('league_id', leagueId)
        .eq('user_id', userId)
        .is('released_at', null);

      const playerIds = (ownership || []).map((r: any) => r.player_id);

      const { data: rosterRows } = playerIds.length
        ? await supabase.from('season_rosters')
            .select('player_id,role,team_id,players(handle,photo_url),teams(code,name)')
            .eq('season_id', league.seasonId)
            .eq('active', true)
            .in('player_id', playerIds)
        : { data: [] as any[] };

      const { data: lineupRow } = await supabase
        .from('weekly_lineups')
        .select('id,captain_player_id,status,submitted_at')
        .eq('league_id', leagueId).eq('user_id', userId).eq('week_id', weekId)
        .maybeSingle();

      const { data: slotRows } = lineupRow
        ? await supabase.from('lineup_players')
            .select('id,player_id,slot_role')
            .eq('lineup_id', lineupRow.id)
        : { data: [] as any[] };

      if (!mounted) return;
      setOwned((rosterRows || []).map((r: any) => ({
        id: r.player_id,
        handle: r.players?.handle || 'PLAYER',
        role: r.role,
        teamId: r.team_id,
        teamCode: r.teams?.code || '—',
        teamName: r.teams?.name || 'TEAM',
        photo: r.players?.photo_url || undefined
      })));
      setLineup((lineupRow as LineupRow) || null);
      setSlots((slotRows as SlotRow[]) || []);
    }
    load();
    return () => { mounted = false; };
  }, [leagueId, weekId, league?.seasonId, userId]);

  // ---- Actions ---------------------------------------------------------------

  async function ensureLineup(): Promise<LineupRow | null> {
    if (!supabase) return null;
    if (lineup) return lineup;
    const { data, error } = await supabase
      .from('weekly_lineups')
      .insert({ league_id: leagueId, user_id: userId, week_id: weekId })
      .select('id,captain_player_id,status,submitted_at')
      .single();
    if (error) { notify(error.message); return null; }
    setLineup(data as LineupRow);
    return data as LineupRow;
  }

  async function assign(role: string, player: OwnedPlayer) {
    if (!supabase || locked || busy) return;
    if (player.role !== role) { notify(`${player.handle} plays ${player.role}.`); return; }
    setBusy(true);
    const current = await ensureLineup();
    if (!current) { setBusy(false); return; }

    const existing = slots.find(s => s.slot_role === role);
    if (existing) {
      const { error } = await supabase.from('lineup_players')
        .update({ player_id: player.id, team_id: player.teamId })
        .eq('id', existing.id);
      setBusy(false);
      if (error) { notify(error.message); return; }
      setSlots(prev => prev.map(s => s.id === existing.id ? { ...s, player_id: player.id } : s));
    } else {
      const { data, error } = await supabase.from('lineup_players')
        .insert({ lineup_id: current.id, player_id: player.id, team_id: player.teamId, slot_role: role })
        .select('id,player_id,slot_role').single();
      setBusy(false);
      if (error) { notify(error.message); return; }
      setSlots(prev => [...prev, data as SlotRow]);
    }
    if (current.status === 'submitted') {
      setLineup(l => l ? { ...l, status: 'draft' } : l);
      await supabase.from('weekly_lineups').update({ status: 'draft' }).eq('id', current.id);
    }
    notify(`${player.handle} set as your ${role}.`);
  }

  async function setCaptain(playerId: string) {
    if (!supabase || locked || busy) return;
    const current = await ensureLineup();
    if (!current) return;
    const { error } = await supabase.from('weekly_lineups')
      .update({ captain_player_id: playerId })
      .eq('id', current.id);
    if (error) { notify(error.message); return; }
    setLineup(l => l ? { ...l, captain_player_id: playerId } : l);
    notify(`${playerById[playerId]?.handle || 'Player'} is your captain — 2× points.`);
  }

  async function submit() {
    if (!supabase || !lineup) return;
    setBusy(true);
    const { data, error } = await supabase.rpc('submit_weekly_lineup', { target_lineup: lineup.id });
    setBusy(false);
    if (error) { notify(error.message); return; }
    setLineup(data as LineupRow);
    notify(`Week ${week?.number ?? ''} lineup submitted — locked in Supabase.`);
  }

  // ---- Render ----------------------------------------------------------------

  if (loading) {
    return <section className="panel lineupPanel"><div className="cloudLoading">LOADING YOUR CLOUD ROSTERS…</div></section>;
  }

  if (!leagues.length) {
    return <section className="panel lineupPanel lineupEmpty">
      <span>◇</span>
      <h3>No drafted cloud roster yet</h3>
      <p>Complete a live league draft first. Your drafted players will appear here for weekly lineup and captain selection.</p>
    </section>;
  }

  const filledCount = slots.length;
  const captainId = lineup?.captain_player_id || '';
  const submitted = lineup?.status === 'submitted';
  const canSubmit = filledCount === 5 && Boolean(captainId) && !locked && !busy;

  return <section className="panel lineupPanel">
    <div className="lineupToolbar">
      <div>
        <h2>Weekly lineup & captain</h2>
        <p>Persistent selection saved to Supabase · captain earns 2× points</p>
      </div>
      <div className="lineupSelectors">
        <select value={leagueId} onChange={e => { setLeagueId(e.target.value); setLineup(null); setSlots([]); }}>
          {leagues.map(l => <option key={l.id} value={l.id}>{l.name}</option>)}
        </select>
        <select value={weekId} onChange={e => { setWeekId(e.target.value); setLineup(null); setSlots([]); }}>
          {weeks.map(w => <option key={w.id} value={w.id}>WEEK {w.number}{w.finalized ? ' · FINAL' : ''}</option>)}
        </select>
      </div>
    </div>

    <div className={`lineupStatus ${submitted ? 'submitted' : locked ? 'lockedState' : ''}`}>
      <span>{locked ? '🔒' : submitted ? '✓' : '◷'}</span>
      <p>{locked
        ? 'This lineup is locked. Selections can no longer change.'
        : submitted
          ? `Submitted ${lineup?.submitted_at ? new Date(lineup.submitted_at).toLocaleString() : ''} — you can still update until the deadline.`
          : `${filledCount} / 5 role slots filled${captainId ? ' · captain chosen' : ' · captain pending'}.`}</p>
      {league?.lineupLocksAt && <small>DEADLINE · {new Date(league.lineupLocksAt).toLocaleString()}</small>}
    </div>

    <div className="lineupSlots">
      {ROLE_SLOTS.map(role => {
        const slot = slots.find(s => s.slot_role === role);
        const player = slot ? playerById[slot.player_id] : undefined;
        const candidates = owned.filter(p => p.role === role);
        return <article className={`lineupSlot ${player ? 'filled' : ''} ${player && captainId === player.id ? 'isCaptain' : ''}`} key={role}>
          <small>{role}</small>
          {player
            ? <>
                <i>{player.photo ? <img src={player.photo} alt={`${player.handle} profile`} /> : <b>PHOTO<br />PENDING</b>}</i>
                <strong>{player.handle}</strong>
                <em>{player.teamName}</em>
                <button className={captainId === player.id ? 'captainOn' : ''} disabled={locked} onClick={() => setCaptain(player.id)}>
                  {captainId === player.id ? '★ CAPTAIN · 2×' : 'MAKE CAPTAIN'}
                </button>
              </>
            : <p className="slotHint">{candidates.length ? 'Select below' : 'No drafted player for this role'}</p>}
          {!locked && candidates.length > 0 && (!player || candidates.length > 1) &&
            <div className="slotChoices">
              {candidates.map(c => <button key={c.id} disabled={busy || slot?.player_id === c.id} onClick={() => assign(role, c)}>
                {slot?.player_id === c.id ? `✓ ${c.handle}` : `USE ${c.handle}`}
              </button>)}
            </div>}
        </article>;
      })}
    </div>

    <div className="lineupFooter">
      <p>{locked
        ? 'Lineup locked by the server deadline.'
        : canSubmit
          ? 'Everything is valid — submit to confirm this week.'
          : 'Fill all five roles and choose a captain to submit.'}</p>
      <button className="primary" disabled={!canSubmit} onClick={submit}>
        {submitted ? 'UPDATE SUBMISSION' : 'SUBMIT WEEKLY LINEUP'}
      </button>
    </div>
  </section>;
}
