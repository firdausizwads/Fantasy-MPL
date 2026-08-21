'use client';

import { useEffect, useMemo, useState } from 'react';
import { supabase } from '../lib/supabase/client';
import officialTeams from './official-teams.json';

type Region = 'MY' | 'ID' | 'PH';
type Role = 'EXP' | 'JUNGLE' | 'MID' | 'GOLD' | 'ROAM';
type Player = { id:string; handle:string; photo:string|null; role:string; teamId:string; team:string; code:string };
const ROLES:Role[]=['EXP','JUNGLE','MID','GOLD','ROAM'];
const ROLE_LABEL:Record<Role,string>={EXP:'EXP LANE',JUNGLE:'JUNGLER',MID:'MID LANE',GOLD:'GOLD LANE',ROAM:'ROAMER'};
const TEAM_LOGOS:Record<string,string>=Object.fromEntries(Object.values(officialTeams).flat().map(team=>[team.code,team.logo]));

export default function RegionalFantasy({region,notify}:{region:Region;notify:(message:string)=>void}) {
  const [loading,setLoading]=useState(true);
  const [week,setWeek]=useState<{id:string;number:number;deadline:string}|null>(null);
  const [players,setPlayers]=useState<Player[]>([]);
  const [selected,setSelected]=useState<Record<string,string>>({});
  const [captain,setCaptain]=useState('');
  const [status,setStatus]=useState('draft');
  const [busy,setBusy]=useState(false);
  const [pickerRole,setPickerRole]=useState<Role|null>(null);

  useEffect(()=>{
    let active=true;
    (async()=>{
      if(!supabase){setLoading(false);return}
      setLoading(true);
      const {data:weekId}=await supabase.rpc('current_regional_fantasy_week',{target_region:region});
      if(!weekId){if(active)setLoading(false);return}
      const {data:weekRow}=await supabase.from('competition_weeks').select('week_number,season_id').eq('id',weekId).single();
      if(!weekRow){if(active)setLoading(false);return}
      const [{data:matches},{data:roster},{data:lineup}]=await Promise.all([
        supabase.from('matches').select('scheduled_at').eq('week_id',weekId).neq('status','cancelled').order('scheduled_at').limit(1),
        supabase.from('season_rosters').select('role,team_id,player:players(id,handle,photo_url),team:teams(name,code)').eq('season_id',weekRow.season_id).eq('active',true).neq('role','COACH'),
        supabase.from('regional_fantasy_lineups').select('id,captain_player_id,status').eq('week_id',weekId).maybeSingle()
      ]);
      const pool=(roster||[]).map(row=>({
        id:row.player?.id||'',handle:row.player?.handle||'PLAYER',photo:row.player?.photo_url||null,
        role:row.role,teamId:row.team_id,team:row.team?.name||'TEAM',code:row.team?.code||'—'
      })).filter(item=>item.id);
      let slots:Record<string,string>={};
      if(lineup){
        const {data:rows}=await supabase.from('regional_fantasy_lineup_players').select('player_id,slot_role').eq('lineup_id',lineup.id);
        slots=Object.fromEntries((rows||[]).map(row=>[row.slot_role,row.player_id]));
      }
      if(!active)return;
      setPlayers(pool);setSelected(slots);setCaptain(lineup?.captain_player_id||'');setStatus(lineup?.status||'draft');
      setWeek({id:weekId,number:weekRow.week_number,deadline:matches?.[0]?.scheduled_at||''});setLoading(false);
    })().catch(error=>{if(active){setLoading(false);notify(error instanceof Error?error.message:'Unable to load fantasy lineup.')}});
    return()=>{active=false};
  },[region]);

  const playerMap=useMemo(()=>Object.fromEntries(players.map(player=>[player.id,player])),[players]);
  const locked=Boolean(week?.deadline&&Date.now()>=new Date(week.deadline).getTime())||status==='scored'||status==='locked';
  const pickerOptions=pickerRole?players.filter(player=>player.role===pickerRole).sort((a,b)=>a.handle.localeCompare(b.handle)):[];
  const occupiedTeams=new Set(Object.entries(selected).filter(([role])=>role!==pickerRole).map(([,id])=>playerMap[id]?.teamId).filter(Boolean));

  function choose(role:Role,id:string){
    const player=playerMap[id];if(!player)return;
    const duplicateRole=Object.entries(selected).find(([key,value])=>key!==role&&value===id);
    const duplicateTeam=Object.entries(selected).find(([key,value])=>key!==role&&playerMap[value]?.teamId===player.teamId);
    if(duplicateRole){notify('A player can fill only one role.');return}
    if(duplicateTeam){notify('Choose only one player from each professional team.');return}
    setSelected(current=>({...current,[role]:id}));
    if(captain&&!Object.values({...selected,[role]:id}).includes(captain))setCaptain('');
    if(status==='submitted')setStatus('draft');
    setPickerRole(null);
  }

  async function save(){
    if(!supabase||!week)return;
    const selections=ROLES.map(role=>({role,player_id:selected[role]}));
    if(selections.some(item=>!item.player_id)||!captain){notify('Fill all five roles and choose a captain.');return}
    setBusy(true);
    const {error}=await supabase.rpc('save_regional_fantasy_lineup',{target_week:week.id,target_captain:captain,selections});
    setBusy(false);
    if(error){notify(error.message);return}
    setStatus('submitted');notify(`Week ${week.number} regional fantasy lineup submitted.`);
  }

  if(loading)return <section className="regionalFantasyLoading">LOADING REGIONAL FANTASY…</section>;
  if(!week)return <section className="regionalFantasyEmpty"><h2>Fantasy week unavailable</h2><p>The next regional week will appear after fixtures are synchronized.</p></section>;
  return <div className="regionalFantasy">
    <section className="regionalFantasyHero"><div><span>OFFICIAL REGIONAL CONTEST · WEEK {week.number}</span><h1>My Fantasy Team</h1><p>Build one five-player lineup for the {region} regional table. One player per role and one player per professional team.</p></div><aside><small>LINEUP LOCKS BEFORE</small><b>{week.deadline?new Date(week.deadline).toLocaleDateString(undefined,{weekday:'short',day:'numeric',month:'short'}).toUpperCase():'DATE PENDING'}</b><span>{week.deadline?new Date(week.deadline).toLocaleTimeString(undefined,{hour:'2-digit',minute:'2-digit'}):'TIME PENDING'}</span></aside></section>
    <section className="fantasyRoleGrid modernFantasyRoles">{ROLES.map((role,index)=>{const id=selected[role]||'',player=playerMap[id];return <article className={player?'filled':''} key={role}>
      <header><span><i>{String(index+1).padStart(2,'0')}</i>{ROLE_LABEL[role]}</span><small>{players.filter(item=>item.role===role).length} AVAILABLE</small></header>
      {player?<div className="fantasySelected modernFantasySelected"><i>{player.photo?<img src={player.photo} alt=""/>:<span>{player.handle.slice(0,2)}</span>}</i><div><small className="fantasyTeamLabel">{TEAM_LOGOS[player.code]&&<img src={TEAM_LOGOS[player.code]} alt=""/>}<span>{player.code}</span></small><h3>{player.handle}</h3><p>{player.team}</p></div><button className={captain===id?'captain':''} disabled={locked} onClick={()=>setCaptain(id)}>{captain===id?'★ CAPTAIN 2×':'MAKE CAPTAIN'}</button></div>:<div className="fantasyNoPick modernFantasyNoPick"><span>+</span><b>EMPTY {ROLE_LABEL[role]} SLOT</b><small>CHOOSE ONE VERIFIED REGIONAL PLAYER</small></div>}
      <button className="choosePlayerBox" disabled={locked} onClick={()=>setPickerRole(role)}><span>{player?'CHANGE PLAYER':'CHOOSE PLAYER'}</span><i>→</i></button>
    </article>})}</section>
    <section className="fantasySubmit"><div><b>{Object.keys(selected).filter(role=>selected[role]).length}/5 ROLES · {captain?'CAPTAIN READY':'CAPTAIN REQUIRED'}</b><p>Selections remain editable until the first match of the week begins.</p></div><button className="primary" disabled={busy||locked||Object.keys(selected).filter(role=>selected[role]).length!==5||!captain} onClick={save}>{busy?'SAVING…':status==='submitted'?'UPDATE LINEUP':'SUBMIT LINEUP'}</button></section>
    {pickerRole&&!locked&&<div className="fantasyPickerShade" onClick={()=>setPickerRole(null)}><section className="fantasyPlayerPicker" role="dialog" aria-modal="true" aria-label={`Choose ${ROLE_LABEL[pickerRole]} player`} onClick={event=>event.stopPropagation()}>
      <header><div><span>WEEK {week.number} · {region}</span><h2>Choose your {ROLE_LABEL[pickerRole]}</h2><p>One player per professional team. Unavailable team conflicts are clearly marked.</p></div><button onClick={()=>setPickerRole(null)} aria-label="Close player picker">×</button></header>
      <div className="fantasyPlayerOptions">{pickerOptions.map(player=>{const conflict=occupiedTeams.has(player.teamId);const active=selected[pickerRole]===player.id;return <button key={player.id} className={active?'selected':''} disabled={conflict} onClick={()=>choose(pickerRole,player.id)}>
        <i>{player.photo?<img src={player.photo} alt=""/>:<span>{player.handle.slice(0,2)}</span>}</i>
        <span><small>{player.code} · {ROLE_LABEL[pickerRole]}</small><b>{player.handle}</b><em>{TEAM_LOGOS[player.code]&&<img src={TEAM_LOGOS[player.code]} alt=""/>}{player.team}</em></span>
        <strong>{active?'✓ SELECTED':conflict?'TEAM USED':'SELECT →'}</strong>
      </button>})}</div>
      {!pickerOptions.length&&<p className="fantasyPickerEmpty">No verified players are available for this role yet.</p>}
    </section></div>}
  </div>;
}
