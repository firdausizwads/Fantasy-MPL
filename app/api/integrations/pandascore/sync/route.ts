import { NextRequest,NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import type { Database,Json } from '../../../../../lib/supabase/database.types';

export const dynamic='force-dynamic';
const LEAGUES=[{id:5294,region:'MY'},{id:5276,region:'ID'},{id:5279,region:'PH'}] as const;
type PandaTeam={id:number;name:string;acronym?:string|null};
type PandaMatch={id:number;begin_at?:string|null;scheduled_at?:string|null;end_at?:string|null;status:string;number_of_games:number;league:{id:number};serie:{id:number;full_name:string;season:number;year:number;begin_at:string};tournament?:{id:number;name:string}|null;opponents:{opponent:PandaTeam}[];results:{team_id:number;score:number}[];winner?:PandaTeam|null};

async function runSync(triggeredBy:string|null){
 const url=process.env.NEXT_PUBLIC_SUPABASE_URL,key=process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY,pandaToken=process.env.PANDASCORE_API_TOKEN,syncSecret=process.env.PANDASCORE_SYNC_SECRET;
 if(!url||!key||!pandaToken||!syncSecret)return NextResponse.json({error:'Integration environment is incomplete'},{status:503});
 const from=new Date(Date.now()-14*86400000).toISOString(),to=new Date(Date.now()+140*86400000).toISOString();
 const batches=await Promise.all(LEAGUES.map(async league=>{const query=new URLSearchParams({'filter[league_id]':String(league.id),'range[begin_at]':`${from},${to}`,per_page:'100',sort:'begin_at'});const response=await fetch(`https://api.pandascore.co/mlbb/matches?${query}`,{headers:{Accept:'application/json',Authorization:`Bearer ${pandaToken}`},cache:'no-store'});if(!response.ok)throw new Error(`PandaScore ${league.region} request failed (${response.status})`);return await response.json() as PandaMatch[]}));
 const normalized=batches.flat().flatMap(match=>{if(match.serie?.season!==18||match.serie?.year!==2026||match.opponents?.length!==2)return[];const scheduled=match.scheduled_at||match.begin_at;if(!scheduled)return[];const [a,b]=match.opponents.map(item=>item.opponent);const scores=new Map(match.results?.map(item=>[item.team_id,item.score])||[]);return[{match_id:match.id,league_id:match.league.id,serie_id:match.serie.id,serie_name:match.serie.full_name,season_number:match.serie.season,season_year:match.serie.year,serie_begin_at:match.serie.begin_at,tournament_id:match.tournament?.id||'',tournament_name:match.tournament?.name||'',scheduled_at:scheduled,end_at:match.end_at||'',status:match.status,best_of:match.number_of_games,team_a_id:a.id,team_a_name:a.name,team_a_acronym:a.acronym||'',team_b_id:b.id,team_b_name:b.name,team_b_acronym:b.acronym||'',team_a_score:scores.has(a.id)?scores.get(a.id):'',team_b_score:scores.has(b.id)?scores.get(b.id):'',winner_team_id:match.winner?.id||''}]});
 const client=createClient<Database>(url,key,{auth:{persistSession:false,autoRefreshToken:false}});const{data,error}=await client.rpc('ingest_pandascore_fixture_batch',{raw_secret:syncSecret,matches:normalized as unknown as Json});if(error)return NextResponse.json({error:error.message},{status:500});return NextResponse.json({ok:true,triggered_by:triggeredBy||'cron',fetched:normalized.length,result:data});
}

export async function POST(request:NextRequest){
 const url=process.env.NEXT_PUBLIC_SUPABASE_URL,key=process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY,syncSecret=process.env.PANDASCORE_SYNC_SECRET;
 const auth=request.headers.get('authorization')||'';const jwt=auth.startsWith('Bearer ')?auth.slice(7):'';
 if(!url||!key||!syncSecret||!jwt)return NextResponse.json({error:'Unauthorized'},{status:401});
 const adminClient=createClient<Database>(url,key,{global:{headers:{Authorization:`Bearer ${jwt}`}},auth:{persistSession:false,autoRefreshToken:false}});const{data:userData,error:userError}=await adminClient.auth.getUser(jwt);if(userError||!userData.user)return NextResponse.json({error:'Unauthorized'},{status:401});
 const{data:profile}=await adminClient.from('profiles').select('account_role').eq('id',userData.user.id).maybeSingle();if(!['admin','super_admin'].includes(profile?.account_role||''))return NextResponse.json({error:'Administrator required'},{status:403});
 const{error:configError}=await adminClient.rpc('configure_pandascore_sync_secret',{raw_secret:syncSecret});if(configError)return NextResponse.json({error:configError.message},{status:500});
 try{return await runSync(userData.user.id)}catch(error){return NextResponse.json({error:error instanceof Error?error.message:'Synchronization failed'},{status:502})}
}

export async function GET(request:NextRequest){const expected=process.env.CRON_SECRET,provided=request.headers.get('authorization');if(!expected||provided!==`Bearer ${expected}`)return NextResponse.json({error:'Unauthorized'},{status:401});try{return await runSync(null)}catch(error){return NextResponse.json({error:error instanceof Error?error.message:'Synchronization failed'},{status:502})}}
