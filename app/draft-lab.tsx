'use client';

import { useEffect, useMemo, useState } from 'react';
import heroAssets from './hero-assets.json';

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

const REGION_INFO:Record<Region,{name:string;logo:string}>={MY:{name:'MPL MALAYSIA',logo:'/leagues/display/mpl-my.webp'},ID:{name:'MPL INDONESIA',logo:'/leagues/display/mpl-id.webp'},PH:{name:'MPL PHILIPPINES',logo:'/leagues/display/mpl-ph.webp'}};

const HEROES: Record<Exclude<Role, 'ALL'>, string[]> = {
  EXP: ['ALDOUS','ALPHA','ALICE','ARGUS','ARLOTT','BADANG','BALMOND','BANE','BENEDETTA','CHOU','CICI','DYRROTH','EDITH','ESMERALDA','FREYA','GATOTKACA','GUINEVERE','HILDA','JAWHEAD','KHALEED','LAPU-LAPU','LEOMORD','LUKAS','MARCEL','MASHA','MINSITTHAR','PAQUITO','PHOVEUS','RUBY','SILVANNA','SORA','SUN','SUYOU','TERIZLA','THAMUZ','URANUS','X.BORG','YIN','YU ZHONG','ZILONG'],
  JUNGLE: ['AAMON','AKAI','ALPHA','ALUCARD','AULUS','BALMOND','BARATS','BAXIA','BENEDETTA','FANNY','FREDRINN','GUSION','HANZO','HARLEY','HIRARA','HAYABUSA','HELCURT','JOY','JULIAN','KARINA','LANCELOT','LING','MARTIS','NOLAN','PAQUITO','ROGER','SABER','SELENA','SORA','SUYOU','YI SUN-SHIN','YIN'],
  MID: ['ALICE','AURORA','BANE','CECILION','CHANG’E','CYCLOPS','EUDORA','FARAMIS','GORD','HARITH','HARLEY','KADITA','KAGURA','KIMMY','LUO YI','LUNOX','LYLIA','NANA','NOVARIA','ODETTE','PHARSA','SELENA','VALE','VALENTINA','VALIR','VEXANA','XAVIER','YVE','ZETIAN','ZHASK','ZHUXIN'],
  GOLD: ['BEATRIX','BRODY','BRUNO','CLAUDE','CLINT','EDITH','GRANGER','HANABI','HARITH','IRITHEL','IXIA','KARRIE','KIMMY','LAYLA','LESLEY','MELISSA','MIYA','MOSKOV','NATAN','OBSIDIA','POPOL AND KUPA','ROGER','WANWAN','YI SUN-SHIN'],
  ROAM: ['AKAI','ANGELA','ATLAS','BELERICK','CARMILLA','CHIP','CHOU','DIGGIE','EDITH','ESTES','FARAMIS','FLORYN','FRANCO','FREDRINN','GATOTKACA','GLOO','GROCK','HILDA','HYLOS','JOHNSON','KAJA','KALEA','KHUFRA','LOLITA','MARCEL','MASHA','MATHILDA','MINOTAUR','NATALIA','RAFAELA','SELENA','TIGREAL']
};

const ALL_HEROES = Array.from(new Set(Object.values(HEROES).flat())).sort();
const ROLE_ORDER: Role[] = ['ALL', 'EXP', 'JUNGLE', 'MID', 'GOLD', 'ROAM'];
const HERO_PORTRAITS:Record<string,string>=Object.fromEntries(heroAssets.map(hero=>[hero.name.toUpperCase(),hero.photo]));
const heroPhoto=(hero:string)=>HERO_PORTRAITS[hero.toUpperCase()];

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
    <span>{hero ? <img src={heroPhoto(hero)} alt=""/> : type === 'BAN' ? '×' : number}</span>
    <b>{hero || (active ? `SELECT ${type}` : `${type} ${number}`)}</b>
    {hero && <small>{rolesFor(hero).join(' · ') || 'HERO'}</small>}
  </button>;
}

