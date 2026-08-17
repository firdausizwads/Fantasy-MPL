'use client';

import { useEffect, useMemo, useState } from 'react';

type Region = 'MY' | 'ID' | 'PH';
type Side = 'BLUE' | 'RED';
type ActionType = 'BAN' | 'PICK';
type Role = 'ALL' | 'EXP' | 'JUNGLE' | 'MID' | 'GOLD' | 'ROAM';
type DraftAction = { side: Side; type: ActionType; phase: 1 | 2 };
type SavedDraft = { actions: string[]; mode: 'companion' | 'sandbox'; firstSide: Side };
type IntelligenceStatus = { ready:boolean; region:string; source_name:string|null; source_url:string|null; attribution:string|null; license:string|null; model_name:string|null; model_version:string|null; patch:string|null; minimum_sample:number|null; eligible_heroes:number; drafts_analyzed:number; last_verified:string|null; blocker:string|null };
type Recommendation = { hero_name:string; score:number; evidence_level:string; sample_size:number; reason:string; pick_rate:number; ban_rate:number; win_rate:number; contest_rate:number };
type RecommendationGroups = { priorityBan:Recommendation[]; potentialPick:Recommendation[]; counterPick:Recommendation[] };
type ModelMetric = { hero:string; games:number; picks:number; bans:number; pick_rate:number; ban_rate:number; win_rate:number; contest_rate:number; roles:string[] };
type ModelRelationship = { hero:string; related_hero:string; type:'SYNERGY'|'COUNTER'|'DENIAL'; sample_size:number; impact_score:number };
type ModelBundle = { status:IntelligenceStatus; weights:Record<string,number>; metrics:ModelMetric[]; relationships:ModelRelationship[]; generated_at:string };

const HEROES: Record<Exclude<Role, 'ALL'>, string[]> = {
  EXP: ['ALDOUS','ALICE','ARGUS','ARLOTT','BADANG','BALMOND','BANE','BENEDETTA','CHOU','CICI','DYRROTH','EDITH','ESMERALDA','FREYA','GATOTKACA','GUINEVERE','HILDA','JAWHEAD','KHALEED','LAPU-LAPU','LEOMORD','LUKAS','MARCEL','MASHA','MINSITTHAR','PAQUITO','PHOVEUS','RUBY','SILVANNA','SORA','SUN','SUYOU','TERIZLA','THAMUZ','URANUS','X.BORG','YIN','YU ZHONG','ZILONG'],
  JUNGLE: ['AAMON','AKAI','ALUCARD','AULUS','BALMOND','BARATS','BAXIA','BENEDETTA','FANNY','FREDRINN','GUSION','HANZO','HARLEY','HAYABUSA','HELCURT','JOY','JULIAN','KARINA','LANCELOT','LING','MARTIS','NOLAN','PAQUITO','ROGER','SABER','SELENA','SORA','SUYOU','YI SUN-SHIN','YIN'],
  MID: ['ALICE','AURORA','BANE','CECILION','CHANG’E','CYCLOPS','EUDORA','FARAMIS','GORD','HARITH','HARLEY','KADITA','KAGURA','KIMMY','LUO YI','LUNOX','LYLIA','NANA','NOVARIA','ODETTE','PHARSA','SELENA','VALE','VALENTINA','VALIR','VEXANA','XAVIER','YVE','ZETIAN','ZHASK','ZHUXIN'],
  GOLD: ['BEATRIX','BRODY','BRUNO','CLAUDE','CLINT','EDITH','GRANGER','HANABI','HARITH','IRITHEL','IXIA','KARRIE','KIMMY','LAYLA','LESLEY','MELISSA','MIYA','MOSKOV','NATAN','OBSIDIA','POPOL AND KUPA','ROGER','WANWAN','YI SUN-SHIN'],
  ROAM: ['AKAI','ANGELA','ATLAS','BELERICK','CARMILLA','CHIP','CHOU','DIGGIE','EDITH','ESTES','FARAMIS','FLORYN','FRANCO','FREDRINN','GATOTKACA','GLOO','GROCK','HILDA','HYLOS','JOHNSON','KAJA','KALEA','KHUFRA','LOLITA','MARCEL','MASHA','MATHILDA','MINOTAUR','NATALIA','RAFAELA','SELENA','TIGREAL']
};

