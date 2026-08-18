import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@supabase/supabase-js";
import type { Database } from "../../../lib/supabase/database.types";

export const revalidate = 30;

const REGIONS = new Set(["MY", "ID", "PH"]);
const SERIES_WINDOW_MS = 4 * 60 * 60 * 1000;
const cacheHeaders = {
  "Cache-Control": "public, s-maxage=30, stale-while-revalidate=60",
  "Vercel-CDN-Cache-Control": "public, s-maxage=30, stale-while-revalidate=60",
};

type MatchWindow = {
  best_of: number;
  scheduled_at: string;
  status: string;
  finalized_at: string | null;
};

export async function GET(request: NextRequest) {
  const region = (
    request.nextUrl.searchParams.get("region") || ""
  ).toUpperCase();
  if (!REGIONS.has(region)) {
    return NextResponse.json({ error: "Unsupported region" }, { status: 400 });
  }

  const serverNow = new Date();
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
  if (!url || !key) {
    return NextResponse.json(
      {
        region,
        state: "pending",
        open: false,
        opens_at: null,
        regular_season_ends_at: null,
        playoff_starts_at: null,
        regular_matches: 0,
        completed_regular_matches: 0,
        server_now: serverNow.toISOString(),
      },
      { headers: cacheHeaders },
    );
  }

  const client = createClient<Database>(url, key, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: season } = await client
    .from("seasons")
    .select("id")
    .eq("region_code", region)
    .eq("season_number", 18)
    .maybeSingle();
  if (!season) {
    return NextResponse.json(
      {
        region,
        state: "pending",
        open: false,
        opens_at: null,
        regular_season_ends_at: null,
        playoff_starts_at: null,
        regular_matches: 0,
        completed_regular_matches: 0,
        server_now: serverNow.toISOString(),
      },
      { headers: cacheHeaders },
    );
  }

  const { data, error } = await client
    .from("matches")
    .select("best_of,scheduled_at,status,finalized_at")
    .eq("season_id", season.id)
    .neq("status", "cancelled")
    .order("scheduled_at");

  if (error) {
    return NextResponse.json(
      { error: "Playoff access status is temporarily unavailable" },
      { status: 503 },
    );
  }

  const matches = (data || []) as MatchWindow[];
  // Current regional data uses BO1/BO3 for regular season and BO5/BO7 for playoffs.
  const regularMatches = matches.filter((match) => match.best_of <= 3);
  const playoffMatches = matches.filter((match) => match.best_of >= 5);
  const completionTimes = regularMatches
    .map((match) => {
      if (match.status === "completed" && match.finalized_at) {
        return new Date(match.finalized_at).getTime();
      }
      return new Date(match.scheduled_at).getTime() + SERIES_WINDOW_MS;
    })
    .filter(Number.isFinite);
  const opensAtMs = completionTimes.length
    ? Math.max(...completionTimes)
    : null;
  const opensAt = opensAtMs == null ? null : new Date(opensAtMs).toISOString();
  const playoffStartsAt = playoffMatches[0]?.scheduled_at || null;
  const open = opensAtMs != null && serverNow.getTime() >= opensAtMs;

  return NextResponse.json(
    {
      region,
      state: open ? "open" : opensAt ? "countdown" : "pending",
      open,
      opens_at: opensAt,
      regular_season_ends_at: opensAt,
      playoff_starts_at: playoffStartsAt,
      regular_matches: regularMatches.length,
      completed_regular_matches: regularMatches.filter(
        (match) => match.status === "completed",
      ).length,
      server_now: serverNow.toISOString(),
    },
    { headers: cacheHeaders },
  );
}
