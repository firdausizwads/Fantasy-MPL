import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import type { Database, Json } from '../../../lib/supabase/database.types';

export const revalidate = 300;

const REGIONS = new Set(['MY', 'ID', 'PH']);
const cacheHeaders = {
  'Cache-Control': 'public, s-maxage=300, stale-while-revalidate=3600',
  'CDN-Cache-Control': 'public, s-maxage=300, stale-while-revalidate=3600',
  'Vercel-CDN-Cache-Control': 'public, s-maxage=300, stale-while-revalidate=3600'
};

function gated(region: string, blocker: string) {
  return {
    status: { ready: false, region, blocker, source_name: null, source_url: null, attribution: null, license: null, model_name: null, model_version: null, patch: null, minimum_sample: null, eligible_heroes: 0, drafts_analyzed: 0, last_verified: null },
    weights: {}, metrics: [], relationships: [], generated_at: new Date().toISOString()
  };
}

export async function GET(request: NextRequest) {
  const region = (request.nextUrl.searchParams.get('region') || '').toUpperCase();
  if (!REGIONS.has(region)) return NextResponse.json({ error: 'Unsupported region' }, { status: 400 });

  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
  if (!url || !key) return NextResponse.json(gated(region, 'MODEL SERVICE NOT CONFIGURED'), { headers: cacheHeaders });

  const client = createClient<Database>(url, key, { auth: { persistSession: false, autoRefreshToken: false } });
  const { data, error } = await client.rpc('draft_model_bundle', { target_region: region });
  if (error) {
    return NextResponse.json(gated(region, 'MODEL BUNDLE TEMPORARILY UNAVAILABLE'), {
      status: 200,
      headers: { ...cacheHeaders, 'Cache-Control': 'public, s-maxage=30, stale-while-revalidate=120' }
    });
  }
  return NextResponse.json(data as Json, { headers: cacheHeaders });
}
