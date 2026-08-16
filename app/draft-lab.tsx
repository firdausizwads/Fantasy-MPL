'use client';

import { useEffect, useMemo, useState } from 'react';
import officialTeams from './official-teams.json';

type Region = 'MY' | 'ID' | 'PH';
type Side = 'BLUE' | 'RED';
type ActionType = 'BAN' | 'PICK';
type Role = 'ALL' | 'EXP' | 'JUNGLE' | 'MID' | 'GOLD' | 'ROAM';
type DraftAction = { side: Side; type: ActionType; phase: 1 | 2 };
type SavedDraft = { game: number; blueTeam: string; redTeam: string; actions: string[]; mode: 'companion' | 'sandbox' };

const REGION_NAME: Record<Region, string> = { MY: 'MPL MALAYSIA', ID: 'MPL INDONESIA', PH: 'MPL PHILIPPINES' };
const REGION_LOGO: Record<Region, string> = { MY: '/leagues/mpl-my.png', ID: '/leagues/mpl-id.png', PH: '/leagues/mpl-ph.png' };

const HEROES: Record<Exclude<Role, 'ALL'>, string[]> = {
  EXP: ['ALDOUS','ALICE','ARGUS','ARLOTT','BADANG','BALMOND','BANE','BENEDETTA','CHOU','CICI','DYRROTH','EDITH','ESMERALDA','FREYA','GATOTKACA','GUINEVERE','HILDA','JAWHEAD','KHALEED','LAPU-LAPU','LEOMORD','LUKAS','MARCEL','MASHA','MINSITTHAR','PAQUITO','PHOVEUS','RUBY','SILVANNA','SORA','SUN','SUYOU','TERIZLA','THAMUZ','URANUS','X.BORG','YIN','YU ZHONG','ZILONG'],
  JUNGLE: ['AAMON','AKAI','ALUCARD','AULUS','BALMOND','BARATS','BAXIA','BENEDETTA','FANNY','FREDRINN','GUSION','HANZO','HARLEY','HAYABUSA','HELCURT','JOY','JULIAN','KARINA','LANCELOT','LING','MARTIS','NOLAN','PAQUITO','ROGER','SABER','SELENA','SORA','SUYOU','YI SUN-SHIN','YIN'],
  MID: ['ALICE','AURORA','BANE','CECILION','CHANG’E','CYCLOPS','EUDORA','FARAMIS','GORD','HARITH','HARLEY','KADITA','KAGURA','KIMMY','LUO YI','LUNOX','LYLIA','NANA','NOVARIA','ODETTE','PHARSA','SELENA','VALE','VALENTINA','VALIR','VEXANA','XAVIER','YVE','ZETIAN','ZHASK','ZHUXIN'],
  GOLD: ['BEATRIX','BRODY','BRUNO','CLAUDE','CLINT','EDITH','GRANGER','HANABI','HARITH','IRITHEL','IXIA','KARRIE','KIMMY','LAYLA','LESLEY','MELISSA','MIYA','MOSKOV','NATAN','OBSIDIA','POPOL AND KUPA','ROGER','WANWAN','YI SUN-SHIN'],
  ROAM: ['AKAI','ANGELA','ATLAS','BELERICK','CARMILLA','CHIP','CHOU','DIGGIE','EDITH','ESTES','FARAMIS','FLORYN','FRANCO','FREDRINN','GATOTKACA','GLOO','GROCK','HILDA','HYLOS','JOHNSON','KAJA','KALEA','KHUFRA','LOLITA','MARCEL','MASHA','MATHILDA','MINOTAUR','NATALIA','RAFAELA','SELENA','TIGREAL']
};

const ALL_HEROES = Array.from(new Set(Object.values(HEROES).flat())).sort();
const ROLE_ORDER: Role[] = ['ALL', 'EXP', 'JUNGLE', 'MID', 'GOLD', 'ROAM'];

// MPL-style tournament sequence: three bans per side, three picks per side,
// two further bans per side, then the final two picks per side.
const DRAFT_SEQUENCE: DraftAction[] = [
  {side:'BLUE',type:'BAN',phase:1},{side:'RED',type:'BAN',phase:1},
  {side:'BLUE',type:'BAN',phase:1},{side:'RED',type:'BAN',phase:1},
  {side:'BLUE',type:'BAN',phase:1},{side:'RED',type:'BAN',phase:1},
  {side:'BLUE',type:'PICK',phase:1},{side:'RED',type:'PICK',phase:1},
  {side:'RED',type:'PICK',phase:1},{side:'BLUE',type:'PICK',phase:1},
  {side:'BLUE',type:'PICK',phase:1},{side:'RED',type:'PICK',phase:1},
  {side:'RED',type:'BAN',phase:2},{side:'BLUE',type:'BAN',phase:2},
  {side:'RED',type:'BAN',phase:2},{side:'BLUE',type:'BAN',phase:2},
  {side:'RED',type:'PICK',phase:2},{side:'BLUE',type:'PICK',phase:2},
  {side:'BLUE',type:'PICK',phase:2},{side:'RED',type:'PICK',phase:2}
];

