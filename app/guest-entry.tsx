'use client';

import { useEffect, useMemo, useState, type CSSProperties } from 'react';
import officialTeams from './official-teams.json';

type Region='MY'|'ID'|'PH';
type AuthMode='register'|'signin';
type Stage='welcome'|'battleground'|'ready';

const MLBB_LOGO='/brand/mobile-legends-bang-bang-logo.png';

const REGIONS:Record<Region,{name:string;country:string;headline:string;copy:string;cinematic:string;logo:string;thumb:string}>={
  MY:{name:'MPL Malaysia',country:'MALAYSIA',headline:'OWN THE ARENA',copy:'Explore Malaysia’s fantasy roster, weekly predictions, draft tools and regional competition.',cinematic:'Born from the arena. Built for bold predictions.',logo:'/leagues/display/mpl-my.webp',thumb:'/leagues/thumb/mpl-my.webp'},
  ID:{name:'MPL Indonesia',country:'INDONESIA',headline:'RULE THE META',copy:'Follow Indonesia’s teams, study the meta and preview every competitive Fantasy MPL workspace.',cinematic:'Where every draft becomes a statement.',logo:'/leagues/display/mpl-id.webp',thumb:'/leagues/thumb/mpl-id.webp'},
  PH:{name:'MPL Philippines',country:'PHILIPPINES',headline:'BACK THE CHAMPIONS',copy:'Enter the Philippine regional hub, explore its players and preview the complete fantasy experience.',cinematic:'Champions rise when the community believes.',logo:'/leagues/display/mpl-ph.webp',thumb:'/leagues/thumb/mpl-ph.webp'}
};

const CINEMATIC_PRELOAD_ASSETS=[MLBB_LOGO,...Object.values(REGIONS).flatMap(region=>[region.logo,region.thumb])];

function Brand(){return <a className="guestBrand" href="/" aria-label="Fantasy MPL home"><img src="/brand/fantasy-mpl-emblem-96.webp" alt=""/><span><b>FANTASY MPL</b><small>FANTASY · PREDICTIONS · COMMUNITY</small></span></a>}