const ALL_HEROES = Array.from(new Set(Object.values(HEROES).flat())).sort();
const ROLE_ORDER: Role[] = ['ALL', 'EXP', 'JUNGLE', 'MID', 'GOLD', 'ROAM'];

// Generic tournament tool sequence. The user chooses side A. Opening bans
// and first picks follow 1–2–2–1; the second phase follows 1–2–1.
function createDraftSequence(firstSide:Side):DraftAction[]{
  const other:Side=firstSide==='BLUE'?'RED':'BLUE';
  return [
    {side:firstSide,type:'BAN',phase:1},{side:other,type:'BAN',phase:1},{side:other,type:'BAN',phase:1},{side:firstSide,type:'BAN',phase:1},{side:firstSide,type:'BAN',phase:1},{side:other,type:'BAN',phase:1},
    {side:firstSide,type:'PICK',phase:1},{side:other,type:'PICK',phase:1},{side:other,type:'PICK',phase:1},{side:firstSide,type:'PICK',phase:1},{side:firstSide,type:'PICK',phase:1},{side:other,type:'PICK',phase:1},
    {side:other,type:'BAN',phase:2},{side:firstSide,type:'BAN',phase:2},{side:firstSide,type:'BAN',phase:2},{side:other,type:'BAN',phase:2},
    {side:other,type:'PICK',phase:2},{side:firstSide,type:'PICK',phase:2},{side:firstSide,type:'PICK',phase:2},{side:other,type:'PICK',phase:2}
  ];
}

function DraftIcon() {
  return <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M4 5h6v6H4zM14 13h6v6h-6z"/><path d="m14 5 6 6M20 5l-6 6M4 16h6M7 13v6"/></svg>;
}

function rolesFor(hero: string) {
  return (Object.keys(HEROES) as Exclude<Role, 'ALL'>[]).filter(role => HEROES[role].includes(hero));
}



function DraftSlot({ hero, type, active, number, onClick }: { hero?: string; type: ActionType; active: boolean; number: number; onClick: () => void }) {
  return <button className={`draftSlot ${type.toLowerCase()} ${hero ? 'filled' : ''} ${active ? 'active' : ''}`} onClick={onClick} disabled={!active && !hero} aria-label={`${type} slot ${number}${hero ? `: ${hero}` : ''}`}>
    <span>{hero ? hero.slice(0, 2) : type === 'BAN' ? '×' : number}</span>
    <b>{hero || (active ? `SELECT ${type}` : `${type} ${number}`)}</b>
    {hero && <small>{rolesFor(hero).join(' · ') || 'HERO'}</small>}
  </button>;
}