function DraftIcon() {
  return <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M4 5h6v6H4zM14 13h6v6h-6z"/><path d="m14 5 6 6M20 5l-6 6M4 16h6M7 13v6"/></svg>;
}

function rolesFor(hero: string) {
  return (Object.keys(HEROES) as Exclude<Role, 'ALL'>[]).filter(role => HEROES[role].includes(hero));
}

function TeamSelector({ label, value, teams, exclude, onChange }: { label: string; value: string; teams: typeof officialTeams[Region]; exclude: string; onChange: (value: string) => void }) {
  const selected = teams.find(team => team.code === value);
  return <label className="draftTeamSelect"><small>{label}</small><span>{selected && <img src={selected.logo} alt=""/>}<select value={value} onChange={event => onChange(event.target.value)}>{teams.filter(team => team.code !== exclude).map(team => <option value={team.code} key={team.code}>{team.name.toUpperCase()}</option>)}</select></span></label>;
}

function DraftSlot({ hero, type, active, number, onClick }: { hero?: string; type: ActionType; active: boolean; number: number; onClick: () => void }) {
  return <button className={`draftSlot ${type.toLowerCase()} ${hero ? 'filled' : ''} ${active ? 'active' : ''}`} onClick={onClick} disabled={!active && !hero} aria-label={`${type} slot ${number}${hero ? `: ${hero}` : ''}`}>
    <span>{hero ? hero.slice(0, 2) : type === 'BAN' ? '×' : number}</span>
    <b>{hero || (active ? `SELECT ${type}` : `${type} ${number}`)}</b>
    {hero && <small>{rolesFor(hero).join(' · ') || 'HERO'}</small>}
  </button>;
}

function ModelPanel({ remaining, current }: { remaining: number; current?: DraftAction }) {
  return <aside className="draftModelPanel">
    <div className="draftModelHead"><span><DraftIcon/></span><div><small>DRAFT INTELLIGENCE</small><h2>MODEL RECOMMENDATIONS</h2></div><i>DATA GATED</i></div>
    <div className="modelUnavailable"><span>◈</span><h3>RECOMMENDATION DATA PENDING</h3><p>THE SIMULATOR IS LIVE, BUT HERO RECOMMENDATIONS WILL REMAIN DISABLED UNTIL CURRENT-PATCH PROFESSIONAL DRAFT DATA IS VERIFIED.</p></div>
    <div className="modelContext"><div><small>CURRENT ACTION</small><b>{current ? `${current.side} · ${current.type}` : 'DRAFT COMPLETE'}</b></div><div><small>AVAILABLE HEROES</small><b>{remaining}</b></div><div><small>MODEL EVIDENCE</small><b>—</b></div><div><small>LAST VERIFIED</small><b>—</b></div></div>
    <section className="modelMethod"><small>THE CONNECTED MODEL WILL CONSIDER</small>{['CURRENT PATCH PRIORITY','PRO PICK & BAN ORDER','ROLE AND FLEX COVERAGE','SYNERGY AND COUNTERS','REGIONAL TENDENCIES','TEAM HISTORY · WHEN SUFFICIENT'].map(item => <div key={item}><span>○</span><b>{item}</b></div>)}</section>
    <p className="modelIntegrity"><b>DATA INTEGRITY FIRST.</b> NO HERO, CONFIDENCE VALUE OR STRATEGIC CLAIM IS GENERATED WITHOUT A TRACEABLE SOURCE.</p>
  </aside>;
}

