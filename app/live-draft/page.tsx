'use client';

import DraftLab from '../draft-lab';

export default function PublicLiveDraftPage() {
  return <main className="publicDraftPage themeMY">
    <header className="publicDraftHeader"><a href="/" className="publicDraftBrand"><img src="/brand/fantasy-mpl-emblem.png" alt="Fantasy MPL"/><span><b>FANTASY MPL</b><small>LIVE DRAFT LAB</small></span></a><div className="publicToolIdentity"><span>GENERAL MLBB TOOL</span><b>CURRENT-PATCH DRAFT ANALYSIS</b></div><a href="/" className="publicDraftAccount">OPEN FANTASY MPL →</a></header>
    <DraftLab region="MY"/>
  </main>;
}