function PickerInsights({current,status,groups,choose}:{current:DraftAction;status:IntelligenceStatus|null;groups:RecommendationGroups;choose:(hero:string)=>void}){const cards=[{tag:'BAN',title:'Priority Ban',items:groups.priorityBan},{tag:'READ',title:'Potential Pick',items:groups.potentialPick},{tag:'PICK',title:'Counter Pick',items:groups.counterPick}];return <aside className="pickerInsights"><header><span>LIVE DRAFT GUIDANCE</span><h3>{current.side} SIDE · {current.type}</h3></header>{status?.ready?<div>{cards.map(card=>{const item=card.items[0];return <button type="button" disabled={!item} onClick={()=>item&&choose(item.hero_name)} key={card.tag}><span>{card.tag}</span>{item?<><i className="recommendationHero"><img src={heroPhoto(item.hero_name)} alt=""/></i><b>{item.hero_name}</b><small>{item.evidence_level} · {item.sample_size} GAMES</small></>:<><b>NO RESULT</b><small>INSUFFICIENT EVIDENCE</small></>}</button>})}</div>:<section><i>◈</i><b>GUIDANCE DATA PENDING</b><p>{status?.blocker||'An approved current-patch source is required.'}</p></section>}<footer>Tap a recommendation to apply it to the active slot.</footer></aside>}
function RecommendationCard({title,tag,items}:{title:string;tag:string;items:Recommendation[]}){const lead=items[0];return <article className="analysisCard"><header><span>{tag}</span><b>{title}</b></header>{lead?<><div className="analysisLead"><i><img src={heroPhoto(lead.hero_name)} alt=""/></i><div><h3>{lead.hero_name}</h3><p>{lead.reason}</p></div></div><footer><b>{lead.evidence_level} EVIDENCE</b><span>{lead.sample_size} GAMES</span></footer>{items.length>1&&<div className="analysisAlternatives">{items.slice(1).map((item,index)=><span key={item.hero_name}><i>{index+2}</i><b>{item.hero_name}</b></span>)}</div>}</>:<div className="analysisEmpty">NO VERIFIED RECOMMENDATION</div>}</article>}
function ModelPanel({ remaining, current, status, groups, loading }: { remaining: number; current?: DraftAction; status: IntelligenceStatus | null; groups: RecommendationGroups; loading: boolean }) {
  const ready=Boolean(status?.ready);
  return <aside className="draftModelPanel toolAnalysisPanel">
    <div className="draftModelHead"><span><DraftIcon/></span><div><small>CURRENT-PATCH INTELLIGENCE</small><h2>AI RECOMMENDATION</h2></div><i className={ready?'ready':''}>{ready?'VERIFIED MODEL':'DATA GATED'}</i></div>
    {!ready?<div className="modelUnavailable"><span>◈</span><h3>RECOMMENDATION DATA PENDING</h3><p>{status?.blocker||'AN APPROVED GENERAL PATCH SOURCE, ACTIVE MODEL AND VERIFIED SAMPLE ARE REQUIRED.'}</p></div>:loading?<div className="modelUnavailable"><span>◷</span><h3>CALCULATING DRAFT OPTIONS</h3><p>CHECKING CURRENT-PATCH MATCHUP EVIDENCE.</p></div>:<div className="analysisCards"><RecommendationCard tag="BAN" title="Priority Ban" items={groups.priorityBan}/><RecommendationCard tag="READ" title="Potential Opposing Pick" items={groups.potentialPick}/><RecommendationCard tag="PICK" title="Best Counter Pick" items={groups.counterPick}/></div>}
    <div className="modelContext"><div><small>CURRENT ACTION</small><b>{current ? `${current.side} · ${current.type}` : 'DRAFT COMPLETE'}</b></div><div><small>AVAILABLE HEROES</small><b>{remaining}</b></div><div><small>MODEL VERSION</small><b>{status?.model_version||'—'}</b></div><div><small>PATCH</small><b>{status?.patch||'—'}</b></div></div>
    {ready?<section className="modelEvidence"><small>VERIFIED DATA</small><div><b>{status?.source_name}</b><span>{status?.drafts_analyzed||0} GAMES · {status?.eligible_heroes||0} ELIGIBLE HEROES</span></div>{status?.attribution&&<p>{status.attribution}</p>}{status?.source_url&&<a href={status.source_url} target="_blank" rel="noreferrer">VIEW DATA SOURCE ↗</a>}</section>:<section className="modelMethod"><small>THE MODEL WILL CONSIDER</small>{['PATCH PICK & BAN PRIORITY','COUNTER MATCHUPS','ALLY SYNERGY','OPEN ROLE COVERAGE','FLEX-PICK VALUE','REMAINING HERO AVAILABILITY'].map(item => <div key={item}><span>○</span><b>{item}</b></div>)}</section>}
    <p className="modelIntegrity"><b>DATA INTEGRITY FIRST.</b> “POTENTIAL PICK” IS A META-BASED READ, NOT A CLAIM ABOUT A SPECIFIC TEAM.</p>
  </aside>;
}


