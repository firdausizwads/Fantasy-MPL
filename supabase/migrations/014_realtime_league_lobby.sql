-- Fantasy MPL — Realtime league lobby refresh
-- Run after 013_mandatory_scores_and_hero_catalog.sql

alter table public.fantasy_leagues replica identity full;

-- League memberships are already added by Migration 005. This keeps the
-- migration safe to rerun and also broadcasts league status changes.
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'fantasy_leagues'
  ) then
    alter publication supabase_realtime add table public.fantasy_leagues;
  end if;

  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'league_members'
  ) then
    alter publication supabase_realtime add table public.league_members;
  end if;
end;
$$;

select schemaname, tablename
from pg_publication_tables
where pubname = 'supabase_realtime'
  and schemaname = 'public'
  and tablename in ('fantasy_leagues', 'league_members')
order by tablename;
