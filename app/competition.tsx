'use client';

import { useEffect, useMemo, useState } from 'react';
import { supabase } from '../lib/supabase/client';

type Region = 'MY' | 'ID' | 'PH';

const REGION_NAMES: Record<Region, { name: string; timezone: string }> = {
  MY: { name: 'MPL Malaysia', timezone: 'MYT' },
  ID: { name: 'MPL Indonesia', timezone: 'WIB' },
  PH: { name: 'MPL Philippines', timezone: 'PHT' }
};

type WeekOption = { id: string; number: number };

type TeamInfo = { id: string; code: string; name: string; logo: string | null };

type MatchRow = {
  id: string;
  weekId: string;
  scheduledAt: string;
  status: string;
  resultState: string;
  homeTeamId: string;
  awayTeamId: string;
  homeScore: number | null;
  awayScore: number | null;
  winnerTeamId: string | null;
};

type StandingRow = {
  team: TeamInfo;
  matchWins: number;
  matchLosses: number;
  gameWins: number;
  gameLosses: number;
  diff: number;
  points: number;
};

export default function CloudCompetition({
  region,
  PageBanner
}: {
  region: Region;
  PageBanner: (props: { tag: string; title: string; copy: string; side: React.ReactNode; sideLabel: string }) => React.ReactElement;
}) {
  const [tab, setTab] = useState<'schedule' | 'standings'>('schedule');
  const [weeks, setWeeks] = useState<WeekOption[]>([]);
  const [weekId, setWeekId] = useState('');
  const [teams, setTeams] = useState<Record<string, TeamInfo>>({});
  const [matches, setMatches] = useState<MatchRow[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let mounted = true;
    async function load() {
      if (!supabase) return;
      setLoading(true);
      const { data: season } = await supabase.from('seasons').select('id')
        .eq('region_code', region).eq('season_number', 18).maybeSingle();
      if (!season) { if (mounted) setLoading(false); return; }

      const [{ data: weekRows }, { data: teamRows }, { data: matchRows }] = await Promise.all([
        supabase.from('competition_weeks').select('id,week_number')
          .eq('season_id', season.id).order('week_number'),
        supabase.from('teams').select('id,code,name,logo_url').eq('region_code', region),
        supabase.from('matches')
          .select('id,week_id,scheduled_at,status,result_state,home_team_id,away_team_id,home_score,away_score,winner_team_id')
          .eq('season_id', season.id).order('scheduled_at')
      ]);

      if (!mounted) return;
      const weekOptions = (weekRows || []).map((w) => ({ id: w.id, number: w.week_number }));
      setWeeks(weekOptions);
      const now=Date.now();
      const upcoming=(matchRows||[]).find(match=>match.status!=='cancelled'&&new Date(match.scheduled_at).getTime()>=now);
      const latestWithMatches=(matchRows||[]).filter(match=>match.status!=='cancelled').at(-1);
      const automaticWeekId=upcoming?.week_id||latestWithMatches?.week_id||weekOptions[0]?.id||'';
      setWeekId(prev=>weekOptions.some(option=>option.id===prev)?prev:automaticWeekId);
      const teamMap: Record<string, TeamInfo> = {};
      (teamRows || []).forEach((t) => {
        teamMap[t.id] = { id: t.id, code: t.code, name: t.name, logo: t.logo_url };
      });
      setTeams(teamMap);
      setMatches((matchRows || []).map((m) => ({
        id: m.id,
        weekId: m.week_id,
        scheduledAt: m.scheduled_at,
        status: m.status,
        resultState: m.result_state,
        homeTeamId: m.home_team_id,
        awayTeamId: m.away_team_id,
        homeScore: m.home_score,
        awayScore: m.away_score,
        winnerTeamId: m.winner_team_id
      })));
      setLoading(false);
    }
    load();
    return () => { mounted = false; };
  }, [region]);

  const weekMatches = useMemo(
    () => matches.filter(m => m.weekId === weekId),
    [matches, weekId]
  );

  const dayGroups = useMemo(() => {
    const groups: { key: string; label: Date; items: MatchRow[] }[] = [];
    weekMatches.forEach(m => {
      const d = new Date(m.scheduledAt);
      const key = d.toDateString();
      let group = groups.find(g => g.key === key);
      if (!group) { group = { key, label: d, items: [] }; groups.push(group); }
      group.items.push(m);
    });
    return groups;
  }, [weekMatches]);

  const standings: StandingRow[] = useMemo(() => {
    const table: Record<string, StandingRow> = {};
    Object.values(teams).forEach(t => {
      table[t.id] = { team: t, matchWins: 0, matchLosses: 0, gameWins: 0, gameLosses: 0, diff: 0, points: 0 };
    });
    matches
      .filter(m => (m.resultState === 'verified' || m.resultState === 'finalized')
        && m.homeScore !== null && m.awayScore !== null)
      .forEach(m => {
        const home = table[m.homeTeamId];
        const away = table[m.awayTeamId];
        if (!home || !away) return;
        home.gameWins += m.homeScore!; home.gameLosses += m.awayScore!;
        away.gameWins += m.awayScore!; away.gameLosses += m.homeScore!;
        // Official MPL format: 1 match win = 1 point, loss = 0.
        if (m.winnerTeamId === m.homeTeamId) {
          home.matchWins += 1; away.matchLosses += 1;
          home.points += 1;
        } else if (m.winnerTeamId === m.awayTeamId) {
          away.matchWins += 1; home.matchLosses += 1;
          away.points += 1;
        }
      });
    Object.values(table).forEach(row => { row.diff = row.gameWins - row.gameLosses; });
    // Ranking rules (official MPL regular season):
    // 1. Match points — 1 per match win, 0 per loss
    // 2. Aggregate (game diff) — -1 ranks above -2, 0 above any negative
    // 3. Fewer matches played — same points and aggregate from fewer matches is better
    //    (a team with games in hand ranks above one that already spent its matches)
    // 4. Game wins, then name
    return Object.values(table).sort((a, b) =>
      b.points - a.points
      || b.diff - a.diff
      || (a.matchWins + a.matchLosses) - (b.matchWins + b.matchLosses)
      || b.gameWins - a.gameWins
      || a.team.name.localeCompare(b.team.name));
  }, [matches, teams]);

  const verifiedCount = matches.filter(m => m.resultState === 'verified' || m.resultState === 'finalized').length;
  const info = REGION_NAMES[region];
  const week = weeks.find(w => w.id === weekId);

  if (loading) {
    return <div className="page"><section className="panel"><div className="cloudLoading">LOADING OFFICIAL COMPETITION DATA…</div></section></div>;
  }

  return <div className="page">
    <PageBanner
      tag={`${info.name.toUpperCase()} · SEASON 18`}
      title="Schedule & Standings"
      copy={`Current regional schedule and official standings · times shown in your local timezone (${info.timezone} region).`}
      side={`WEEK ${week?.number ?? '—'}`}
      sideLabel="REGULAR SEASON" />

    <div className="competitionTabs">
      <button className={tab === 'schedule' ? 'active' : ''} onClick={() => setTab('schedule')}>Match schedule</button>
      <button className={tab === 'standings' ? 'active' : ''} onClick={() => setTab('standings')}>League standings</button>
    </div>

    {tab === 'schedule'
      ? <>
          <div className="fixtureToolbar">
            <div>
              {weeks.map(w => <button key={w.id} className={w.id === weekId ? 'active' : ''} onClick={() => setWeekId(w.id)}>WEEK {w.number}</button>)}
            </div>
            <span>● CURRENT REGIONAL SCHEDULE & RESULTS</span>
          </div>
          {dayGroups.length === 0
            ? <p className="adminEmptyNote">No fixtures recorded for this week yet.</p>
            : <div className="fixtureDays">
                {dayGroups.map(group => <section className="fixtureDay" key={group.key}>
                  <div className="fixtureDate">
                    <span>{group.label.getDate()}</span>
                    <div>
                      <b>{group.label.toLocaleDateString(undefined, { month: 'short' }).toUpperCase()}</b>
                      <small>{group.label.toLocaleDateString(undefined, { weekday: 'long' }).toUpperCase()}</small>
                    </div>
                  </div>
                  <div className="fixtureList">
                    {group.items.map(m => {
                      const home = teams[m.homeTeamId];
                      const away = teams[m.awayTeamId];
                      const done = (m.resultState === 'verified' || m.resultState === 'finalized') && m.homeScore !== null;
                      return <div className={`fixtureRow ${done ? 'completed' : 'scheduled'}`} key={m.id}>
                        <span className="fixtureTime">
                          {new Date(m.scheduledAt).toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit' })}
                          <small>{done ? 'FINAL' : 'SCHEDULED'}</small>
                        </span>
                        <div className="fixtureTeam home">
                          <b>{home?.name || 'TBD'}</b>
                          {home?.logo && <img src={home.logo} alt={`${home.name} logo`} />}
                        </div>
                        <strong>{done ? `${m.homeScore} – ${m.awayScore}` : 'VS'}</strong>
                        <div className="fixtureTeam">
                          {away?.logo && <img src={away.logo} alt={`${away.name} logo`} />}
                          <b>{away?.name || 'TBD'}</b>
                        </div>
                        <em className={`fixtureState ${done ? 'ok' : ''}`}>{done ? '✓ VERIFIED' : '◷'}</em>
                      </div>;
                    })}
                  </div>
                </section>)}
              </div>}
          <div className="scheduleSource"><span>✓</span><p><b>Current schedule:</b> fixtures update from the regional competition feed. Final scores appear after administrator verification.</p></div>
        </>
      : verifiedCount === 0
        ? <section className="standingsPending">
            <h2>Official table pending results</h2>
            <p>The regional table is computed from verified results only. It will fill in as soon as the first official result is saved in the admin console.</p>
            <span>DATA INTEGRITY FIRST</span>
          </section>
        : <section className="panel officialStandings">
            <div className="standingTableHead"><span>#</span><span>TEAM</span><span>MATCH W–L</span><span>GAME W–L</span><span>MATCH PTS</span><span>AGGREGATE</span></div>
            {standings.map((row, i) => <div className="officialStandingRow" key={row.team.id}>
              <strong>{i + 1}</strong>
              <span>{row.team.logo && <img src={row.team.logo} alt={`${row.team.name} logo`} />}<b>{row.team.name}</b></span>
              <span>{row.matchWins}–{row.matchLosses}</span>
              <span>{row.gameWins}–{row.gameLosses}</span>
              <strong>{row.points}</strong>
              <span className={row.diff > 0 ? 'aggUp' : row.diff < 0 ? 'aggDown' : ''}>{row.diff > 0 ? `+${row.diff}` : row.diff}</span>
            </div>)}
            <div className="standingFoot">1 match win = 1 point · ties broken by aggregate, then game wins — computed live from {verifiedCount} verified result{verifiedCount === 1 ? '' : 's'}</div>
          </section>}
  </div>;
}