function RecommendationCard({title,tag,items}:{title:string;tag:string;items:Recommendation[]}){const lead=items[0];return <article className="analysisCard"><header><span>{tag}</span><b>{title}</b></header>{lead?<><div className="analysisLead"><i>{lead.hero_name.slice(0,2)}</i><div><h3>{lead.hero_name}</h3><p>{lead.reason}</p></div></div><footer><b>{lead.evidence_level} EVIDENCE</b><span>{lead.sample_size} GAMES</span></footer>{items.length>1&&<div className="analysisAlternatives">{items.slice(1).map((item,index)=><span key={item.hero_name}><i>{index+2}</i><b>{item.hero_name}</b></span>)}</div>}</>:<div className="analysisEmpty">NO VERIFIED RECOMMENDATION</div>}</article>}
function ModelPanel({ remaining, current, status, groups, loading }: { remaining: number; current?: DraftAction; status: IntelligenceStatus | null; groups: RecommendationGroups; loading: boolean }) {
  const ready=Boolean(status?.ready);
  return <aside className="draftModelPanel toolAnalysisPanel">
    <div className="draftModelHead"><span><DraftIcon/></span><div><small>CURRENT-PATCH INTELLIGENCE</small><h2>DRAFT ANALYSIS</h2></div><i className={ready?'ready':''}>{ready?'VERIFIED MODEL':'DATA GATED'}</i></div>
    {!ready?<div className="modelUnavailable"><span>◈</span><h3>RECOMMENDATION DATA PENDING</h3><p>{status?.blocker||'AN APPROVED GENERAL PATCH SOURCE, ACTIVE MODEL AND VERIFIED SAMPLE ARE REQUIRED.'}</p></div>:loading?<div className="modelUnavailable"><span>◷</span><h3>CALCULATING DRAFT OPTIONS</h3><p>CHECKING CURRENT-PATCH MATCHUP EVIDENCE.</p></div>:<div className="analysisCards"><RecommendationCard tag="BAN" title="Priority Ban" items={groups.priorityBan}/><RecommendationCard tag="READ" title="Potential Opposing Pick" items={groups.potentialPick}/><RecommendationCard tag="PICK" title="Best Counter Pick" items={groups.counterPick}/></div>}
    <div className="modelContext"><div><small>CURRENT ACTION</small><b>{current ? `${current.side} · ${current.type}` : 'DRAFT COMPLETE'}</b></div><div><small>AVAILABLE HEROES</small><b>{remaining}</b></div><div><small>MODEL VERSION</small><b>{status?.model_version||'—'}</b></div><div><small>PATCH</small><b>{status?.patch||'—'}</b></div></div>
    {ready?<section className="modelEvidence"><small>VERIFIED DATA</small><div><b>{status?.source_name}</b><span>{status?.drafts_analyzed||0} GAMES · {status?.eligible_heroes||0} ELIGIBLE HEROES</span></div>{status?.attribution&&<p>{status.attribution}</p>}{status?.source_url&&<a href={status.source_url} target="_blank" rel="noreferrer">VIEW DATA SOURCE ↗</a>}</section>:<section className="modelMethod"><small>THE MODEL WILL CONSIDER</small>{['PATCH PICK & BAN PRIORITY','COUNTER MATCHUPS','ALLY SYNERGY','OPEN ROLE COVERAGE','FLEX-PICK VALUE','REMAINING HERO AVAILABILITY'].map(item => <div key={item}><span>○</span><b>{item}</b></div>)}</section>}
    <p className="modelIntegrity"><b>DATA INTEGRITY FIRST.</b> “POTENTIAL PICK” IS A META-BASED READ, NOT A CLAIM ABOUT A SPECIFIC TEAM.</p>
  </aside>;
}

