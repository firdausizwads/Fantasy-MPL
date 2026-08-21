'use client';

import { FormEvent, useEffect, useState } from 'react';
import { supabase } from '../lib/supabase/client';

type Region = 'MY' | 'ID' | 'PH';
type SourceRow = { id:string; name:string; provider_url:string; terms_url:string|null; license_name:string|null; attribution_text:string|null; approval_status:string; commercial_use_confirmed:boolean; primary_for_model:boolean; notes:string|null };
type PatchRow = { id:string; version:string; released_at:string|null; notes_url:string|null; active:boolean };
type ModelRow = { id:string; name:string; version:string; description:string|null; minimum_sample:number; active:boolean; patch_id:string|null };
type MetricSummary = { region_code:string; heroes:number; games:number; last_verified:string|null };
type TeamRow = { id:string; code:string; name:string; region_code:string };
type Config = { sources:SourceRow[]; patches:PatchRow[]; models:ModelRow[]; teams:TeamRow[]; metrics_by_region:MetricSummary[]; verified_games:number; ordered_actions:number };
type MetricInput = { hero:string; games:number; picks:number; bans:number; wins:number };
type DraftActionInput = { sequence:number; side:'BLUE'|'RED'; type:'BAN'|'PICK'; phase:number; hero:string };
type IntelligenceTab = 'overview'|'sources'|'data'|'import'|'model';

const emptyConfig:Config={sources:[],patches:[],models:[],teams:[],metrics_by_region:[],verified_games:0,ordered_actions:0};