function DraftBetaVisual(){const picks=['FANNY','HARITH','KAJA','BRUNO','FARAMIS'];const bans=['JOY','LING','CHIP','HAYABUSA','CHOU'];const HeroCard=({hero,type,index}:{hero:string;type:'PICK'|'BAN';index:number})=><article className={`finalPreviewHero ${type.toLowerCase()}`}><div className="finalPreviewPortrait"><img src={heroPhoto(hero)} alt={`${hero} hero portrait`} loading="lazy" decoding="async"/></div><div className="finalPreviewText"><small>{type} {index+1}</small><b>{hero}</b></div></article>;return <section className="draftBetaVisual finalDraftPreview"><header><div className="finalPreviewCopy"><span>FUNCTIONAL CLOSED BETA PREVIEW</span><h2>Clean 5-pick and 5-ban preview.</h2><p>Compact hero cards show the draft flow clearly.<br/>Tap the board below to test picks, bans, undo, reset and AI Recommendation.</p></div></header><div className="finalPreviewGrid"><section><div className="finalPreviewTitle"><span>PICK LINEUP</span><b>5 HERO PICKS</b></div><div className="finalPreviewCards">{picks.map((hero,index)=><HeroCard hero={hero} type="PICK" index={index} key={hero}/>)}</div></section><section><div className="finalPreviewTitle"><span>BAN LIST</span><b>5 HERO BANS</b></div><div className="finalPreviewCards">{bans.map((hero,index)=><HeroCard hero={hero} type="BAN" index={index} key={hero}/>)}</div></section></div></section>}

function DraftReport({region,actions,sequence,bundle,status}:{region:Region;actions:string[];sequence:DraftAction[];bundle:ModelBundle|null;status:IntelligenceStatus|null}){const entries=actions.map((hero,index)=>({hero,...sequence[index]}));const sideData=(side:Side)=>{const picks=entries.filter(item=>item.side===side&&item.type==='PICK');const bans=entries.filter(item=>item.side===side&&item.type==='BAN');const metrics=picks.map(item=>bundle?.metrics.find(metric=>metric.hero===item.hero)).filter((item):item is ModelMetric=>Boolean(item));const banMetrics=bans.map(item=>bundle?.metrics.find(metric=>metric.hero===item.hero)).filter((item):item is ModelMetric=>Boolean(item));const roles=new Set(metrics.flatMap(metric=>metric.roles||[]));const average=metrics.length===5?metrics.reduce((sum,item)=>sum+Number(item.win_rate),0)/5:null;const synergy=metrics.length===5?bundle?.relationships.filter(rel=>rel.type==='SYNERGY'&&picks.some(item=>item.hero===rel.hero)&&picks.some(item=>item.hero===rel.related_hero)).reduce((sum,item)=>sum+Math.max(0,Number(item.impact_score)),0)||0:0;return{picks,bans,average,rating:average==null?null:average+synergy*1.5,roles:metrics.length===5?roles.size:null,banPressure:banMetrics.length?banMetrics.reduce((sum,item)=>sum+Number(item.ban_rate),0)/banMetrics.length:null}};const blue=sideData('BLUE'),red=sideData('RED');const estimable=Boolean(status?.ready&&blue.rating!=null&&red.rating!=null);const total=estimable?Number(blue.rating)+Number(red.rating):0;const blueShare=estimable?Math.max(20,Math.min(80,Number(blue.rating)/total*100)):null;const redShare=blueShare==null?null:100-blueShare;return <section className="draftReport"><header><div><span>20 / 20 ACTIONS COMPLETE</span><h2>Draft Report</h2><p>Composition summary and evidence-backed draft edge.</p></div><strong>COMPLETE</strong></header><div className="draftEstimate"><article className="blue"><div><img src={REGION_INFO[region].logo} alt=""/><span><small>BLUE SIDE</small><b>{blueShare==null?'—':`${blueShare.toFixed(1)}%`}</b></span></div><div className="estimateBar"><i style={{width:`${blueShare??50}%`}}/></div><p>{blueShare==null?'VERIFIED MODEL DATA REQUIRED':'EXPERIMENTAL DRAFT WIN ESTIMATE'}</p></article><div className="estimateCenter"><span>VS</span><small>PATCH {status?.patch||'—'}</small></div><article className="red"><div><span><small>RED SIDE</small><b>{redShare==null?'—':`${redShare.toFixed(1)}%`}</b></span><img src={REGION_INFO[region].logo} alt=""/></div><div className="estimateBar"><i style={{width:`${redShare??50}%`}}/></div><p>{redShare==null?'VERIFIED MODEL DATA REQUIRED':'EXPERIMENTAL DRAFT WIN ESTIMATE'}</p></article></div><div className="draftStatGrid">{([['BLUE',blue],['RED',red]] as const).map(([side,data])=><article className={side.toLowerCase()} key={side}><h3>{side} DRAFT PROFILE</h3><div><span><small>AVG HERO WIN RATE</small><b>{data.average==null?'—':`${data.average.toFixed(1)}%`}</b></span><span><small>ROLE OPTIONS</small><b>{data.roles==null?'—':`${data.roles} / 5`}</b></span><span><small>BAN PRESSURE</small><b>{data.banPressure==null?'—':`${data.banPressure.toFixed(1)}%`}</b></span></div><footer>{data.picks.map(item=><i key={item.hero}>{item.hero}</i>)}</footer></article>)}</div><p className="estimateDisclaimer"><b>MODEL LIMITATION:</b> The estimate measures draft composition evidence only. It does not include player skill, execution, objectives or in-game decisions and is not a guaranteed match outcome.</p></section>}

