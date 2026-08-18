import { NextRequest,NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import type { Database,Json } from '../../../../../lib/supabase/database.types';

export const dynamic='force-dynamic';
const LEAGUES=[{id:5294,region:'MY'},{id:5276,region:'ID'},{id:5279,region:'PH'}] as const;
type PandaTeam={id:number;name:string;acronym?:string|null};
type PandaMatch={id:number;begin_at?:string|null;scheduled_at?:string|null;end_at?:string|null;status:string;number_of_games:number;league:{id:number};serie:{id:number;full_name?:string|null;season?:number|null;year?:number|null;begin_at?:string|null};tournament?:{id:number;name:string}|null;opponents:{opponent:PandaTeam}[];results:{team_id:number;score:number}[];winner?:PandaTeam|null};

async function runSync(triggeredBy:string|null){
 const url=process.env.NEXT_PUBLIC_SUPABASE_URL,key=process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY,pandaToken=process.env.PANDASCORE_API_TOKEN,syncSecret=process.env.PANDASCORE_SYNC_SECRET;
 const missing=[!url&&'NEXT_PUBLIC_SUPABASE_URL',!key&&'NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY',!pandaToken&&'PANDASCORE_API_TOKEN',!syncSecret&&'PANDASCORE_SYNC_SECRET'].filter(Boolean);
 if(missing.length)return NextResponse.json({error:`Missing server configuration: ${missing.join(', ')}`},{status:503});
 const from=new Date(Date.now()-14*86400000).toISOString(),to=new Date(Date.now()+140*86400000).toISOString();
 const batches=await Promise.all(LEAGUES.map(async league=>{const query=new URLSearchParams({'filter[league_id]':String(league.id),'range[begin_at]':`${from},${to}`,per_page:'100',sort:'begin_at'});const response=await fetch(`https://api.pandascore.co/mlbb/matches?${query}`,{headers:{Accept:'application/json',Authorization:`Bearer ${pandaToken}`},cache:'no-store'});if(!response.ok)throw new Error(`PandaScore ${league.region} request failed (${response.status})`);return await response.json() as PandaMatch[]}));
 const rawMatches=batches.flat();
 const seriesStarts=new Map<number,string>();rawMatches.forEach(match=>{if(match.serie?.id&&match.serie.begin_at)seriesStarts.set(match.serie.id,match.serie.begin_at)});
 const missingSeries=Array.from(new Set(rawMatches.filter(match=>match.serie?.id&&!match.serie.begin_at).map(match=>match.serie.id)));
 await Promise.all(missingSeries.map(async id=>{const response=await fetch(`https://api.pandascore.co/series/${id}`,{headers:{Accept:'application/json',Authorization:`Bearer ${pandaToken}`},cache:'no-store'});if(response.ok){const detail=await response.json() as{begin_at?:string|null};if(detail.begin_at)seriesStarts.set(id,detail.begin_at)}}));
 const rejected={wrongSeason:0,opponents:0,missingTime:0,missingSeriesStart:0};
 const normalized=rawMatches.flatMap(match=>{
  const label=match.serie?.full_name||'';
  const seasonOk=Number(match.serie?.season)===18||/season\s*18/i.test(label);
  const yearOk=Number(match.serie?.year)===2026||/2026/.test(label);
  if(!seasonOk||!yearOk){rejected.wrongSeason+=1;return[]}
  if(match.opponents?.length!==2){rejected.opponents+=1;return[]}
  const scheduled=match.scheduled_at||match.begin_at;if(!scheduled){rejected.missingTime+=1;return[]}
  const serieBegin=match.serie?.begin_at||seriesStarts.get(match.serie.id);if(!serieBegin){rejected.missingSeriesStart+=1;return[]}
  const[a,b]=match.opponents.map(item=>item.opponent);const scores=new Map(match.results?.map(item=>[item.team_id,item.score])||[]);
  return[{match_id:match.id,league_id:match.league.id,serie_id:match.serie.id,serie_name:label||'Season 18 2026',season_number:18,season_year:2026,serie_begin_at:serieBegin,tournament_id:match.tournament?.id||'',tournament_name:match.tournament?.name||'',scheduled_at:scheduled,end_at:match.end_at||'',status:match.status,best_of:match.number_of_games,team_a_id:a.id,team_a_name:a.name,team_a_acronym:a.acronym||'',team_b_id:b.id,team_b_name:b.name,team_b_acronym:b.acronym||'',team_a_score:scores.has(a.id)?scores.get(a.id):'',team_b_score:scores.has(b.id)?scores.get(b.id):'',winner_team_id:match.winner?.id||''}]
 });
 const client=createClient<Database>(url!,key!,{auth:{persistSession:false,autoRefreshToken:false}});const{data,error}=await client.rpc('ingest_pandascore_fixture_batch',{raw_secret:syncSecret!,matches:normalized as unknown as Json});if(error)return NextResponse.json({error:error.message},{status:500});return NextResponse.json({ok:true,triggered_by:triggeredBy||'cron',raw_fetched:rawMatches.length,accepted:normalized.length,rejected,result:data});
}

export async function POST(request:NextRequest){
 const url=process.env.NEXT_PUBLIC_SUPABASE_URL,key=process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY,syncSecret=process.env.PANDASCORE_SYNC_SECRET;
 const auth=request.headers.get('authorization')||'';const jwt=auth.startsWith('Bearer ')?auth.slice(7):'';
 if(!jwt)return NextResponse.json({error:'Unauthorized'},{status:401});
 if(!url||!key||!syncSecret)return NextResponse.json({error:'Fixture sync server configuration is incomplete'},{status:503});
 const adminClient=createClient<Database>(url,key,{global:{headers:{Authorization:`Bearer ${jwt}`}},auth:{persistSession:false,autoRefreshToken:false}});const{data:userData,error:userError}=await adminClient.auth.getUser(jwt);if(userError||!userData.user)return NextResponse.json({error:'Unauthorized'},{status:401});
 const{data:profile}=await adminClient.from('profiles').select('account_role').eq('id',userData.user.id).maybeSingle();if(!['admin','super_admin'].includes(profile?.account_role||''))return NextResponse.json({error:'Administrator required'},{status:403});
 const{error:configError}=await adminClient.rpc('configure_pandascore_sync_secret',{raw_secret:syncSecret});if(configError)return NextResponse.json({error:configError.message},{status:500});
 try{return await runSync(userData.user.id)}catch(error){return NextResponse.json({error:error instanceof Error?error.message:'Synchronization failed'},{status:502})}
}

export async function GET(request:NextRequest){const expected=process.env.CRON_SECRET,provided=request.headers.get('authorization');if(!expected||provided!==`Bearer ${expected}`)return NextResponse.json({error:'Unauthorized'},{status:401});try{return await runSync(null)}catch(error){return NextResponse.json({error:error instanceof Error?error.message:'Synchronization failed'},{status:502})}}
