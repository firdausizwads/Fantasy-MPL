import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import type { Database } from '../../../lib/supabase/database.types';

export const revalidate=15;
const headers={'Cache-Control':'public, s-maxage=15, stale-while-revalidate=30','Vercel-CDN-Cache-Control':'public, s-maxage=15, stale-while-revalidate=30'};

export async function GET(){
 const started=Date.now();const url=process.env.NEXT_PUBLIC_SUPABASE_URL,key=process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
 if(!url||!key)return NextResponse.json({status:'misconfigured',database:'unavailable',regions:{},checked_at:new Date().toISOString()},{status:503,headers});
 const client=createClient<Database>(url,key,{auth:{persistSession:false,autoRefreshToken:false}});
 const checks=await Promise.all((['MY','ID','PH'] as const).map(async region=>{const{data,error}=await client.rpc('regional_feature_status',{target_region:region});return[region,error?{status:'error'}:{status:'ok',features:(data as {features?:unknown})?.features||{}}] as const}));
 const regions=Object.fromEntries(checks);const healthy=checks.every(([,result])=>result.status==='ok');
 return NextResponse.json({status:healthy?'ok':'degraded',database:healthy?'reachable':'partial',regions,latency_ms:Date.now()-started,release:process.env.VERCEL_GIT_COMMIT_SHA?.slice(0,7)||'local',checked_at:new Date().toISOString()},{status:healthy?200:503,headers});
}