export default function DraftLab({ region, notify }: { region: Region; notify?: (message: string) => void }) {
  const storageKey = 'fmpl_draft_tool';
  const [firstSide,setFirstSide]=useState<Side>('BLUE');
  const [draftReady,setDraftReady]=useState(false);
  const [mode, setMode] = useState<'companion' | 'sandbox'>('companion');
  const [actions, setActions] = useState<string[]>([]);
  const [pickerOpen, setPickerOpen] = useState(false);
  const [search, setSearch] = useState('');
  const [role, setRole] = useState<Role>('ALL');
  const [mobileTab, setMobileTab] = useState<'draft' | 'model'>('draft');
  const [intelligence, setIntelligence] = useState<IntelligenceStatus | null>(null);
  const [modelBundle, setModelBundle] = useState<ModelBundle | null>(null);
  const [groups,setGroups]=useState<RecommendationGroups>({priorityBan:[],potentialPick:[],counterPick:[]});
  const [modelLoading, setModelLoading] = useState(false);
  const [servicePause,setServicePause]=useState<string|null>(null);
  const sequence=useMemo(()=>createDraftSequence(firstSide),[firstSide]);
  const current = sequence[actions.length];
  const used = useMemo(() => new Set(actions), [actions]);
  const pickerVisible=Boolean(pickerOpen&&current);

  useEffect(()=>{
    if(!pickerVisible)return;
    const previousOverflow=document.body.style.overflow;
    document.body.style.overflow='hidden';
    const onKeyDown=(event:KeyboardEvent)=>{if(event.key==='Escape'){setPickerOpen(false);setMobileTab('draft')}};
    window.addEventListener('keydown',onKeyDown);
    return()=>{document.body.style.overflow=previousOverflow;window.removeEventListener('keydown',onKeyDown)};
  },[pickerVisible]);

  useEffect(() => {
    try {
      const saved = JSON.parse(localStorage.getItem(storageKey) || 'null') as SavedDraft | null;
      setFirstSide(saved?.firstSide==='RED'?'RED':'BLUE');
      setActions(Array.isArray(saved?.actions)?saved.actions.slice(0,20):[]);
      setMode(saved?.mode||'companion');
    } catch { setFirstSide('BLUE');setActions([]);setMode('companion'); }
    finally { setDraftReady(true); }
  }, [storageKey]);

  useEffect(() => {
    if(!draftReady)return;
    const saved: SavedDraft = { firstSide, actions, mode };
    localStorage.setItem(storageKey, JSON.stringify(saved));
  }, [storageKey, firstSide, actions, mode, draftReady]);

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

  function closePicker(){setPickerOpen(false);setMobileTab('draft')}

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

  if(servicePause)return <div className="page liveDraftLab"><section className="regionalPause"><span>REGIONAL SERVICE CONTROL</span><img src="/brand/fantasy-mpl-emblem-display.webp" alt=""/><h1>Live Draft Lab is temporarily paused.</h1><p>{servicePause}</p><button onClick={()=>window.location.reload()}>CHECK STATUS AGAIN</button></section></div>;
  return <div className="page liveDraftLab">
    <section className="draftLabHero genericDraftHero"><div><span>CURRENT-PATCH MLBB DRAFT TOOL</span><h1>BUILD THE DRAFT.<br/><em>READ THE NEXT MOVE.</em></h1><p>CHOOSE WHICH SIDE ACTS FIRST, RECORD EACH BAN AND PICK, THEN REVIEW PRIORITY BANS, POTENTIAL OPPOSING PICKS AND COUNTER OPTIONS.</p><div className="draftHeroActions"><button className="active">LIVE COMPANION</button><span className="draftBetaPill">BETA TEST · GUIDANCE PENDING</span></div></div><div className="toolBrandCard"><img src="/brand/fantasy-mpl-emblem-display.webp" alt=""/><div><small>FANTASY MPL</small><b>DRAFT INTELLIGENCE</b><span>CURRENT PATCH TOOL</span></div></div></section>

    <div className="draftIntegrity"><span>PUBLIC BETA</span><p>GENERIC PATCH TOOL · NO TEAM TENDENCIES · NO BROADCAST PROCESSING · RECOMMENDATIONS REQUIRE VERIFIED MATCHUP DATA.</p><a href="/live-draft">PUBLIC TOOL ↗</a></div>
    <div className="roneAttribution"><span>AUTHORIZED DATA INTEGRATION</span><p>Powered by MLBB Public Data API <i>•</i> Data © Moonton (Mobile Legends) <i>•</i> API maintained by ridwaanhall / RoneAI.</p><small>NON-COMMERCIAL BETA · SERVER-CACHED SNAPSHOTS · TOKEN NEVER EXPOSED TO THE BROWSER</small></div>

    <DraftBetaVisual/>

    <section className="draftToolSetup"><div><small>WHICH SIDE ACTS FIRST?</small><p>Match the first-ban side shown in your preview or lobby.</p></div><div className="firstSideChoices"><button className={firstSide==='BLUE'?'active blue':''} onClick={()=>changeFirstSide('BLUE')} disabled={!draftReady}><i><img src={REGION_INFO[region].logo} alt=""/></i><span><b>BLUE SIDE</b><small>FIRST BAN · FIRST PICK</small></span></button><button className={firstSide==='RED'?'active red':''} onClick={()=>changeFirstSide('RED')} disabled={!draftReady}><i><img src={REGION_INFO[region].logo} alt=""/></i><span><b>RED SIDE</b><small>FIRST BAN · FIRST PICK</small></span></button></div><div className="draftSetupActions"><button onClick={undo} disabled={!actions.length}>↶ UNDO</button><button onClick={reset} disabled={!actions.length}>RESET</button></div></section>

    <nav className="draftMobileTabs"><button className={mobileTab === 'draft' ? 'active' : ''} onClick={() => setMobileTab('draft')} disabled={!draftReady}>DRAFT</button><button className={mobileTab === 'model' ? 'active' : ''} onClick={() => setMobileTab('model')} disabled={!draftReady}>AI RECOMMENDATION</button></nav>

    <div className="draftWorkspace">
      <section className={`draftBoard ${mobileTab !== 'draft' ? 'mobileHidden' : ''}`}>
        <div className="draftTurn"><span className={current?.side === 'RED' ? 'red' : ''}>{current ? `${current.side} SIDE` : 'COMPLETE'}</span><div><small>{current ? `PHASE ${current.phase} · ${current.type}` : 'DRAFT COMPLETE'}</small><h2>{current ? `SELECT ${current.side} SIDE’S NEXT ${current.type}` : 'ALL PICKS AND BANS RECORDED'}</h2></div><strong>{actions.length} / {sequence.length}</strong></div>
        <div className="draftSides">
          {(['BLUE','RED'] as Side[]).map(side => <article className={`draftSide brandedDraftSide ${side.toLowerCase()} ${current?.side===side?'turnActive':''}`} key={side}>
            <img className="sideColumnWatermark" src={REGION_INFO[region].logo} alt="" aria-hidden="true"/>
            <header className="genericSideHead brandedSideHead"><span className="sideRegionMark"><img src={REGION_INFO[region].logo} alt=""/></span><div><small>{REGION_INFO[region].name}</small><h2>{side} SIDE · {side===firstSide?'FIRST ACTION':'RESPONSE'}</h2></div></header>
            <div className="draftBanRow"><small>BANS</small><div>{Array.from({length:5}, (_, position) => { const index = actionIndex(side,'BAN',position); return <DraftSlot key={position} type="BAN" number={position + 1} hero={actions[index]} active={draftReady && index === actions.length} onClick={() => draftReady && index === actions.length && setPickerOpen(true)}/>; })}</div></div>
            <div className="draftPickColumn"><small>LINEUP</small>{Array.from({length:5}, (_, position) => { const index = actionIndex(side,'PICK',position); return <DraftSlot key={position} type="PICK" number={position + 1} hero={actions[index]} active={draftReady && index === actions.length} onClick={() => draftReady && index === actions.length && setPickerOpen(true)}/>; })}</div>
          </article>)}
        </div>
        <div className="draftSequence"><span style={{width:`${(actions.length / sequence.length) * 100}%`}}/><small>GENERIC SNAKE FLOW · OPENING 1–2–2–1 · 10 BANS · 10 PICKS</small></div>
      </section>
      <div className={mobileTab !== 'model' ? 'modelMobileHidden' : ''}><ModelPanel remaining={ALL_HEROES.length - used.size} current={current} status={intelligence} groups={groups} loading={modelLoading}/></div>
    </div>
    {actions.length===sequence.length&&<DraftReport region={region} actions={actions} sequence={sequence} bundle={modelBundle} status={intelligence}/>} 

    {pickerVisible&&current&&<div className="heroPickerOverlay" onMouseDown={event=>{if(event.target===event.currentTarget)closePicker()}}><section className="heroPicker guidedHeroPicker" role="dialog" aria-modal="true" aria-labelledby="hero-picker-title">
      <div className="heroPickerHead"><div><span className={current.side==='RED'?'red':''}>{current.side} SIDE · {current.type}</span><h2 id="hero-picker-title">SELECT THE HERO TO {current.type}</h2><p>Search manually or apply verified guidance without leaving this screen.</p></div><button type="button" onClick={closePicker} aria-label="Close hero selector">×</button></div>
      <div className="heroPickerContent"><main className="heroPickerMain"><div className="heroPickerTools"><input value={search} onChange={event=>setSearch(event.target.value)} placeholder="SEARCH HERO" inputMode="search" aria-label="Search heroes"/><div>{ROLE_ORDER.map(item=><button type="button" className={role===item?'active':''} onClick={()=>setRole(item)} key={item}>{item}</button>)}</div></div><div className="heroGrid" tabIndex={0} aria-label="Available heroes">{filtered.map(hero=><button onClick={()=>chooseHero(hero)} key={hero}><span className="heroPortrait"><img src={heroPhoto(hero)} alt="" decoding="async"/></span><b>{hero}</b><small>{rolesFor(hero).join(' · ')}</small></button>)}</div>{!filtered.length&&<p className="heroPickerEmpty">NO AVAILABLE HERO MATCHES THIS FILTER.</p>}</main><PickerInsights current={current} status={intelligence} groups={groups} choose={chooseHero}/></div>
    </section></div>}

    <footer className="draftDisclaimer"><span>i</span><p><b>UNOFFICIAL ANALYSIS TOOL.</b> LIVE DRAFT LAB IS NOT AFFILIATED WITH OR ENDORSED BY MOONTON. RECOMMENDATIONS ARE PATCH-BASED GUIDANCE, NOT GUARANTEED OUTCOMES.</p></footer>
  </div>;
}
