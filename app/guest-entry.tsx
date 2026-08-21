'use client';

import { useEffect, useMemo, useState, type CSSProperties } from 'react';
import officialTeams from './official-teams.json';

type Region='MY'|'ID'|'PH';
type AuthMode='register'|'signin';
type Stage='welcome'|'battleground'|'ready';

const REGIONS:Record<Region,{name:string;country:string;headline:string;copy:string;logo:string;thumb:string}>={
  MY:{name:'MPL Malaysia',country:'MALAYSIA',headline:'OWN THE ARENA',copy:'Explore Malaysia’s fantasy roster, weekly predictions, draft tools and regional competition.',logo:'/leagues/display/mpl-my.webp',thumb:'/leagues/thumb/mpl-my.webp'},
  ID:{name:'MPL Indonesia',country:'INDONESIA',headline:'RULE THE META',copy:'Follow Indonesia’s teams, study the meta and preview every competitive Fantasy MPL workspace.',logo:'/leagues/display/mpl-id.webp',thumb:'/leagues/thumb/mpl-id.webp'},
  PH:{name:'MPL Philippines',country:'PHILIPPINES',headline:'BACK THE CHAMPIONS',copy:'Enter the Philippine regional hub, explore its players and preview the complete fantasy experience.',logo:'/leagues/display/mpl-ph.webp',thumb:'/leagues/thumb/mpl-ph.webp'}
};

const SHOWCASE=(Object.entries(officialTeams) as [Region,(typeof officialTeams)[Region]][]).flatMap(([region,teams])=>teams.map(team=>({...team,region})));

function Brand(){return <a className="guestBrand" href="/" aria-label="Fantasy MPL home"><img src="/brand/fantasy-mpl-emblem-96.webp" alt=""/><span><b>FANTASY MPL</b><small>FANTASY · PREDICTIONS · COMMUNITY</small></span></a>}