export default function DraftLab({ region, notify }: { region: Region; notify?: (message: string) => void }) {
  const teams = officialTeams[region];
  const storageKey = `fmpl_live_draft_${region}`;
  const [game, setGame] = useState(1);
  const [blueTeam, setBlueTeam] = useState(teams[0].code);
  const [redTeam, setRedTeam] = useState(teams[1]?.code || teams[0].code);
  const [mode, setMode] = useState<'companion' | 'sandbox'>('companion');
  const [actions, setActions] = useState<string[]>([]);
  const [pickerOpen, setPickerOpen] = useState(false);
  const [search, setSearch] = useState('');
  const [role, setRole] = useState<Role>('ALL');
  const [mobileTab, setMobileTab] = useState<'draft' | 'heroes' | 'model'>('draft');
  const current = DRAFT_SEQUENCE[actions.length];
  const used = useMemo(() => new Set(actions), [actions]);

  useEffect(() => {
    try {
      const saved = JSON.parse(localStorage.getItem(storageKey) || 'null') as SavedDraft | null;
      if (!saved) {
        setGame(1); setBlueTeam(teams[0].code); setRedTeam(teams[1]?.code || teams[0].code);
        setActions([]); setMode('companion'); setPickerOpen(false); setMobileTab('draft');
        return;
      }
      setGame(saved.game || 1); setBlueTeam(saved.blueTeam || teams[0].code);
      setRedTeam(saved.redTeam || teams[1]?.code || teams[0].code);
      setActions(Array.isArray(saved.actions) ? saved.actions.slice(0, DRAFT_SEQUENCE.length) : []);
      setMode(saved.mode || 'companion');
    } catch { /* Ignore malformed local preview data. */ }
  }, [storageKey, teams]);

  useEffect(() => {
    const saved: SavedDraft = { game, blueTeam, redTeam, actions, mode };
    localStorage.setItem(storageKey, JSON.stringify(saved));
  }, [storageKey, game, blueTeam, redTeam, actions, mode]);

  function chooseHero(hero: string) {
    if (!current || used.has(hero)) return;
    setActions(previous => [...previous, hero]);
    setPickerOpen(false); setSearch(''); setRole('ALL'); setMobileTab('draft');
    notify?.(`${hero} recorded as ${current.side.toLowerCase()} ${current.type.toLowerCase()}.`);
  }

  function undo() {
    if (!actions.length) return;
    const removed = actions.at(-1);
    setActions(previous => previous.slice(0, -1));
    notify?.(`${removed} removed from the draft.`);
  }

  function reset() {
    if (actions.length && !window.confirm('Reset every pick and ban in this draft?')) return;
    setActions([]); setPickerOpen(false); setMobileTab('draft');
    notify?.('Draft reset.');
  }

  function actionIndex(side: Side, type: ActionType, position: number) {
    let seen = -1;
    return DRAFT_SEQUENCE.findIndex(action => {
      if (action.side === side && action.type === type) seen += 1;
      return action.side === side && action.type === type && seen === position;
    });
  }

  const filtered = ALL_HEROES.filter(hero => !used.has(hero) && (role === 'ALL' || HEROES[role].includes(hero)) && hero.includes(search.trim().toUpperCase()));
  const team = (code: string) => teams.find(item => item.code === code) || teams[0];

  return <div className="page liveDraftLab">
    <section className="draftLabHero"><div><span>INTERACTIVE BROADCAST COMPANION · {REGION_NAME[region]}</span><h1>FOLLOW THE DRAFT.<br/><em>READ THE NEXT MOVE.</em></h1><p>MIRROR EACH PICK AND BAN FROM THE OFFICIAL BROADCAST. THE DRAFT ENGINE TRACKS AVAILABILITY WHILE VERIFIED MODEL INTELLIGENCE IS PREPARED.</p><div><button className={mode === 'companion' ? 'active' : ''} onClick={() => setMode('companion')}>LIVE COMPANION</button><button className={mode === 'sandbox' ? 'active' : ''} onClick={() => setMode('sandbox')}>SANDBOX</button></div></div><div className="draftLabMark"><img src={REGION_LOGO[region]} alt={`${REGION_NAME[region]} logo`}/><span>UNOFFICIAL COMPANION</span></div></section>

    <div className="draftIntegrity"><span>PUBLIC BETA</span><p>YOU CONTROL THE DRAFT BOARD. FANTASY MPL DOES NOT REBROADCAST OR AUTOMATICALLY READ THE OFFICIAL STREAM.</p><a href="/live-draft">OPEN PUBLIC VERSION ↗</a></div>

    <section className="draftSetupBar"><div><TeamSelector label="BLUE SIDE" value={blueTeam} teams={teams} exclude={redTeam} onChange={setBlueTeam}/><i>VS</i><TeamSelector label="RED SIDE" value={redTeam} teams={teams} exclude={blueTeam} onChange={setRedTeam}/></div><label><small>GAME</small><select value={game} onChange={event => { setGame(Number(event.target.value)); setActions([]); }}>{[1,2,3,4,5,6,7].map(number => <option key={number} value={number}>GAME {number}</option>)}</select></label><div className="draftSetupActions"><button onClick={undo} disabled={!actions.length}>↶ UNDO</button><button onClick={reset} disabled={!actions.length}>RESET</button></div></section>

    <nav className="draftMobileTabs"><button className={mobileTab === 'draft' ? 'active' : ''} onClick={() => setMobileTab('draft')}>DRAFT</button><button className={mobileTab === 'heroes' ? 'active' : ''} onClick={() => { setMobileTab('heroes'); setPickerOpen(true); }}>HEROES</button><button className={mobileTab === 'model' ? 'active' : ''} onClick={() => setMobileTab('model')}>MODEL</button></nav>

    <div className="draftWorkspace">
      <section className={`draftBoard ${mobileTab !== 'draft' ? 'mobileHidden' : ''}`}>
        <div className="draftTurn"><span className={current?.side === 'RED' ? 'red' : ''}>{current ? `${current.side} SIDE` : 'COMPLETE'}</span><div><small>{current ? `PHASE ${current.phase} · ${current.type}` : 'DRAFT COMPLETE'}</small><h2>{current ? `SELECT THE ${current.type} SHOWN ON THE BROADCAST` : 'ALL PICKS AND BANS RECORDED'}</h2></div><strong>{actions.length} / {DRAFT_SEQUENCE.length}</strong></div>
        <div className="draftSides">
          {(['BLUE','RED'] as Side[]).map(side => <article className={`draftSide ${side.toLowerCase()}`} key={side}>
            <header><span><img src={team(side === 'BLUE' ? blueTeam : redTeam).logo} alt=""/></span><div><small>{side} SIDE</small><h2>{team(side === 'BLUE' ? blueTeam : redTeam).name.toUpperCase()}</h2></div></header>
            <div className="draftBanRow"><small>BANS</small><div>{Array.from({length:5}, (_, position) => { const index = actionIndex(side,'BAN',position); return <DraftSlot key={position} type="BAN" number={position + 1} hero={actions[index]} active={index === actions.length} onClick={() => index === actions.length && setPickerOpen(true)}/>; })}</div></div>
            <div className="draftPickColumn"><small>LINEUP</small>{Array.from({length:5}, (_, position) => { const index = actionIndex(side,'PICK',position); return <DraftSlot key={position} type="PICK" number={position + 1} hero={actions[index]} active={index === actions.length} onClick={() => index === actions.length && setPickerOpen(true)}/>; })}</div>
          </article>)}
        </div>
        <div className="draftSequence"><span style={{width:`${(actions.length / DRAFT_SEQUENCE.length) * 100}%`}}/><small>TOURNAMENT DRAFT FLOW · 10 BANS · 10 PICKS</small></div>
      </section>
      <div className={mobileTab !== 'model' ? 'modelMobileHidden' : ''}><ModelPanel remaining={ALL_HEROES.length - used.size} current={current}/></div>
    </div>

    {(pickerOpen || mobileTab === 'heroes') && current && <section className={`heroPicker ${mobileTab === 'heroes' ? 'mobilePicker' : ''}`}>
      <div className="heroPickerHead"><div><span className={current.side === 'RED' ? 'red' : ''}>{current.side} SIDE · {current.type}</span><h2>SELECT THE HERO SHOWN ON THE BROADCAST</h2></div><button onClick={() => { setPickerOpen(false); setMobileTab('draft'); }} aria-label="Close hero selector">×</button></div>
      <div className="heroPickerTools"><input value={search} onChange={event => setSearch(event.target.value)} placeholder="SEARCH 131 HERO CATALOG" autoFocus/><div>{ROLE_ORDER.map(item => <button className={role === item ? 'active' : ''} onClick={() => setRole(item)} key={item}>{item}</button>)}</div></div>
      <div className="heroGrid">{filtered.map(hero => <button onClick={() => chooseHero(hero)} key={hero}><span>{hero.slice(0,2)}</span><b>{hero}</b><small>{rolesFor(hero).join(' · ')}</small></button>)}</div>
      {!filtered.length && <p className="heroPickerEmpty">NO AVAILABLE HERO MATCHES THIS FILTER.</p>}
    </section>}

    <footer className="draftDisclaimer"><span>i</span><p><b>UNOFFICIAL ANALYSIS TOOL.</b> LIVE DRAFT LAB IS NOT AFFILIATED WITH OR ENDORSED BY MPL OR MOONTON. COMPETITION AND TEAM ASSETS REQUIRE THE APPROPRIATE RIGHTS FOR COMMERCIAL USE.</p></footer>
  </div>;
}
