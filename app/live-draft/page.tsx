'use client';

import { useState } from 'react';
import DraftLab from '../draft-lab';
type Region='MY'|'ID'|'PH';
const REGIONS:{code:Region;name:string;logo:string}[]=[{code:'MY',name:'MALAYSIA',logo:'/leagues/mpl-my.png'},{code:'ID',name:'INDONESIA',logo:'/leagues/mpl-id.png'},{code:'PH',name:'PHILIPPINES',logo:'/leagues/mpl-ph.png'}];

export default function PublicLiveDraftPage() {
  const[region,setRegion]=useState<Region>('MY');
  return <main className={`publicDraftPage theme${region}`}>
    <header className="publicDraftHeader"><a href="/" className="publicDraftBrand"><img src="/brand/fantasy-mpl-emblem.png" alt="Fantasy MPL"/><span><b>FANTASY MPL</b><small>LIVE DRAFT LAB</small></span></a><div className="publicRegionTool"><small>REGIONAL PATCH VIEW</small><nav>{REGIONS.map(item=><button className={region===item.code?'active':''} onClick={()=>setRegion(item.code)} key={item.code}><img src={item.logo} alt=""/><span>{item.name}</span></button>)}</nav></div><a href="/" className="publicDraftAccount">OPEN FANTASY MPL →</a></header>
    <DraftLab region={region}/>
  </main>;
}