export default function AdminDraftIntelligence({region,notify}:{region:Region;notify:(message:string)=>void}){
  const [config,setConfig]=useState<Config>(emptyConfig);
  const [activeTab,setActiveTab]=useState<IntelligenceTab>('overview');
  const [loading,setLoading]=useState(true);
  const [busy,setBusy]=useState(false);
  const [sourceName,setSourceName]=useState('');
  const [providerUrl,setProviderUrl]=useState('');
  const [termsUrl,setTermsUrl]=useState('');
  const [licenseName,setLicenseName]=useState('');
  const [attribution,setAttribution]=useState('');
  const [approval,setApproval]=useState('pending');
  const [commercial,setCommercial]=useState(false);
  const [primary,setPrimary]=useState(false);
  const [notes,setNotes]=useState('');
  const [sourceId,setSourceId]=useState('');
  const [patchId,setPatchId]=useState('');
  const [csv,setCsv]=useState('hero,games,picks,bans,wins\n');
  const [patchVersion,setPatchVersion]=useState('');
  const [patchReleased,setPatchReleased]=useState('');
  const [patchNotes,setPatchNotes]=useState('');
  const [minimumSample,setMinimumSample]=useState(10);
  const [matchKey,setMatchKey]=useState('');
  const [gameNumber,setGameNumber]=useState(1);
  const [playedAt,setPlayedAt]=useState('');
  const [blueTeam,setBlueTeam]=useState('');
  const [redTeam,setRedTeam]=useState('');
  const [winnerSide,setWinnerSide]=useState<'BLUE'|'RED'>('BLUE');
  const [draftSourceUrl,setDraftSourceUrl]=useState('');
  const [actionsCsv,setActionsCsv]=useState('sequence,side,type,phase,hero\n1,BLUE,BAN,1,\n2,RED,BAN,1,\n3,BLUE,BAN,1,\n4,RED,BAN,1,\n5,BLUE,BAN,1,\n6,RED,BAN,1,\n7,BLUE,PICK,1,\n8,RED,PICK,1,\n9,RED,PICK,1,\n10,BLUE,PICK,1,\n11,BLUE,PICK,1,\n12,RED,PICK,1,\n13,RED,BAN,2,\n14,BLUE,BAN,2,\n15,RED,BAN,2,\n16,BLUE,BAN,2,\n17,RED,PICK,2,\n18,BLUE,PICK,2,\n19,BLUE,PICK,2,\n20,RED,PICK,2,');

  async function load(){
    if(!supabase)return;
    setLoading(true);
    const {data,error}=await supabase.rpc('admin_draft_intelligence_config');
    if(error){notify(error.message);setLoading(false);return}
    const next=data as unknown as Config;
    setConfig(next);
    const eligibleSources=next.sources.filter(item=>item.approval_status==='approved'&&item.commercial_use_confirmed);
    setSourceId(current=>eligibleSources.some(item=>item.id===current)?current:eligibleSources.find(item=>item.primary_for_model)?.id||eligibleSources[0]?.id||'');
    setPatchId(current=>current||next.patches.find(item=>item.active)?.id||next.patches[0]?.id||'');
    const regionalTeams=(next.teams||[]).filter(item=>item.region_code===region);
    setBlueTeam(current=>regionalTeams.some(item=>item.code===current)?current:regionalTeams[0]?.code||'');
    setRedTeam(current=>regionalTeams.some(item=>item.code===current)&&current!==regionalTeams[0]?.code?current:regionalTeams[1]?.code||'');
    setLoading(false);
  }
  useEffect(()=>{load()},[region]);

  async function saveSource(event:FormEvent){
    event.preventDefault(); if(!supabase)return;
    if(sourceName.trim().length<3||!providerUrl.startsWith('http')){notify('Enter a source name and valid provider URL.');return}
    if(primary&&(!commercial||approval!=='approved')){notify('A primary source must be approved for commercial use.');return}
    setBusy(true);
    const {error}=await supabase.rpc('admin_upsert_draft_source',{
      source_name:sourceName.trim(),source_provider_url:providerUrl.trim(),source_terms_url:termsUrl.trim(),
      source_license_name:licenseName.trim(),source_attribution_text:attribution.trim(),
      source_approval_status:approval,source_commercial_confirmed:commercial,source_primary:primary,source_notes:notes.trim()
    });
    setBusy(false);if(error){notify(error.message);return}
    notify('Draft data source saved.');setSourceName('');setProviderUrl('');setTermsUrl('');setLicenseName('');setAttribution('');setNotes('');setApproval('pending');setCommercial(false);setPrimary(false);await load();
  }

  async function savePatch(event:FormEvent){
    event.preventDefault();if(!supabase)return;
    if(!/^\d+(\.\d+)+$/.test(patchVersion.trim())){notify('Enter a patch version such as 2.1.95.');return}
    setBusy(true);
    await supabase.from('patches').update({active:false}).eq('active',true);
    const {error}=await supabase.from('patches').upsert({version:patchVersion.trim(),notes_url:patchNotes.trim()||null,released_at:patchReleased?new Date(`${patchReleased}T00:00:00Z`).toISOString():null,active:true},{onConflict:'version'});
    setBusy(false);if(error){notify(error.message);return}
    notify(`Patch ${patchVersion.trim()} set active.`);setPatchVersion('');setPatchReleased('');setPatchNotes('');setPatchId('');await load();
  }

  function parseMetrics():MetricInput[]{
    const lines=csv.trim().split(/\r?\n/).filter(Boolean);
    if(lines[0]?.toLowerCase().replaceAll(' ','')==='hero,games,picks,bans,wins')lines.shift();
    return lines.map((line,index)=>{
      const [hero,games,picks,bans,wins]=line.split(',').map(value=>value.trim());
      const row={hero:hero?.toUpperCase(),games:Number(games),picks:Number(picks),bans:Number(bans),wins:Number(wins)};
      if(!row.hero||[row.games,row.picks,row.bans,row.wins].some(value=>!Number.isInteger(value)||value<0))throw new Error(`Invalid metrics on CSV row ${index+2}.`);
      if(row.picks>row.games||row.bans>row.games||row.wins>row.picks)throw new Error(`Impossible counts on CSV row ${index+2}.`);
      return row;
    });
  }

  async function importMetrics(){
    if(!supabase||!sourceId||!patchId){notify('Choose an approved source and active patch.');return}
    let metrics:MetricInput[];try{metrics=parseMetrics()}catch(error){notify(error instanceof Error?error.message:'Invalid CSV.');return}
    if(!metrics.length){notify('Add at least one metrics row.');return}
    setBusy(true);
    const {data,error}=await supabase.rpc('admin_import_hero_metrics',{target_source:sourceId,target_patch:patchId,target_region:region,metrics});
    setBusy(false);if(error){notify(error.message);return}
    const result=data as {imported?:number};notify(`${result.imported||metrics.length} verified hero metrics imported for ${region}.`);await load();
  }

  function parseDraftActions():DraftActionInput[]{
    const lines=actionsCsv.trim().split(/\r?\n/).filter(Boolean);
    if(lines[0]?.toLowerCase().replaceAll(' ','')==='sequence,side,type,phase,hero')lines.shift();
    const expected:[string,string,number][]=[['BLUE','BAN',1],['RED','BAN',1],['BLUE','BAN',1],['RED','BAN',1],['BLUE','BAN',1],['RED','BAN',1],['BLUE','PICK',1],['RED','PICK',1],['RED','PICK',1],['BLUE','PICK',1],['BLUE','PICK',1],['RED','PICK',1],['RED','BAN',2],['BLUE','BAN',2],['RED','BAN',2],['BLUE','BAN',2],['RED','PICK',2],['BLUE','PICK',2],['BLUE','PICK',2],['RED','PICK',2]];
    if(lines.length!==20)throw new Error('A complete professional draft requires exactly 20 action rows.');
    const seen=new Set<string>();
    return lines.map((line,index)=>{
      const [sequenceRaw,sideRaw,typeRaw,phaseRaw,heroRaw]=line.split(',').map(value=>value.trim());
      const sequence=Number(sequenceRaw),phase=Number(phaseRaw),side=sideRaw.toUpperCase(),type=typeRaw.toUpperCase(),hero=heroRaw.toUpperCase();
      const rule=expected[index];
      if(sequence!==index+1||side!==rule[0]||type!==rule[1]||phase!==rule[2])throw new Error(`Draft sequence mismatch on row ${index+2}.`);
      if(!hero)throw new Error(`Hero is missing on row ${index+2}.`);
      if(seen.has(hero))throw new Error(`${hero} appears more than once.`);seen.add(hero);
      return{sequence,side:side as 'BLUE'|'RED',type:type as 'BAN'|'PICK',phase,hero};
    });
  }

  async function importOrderedDraft(){
    if(!supabase||!sourceId||!patchId){notify('Choose an approved source and patch.');return}
    if(!matchKey.trim()||!playedAt||!blueTeam||!redTeam||blueTeam===redTeam||!draftSourceUrl.startsWith('http')){notify('Complete the match key, source URL, date and two different teams.');return}
    let actions:DraftActionInput[];try{actions=parseDraftActions()}catch(error){notify(error instanceof Error?error.message:'Invalid ordered draft CSV.');return}
    setBusy(true);
    const {data,error}=await supabase.rpc('admin_import_pro_draft_game',{target_source:sourceId,target_patch:patchId,target_region:region,target_source_match_key:matchKey.trim(),target_game_number:gameNumber,target_played_at:new Date(playedAt).toISOString(),target_blue_team_code:blueTeam,target_red_team_code:redTeam,target_winner_side:winnerSide,target_source_url:draftSourceUrl.trim(),target_actions:actions});
    setBusy(false);if(error){notify(error.message);return}
    const result=data as {actions_imported?:number};notify(`${result.actions_imported||20} ordered actions verified and imported.`);setMatchKey('');setDraftSourceUrl('');await load();
  }

  async function activateModel(modelId:string){
    if(!supabase||!patchId){notify('Choose the active patch first.');return}
    if(!window.confirm('Activate this model for public recommendations using the approved primary source?'))return;
    setBusy(true);const {error}=await supabase.rpc('admin_activate_draft_model',{target_model:modelId,target_patch:patchId,target_minimum_sample:minimumSample});setBusy(false);
    if(error){notify(error.message);return}notify('Draft intelligence model activated.');await load();
  }

  if(loading)return <section className="panel intelligenceLoading"><span>◌</span><h2>Preparing Draft Intelligence</h2><p>Loading sources, patches and model configuration.</p></section>;
  const approvedSources=config.sources.filter(item=>item.approval_status==='approved'&&item.commercial_use_confirmed);
  const activePatch=config.patches.find(item=>item.active);
  const primarySource=approvedSources.find(item=>item.primary_for_model);
  const activeModel=config.models.find(item=>item.active);
  const regionalMetrics=config.metrics_by_region.find(item=>item.region_code===region);
  const readiness=[
    {label:'Approved data source',ready:Boolean(primarySource),detail:primarySource?.name||'Approval and commercial-use confirmation required'},
    {label:'Active patch',ready:Boolean(activePatch),detail:activePatch?.version||'No patch is active'},
    {label:`${region} patch data`,ready:Boolean(regionalMetrics?.heroes),detail:regionalMetrics?`${regionalMetrics.heroes} heroes · ${regionalMetrics.games} games`:'No verified metrics imported'},
    {label:'Active model',ready:Boolean(activeModel),detail:activeModel?.version||'Model activation pending'}
  ];
  const readyCount=readiness.filter(item=>item.ready).length;
  const regionalTeams=config.teams.filter(team=>team.region_code===region);
  const tabs:{id:IntelligenceTab;label:string;description:string}[]=[
    {id:'overview',label:'Overview',description:'Readiness and status'},
    {id:'sources',label:'Sources',description:'Rights and attribution'},
    {id:'data',label:'Patch & Data',description:'Patch and metrics'},
    {id:'import',label:'Draft Import',description:'Ordered game records'},
    {id:'model',label:'Model',description:'Version activation'}
  ];

  return <div className="intelligenceConsole">
    <header className="intelligenceHeader">
      <div><span>LIVE DRAFT LAB · ADMINISTRATION</span><h1>Draft Intelligence</h1><p>Manage trusted sources, current-patch evidence and public model activation from one controlled workspace.</p></div>
      <aside><small>PUBLIC STATUS</small><strong className={activeModel?'online':'offline'}>{activeModel?'MODEL ACTIVE':'DATA GATED'}</strong><span>{readyCount} of {readiness.length} requirements ready</span></aside>
    </header>

    <nav className="intelligenceTabs" aria-label="Draft intelligence sections">{tabs.map(tab=><button type="button" className={activeTab===tab.id?'active':''} onClick={()=>setActiveTab(tab.id)} key={tab.id}><b>{tab.label}</b><small>{tab.description}</small></button>)}</nav>

    {activeTab==='overview'&&<div className="intelligenceOverview">
      <section className="panel readinessPanel"><div className="intelligenceSectionHead"><div><span>MODEL READINESS</span><h2>Launch requirements</h2><p>Public recommendations stay disabled until every required evidence gate passes.</p></div><strong>{readyCount}/{readiness.length}</strong></div><div className="readinessList">{readiness.map(item=><article className={item.ready?'ready':'pending'} key={item.label}><i>{item.ready?'✓':'!'}</i><div><b>{item.label}</b><span>{item.detail}</span></div><em>{item.ready?'READY':'ACTION NEEDED'}</em></article>)}</div></section>
      <aside className="overviewSide">
        <section className="panel intelligenceSummary"><span>CURRENT CONFIGURATION</span><div><small>REGION</small><b>{region}</b></div><div><small>PRIMARY SOURCE</small><b>{primarySource?.name||'—'}</b></div><div><small>PATCH</small><b>{activePatch?.version||'—'}</b></div><div><small>MODEL VERSION</small><b>{activeModel?.version||'—'}</b></div></section>
        <section className="panel evidenceTotals"><span>VERIFIED EVIDENCE</span><div><b>{config.verified_games}</b><small>PRO GAMES</small></div><div><b>{config.ordered_actions}</b><small>ORDERED ACTIONS</small></div><div><b>{regionalMetrics?.heroes||0}</b><small>{region} HEROES</small></div></section>
      </aside>
      <section className="panel regionCoverage"><div className="intelligenceSectionHead"><div><span>REGIONAL COVERAGE</span><h2>Dataset health</h2></div></div><div>{(['MY','ID','PH'] as Region[]).map(code=>{const row=config.metrics_by_region.find(item=>item.region_code===code);return <article className={row?.heroes?'hasData':''} key={code}><strong>{code}</strong><div><b>{row?.heroes||0} HEROES</b><span>{row?.games||0} verified games</span></div><em>{row?.last_verified?new Date(row.last_verified).toLocaleDateString():'NOT IMPORTED'}</em></article>})}</div></section>
    </div>}

    {activeTab==='sources'&&<div className="sourceWorkspace modernSourceWorkspace">
      <section className="sourceGovernanceSummary">
        <div><span>DATA SOURCE GOVERNANCE</span><h2>Approve evidence before it reaches public models.</h2><p>Record ownership, usage rights and exact attribution in one review flow. Pending or unconfirmed providers remain blocked from activation.</p></div>
        <div className="sourceGovernanceStats"><article><small>REGISTERED</small><b>{config.sources.length}</b><span>source records</span></article><article><small>APPROVED</small><b>{config.sources.filter(source=>source.approval_status==='approved').length}</b><span>reviewed providers</span></article><article><small>COMMERCIAL RIGHTS</small><b>{config.sources.filter(source=>source.commercial_use_confirmed).length}</b><span>written permission</span></article><article><small>PRIMARY</small><b>{config.sources.filter(source=>source.primary_for_model).length}</b><span>model source</span></article></div>
      </section>

      <section className="panel sourceLibrary"><div className="intelligenceSectionHead"><div><span>REGISTERED SOURCES</span><h2>Source library</h2><p>Review provider status, rights and required public credit at a glance.</p></div><strong>{config.sources.length}</strong></div>{config.sources.length?<div className="sourceCards">{config.sources.map(source=><article className={`sourceCard sourceCard${source.approval_status}`} key={source.id}><div className="sourceCardTop"><div><span className={`sourceStatus sourceStatus${source.approval_status}`}>{source.approval_status.toUpperCase()}</span>{source.primary_for_model&&<em>PRIMARY MODEL SOURCE</em>}</div><a href={source.provider_url} target="_blank" rel="noreferrer" aria-label={`Open ${source.name} provider website`}>OPEN ↗</a></div><h3>{source.name}</h3><a className="sourceProviderUrl" href={source.provider_url} target="_blank" rel="noreferrer">{source.provider_url}</a><div className="sourceRightsGrid"><div><small>LICENCE</small><b>{source.license_name||'Not recorded'}</b></div><div className={source.commercial_use_confirmed?'cleared':'unconfirmed'}><small>COMMERCIAL USE</small><b>{source.commercial_use_confirmed?'✓ CONFIRMED':'! UNCONFIRMED'}</b></div></div>{source.terms_url&&<a className="sourceTermsLink" href={source.terms_url} target="_blank" rel="noreferrer">VIEW RECORDED TERMS ↗</a>}{source.attribution_text?<blockquote><span>PUBLIC ATTRIBUTION</span><p>{source.attribution_text}</p></blockquote>:<div className="sourceMissingAttribution"><span>!</span><p>Public attribution has not been recorded.</p></div>}</article>)}</div>:<div className="intelligenceEmpty sourceEmptyState"><span>＋</span><h3>No sources registered</h3><p>Use the guided review form to create the first governed provider record.</p></div>}</section>

      <form className="panel sourceReviewForm modernSourceReview" onSubmit={saveSource}><div className="intelligenceSectionHead"><div><span>GUIDED SOURCE REVIEW</span><h2>Register or update a provider</h2><p>Complete the legal record before approving a source.</p></div><strong>3 STEPS</strong></div><div className="sourceFormSteps" aria-label="Source review steps"><span><i>1</i><b>Identity</b></span><span><i>2</i><b>Rights & credit</b></span><span><i>3</i><b>Approval</b></span></div>
        <section className="sourceFormSection"><div className="sourceFormSectionTitle"><i>1</i><div><h3>Provider identity</h3><p>Name the provider and record its official legal references.</p></div></div><div className="formGrid"><label>SOURCE NAME<input value={sourceName} onChange={e=>setSourceName(e.target.value)} placeholder="Provider or API name" required/></label><label>LICENCE<input value={licenseName} onChange={e=>setLicenseName(e.target.value)} placeholder="Licence or agreement name"/></label><label className="wide">PROVIDER URL<input type="url" value={providerUrl} onChange={e=>setProviderUrl(e.target.value)} placeholder="https:// official provider website" required/></label><label className="wide">TERMS URL<input type="url" value={termsUrl} onChange={e=>setTermsUrl(e.target.value)} placeholder="https:// terms, licence or written permission"/></label></div></section>
        <section className="sourceFormSection"><div className="sourceFormSectionTitle"><i>2</i><div><h3>Rights and public credit</h3><p>Copy the required attribution exactly and record restrictions.</p></div></div><div className="formGrid"><label className="wide">PUBLIC ATTRIBUTION<input value={attribution} onChange={e=>setAttribution(e.target.value)} placeholder="Exact wording that must appear publicly"/></label><label className="wide">REVIEW NOTES<textarea value={notes} onChange={e=>setNotes(e.target.value)} placeholder="Contact, permission date, restrictions, caching terms and renewal notes"/></label></div></section>
        <section className="sourceFormSection sourceDecisionSection"><div className="sourceFormSectionTitle"><i>3</i><div><h3>Review decision</h3><p>Keep the provider pending until every permission is documented.</p></div></div><div className="sourceDecisionGrid"><label className="sourceStatusField">REVIEW STATUS<select value={approval} onChange={e=>setApproval(e.target.value)}><option value="pending">PENDING REVIEW</option><option value="approved">APPROVED</option><option value="rejected">REJECTED</option><option value="suspended">SUSPENDED</option></select></label><div className="sourcePermissions"><label className={commercial?'selected':''}><input type="checkbox" checked={commercial} onChange={e=>setCommercial(e.target.checked)}/><i>{commercial?'✓':'○'}</i><span><b>Commercial use confirmed</b><small>Written permission or compatible commercial terms are recorded</small></span></label><label className={primary?'selected':''}><input type="checkbox" checked={primary} onChange={e=>setPrimary(e.target.checked)}/><i>{primary?'✓':'○'}</i><span><b>Use as primary model source</b><small>Public recommendations may use this provider</small></span></label></div></div></section>
        <div className="formAction sourceReviewAction"><div><b>REVIEW SAFETY</b><p>Approval must be based on documented permission—not assumptions. You can safely save incomplete research as Pending.</p></div><button className="primary" disabled={busy}>{busy?'SAVING REVIEW…':'SAVE SOURCE REVIEW'}</button></div>
      </form>
    </div>}

    {activeTab==='data'&&<div className="dataWorkspace">
      <form className="panel activePatchCard" onSubmit={savePatch}><div className="intelligenceSectionHead"><div><span>PATCH CONTROL</span><h2>Current MLBB patch</h2><p>Recommendations never combine statistics from different patches.</p></div>{activePatch&&<strong>{activePatch.version}</strong>}</div><div className="formGrid"><label>PATCH VERSION<input value={patchVersion} onChange={e=>setPatchVersion(e.target.value)} placeholder="2.1.95"/></label><label>RELEASE DATE · OPTIONAL<input type="date" value={patchReleased} onChange={e=>setPatchReleased(e.target.value)}/></label><label className="wide">OFFICIAL NOTES URL<input value={patchNotes} onChange={e=>setPatchNotes(e.target.value)} placeholder="https://"/></label></div><button className="secondary" disabled={busy}>SAVE AND SET ACTIVE</button><div className="patchTimeline">{config.patches.slice(0,6).map(patch=><span className={patch.active?'active':''} key={patch.id}><b>{patch.version}</b><small>{patch.active?'ACTIVE':'ARCHIVED'}</small></span>)}</div></form>
      <section className="panel metricsWorkspace"><div className="intelligenceSectionHead"><div><span>AGGREGATE DATA</span><h2>Verified hero metrics</h2><p>Import hero, games, picks, bans and wins. PostgreSQL calculates every rate.</p></div><strong>{region}</strong></div><div className="formGrid"><label>APPROVED SOURCE<select value={sourceId} onChange={e=>setSourceId(e.target.value)}><option value="">Choose source</option>{approvedSources.map(source=><option value={source.id} key={source.id}>{source.name}</option>)}</select></label><label>PATCH<select value={patchId} onChange={e=>setPatchId(e.target.value)}><option value="">Choose patch</option>{config.patches.map(patch=><option value={patch.id} key={patch.id}>{patch.version}{patch.active?' · ACTIVE':''}</option>)}</select></label></div><label className="codeField"><span>CSV DATA</span><small>hero,games,picks,bans,wins</small><textarea value={csv} onChange={e=>setCsv(e.target.value)} spellCheck={false}/></label><button type="button" className="primary fullButton" disabled={busy||!approvedSources.length} onClick={importMetrics}>VALIDATE AND IMPORT {region} METRICS</button></section>
    </div>}

    {activeTab==='import'&&<section className="panel cleanDraftImport"><div className="intelligenceSectionHead"><div><span>VERIFIED GAME IMPORT</span><h2>Ordered professional draft</h2><p>Record one complete game using the exact 20-action tournament sequence.</p></div><aside><b>20</b><small>REQUIRED ACTIONS</small></aside></div><div className="importGuide"><span>1<b>Choose evidence</b><small>Approved source and patch</small></span><i>→</i><span>2<b>Identify game</b><small>Teams, winner and source URL</small></span><i>→</i><span>3<b>Validate sequence</b><small>10 bans and 10 picks</small></span></div><div className="draftMetadata"><label>APPROVED SOURCE<select value={sourceId} onChange={e=>setSourceId(e.target.value)}><option value="">Choose source</option>{approvedSources.map(source=><option value={source.id} key={source.id}>{source.name}</option>)}</select></label><label>PATCH<select value={patchId} onChange={e=>setPatchId(e.target.value)}><option value="">Choose patch</option>{config.patches.map(patch=><option value={patch.id} key={patch.id}>{patch.version}{patch.active?' · ACTIVE':''}</option>)}</select></label><label>SOURCE MATCH KEY<input value={matchKey} onChange={e=>setMatchKey(e.target.value)} placeholder="Provider match ID"/></label><label>GAME NUMBER<input type="number" min="1" max="20" value={gameNumber} onChange={e=>setGameNumber(Number(e.target.value))}/></label><label>PLAYED AT<input type="datetime-local" value={playedAt} onChange={e=>setPlayedAt(e.target.value)}/></label><label>BLUE SIDE<select value={blueTeam} onChange={e=>setBlueTeam(e.target.value)}>{regionalTeams.filter(team=>team.code!==redTeam).map(team=><option value={team.code} key={team.id}>{team.name} · {team.code}</option>)}</select></label><label>RED SIDE<select value={redTeam} onChange={e=>setRedTeam(e.target.value)}>{regionalTeams.filter(team=>team.code!==blueTeam).map(team=><option value={team.code} key={team.id}>{team.name} · {team.code}</option>)}</select></label><label>WINNER SIDE<select value={winnerSide} onChange={e=>setWinnerSide(e.target.value as 'BLUE'|'RED')}><option value="BLUE">BLUE</option><option value="RED">RED</option></select></label><label className="wide">SOURCE GAME URL<input value={draftSourceUrl} onChange={e=>setDraftSourceUrl(e.target.value)} placeholder="https:// exact game record"/></label></div><label className="codeField draftCode"><span>ACTION SEQUENCE CSV</span><small>sequence,side,type,phase,hero</small><textarea value={actionsCsv} onChange={e=>setActionsCsv(e.target.value)} spellCheck={false}/></label><div className="formAction"><p>The complete import rolls back if one action, hero, team or source field fails validation.</p><button type="button" className="primary" disabled={busy||!approvedSources.length} onClick={importOrderedDraft}>VALIDATE AND IMPORT GAME</button></div></section>}

    {activeTab==='model'&&<div className="modelWorkspace"><section className="panel modelGate"><div className="intelligenceSectionHead"><div><span>PUBLIC RECOMMENDATION MODEL</span><h2>Version activation</h2><p>Activation is deliberate and reversible. It never bypasses evidence requirements.</p></div><label>MINIMUM SAMPLE<input type="number" min="1" max="1000" value={minimumSample} onChange={e=>setMinimumSample(Number(e.target.value))}/></label></div>{config.models.map(model=><article className={model.active?'active':''} key={model.id}><header><span>{model.active?'● ACTIVE':'INACTIVE'}</span><b>{model.version}</b></header><h3>{model.name}</h3><p>{model.description}</p><dl><div><dt>Minimum sample</dt><dd>{model.minimum_sample} games</dd></div><div><dt>Patch</dt><dd>{config.patches.find(item=>item.id===model.patch_id)?.version||'Not assigned'}</dd></div></dl><button type="button" disabled={busy||model.active||!primarySource||!activePatch} onClick={()=>activateModel(model.id)}>{model.active?'MODEL ACTIVE':'ACTIVATE THIS VERSION'}</button></article>)}</section><aside className="panel activationChecklist"><span>BEFORE ACTIVATION</span>{readiness.slice(0,3).map(item=><div className={item.ready?'ready':''} key={item.label}><i>{item.ready?'✓':'!'}</i><p><b>{item.label}</b><small>{item.detail}</small></p></div>)}<footer>Public recommendations remain data-gated if any requirement fails.</footer></aside></div>}

    <footer className="intelligenceGovernance"><span>!</span><p><b>DATA GOVERNANCE</b> Never scrape restricted pages, expose API credentials or mark commercial use as confirmed without documented permission.</p></footer>
  </div>;
}
