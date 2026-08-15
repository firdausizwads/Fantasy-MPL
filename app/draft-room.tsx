'use client';

import { useEffect, useMemo, useRef, useState } from 'react';
import { supabase } from '../lib/supabase/client';

type Region = 'MY' | 'ID' | 'PH';

type DraftRow = {
  id: string;
  league_id: string;
  status: 'waiting' | 'active' | 'paused' | 'completed' | 'cancelled';
  manager_count: number | null;
  roster_size: number;
  current_pick_number: number;
  scheduled_at: string | null;
  started_at: string | null;
  completed_at: string | null;
  turn_expires_at: string | null;
};

type Member = {
  user_id: string;
  draft_position: number;
  member_role: string;
  name: string;
};

type PoolPlayer = {
  id: string;
  handle: string;
  role: string;
  teamId: string;
  teamCode: string;
  teamName: string;
  photo?: string;
};

type PickRow = {
  id: string;
  user_id: string;
  player_id: string;
  pick_number: number;
  round_number: number;
  auto_picked: boolean;
};

type ChatMessage = {
  id: string;
  user_id: string;
  message: string;
  message_type: string;
  created_at: string;
};

type Reaction = { id: string; message_id: string; user_id: string; reaction: string };

const ROLES = ['EXP', 'JUNGLE', 'MID', 'GOLD', 'ROAM'];
const REACTIONS: { code: 'GG' | 'NICE' | 'META' | 'FIRE'; label: string }[] = [
  { code: 'GG', label: 'GG' },
  { code: 'NICE', label: 'NICE' },
  { code: 'META', label: 'META' },
  { code: 'FIRE', label: '🔥' }
];

function snakePosition(pickNumber: number, managerCount: number) {
  const round = Math.floor((pickNumber - 1) / managerCount) + 1;
  const slot = ((pickNumber - 1) % managerCount) + 1;
  const position = round % 2 === 1 ? slot : managerCount - slot + 1;
  return { round, position };
}

