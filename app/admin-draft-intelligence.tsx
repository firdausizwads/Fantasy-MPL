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

const emptyConfig:Config={sources:[],patches:[],models:[],teams:[],metrics_by_region:[],verified_games:0,ordered_actions:0};

export default function AdminDraftIntelligence({region,notify}:{region:Region;notify:(message:string)=>void}){
  const [config,setConfig]=useState<Config>(emptyConfig);
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

  if(loading)return <section className="panel draftAdminLoading">LOADING DRAFT INTELLIGENCE CONTROL…</section>;
  const approvedSources=config.sources.filter(item=>item.approval_status==='approved'&&item.commercial_use_confirmed);
  const activePatch=config.patches.find(item=>item.active);
  return <div className="draftAdmin">
    <section className="draftAdminHero"><div><span>LIVE DRAFT LAB · DATA GOVERNANCE</span><h2>DRAFT INTELLIGENCE CONTROL</h2><p>REGISTER APPROVED SOURCES, IMPORT TRACEABLE PROFESSIONAL METRICS AND ACTIVATE VERSIONED RECOMMENDATION MODELS.</p></div><div><small>PUBLIC MODEL</small><strong>{config.models.find(item=>item.active)?.version||'INACTIVE'}</strong></div></section>
    <div className="draftAdminStats"><article><small>APPROVED SOURCES</small><strong>{approvedSources.length}</strong></article><article><small>ACTIVE PATCH</small><strong>{activePatch?.version||'—'}</strong></article><article><small>VERIFIED GAMES</small><strong>{config.verified_games}</strong></article><article><small>ORDERED ACTIONS</small><strong>{config.ordered_actions}</strong></article></div>

    <div className="draftAdminGrid">
      <form className="panel draftSourceForm" onSubmit={saveSource}><header><span>01</span><div><h3>DATA SOURCE REGISTRY</h3><p>DO NOT APPROVE A SOURCE UNTIL ITS TERMS AND COMMERCIAL RIGHTS ARE CONFIRMED.</p></div></header><label>SOURCE NAME<input value={sourceName} onChange={e=>setSourceName(e.target.value)} placeholder="E.G. LIQUIPEDIA API"/></label><label>PROVIDER URL<input value={providerUrl} onChange={e=>setProviderUrl(e.target.value)} placeholder="HTTPS://"/></label><div className="draftAdminTwo"><label>TERMS URL<input value={termsUrl} onChange={e=>setTermsUrl(e.target.value)} placeholder="HTTPS://"/></label><label>LICENSE<input value={licenseName} onChange={e=>setLicenseName(e.target.value)} placeholder="E.G. CC-BY-SA 3.0"/></label></div><label>PUBLIC ATTRIBUTION<input value={attribution} onChange={e=>setAttribution(e.target.value)} placeholder="DATA SOURCE ATTRIBUTION"/></label><label>REVIEW NOTES<textarea value={notes} onChange={e=>setNotes(e.target.value)} placeholder="APPROVAL DATE, CONTACT OR API CONDITIONS"/></label><div className="draftAdminTwo"><label>STATUS<select value={approval} onChange={e=>setApproval(e.target.value)}><option value="pending">PENDING</option><option value="approved">APPROVED</option><option value="rejected">REJECTED</option><option value="suspended">SUSPENDED</option></select></label><div className="draftChecks"><label><input type="checkbox" checked={commercial} onChange={e=>setCommercial(e.target.checked)}/> COMMERCIAL USE CONFIRMED</label><label><input type="checkbox" checked={primary} onChange={e=>setPrimary(e.target.checked)}/> PRIMARY MODEL SOURCE</label></div></div><button className="primary" disabled={busy}>SAVE SOURCE REVIEW</button></form>

      <section className="panel draftSourceList"><header><span>REGISTERED SOURCES</span><b>{config.sources.length}</b></header>{config.sources.length?config.sources.map(source=><article key={source.id}><div><span className={source.approval_status}>{source.approval_status.toUpperCase()}</span>{source.primary_for_model&&<em>PRIMARY</em>}</div><h3>{source.name}</h3><a href={source.provider_url} target="_blank" rel="noreferrer">{source.provider_url}</a><p>{source.license_name||'LICENSE NOT RECORDED'} · {source.commercial_use_confirmed?'COMMERCIAL USE CONFIRMED':'COMMERCIAL USE UNCONFIRMED'}</p></article>):<div className="draftAdminEmpty">NO SOURCES REGISTERED.</div>}</section>
    </div>

    <div className="draftAdminGrid lower">
      <form className="panel patchForm" onSubmit={savePatch}><header><span>02</span><div><h3>ACTIVE PATCH</h3><p>RECOMMENDATIONS NEVER MIX METRICS ACROSS PATCHES.</p></div></header><div className="draftAdminTwo"><label>PATCH VERSION<input value={patchVersion} onChange={e=>setPatchVersion(e.target.value)} placeholder="2.1.95"/></label><label>RELEASE DATE · OPTIONAL<input type="date" value={patchReleased} onChange={e=>setPatchReleased(e.target.value)}/></label></div><label>OFFICIAL NOTES URL<input value={patchNotes} onChange={e=>setPatchNotes(e.target.value)} placeholder="HTTPS://"/></label><button className="secondary" disabled={busy}>SAVE & SET ACTIVE</button><div className="patchHistory">{config.patches.slice(0,5).map(patch=><span className={patch.active?'active':''} key={patch.id}><b>{patch.version}</b><small>{patch.active?'ACTIVE':'INACTIVE'}</small></span>)}</div></form>

      <section className="panel metricsImport"><header><span>03</span><div><h3>VERIFIED METRICS IMPORT</h3><p>CSV COLUMNS: HERO, GAMES, PICKS, BANS, WINS.</p></div></header><div className="draftAdminTwo"><label>APPROVED SOURCE<select value={sourceId} onChange={e=>setSourceId(e.target.value)}><option value="">CHOOSE SOURCE</option>{approvedSources.map(source=><option value={source.id} key={source.id}>{source.name}</option>)}</select></label><label>PATCH<select value={patchId} onChange={e=>setPatchId(e.target.value)}><option value="">CHOOSE PATCH</option>{config.patches.map(patch=><option value={patch.id} key={patch.id}>{patch.version}{patch.active?' · ACTIVE':''}</option>)}</select></label></div><textarea className="metricsCsv" value={csv} onChange={e=>setCsv(e.target.value)} spellCheck={false}/><button className="primary" disabled={busy||!approvedSources.length} onClick={importMetrics}>VALIDATE & IMPORT {region} METRICS</button><div className="metricRegions">{(['MY','ID','PH'] as Region[]).map(code=>{const row=config.metrics_by_region.find(item=>item.region_code===code);return <span key={code}><b>{code}</b><strong>{row?.heroes||0} HEROES</strong><small>{row?.games||0} GAMES</small></span>})}</div></section>
    </div>

    <section className="panel orderedDraftImport"><header><span>04</span><div><h3>ORDERED PROFESSIONAL DRAFT</h3><p>IMPORT ONE COMPLETE GAME AS THE VERIFIED 20-ACTION TOURNAMENT SEQUENCE. AGGREGATES AND PAIR EVIDENCE REBUILD AUTOMATICALLY.</p></div></header><div className="orderedDraftMeta"><label>APPROVED SOURCE<select value={sourceId} onChange={e=>setSourceId(e.target.value)}><option value="">CHOOSE SOURCE</option>{approvedSources.map(source=><option value={source.id} key={source.id}>{source.name}</option>)}</select></label><label>PATCH<select value={patchId} onChange={e=>setPatchId(e.target.value)}><option value="">CHOOSE PATCH</option>{config.patches.map(patch=><option value={patch.id} key={patch.id}>{patch.version}{patch.active?' · ACTIVE':''}</option>)}</select></label><label>SOURCE MATCH KEY<input value={matchKey} onChange={e=>setMatchKey(e.target.value)} placeholder="PROVIDER MATCH ID"/></label><label>GAME NUMBER<input type="number" min="1" max="20" value={gameNumber} onChange={e=>setGameNumber(Number(e.target.value))}/></label><label>PLAYED AT<input type="datetime-local" value={playedAt} onChange={e=>setPlayedAt(e.target.value)}/></label><label>BLUE SIDE<select value={blueTeam} onChange={e=>setBlueTeam(e.target.value)}>{config.teams.filter(team=>team.region_code===region&&team.code!==redTeam).map(team=><option value={team.code} key={team.id}>{team.name} · {team.code}</option>)}</select></label><label>RED SIDE<select value={redTeam} onChange={e=>setRedTeam(e.target.value)}>{config.teams.filter(team=>team.region_code===region&&team.code!==blueTeam).map(team=><option value={team.code} key={team.id}>{team.name} · {team.code}</option>)}</select></label><label>WINNER SIDE<select value={winnerSide} onChange={e=>setWinnerSide(e.target.value as 'BLUE'|'RED')}><option value="BLUE">BLUE</option><option value="RED">RED</option></select></label></div><label>SOURCE GAME URL<input value={draftSourceUrl} onChange={e=>setDraftSourceUrl(e.target.value)} placeholder="HTTPS://"/></label><div className="orderedDraftCsv"><div><span>ACTION CSV</span><small>SEQUENCE, SIDE, TYPE, PHASE AND HERO MUST MATCH THE TOURNAMENT FLOW.</small></div><textarea value={actionsCsv} onChange={e=>setActionsCsv(e.target.value)} spellCheck={false}/></div><button className="primary" disabled={busy||!approvedSources.length} onClick={importOrderedDraft}>VALIDATE & IMPORT COMPLETE GAME</button></section>

    <section className="panel modelActivation"><header><span>05</span><div><h3>MODEL VERSIONING</h3><p>ACTIVATION REQUIRES AN APPROVED PRIMARY SOURCE, ACTIVE PATCH AND IMPORTED SAMPLE.</p></div><label>MINIMUM SAMPLE<input type="number" min="1" max="1000" value={minimumSample} onChange={e=>setMinimumSample(Number(e.target.value))}/></label></header>{config.models.map(model=><article key={model.id}><div><span>{model.name}</span><h3>{model.version}</h3><p>{model.description}</p></div><div><small>MINIMUM SAMPLE</small><b>{model.minimum_sample} GAMES</b></div><button className={model.active?'active':''} disabled={busy||model.active||!approvedSources.some(item=>item.primary_for_model)||!activePatch} onClick={()=>activateModel(model.id)}>{model.active?'● ACTIVE':'ACTIVATE MODEL'}</button></article>)}</section>
    <div className="draftGovernanceNote"><span>!</span><p><b>NO AUTOMATIC SCRAPING.</b> API ACCESS, ATTRIBUTION, CACHING, RATE LIMITS AND COMMERCIAL RIGHTS MUST BE RECORDED BEFORE A SOURCE CAN POWER PUBLIC RECOMMENDATIONS.</p></div>
  </div>;
}
