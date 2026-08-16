'use client';

import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase/client';

type Region = 'MY' | 'ID' | 'PH';

type WeekRow = { id: string; number: number; startsAt: string; endsAt: string; finalized: boolean };
type TeamRow = { id: string; code: string; name: string };
type MatchRow = {
  id: string; weekId: string; scheduledAt: string; status: string; resultState: string;
  homeTeamId: string; awayTeamId: string;
};

export default function AdminFixtures({ region, notify }: { region: Region; notify: (message: string) => void }) {
  const [seasonId, setSeasonId] = useState('');
  const [weeks, setWeeks] = useState<WeekRow[]>([]);
  const [teams, setTeams] = useState<TeamRow[]>([]);
  const [matches, setMatches] = useState<MatchRow[]>([]);
  const [weekId, setWeekId] = useState('');
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  // new week form
  const [newWeekNum, setNewWeekNum] = useState('');
  const [newWeekStart, setNewWeekStart] = useState('');
  const [newWeekEnd, setNewWeekEnd] = useState('');
  // new match form
  const [homeTeam, setHomeTeam] = useState('');
  const [awayTeam, setAwayTeam] = useState('');
  const [matchTime, setMatchTime] = useState('');
  const [bestOf, setBestOf] = useState('3');

  async function loadAll() {
    if (!supabase) return;
    setLoading(true);
    const { data: season } = await supabase.from('seasons').select('id')
      .eq('region_code', region).eq('season_number', 18).maybeSingle();
    if (!season) { setLoading(false); return; }
    setSeasonId(season.id);

    const [{ data: weekRows }, { data: teamRows }, { data: matchRows }] = await Promise.all([
      supabase.from('competition_weeks')
        .select('id,week_number,starts_at,ends_at,finalized_at')
        .eq('season_id', season.id).order('week_number'),
      supabase.from('teams').select('id,code,name')
        .eq('region_code', region).eq('active', true).order('code'),
      supabase.from('matches')
        .select('id,week_id,scheduled_at,status,result_state,home_team_id,away_team_id')
        .eq('season_id', season.id).order('scheduled_at')
    ]);

    const weekOptions = (weekRows || []).map((w) => ({
      id: w.id, number: w.week_number, startsAt: w.starts_at, endsAt: w.ends_at,
      finalized: Boolean(w.finalized_at)
    }));
    setWeeks(weekOptions);
    setWeekId(prev => weekOptions.some((w: WeekRow) => w.id === prev) ? prev : weekOptions[weekOptions.length - 1]?.id || '');
    setTeams((teamRows || []).map((t) => ({ id: t.id, code: t.code, name: t.name })));
    setMatches((matchRows || []).map((m) => ({
      id: m.id, weekId: m.week_id, scheduledAt: m.scheduled_at, status: m.status,
      resultState: m.result_state, homeTeamId: m.home_team_id, awayTeamId: m.away_team_id
    })));
    setLoading(false);
  }

  useEffect(() => { loadAll(); }, [region]);

  const teamName = (id: string) => teams.find(t => t.id === id)?.code || '—';
  const weekMatches = matches.filter(m => m.weekId === weekId);
  const nextWeekNumber = weeks.length ? Math.max(...weeks.map(w => w.number)) + 1 : 1;

  async function createWeek() {
    if (!supabase || !seasonId) return;
    const num = parseInt(newWeekNum || String(nextWeekNumber), 10);
    if (!newWeekStart || !newWeekEnd) { notify('Set the week start and end.'); return; }
    setBusy(true);
    const { error } = await supabase.rpc('admin_upsert_week', {
      target_season: seasonId,
      week_num: num,
      week_starts: new Date(newWeekStart).toISOString(),
      week_ends: new Date(newWeekEnd).toISOString()
    });
    setBusy(false);
    if (error) { notify(error.message); return; }
    notify(`Week ${num} saved.`);
    setNewWeekNum(''); setNewWeekStart(''); setNewWeekEnd('');
    loadAll();
  }

  async function createMatch() {
    if (!supabase || !weekId) return;
    if (!homeTeam || !awayTeam || !matchTime) { notify('Choose both teams and a start time.'); return; }
    if (homeTeam === awayTeam) { notify('A team cannot play itself.'); return; }
    setBusy(true);
    const { error } = await supabase.rpc('admin_create_match', {
      target_week: weekId,
      home_team: homeTeam,
      away_team: awayTeam,
      match_time: new Date(matchTime).toISOString(),
      series_best_of: parseInt(bestOf, 10)
    });
    setBusy(false);
    if (error) { notify(error.message); return; }
    notify('Fixture created — it is live for predictions immediately.');
    setHomeTeam(''); setAwayTeam(''); setMatchTime('');
    loadAll();
  }

  async function reschedule(match: MatchRow) {
    if (!supabase) return;
    const input = prompt('New start time (YYYY-MM-DD HH:MM, local time):',
      new Date(match.scheduledAt).toISOString().slice(0, 16).replace('T', ' '));
    if (!input) return;
    const parsed = new Date(input.replace(' ', 'T'));
    if (isNaN(parsed.getTime())) { notify('Invalid date format.'); return; }
    const { error } = await supabase.rpc('admin_update_match_schedule', {
      target_match: match.id, new_time: parsed.toISOString(), new_status: 'scheduled'
    });
    if (error) { notify(error.message); return; }
    notify('Fixture rescheduled.');
    loadAll();
  }

  async function cancel(match: MatchRow) {
    if (!supabase) return;
    const { error } = await supabase.rpc('admin_update_match_schedule', {
      target_match: match.id, new_status: 'cancelled'
    });
    if (error) { notify(error.message); return; }
    notify('Fixture cancelled.');
    loadAll();
  }

  async function remove(match: MatchRow) {
    if (!supabase) return;
    if (!confirm(`Delete ${teamName(match.homeTeamId)} vs ${teamName(match.awayTeamId)}? Only possible when no predictions exist.`)) return;
    const { error } = await supabase.rpc('admin_delete_match', { target_match: match.id });
    if (error) { notify(error.message); return; }
    notify('Fixture deleted.');
    loadAll();
  }

  if (loading) return <section className="panel adminCloudPanel"><div className="cloudLoading">LOADING FIXTURE MANAGER…</div></section>;

  return <section className="panel adminCloudPanel">
    <div className="adminCloudHead">
      <div>
        <span className="adminCloudTag">● SEASON OPERATIONS · SUPABASE</span>
        <h2>Weeks & fixtures</h2>
        <p>Create competition weeks and schedule official fixtures. New fixtures open for predictions instantly.</p>
      </div>
    </div>

    <div className="fixtureManagerGrid">
      <div className="fixtureFormCard">
        <h3>Create / update week</h3>
        <label>WEEK NUMBER
          <input type="number" min={1} max={30} placeholder={String(nextWeekNumber)} value={newWeekNum} onChange={e => setNewWeekNum(e.target.value)} />
        </label>
        <label>STARTS
          <input type="datetime-local" value={newWeekStart} onChange={e => setNewWeekStart(e.target.value)} />
        </label>
        <label>ENDS
          <input type="datetime-local" value={newWeekEnd} onChange={e => setNewWeekEnd(e.target.value)} />
        </label>
        <button className="primary" disabled={busy} onClick={createWeek}>SAVE WEEK</button>
      </div>

      <div className="fixtureFormCard">
        <h3>Add fixture to <select className="inlineWeekPick" value={weekId} onChange={e => setWeekId(e.target.value)}>
          {weeks.map(w => <option key={w.id} value={w.id}>WEEK {w.number}</option>)}
        </select></h3>
        <div className="fixtureTeamsRow">
          <label>HOME
            <select value={homeTeam} onChange={e => setHomeTeam(e.target.value)}>
              <option value="">TEAM…</option>
              {teams.map(t => <option key={t.id} value={t.id}>{t.code} · {t.name}</option>)}
            </select>
          </label>
          <label>AWAY
            <select value={awayTeam} onChange={e => setAwayTeam(e.target.value)}>
              <option value="">TEAM…</option>
              {teams.filter(t => t.id !== homeTeam).map(t => <option key={t.id} value={t.id}>{t.code} · {t.name}</option>)}
            </select>
          </label>
        </div>
        <div className="fixtureTeamsRow">
          <label>START TIME
            <input type="datetime-local" value={matchTime} onChange={e => setMatchTime(e.target.value)} />
          </label>
          <label>SERIES
            <select value={bestOf} onChange={e => setBestOf(e.target.value)}>
              <option value="1">BO1</option><option value="3">BO3</option>
              <option value="5">BO5</option><option value="7">BO7</option>
            </select>
          </label>
        </div>
        <button className="primary" disabled={busy} onClick={createMatch}>CREATE FIXTURE</button>
      </div>
    </div>

    <h3 className="fixtureListTitle">Week {weeks.find(w => w.id === weekId)?.number ?? '—'} fixtures</h3>
    <div className="adminMatchList">
      {weekMatches.length === 0 && <p className="adminEmptyNote">No fixtures in this week yet.</p>}
      {weekMatches.map(m => <div className={`adminMatchRow ${m.resultState}`} key={m.id}>
        <span className="adminMatchTime">{new Date(m.scheduledAt).toLocaleString(undefined, { weekday: 'short', day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' })}</span>
        <b>{teamName(m.homeTeamId)}</b>
        <strong>VS</strong>
        <b>{teamName(m.awayTeamId)}</b>
        <em className={m.resultState !== 'unverified' ? 'ok' : ''}>
          {m.resultState !== 'unverified' ? '✓ RESULT SAVED' : m.status.toUpperCase()}
        </em>
        <span className="fixtureRowActions">
          {m.resultState === 'unverified' && <>
            <button className="secondary" onClick={() => reschedule(m)}>Reschedule</button>
            {m.status !== 'cancelled' && <button className="secondary" onClick={() => cancel(m)}>Cancel</button>}
            <button className="secondary danger" onClick={() => remove(m)}>Delete</button>
          </>}
        </span>
      </div>)}
    </div>
  </section>;
}