export default function CloudDraftRoom({
  leagueId,
  leagueName,
  region,
  userId,
  close,
  notify
}: {
  leagueId: string;
  leagueName: string;
  region: Region;
  userId: string;
  close: () => void;
  notify: (message: string) => void;
}) {
  const [loading, setLoading] = useState(true);
  const [pickSeconds, setPickSeconds] = useState(60);
  const [draft, setDraft] = useState<DraftRow | null>(null);
  const [members, setMembers] = useState<Member[]>([]);
  const [pool, setPool] = useState<PoolPlayer[]>([]);
  const [picks, setPicks] = useState<PickRow[]>([]);
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [reactions, setReactions] = useState<Reaction[]>([]);
  const [chatInput, setChatInput] = useState('');
  const [filter, setFilter] = useState('All');
  const [search, setSearch] = useState('');
  const [scheduleAt, setScheduleAt] = useState('');
  const [remaining, setRemaining] = useState<number | null>(null);
  const [busy, setBusy] = useState(false);
  const autoPickAttemptedFor = useRef(0);
  const chatEndRef = useRef<HTMLDivElement | null>(null);

  const isCommissioner = useMemo(
    () => members.some(m => m.user_id === userId && ['commissioner', 'moderator'].includes(m.member_role)),
    [members, userId]
  );

  const memberName = useMemo(() => {
    const map: Record<string, string> = {};
    members.forEach(m => { map[m.user_id] = m.name; });
    return (id: string) => map[id] || 'MANAGER';
  }, [members]);

  const playerById = useMemo(() => {
    const map: Record<string, PoolPlayer> = {};
    pool.forEach(p => { map[p.id] = p; });
    return map;
  }, [pool]);

  // ---- Initial load ---------------------------------------------------------

  useEffect(() => {
    let mounted = true;

    async function load() {
      if (!supabase) return;

      const { data: league, error: leagueError } = await supabase
        .from('fantasy_leagues')
        .select('season_id,pick_seconds')
        .eq('id', leagueId)
        .single();
      if (leagueError || !league) { notify(leagueError?.message || 'League not found.'); return; }

      const [draftRes, memberRes, rosterRes] = await Promise.all([
        supabase.from('drafts').select('*').eq('league_id', leagueId).maybeSingle(),
        supabase.from('league_members')
          .select('user_id,draft_position,member_role,status')
          .eq('league_id', leagueId).eq('status', 'active')
          .order('draft_position'),
        supabase.from('season_rosters')
          .select('player_id,role,team_id,players(handle,photo_url),teams(code,name)')
          .eq('season_id', league.season_id)
          .eq('active', true)
          .in('role', ROLES)
      ]);

      const userIds = (memberRes.data || []).map((m: any) => m.user_id);
      const { data: profiles } = userIds.length
        ? await supabase.from('profiles').select('id,manager_name').in('id', userIds)
        : { data: [] as any[] };

      if (!mounted) return;

      setPickSeconds(league.pick_seconds || 60);
      setDraft((draftRes.data as DraftRow) || null);
      setMembers((memberRes.data || []).map((m: any) => ({
        user_id: m.user_id,
        draft_position: m.draft_position || 99,
        member_role: m.member_role,
        name: (profiles || []).find((p: any) => p.id === m.user_id)?.manager_name || 'MANAGER'
      })));
      setPool((rosterRes.data || []).map((r: any) => ({
        id: r.player_id,
        handle: r.players?.handle || 'PLAYER',
        role: r.role,
        teamId: r.team_id,
        teamCode: r.teams?.code || '—',
        teamName: r.teams?.name || 'TEAM',
        photo: r.players?.photo_url || undefined
      })));

      if (draftRes.data) {
        const [{ data: pickRows }, { data: chatRows }] = await Promise.all([
          supabase.from('draft_picks')
            .select('id,user_id,player_id,pick_number,round_number,auto_picked')
            .eq('league_id', leagueId).order('pick_number'),
          supabase.from('league_chat_messages')
            .select('id,user_id,message,message_type,created_at')
            .eq('league_id', leagueId)
            .is('removed_at', null)
            .order('created_at', { ascending: false })
            .limit(50)
        ]);
        if (!mounted) return;
        setPicks((pickRows as PickRow[]) || []);
        const orderedChat = ((chatRows as ChatMessage[]) || []).reverse();
        setMessages(orderedChat);
        const messageIds = orderedChat.map(m => m.id);
        if (messageIds.length) {
          const { data: reactionRows } = await supabase
            .from('league_chat_reactions')
            .select('id,message_id,user_id,reaction')
            .in('message_id', messageIds);
          if (mounted) setReactions((reactionRows as Reaction[]) || []);
        }
      } else {
        const { data: chatRows } = await supabase.from('league_chat_messages')
          .select('id,user_id,message,message_type,created_at')
          .eq('league_id', leagueId)
          .is('removed_at', null)
          .order('created_at', { ascending: false })
          .limit(50);
        if (mounted) setMessages(((chatRows as ChatMessage[]) || []).reverse());
      }

      setLoading(false);
    }

    load();
    return () => { mounted = false; };
  }, [leagueId]);

  // ---- Realtime subscriptions -----------------------------------------------

  useEffect(() => {
    if (!supabase) return;
    const channel = supabase
      .channel(`draft-room-${leagueId}`)
      .on('postgres_changes',
        { event: '*', schema: 'public', table: 'drafts', filter: `league_id=eq.${leagueId}` },
        payload => { if (payload.new) setDraft(payload.new as DraftRow); })
      .on('postgres_changes',
        { event: 'INSERT', schema: 'public', table: 'draft_picks', filter: `league_id=eq.${leagueId}` },
        payload => {
          const pick = payload.new as PickRow;
          setPicks(prev => prev.some(p => p.id === pick.id) ? prev : [...prev, pick].sort((a, b) => a.pick_number - b.pick_number));
        })
      .on('postgres_changes',
        { event: 'INSERT', schema: 'public', table: 'league_members', filter: `league_id=eq.${leagueId}` },
        async payload => {
          if (!supabase) return;
          const row: any = payload.new;
          const { data: profile } = await supabase.from('profiles').select('manager_name').eq('id', row.user_id).maybeSingle();
          setMembers(prev => prev.some(m => m.user_id === row.user_id) ? prev : [...prev, {
            user_id: row.user_id,
            draft_position: row.draft_position || 99,
            member_role: row.member_role,
            name: profile?.manager_name || 'MANAGER'
          }].sort((a, b) => a.draft_position - b.draft_position));
        })
      .on('postgres_changes',
        { event: 'INSERT', schema: 'public', table: 'league_chat_messages', filter: `league_id=eq.${leagueId}` },
        payload => {
          const message = payload.new as ChatMessage;
          setMessages(prev => prev.some(m => m.id === message.id) ? prev : [...prev.slice(-79), message]);
        })
      .on('postgres_changes',
        { event: 'INSERT', schema: 'public', table: 'league_chat_reactions' },
        payload => {
          const reaction = payload.new as Reaction;
          setReactions(prev => prev.some(r => r.id === reaction.id) ? prev : [...prev, reaction]);
        })
      .on('postgres_changes',
        { event: 'DELETE', schema: 'public', table: 'league_chat_reactions' },
        payload => {
          const removed: any = payload.old;
          setReactions(prev => prev.filter(r => r.id !== removed.id));
        })
      .subscribe();

    return () => { supabase?.removeChannel(channel); };
  }, [leagueId]);

  useEffect(() => { chatEndRef.current?.scrollIntoView({ behavior: 'smooth' }); }, [messages]);

  // ---- Turn + timer ----------------------------------------------------------

  const managerCount = draft?.manager_count || members.length;
  const nextPickNumber = (draft?.current_pick_number || 0) + 1;
  const { round, position } = managerCount
    ? snakePosition(nextPickNumber, managerCount)
    : { round: 1, position: 1 };
  const onClock = members.find(m => m.draft_position === position);
  const myTurn = draft?.status === 'active' && onClock?.user_id === userId;
  const totalPicks = managerCount * (draft?.roster_size || 5);

  useEffect(() => {
    if (!draft || draft.status !== 'active' || !draft.turn_expires_at) { setRemaining(null); return; }
    const tick = () => {
      const secondsLeft = Math.round((new Date(draft.turn_expires_at as string).getTime() - Date.now()) / 1000);
      setRemaining(secondsLeft);
      if (secondsLeft <= -1 && supabase && autoPickAttemptedFor.current !== nextPickNumber) {
        autoPickAttemptedFor.current = nextPickNumber;
        supabase.rpc('auto_pick_expired_turn', { target_draft: draft.id }).then(({ error }) => {
          if (error && !/not expired|not active/i.test(error.message)) notify(error.message);
        });
      }
    };
    tick();
    const interval = window.setInterval(tick, 500);
    return () => window.clearInterval(interval);
  }, [draft?.turn_expires_at, draft?.status, nextPickNumber]);

  // ---- Eligibility -----------------------------------------------------------

  const ownedIds = useMemo(() => new Set(picks.map(p => p.player_id)), [picks]);
  const myPicks = picks.filter(p => p.user_id === userId);
  const myRoles = new Set(myPicks.map(p => playerById[p.player_id]?.role));
  const myTeams = new Set(myPicks.map(p => playerById[p.player_id]?.teamId));

  function eligibility(player: PoolPlayer): string | null {
    if (ownedIds.has(player.id)) return 'OWNED';
    if (myRoles.has(player.role)) return 'ROLE TAKEN';
    if (myTeams.has(player.teamId)) return 'TEAM TAKEN';
    return null;
  }

  // ---- Actions ---------------------------------------------------------------

  async function ensureDraft(withSchedule?: string) {
    if (!supabase) return;
    setBusy(true);
    const { data, error } = await supabase.rpc('ensure_league_draft', {
      target_league: leagueId,
      schedule_at: withSchedule ? new Date(withSchedule).toISOString() : null
    });
    setBusy(false);
    if (error) { notify(error.message); return; }
    setDraft(data as DraftRow);
    notify(withSchedule ? 'Draft scheduled for all managers.' : 'Draft room created.');
  }

  async function startDraft() {
    if (!supabase) return;
    setBusy(true);
    let draftId = draft?.id;
    if (!draftId) {
      const { data, error } = await supabase.rpc('ensure_league_draft', { target_league: leagueId, schedule_at: null });
      if (error) { notify(error.message); setBusy(false); return; }
      draftId = (data as DraftRow).id;
      setDraft(data as DraftRow);
    }
    const { error } = await supabase.rpc('start_league_draft', { target_draft: draftId });
    setBusy(false);
    if (error) { notify(error.message); return; }
    notify('Draft is live — good luck managers!');
  }

  async function makePick(player: PoolPlayer) {
    if (!supabase || !draft) return;
    if (!myTurn) { notify(`Waiting for ${onClock?.name || 'the next manager'} to pick.`); return; }
    const conflict = eligibility(player);
    if (conflict) { notify(`Cannot draft ${player.handle}: ${conflict.toLowerCase()}.`); return; }
    setBusy(true);
    const { error } = await supabase.rpc('make_draft_pick', {
      target_draft: draft.id,
      selected_player: player.id
    });
    setBusy(false);
    if (error) { notify(error.message); return; }
    notify(`${player.handle} drafted to your roster!`);
  }

  async function sendChat(text?: string) {
    if (!supabase) return;
    const clean = (text ?? chatInput).trim().slice(0, 300);
    if (!clean) return;
    setChatInput('');
    const { error } = await supabase.from('league_chat_messages').insert({
      league_id: leagueId, user_id: userId, message: clean, message_type: 'text'
    });
    if (error) notify(error.message);
  }

  async function toggleReaction(messageId: string, code: string) {
    if (!supabase) return;
    const existing = reactions.find(r => r.message_id === messageId && r.user_id === userId && r.reaction === code);
    if (existing) {
      const { error } = await supabase.from('league_chat_reactions').delete().eq('id', existing.id);
      if (error) notify(error.message);
    } else {
      const { error } = await supabase.from('league_chat_reactions').insert({
        message_id: messageId, user_id: userId, reaction: code
      });
      if (error) notify(error.message);
    }
  }

  // ---- Render ----------------------------------------------------------------

  if (loading) {
    return <div className="draftOverlay"><div className="draftWaiting"><span>◌</span><h2>Connecting to the draft room…</h2><p>Loading league members, player pool and live draft state.</p></div></div>;
  }

  const shownPool = pool
    .filter(p => !ownedIds.has(p.id))
    .filter(p => (filter === 'All' || p.role === filter))
    .filter(p => p.handle.toLowerCase().includes(search.toLowerCase()) || p.teamName.toLowerCase().includes(search.toLowerCase()))
    .sort((a, b) => a.teamCode.localeCompare(b.teamCode) || a.handle.localeCompare(b.handle));

  const draftDone = draft?.status === 'completed';
  const waiting = !draft || draft.status === 'waiting' || draft.status === 'paused';

  return <div className="draftOverlay">
    <div className="draftHeader">
      <div><small>{leagueName} · {draftDone ? 'COMPLETED' : waiting ? 'WAITING ROOM' : `ROUND ${round}`}</small>
        <strong>
          {draftDone ? 'DRAFT COMPLETE' : waiting ? (draft?.scheduled_at ? `SCHEDULED · ${new Date(draft.scheduled_at).toLocaleString()}` : 'WAITING FOR COMMISSIONER')
            : myTurn ? 'YOU ARE ON THE CLOCK' : `${onClock?.name || 'MANAGER'} IS PICKING`}
        </strong>
      </div>
      <div className="draftLiveBadge"><span>●</span> LIVE · SUPABASE REALTIME</div>
      <button onClick={close}>Exit draft</button>
    </div>

    <div className="draftOrder">
      {members.map(m => <div className={draft?.status === 'active' && m.draft_position === position ? 'turn' : ''} key={m.user_id}>
        <span>{m.draft_position}</span>
        <b>{m.user_id === userId ? `${m.name} (YOU)` : m.name}</b>
        <small>{picks.filter(p => p.user_id === m.user_id).length} picks{m.member_role === 'commissioner' ? ' · COMM' : ''}</small>
      </div>)}
    </div>

    {waiting
      ? <div className="draftWaiting">
          <span>⧗</span>
          <h2>{members.length} manager{members.length === 1 ? '' : 's'} in the room</h2>
          <p>{members.length < 2 ? 'At least two active managers are required before the draft can begin.' : 'Everyone sees this room update live. The commissioner controls the start.'}</p>
          {isCommissioner
            ? <div className="draftCommissioner">
                <label>SCHEDULE (OPTIONAL)
                  <input type="datetime-local" value={scheduleAt} onChange={e => setScheduleAt(e.target.value)} />
                </label>
                <button className="secondary" disabled={busy || !scheduleAt} onClick={() => ensureDraft(scheduleAt)}>Save schedule</button>
                <button className="primary" disabled={busy || members.length < 2} onClick={startDraft}>Start live snake draft →</button>
              </div>
            : <p className="draftWaitNote">Waiting for the commissioner to start the draft…</p>}
        </div>
      : <div className="draftBody">
          <section>
            <div className="draftTools">
              <div><h2>Available players</h2><p>Season 18 verified pool · one role and one professional team per manager</p></div>
              <div className="draftFilterTools">
                <input value={search} onChange={e => setSearch(e.target.value)} placeholder="SEARCH PLAYER OR TEAM" />
                {['All', ...ROLES].map(r => <button className={filter === r ? 'active' : ''} onClick={() => setFilter(r)} key={r}>{r}</button>)}
              </div>
            </div>
            <div className="playerTable">
              {shownPool.map((p, i) => {
                const conflict = eligibility(p);
                return <button key={p.id} onClick={() => makePick(p)} disabled={draftDone || !myTurn || Boolean(conflict) || busy}>
                  <span className="draftRank">{i + 1}</span>
                  <i>{p.photo ? <img src={p.photo} alt={`${p.handle} profile`} /> : <b>PHOTO<br />PENDING</b>}</i>
                  <span><strong>{p.handle}</strong><small>{p.teamName}</small></span>
                  <b>{p.role}</b>
                  <u>{draftDone ? 'DONE' : myTurn ? (conflict || 'DRAFT') : 'LOCKED'}</u>
                </button>;
              })}
            </div>
          </section>

          <aside className="draftSide">
            <div className="clock">
              <small>PICK #{Math.min(nextPickNumber, totalPicks)} OF {totalPicks}</small>
              <strong>{draftDone ? '✓' : remaining === null ? '—' : `0:${String(Math.max(remaining, 0)).padStart(2, '0')}`}</strong>
              <span>{draftDone ? 'COMPLETE' : myTurn ? 'YOUR PICK' : onClock?.name?.toUpperCase() || '—'}</span>
              {!draftDone && remaining !== null && <div className="timerBar"><i style={{ width: `${Math.max(0, Math.min(100, (remaining / pickSeconds) * 100))}%` }} /></div>}
            </div>

            <h3>Your roster</h3>
            {myPicks.length === 0
              ? <p className="noPicks">Your drafted players will appear here.</p>
              : myPicks.map(p => {
                  const player = playerById[p.player_id];
                  return <div className="myPick" key={p.id}><i>♟</i><span><b>{player?.handle || 'PLAYER'}</b><small>{player?.role} · {player?.teamCode}</small></span><strong>✓</strong></div>;
                })}

            <h3>Recent picks</h3>
            {picks.slice(-4).reverse().map(p => {
              const player = playerById[p.player_id];
              return <div className="recentPick" key={p.id}><span>#{p.pick_number}</span><p><b>{player?.handle || 'PLAYER'}</b><small>{memberName(p.user_id)}{p.auto_picked ? ' · AUTO' : ''}</small></p></div>;
            })}

            <CloudDraftChat
              messages={messages}
              reactions={reactions}
              userId={userId}
              memberName={memberName}
              input={chatInput}
              setInput={setChatInput}
              send={sendChat}
              toggleReaction={toggleReaction}
              endRef={chatEndRef}
            />
          </aside>
        </div>}

    {draftDone && <div className="draftComplete">
      <span>✓</span>
      <h2>Draft complete!</h2>
      <p>Every roster is saved to player ownership. Weekly lineups and captain selection open next.</p>
      <div className="draftFinalRosters">
        {members.map(m => <article key={m.user_id}>
          <b>{m.user_id === userId ? `${m.name} (YOU)` : m.name}</b>
          {picks.filter(p => p.user_id === m.user_id).map(p => <small key={p.id}>{playerById[p.player_id]?.role} · {playerById[p.player_id]?.handle}</small>)}
        </article>)}
      </div>
      <button className="primary" onClick={close}>Back to league</button>
    </div>}
  </div>;
}