export default function GuestEntry({initialRegion,onExplore,onAuth}:{initialRegion?:Region;onExplore:(region:Region)=>void;onAuth:(mode:AuthMode)=>void}){
  const[stage,setStage]=useState<Stage>('welcome');
  const[transitioning,setTransitioning]=useState(false);
  const[selected,setSelected]=useState<Region|undefined>(initialRegion);
  const regionEntries=useMemo(()=>Object.entries(REGIONS) as [Region,(typeof REGIONS)[Region]][],[]);

  useEffect(()=>{
    if(stage!=='welcome')return;
    let switchTimer:number|undefined;
    const fadeTimer=window.setTimeout(()=>{setTransitioning(true);switchTimer=window.setTimeout(()=>{setStage('battleground');setTransitioning(false)},450)},5750);
    return()=>{window.clearTimeout(fadeTimer);if(switchTimer)window.clearTimeout(switchTimer)};
  },[stage]);

  useEffect(()=>{
    if(stage!=='ready'||!selected)return;
    const timer=window.setTimeout(()=>onExplore(selected),1250);
    return()=>window.clearTimeout(timer);
  },[stage,selected,onExplore]);

  function showBattleground(){if(transitioning)return;setTransitioning(true);window.setTimeout(()=>{setStage('battleground');setTransitioning(false)},450)}
  function choose(region:Region){setSelected(region);setStage('ready')}

  return <main className={`guestEntry guestStage-${stage} ${transitioning?'guestTransitioning':''}`}>
    <div className="guestAmbient guestAmbientOne"/><div className="guestAmbient guestAmbientTwo"/>
    <header className="guestEntryHeader"><Brand/><nav><button type="button" onClick={()=>onAuth('signin')}>SIGN IN</button><button type="button" className="guestJoinButton" onClick={()=>onAuth('register')}>CREATE FREE ACCOUNT</button></nav></header>

    <div className="guestJourney" aria-label="Fantasy MPL entry journey">{([['welcome','1','WELCOME'],['battleground','2','CHOOSE REGION'],['ready','3','EXPLORE']] as const).map(([id,number,label])=><span className={stage===id?'active':stage==='ready'||(stage==='battleground'&&id==='welcome')?'done':''} key={id}><i>{stage!==id&&(stage==='ready'||(stage==='battleground'&&id==='welcome'))?'✓':number}</i><b>{label}</b></span>)}</div>

    {stage==='welcome'&&<section className="guestWelcome" aria-live="polite"><div className="guestWelcomeCopy"><span>WELCOME TO THE REGIONAL ARENA</span><h1>YOUR MPL JOURNEY<br/>STARTS <em>HERE.</em></h1><p>Explore fantasy rosters, match predictions, team directories, playoff brackets, Meta Lab and Live Draft Lab before creating an account.</p><div><button type="button" className="guestPrimary" onClick={showBattleground}>EXPLORE THE ARENA <i>→</i></button><button type="button" className="guestSecondary" onClick={()=>onAuth('register')}>CREATE YOUR MANAGER</button></div><small>A Fantasy MPL account is only required when you want to save, submit and compete.</small></div><div className="guestWelcomeVisual" aria-hidden="true"><div className="guestOrbit"><img className="guestCore" src="/brand/fantasy-mpl-emblem-display.webp" alt=""/>{regionEntries.map(([code,region],index)=><span className={`guestOrbitRegion orbit${index+1}`} key={code}><img src={region.thumb} alt=""/><b>{code}</b></span>)}</div><div className="guestVisualCaption"><span>SEASON 18</span><b>THREE REGIONS · ONE PLATFORM</b></div></div><button type="button" className="guestSkip" onClick={showBattleground}>SKIP INTRO</button></section>}

    {stage==='battleground'&&<section className="guestBattleground" aria-live="polite"><div className="guestBattleIntro"><span>STEP 2 · REGIONAL ENTRY</span><h1>CHOOSE YOUR BATTLEGROUND</h1><p>Browse any region now. You can switch between Malaysia, Indonesia and the Philippines at any time.</p></div><div className="guestRegionCards">{regionEntries.map(([code,region],index)=><button type="button" className={`guestRegionCard guestRegion${code}`} style={{'--guest-order':index} as CSSProperties} onClick={()=>choose(code)} key={code}><img className="guestRegionWatermark" src={region.logo} alt=""/><header><span><img src={region.thumb} alt=""/></span><b>{region.country}</b><em>0{index+1}</em></header><div className="guestRegionLogo"><img src={region.logo} alt={`${region.name} logo`}/></div><div className="guestRegionInfo"><small>REGIONAL EXPERIENCE</small><h2>{region.name}</h2><strong>{region.headline}</strong><p>{region.copy}</p></div><footer><span>EXPLORE AS GUEST</span><i>→</i></footer></button>)}</div><section className="guestTeamShowcase"><header><div><span>SEASON 18 TEAM SHOWCASE</span><h2>Meet the teams inside every regional arena.</h2></div><p>No login required to browse team and player directories.</p></header><div className="guestShowcaseViewport"><div className="guestShowcaseTrack">{[...SHOWCASE,...SHOWCASE].map((team,index)=><article className={`showcase${team.region}`} key={`${team.region}-${team.code}-${index}`}><i><img src={team.logo.replace('/teams-display/','/teams-thumb/')} alt="" loading="lazy"/></i><span><small>{REGIONS[team.region].name}</small><b>{team.name}</b></span><em>{team.code}</em></article>)}</div></div></section></section>}

    {stage==='ready'&&selected&&<section className={`guestReady guestReady${selected}`} aria-live="polite"><div className="guestReadyPulse"><img src={REGIONS[selected].logo} alt=""/><i/></div><span>STEP 3 · ARENA READY</span><h1>{REGIONS[selected].name}</h1><p>Opening the regional command center in guest preview mode.</p><div className="guestReadyProgress"><i/></div><button type="button" onClick={()=>onExplore(selected)}>ENTER NOW →</button></section>}

    <footer className="guestEntryFooter"><span>UNOFFICIAL COMMUNITY PLATFORM · NOT AFFILIATED WITH MOONTON</span><nav><a href="/privacy">PRIVACY</a><a href="/terms">TERMS</a><a href="/rules">SCORING</a><a href="/community-guidelines">COMMUNITY</a></nav></footer>
  </main>
}
