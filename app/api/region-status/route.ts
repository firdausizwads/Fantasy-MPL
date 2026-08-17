import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import type { Database, Json } from '../../../lib/supabase/database.types';

export const revalidate=15;
const REGIONS=new Set(['MY','ID','PH']);
const headers={'Cache-Control':'public, s-maxage=15, stale-while-revalidate=60','Vercel-CDN-Cache-Control':'public, s-maxage=15, stale-while-revalidate=60'};
export async function GET(request:NextRequest){
 const region=(request.nextUrl.searchParams.get('region')||'').toUpperCase();
 if(!REGIONS.has(region))return NextResponse.json({error:'Unsupported region'},{status:400});
 const url=process.env.NEXT_PUBLIC_SUPABASE_URL,key=process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
 if(!url||!key)return NextResponse.json({region,features:{},generated_at:new Date().toISOString()},{headers});
 const client=createClient<Database>(url,key,{auth:{persistSession:false,autoRefreshToken:false}});
 const{data}=await client.rpc('regional_feature_status',{target_region:region});
 return NextResponse.json((data||{region,features:{}}) as Json,{headers});
}