function CloudDraftChat({ messages, reactions, userId, memberName, input, setInput, send, toggleReaction, endRef }: {
  messages: ChatMessage[];
  reactions: Reaction[];
  userId: string;
  memberName: (id: string) => string;
  input: string;
  setInput: (value: string) => void;
  send: (text?: string) => void;
  toggleReaction: (messageId: string, code: string) => void;
  endRef: React.RefObject<HTMLDivElement | null>;
}) {
  return <div className="draftChat">
    <div className="chatHead"><div><span>●</span><b>LIVE DRAFT CHAT</b><small>SYNCED · ALL MANAGERS</small></div></div>
    <div className="chatReactions">
      {REACTIONS.map(r => <button onClick={() => send(r.label)} key={r.code}>{r.label}</button>)}
    </div>
    <div className="chatMessages">
      {messages.map(m => {
        const messageReactions = reactions.filter(r => r.message_id === m.id);
        const isEvent = m.message_type !== 'text';
        return <div className={isEvent ? 'system' : ''} key={m.id}>
          <b>{isEvent ? 'DRAFT' : m.user_id === userId ? 'YOU' : memberName(m.user_id)}</b>
          <p>{m.message}</p>
          {!isEvent && <span className="messageReactions">
            {REACTIONS.map(r => {
              const count = messageReactions.filter(x => x.reaction === r.code).length;
              const mine = messageReactions.some(x => x.reaction === r.code && x.user_id === userId);
              return <button key={r.code} className={mine ? 'mine' : ''} onClick={() => toggleReaction(m.id, r.code)}>
                {r.label}{count > 0 ? ` ${count}` : ''}
              </button>;
            })}
          </span>}
        </div>;
      })}
      <div ref={endRef} />
    </div>
    <div className="chatInput">
      <input value={input} onChange={e => setInput(e.target.value)} onKeyDown={e => e.key === 'Enter' && send()} placeholder="MESSAGE YOUR LEAGUE…" maxLength={300} />
      <button disabled={!input.trim()} onClick={() => send()}>↑</button>
    </div>
    <p className="chatSafety">SUPABASE REALTIME · LEAGUE MEMBERS ONLY · MODERATION ENABLED</p>
  </div>;
}
