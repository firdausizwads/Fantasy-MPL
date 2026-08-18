'use client';

import { useState } from 'react';
import DraftLab from '../draft-lab';
type Region='MY'|'ID'|'PH';
const REGIONS:{code:Region;name:string;logo:string}[]=[{code:'MY',name:'MALAYSIA',logo:'/leagues/display/mpl-my.webp'},{code:'ID',name:'INDONESIA',logo:'/leagues/display/mpl-id.webp'},{code:'PH',name:'PHILIPPINES',logo:'/leagues/display/mpl-ph.webp'}];

export default function PublicLiveDraftPage() {
  const[region,setRegion]=useState<Region>('MY');
  return <main className={`publicDraftPage theme${region}`}>
    <header className="publicDraftHeader"><a href="/" className="publicDraftBrand"><img src="/brand/fantasy-mpl-emblem-display.webp" alt="Fantasy MPL"/><span><b>FANTASY MPL</b><small>LIVE DRAFT LAB</small></span></a><div className="publicRegionTool"><small>REGIONAL PATCH VIEW</small><nav>{REGIONS.map(item=><button className={region===item.code?'active':''} onClick={()=>setRegion(item.code)} key={item.code}><img src={item.logo} alt=""/><span>{item.name}</span></button>)}</nav></div><a href="/" className="publicDraftAccount">OPEN FANTASY MPL →</a></header>
    <DraftLab region={region}/>
  </main>;
}
