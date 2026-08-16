'use client';

import { useState } from 'react';
import DraftLab from '../draft-lab';

type Region = 'MY' | 'ID' | 'PH';
const REGIONS: { code: Region; name: string; logo: string }[] = [
  { code: 'MY', name: 'MPL MALAYSIA', logo: '/leagues/mpl-my.png' },
  { code: 'ID', name: 'MPL INDONESIA', logo: '/leagues/mpl-id.png' },
  { code: 'PH', name: 'MPL PHILIPPINES', logo: '/leagues/mpl-ph.png' }
];

export default function PublicLiveDraftPage() {
  const [region, setRegion] = useState<Region>('MY');
  return <main className={`publicDraftPage theme${region}`}>
    <header className="publicDraftHeader"><a href="/" className="publicDraftBrand"><img src="/brand/fantasy-mpl-emblem.png" alt="Fantasy MPL"/><span><b>FANTASY MPL</b><small>LIVE DRAFT LAB</small></span></a><nav>{REGIONS.map(item => <button key={item.code} className={region === item.code ? 'active' : ''} onClick={() => setRegion(item.code)}><img src={item.logo} alt=""/>{item.name}</button>)}</nav><a href="/" className="publicDraftAccount">OPEN FANTASY MPL →</a></header>
    <DraftLab region={region}/>
  </main>;
}