export default function GuestEntry({initialRegion,onExplore,onAuth}:{initialRegion?:Region;onExplore:(region:Region)=>void;onAuth:(mode:AuthMode)=>void}){
  const[stage,setStage]=useState<Stage>('welcome');
  const[scene,setScene]=useState(0);
  const[transitioning,setTransitioning]=useState(false);
  const[selected,setSelected]=useState<Region|undefined>(initialRegion);
  const[showcaseRegion,setShowcaseRegion]=useState<Region>(initialRegion||'MY');
  const regionEntries=useMemo(()=>Object.entries(REGIONS) as [Region,(typeof REGIONS)[Region]][],[]);

  useEffect(()=>{
    CINEMATIC_PRELOAD_ASSETS.forEach(src=>{
      const image=new Image();
      image.decoding='async';
      image.src=src;
    });
  },[]);

  useEffect(()=>{
    if(stage!=='welcome')return;
    const reduced=window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    const timers:number[]=[];
    if(reduced){setScene(4);timers.push(window.setTimeout(()=>setTransitioning(true),2200),window.setTimeout(()=>{setStage('battleground');setTransitioning(false)},2550))}
    else{
      [[1400,1],[3200,2],[5000,3],[6800,4]].forEach(([delay,next])=>timers.push(window.setTimeout(()=>setScene(next),delay)));
      timers.push(window.setTimeout(()=>setTransitioning(true),8500));
      timers.push(window.setTimeout(()=>{setStage('battleground');setTransitioning(false)},8950));
    }
    return()=>timers.forEach(timer=>window.clearTimeout(timer));
  },[stage]);

  useEffect(()=>{
    if(stage!=='ready'||!selected)return;
    const timer=window.setTimeout(()=>onExplore(selected),1250);
    return()=>window.clearTimeout(timer);
  },[stage,selected,onExplore]);

  function choose(region:Region){setSelected(region);setStage('ready')}
  const activeShowcase=officialTeams[showcaseRegion];

  return <main className={`guestEntry guestStage-${stage} guestScene-${scene} ${transitioning?'guestTransitioning':''}`}>
    <div className="guestAmbient guestAmbientOne"/><div className="guestAmbient guestAmbientTwo"/>
    <header className="guestEntryHeader"><Brand/><nav><button type="button" onClick={()=>onAuth('signin')}>SIGN IN</button><button type="button" className="guestJoinButton" onClick={()=>onAuth('register')}>CREATE FREE ACCOUNT</button></nav></header>

    {stage==='welcome'&&<section className="guestCinematic" aria-live="polite">
      <div className="cinematicGrid" aria-hidden="true"/><div className="cinematicBeam" aria-hidden="true"/><div className="cinematicGrain" aria-hidden="true"/>
      <article className={`cinematicIntro ${scene===0?'active':''}`} aria-hidden={scene!==0}><span>THE REGIONAL FANTASY EXPERIENCE</span><h1>WELCOME TO<br/><em>FANTASY MPL.</em></h1><p>Fantasy. Predictions. Draft intelligence. Community.</p><div className="cinematicMlbbReveal" aria-hidden="true"><span className="mlbbPortal"><i/><i/><i/></span><span className="mlbbLightSweep"/><img src={MLBB_LOGO} alt="" loading="eager" decoding="async" fetchPriority="high"/></div></article>
      {regionEntries.map(([code,region],index)=><article className={`cinematicRegion cinematic${code} ${scene===index+1?'active':''} ${scene>index+1?'played':''}`} aria-hidden={scene!==index+1} key={code}><div className="cinematicRegionWord">{region.country}</div><div className="cinematicRegionCopy"><span>REGIONAL ARENA</span><h2>{region.name}</h2><p>{region.cinematic}</p><small>SEASON 18 · {region.headline}</small></div><div className="cinematicRegionLogo"><i/><img src={region.logo} alt={`${region.name} logo`}/></div></article>)}
      <article className={`cinematicFinal ${scene===4?'active':''}`} aria-hidden={scene!==4}><div className="cinematicFinalMarks">{regionEntries.map(([code,region])=><span key={code}><img src={region.thumb} alt={`${region.name} mark`}/></span>)}</div><img className="cinematicFinalBrand" src={MLBB_LOGO} alt="Mobile Legends: Bang Bang" loading="eager" decoding="async" fetchPriority="high"/><span>THE ARENA IS OPEN</span><h2>THREE REGIONS.<br/>ONE FANTASY ARENA.</h2><p>Choose your battleground next.</p></article>
      <div className="cinematicTimeline" aria-hidden="true"><span className={scene>=1?'active':''}>MALAYSIA</span><span className={scene>=2?'active':''}>INDONESIA</span><span className={scene>=3?'active':''}>PHILIPPINES</span><i><b style={{width:`${Math.min(100,(scene/4)*100)}%`}}/></i></div>
    </section>}

    {stage==='battleground'&&<section className="guestBattleground" aria-live="polite"><div className="guestBattleIntro"><span>SELECT YOUR REGIONAL EXPERIENCE</span><h1>CHOOSE YOUR BATTLEGROUND</h1><p>Browse any region now. You can switch between Malaysia, Indonesia and the Philippines at any time.</p></div><div className="guestRegionCards">{regionEntries.map(([code,region],index)=><button type="button" className={`guestRegionCard guestRegion${code}`} style={{'--guest-order':index} as CSSProperties} onClick={()=>choose(code)} key={code}><img className="guestRegionWatermark" src={region.logo} alt=""/><header><span><img src={region.thumb} alt=""/></span><b>{region.country}</b></header><div className="guestRegionLogo"><img src={region.logo} alt={`${region.name} logo`}/></div><div className="guestRegionInfo"><small>REGIONAL EXPERIENCE</small><h2>{region.name}</h2><strong>{region.headline}</strong><p>{region.copy}</p></div><footer><span>EXPLORE AS GUEST</span><i>→</i></footer></button>)}</div><section className="guestTeamShowcase modernTeamShowcase"><header><div><span>SEASON 18 · VERIFIED TEAMS</span><h2>Explore the regional team grid.</h2><p>Choose a league to preview every team inside its Fantasy MPL directory.</p></div><nav aria-label="Team showcase region">{regionEntries.map(([code,region])=><button type="button" className={showcaseRegion===code?'active':''} onClick={()=>setShowcaseRegion(code)} key={code}><img src={region.thumb} alt=""/><span>{code}</span><b>{region.name}</b></button>)}</nav></header><div className="modernTeamGrid" key={showcaseRegion}>{activeShowcase.map((team,index)=><article style={{'--team-order':index} as CSSProperties} key={team.code}><div className="modernTeamLogo"><img src={team.logo} alt={`${team.name} logo`} loading="lazy"/></div><span><small>{REGIONS[showcaseRegion].name}</small><b>{team.name}</b><em>{team.code}</em></span><i>VIEW</i></article>)}</div><footer><span>{activeShowcase.length} VERIFIED TEAM IDENTITIES</span><p>Player rosters and sourced portraits are available after entering {REGIONS[showcaseRegion].name}.</p></footer></section></section>}

    {stage==='ready'&&selected&&<section className={`guestReady guestReady${selected}`} aria-live="polite"><div className="guestReadyPulse"><img src={REGIONS[selected].logo} alt=""/><i/></div><span>REGIONAL ARENA READY</span><h1>{REGIONS[selected].name}</h1><p>Opening the regional command center in guest preview mode.</p><div className="guestReadyProgress"><i/></div><button type="button" onClick={()=>onExplore(selected)}>ENTER NOW →</button></section>}

    <footer className="guestEntryFooter"><span>UNOFFICIAL COMMUNITY PLATFORM · NOT AFFILIATED WITH MOONTON</span><nav><a href="/privacy">PRIVACY</a><a href="/terms">TERMS</a><a href="/rules">SCORING</a><a href="/community-guidelines">COMMUNITY</a></nav></footer>
  </main>
}