export default function DraftLab({ region, notify }: { region: Region; notify?: (message: string) => void }) {
  const storageKey = 'fmpl_draft_tool';
  const [firstSide,setFirstSide]=useState<Side>('BLUE');
  const [mode, setMode] = useState<'companion' | 'sandbox'>('companion');
  const [actions, setActions] = useState<string[]>([]);
  const [pickerOpen, setPickerOpen] = useState(false);
  const [search, setSearch] = useState('');
  const [role, setRole] = useState<Role>('ALL');
  const [mobileTab, setMobileTab] = useState<'draft' | 'heroes' | 'model'>('draft');
  const [intelligence, setIntelligence] = useState<IntelligenceStatus | null>(null);
  const [modelBundle, setModelBundle] = useState<ModelBundle | null>(null);
  const [groups,setGroups]=useState<RecommendationGroups>({priorityBan:[],potentialPick:[],counterPick:[]});
  const [modelLoading, setModelLoading] = useState(false);
  const [servicePause,setServicePause]=useState<string|null>(null);
  const sequence=useMemo(()=>createDraftSequence(firstSide),[firstSide]);
  const current = sequence[actions.length];
  const used = useMemo(() => new Set(actions), [actions]);

  useEffect(() => {
    try {
      const saved = JSON.parse(localStorage.getItem(storageKey) || 'null') as SavedDraft | null;
      setFirstSide(saved?.firstSide==='RED'?'RED':'BLUE');
      setActions(Array.isArray(saved?.actions)?saved.actions.slice(0,20):[]);
      setMode(saved?.mode||'companion');setPickerOpen(false);setMobileTab('draft');
    } catch { setFirstSide('BLUE');setActions([]);setMode('companion'); }
  }, [storageKey]);

  useEffect(() => {
    const saved: SavedDraft = { firstSide, actions, mode };
    localStorage.setItem(storageKey, JSON.stringify(saved));
  }, [storageKey, firstSide, actions, mode]);

  useEffect(() => {
    const controller=new AbortController();
    async function loadBundle(){
      setModelLoading(true);setGroups({priorityBan:[],potentialPick:[],counterPick:[]});setServicePause(null);
      try{
        const [modelResponse,statusResponse]=await Promise.all([fetch(`/api/draft-model?region=${region}`,{signal:controller.signal}),fetch(`/api/region-status?region=${region}`,{signal:controller.signal})]);
        const [bundle,status]=await Promise.all([modelResponse.json() as Promise<ModelBundle>,statusResponse.json() as Promise<{features?:Record<string,{enabled:boolean;message?:string|null}>}>]);
        if(controller.signal.aborted)return;
        const draftFlag=status.features?.draft_lab;setServicePause(draftFlag?.enabled===false?(draftFlag.message||'Live Draft Lab is temporarily paused for this region.'):null);
        setModelBundle(bundle);setIntelligence(bundle.status);
      }catch(error){
        if(controller.signal.aborted)return;
        setModelBundle(null);setIntelligence({ready:false,region,source_name:null,source_url:null,attribution:null,license:null,model_name:null,model_version:null,patch:null,minimum_sample:null,eligible_heroes:0,drafts_analyzed:0,last_verified:null,blocker:error instanceof Error?'MODEL BUNDLE TEMPORARILY UNAVAILABLE':'MODEL DATA UNAVAILABLE'});
      }finally{if(!controller.signal.aborted)setModelLoading(false)}
    }
    loadBundle();return()=>controller.abort();
  },[region]);

  useEffect(() => {
    if(!modelBundle?.status.ready||!current){setGroups({priorityBan:[],potentialPick:[],counterPick:[]});return}
    const ally:string[]=[],enemy:string[]=[],banned:string[]=[];
    actions.forEach((hero,index)=>{const step=sequence[index];if(step.type==='BAN')banned.push(hero);else if(step.side===current.side)ally.push(hero);else enemy.push(hero)});
    const excluded=new Set([...ally,...enemy,...banned].map(hero=>hero.toUpperCase()));
    const weight=(name:string,fallback:number)=>Number(modelBundle.weights[name]??fallback);
    const candidates=modelBundle.metrics.filter(metric=>!excluded.has(metric.hero.toUpperCase())).map(metric=>{
      const synergy=modelBundle.relationships.filter(item=>item.hero===metric.hero&&item.type==='SYNERGY'&&ally.includes(item.related_hero)).reduce((sum,item)=>sum+Number(item.impact_score),0);
      const counter=modelBundle.relationships.filter(item=>item.hero===metric.hero&&['COUNTER','DENIAL'].includes(item.type)&&enemy.includes(item.related_hero)).reduce((sum,item)=>sum+Number(item.impact_score),0);
      const common={hero_name:metric.hero,evidence_level:metric.games>=50?'STRONG':metric.games>=25?'MODERATE':'LIMITED',sample_size:metric.games,pick_rate:metric.pick_rate,ban_rate:metric.ban_rate,win_rate:metric.win_rate,contest_rate:metric.contest_rate};
      return{metric,synergy,counter,common};
    });
    const priorityBan=candidates.map(item=>({...item.common,score:item.metric.ban_rate*weight('ban_rate',.6)+item.metric.contest_rate*weight('contest_rate',.4),reason:`Patch priority · ${item.metric.bans} bans across ${item.metric.games} games`})).sort((a,b)=>b.score-a.score||a.hero_name.localeCompare(b.hero_name)).slice(0,3);
    const potentialPick=candidates.map(item=>({...item.common,score:item.metric.pick_rate*.5+item.metric.contest_rate*.3+item.metric.win_rate*.2,reason:`Meta read · ${item.metric.picks} picks and ${item.metric.pick_rate.toFixed(1)}% pick rate`})).sort((a,b)=>b.score-a.score||a.hero_name.localeCompare(b.hero_name)).slice(0,3);
    const counterPick=candidates.map(item=>({...item.common,score:item.metric.pick_rate*weight('pick_rate',.35)+item.metric.win_rate*weight('win_rate',.25)+item.metric.contest_rate*weight('pick_contest',.15)+item.synergy*100*weight('synergy',.15)+item.counter*100*weight('counter',.1),reason:enemy.length?`Counter-fit against ${enemy.length} visible enemy pick${enemy.length===1?'':'s'}`:`Safe current-patch pick · ${item.metric.win_rate.toFixed(1)}% win rate`})).sort((a,b)=>b.score-a.score||a.hero_name.localeCompare(b.hero_name)).slice(0,3);
    setGroups({priorityBan,potentialPick,counterPick});
  },[actions,current?.side,current?.type,modelBundle,sequence]);

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
  function changeFirstSide(side:Side){if(side===firstSide)return;if(actions.length&&!window.confirm('Changing the first-action side will reset this draft. Continue?'))return;setFirstSide(side);setActions([]);setPickerOpen(false);notify?.(`${side} Side will act first.`)}

  function actionIndex(side: Side, type: ActionType, position: number) {
    let seen = -1;
    return sequence.findIndex(action => {
      if (action.side === side && action.type === type) seen += 1;
      return action.side === side && action.type === type && seen === position;
    });
  }

  const filtered = ALL_HEROES.filter(hero => !used.has(hero) && (role === 'ALL' || HEROES[role].includes(hero)) && hero.includes(search.trim().toUpperCase()));

  if(servicePause)return <div className="page liveDraftLab"><section className="regionalPause"><span>REGIONAL SERVICE CONTROL</span><img src="/brand/fantasy-mpl-emblem.png" alt=""/><h1>Live Draft Lab is temporarily paused.</h1><p>{servicePause}</p><button onClick={()=>window.location.reload()}>CHECK STATUS AGAIN</button></section></div>;
  return <div className="page liveDraftLab">
    <section className="draftLabHero genericDraftHero"><div><span>CURRENT-PATCH MLBB DRAFT TOOL</span><h1>BUILD THE DRAFT.<br/><em>READ THE NEXT MOVE.</em></h1><p>CHOOSE WHICH SIDE ACTS FIRST, RECORD EACH BAN AND PICK, THEN REVIEW PRIORITY BANS, POTENTIAL OPPOSING PICKS AND COUNTER OPTIONS.</p><div><button className={mode === 'companion' ? 'active' : ''} onClick={() => setMode('companion')}>LIVE COMPANION</button><button className={mode === 'sandbox' ? 'active' : ''} onClick={() => setMode('sandbox')}>SANDBOX</button></div></div><div className="draftLabMark genericToolMark"><DraftIcon/><span>DRAFT TOOL</span></div></section>

    <div className="draftIntegrity"><span>PUBLIC BETA</span><p>GENERIC PATCH TOOL · NO TEAM TENDENCIES · NO BROADCAST PROCESSING · RECOMMENDATIONS REQUIRE VERIFIED MATCHUP DATA.</p><a href="/live-draft">PUBLIC TOOL ↗</a></div>

    <section className="draftToolSetup"><div><small>WHICH SIDE ACTS FIRST?</small><p>Match the first-ban side shown in your preview or lobby.</p></div><div className="firstSideChoices"><button className={firstSide==='BLUE'?'active blue':''} onClick={()=>changeFirstSide('BLUE')}><i>B</i><span><b>BLUE SIDE</b><small>FIRST BAN · FIRST PICK</small></span></button><button className={firstSide==='RED'?'active red':''} onClick={()=>changeFirstSide('RED')}><i>R</i><span><b>RED SIDE</b><small>FIRST BAN · FIRST PICK</small></span></button></div><div className="draftSetupActions"><button onClick={undo} disabled={!actions.length}>↶ UNDO</button><button onClick={reset} disabled={!actions.length}>RESET</button></div></section>

    <nav className="draftMobileTabs"><button className={mobileTab === 'draft' ? 'active' : ''} onClick={() => setMobileTab('draft')}>DRAFT</button><button className={mobileTab === 'heroes' ? 'active' : ''} onClick={() => { setMobileTab('heroes'); setPickerOpen(true); }}>HEROES</button><button className={mobileTab === 'model' ? 'active' : ''} onClick={() => setMobileTab('model')}>MODEL</button></nav>

    <div className="draftWorkspace">
      <section className={`draftBoard ${mobileTab !== 'draft' ? 'mobileHidden' : ''}`}>
        <div className="draftTurn"><span className={current?.side === 'RED' ? 'red' : ''}>{current ? `${current.side} SIDE` : 'COMPLETE'}</span><div><small>{current ? `PHASE ${current.phase} · ${current.type}` : 'DRAFT COMPLETE'}</small><h2>{current ? `SELECT ${current.side} SIDE’S NEXT ${current.type}` : 'ALL PICKS AND BANS RECORDED'}</h2></div><strong>{actions.length} / {sequence.length}</strong></div>
        <div className="draftSides">
          {(['BLUE','RED'] as Side[]).map(side => <article className={`draftSide ${side.toLowerCase()}`} key={side}>
            <header className="genericSideHead"><span>{side==='BLUE'?'B':'R'}</span><div><small>{side} SIDE</small><h2>{side===firstSide?'FIRST-ACTION SIDE':'RESPONSE SIDE'}</h2></div></header>
            <div className="draftBanRow"><small>BANS</small><div>{Array.from({length:5}, (_, position) => { const index = actionIndex(side,'BAN',position); return <DraftSlot key={position} type="BAN" number={position + 1} hero={actions[index]} active={index === actions.length} onClick={() => index === actions.length && setPickerOpen(true)}/>; })}</div></div>
            <div className="draftPickColumn"><small>LINEUP</small>{Array.from({length:5}, (_, position) => { const index = actionIndex(side,'PICK',position); return <DraftSlot key={position} type="PICK" number={position + 1} hero={actions[index]} active={index === actions.length} onClick={() => index === actions.length && setPickerOpen(true)}/>; })}</div>
          </article>)}
        </div>
        <div className="draftSequence"><span style={{width:`${(actions.length / sequence.length) * 100}%`}}/><small>GENERIC SNAKE FLOW · OPENING 1–2–2–1 · 10 BANS · 10 PICKS</small></div>
      </section>
      <div className={mobileTab !== 'model' ? 'modelMobileHidden' : ''}><ModelPanel remaining={ALL_HEROES.length - used.size} current={current} status={intelligence} groups={groups} loading={modelLoading}/></div>
    </div>

    {(pickerOpen || mobileTab === 'heroes') && current && <section className={`heroPicker ${mobileTab === 'heroes' ? 'mobilePicker' : ''}`}>
      <div className="heroPickerHead"><div><span className={current.side === 'RED' ? 'red' : ''}>{current.side} SIDE · {current.type}</span><h2>SELECT THE HERO TO {current.type}</h2></div><button onClick={() => { setPickerOpen(false); setMobileTab('draft'); }} aria-label="Close hero selector">×</button></div>
      <div className="heroPickerTools"><input value={search} onChange={event => setSearch(event.target.value)} placeholder="SEARCH 131 HERO CATALOG" autoFocus/><div>{ROLE_ORDER.map(item => <button className={role === item ? 'active' : ''} onClick={() => setRole(item)} key={item}>{item}</button>)}</div></div>
      <div className="heroGrid">{filtered.map(hero => <button onClick={() => chooseHero(hero)} key={hero}><span>{hero.slice(0,2)}</span><b>{hero}</b><small>{rolesFor(hero).join(' · ')}</small></button>)}</div>
      {!filtered.length && <p className="heroPickerEmpty">NO AVAILABLE HERO MATCHES THIS FILTER.</p>}
    </section>}

    <footer className="draftDisclaimer"><span>i</span><p><b>UNOFFICIAL ANALYSIS TOOL.</b> LIVE DRAFT LAB IS NOT AFFILIATED WITH OR ENDORSED BY MOONTON. RECOMMENDATIONS ARE PATCH-BASED GUIDANCE, NOT GUARANTEED OUTCOMES.</p></footer>
  </div>;
}
