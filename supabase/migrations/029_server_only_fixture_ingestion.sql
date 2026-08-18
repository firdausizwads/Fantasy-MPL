-- Fantasy MPL — server-only PandaScore fixture ingestion
-- Run after 028_live_meta_lab.sql.
-- IMPORTANT: add SUPABASE_SERVICE_ROLE_KEY to Vercel before applying this migration.
-- The service-role key must remain server-only and must never use a NEXT_PUBLIC_ prefix.

-- Prevent browsers from invoking the secret-protected ingestion function.
-- The Vercel integration route now calls this RPC with the server-only service role.
revoke all on function public.ingest_pandascore_fixture_batch(text, jsonb)
  from public, anon, authenticated;
grant execute on function public.ingest_pandascore_fixture_batch(text, jsonb)
  to service_role;

-- Serialize imports for a provider. A second transaction waits for the active
-- import to finish instead of running an overlapping fixture batch.
create unique index if not exists one_running_fixture_sync_per_provider
  on public.fixture_sync_runs (provider)
  where status = 'running';

select
  has_function_privilege('service_role', 'public.ingest_pandascore_fixture_batch(text,jsonb)', 'execute')
    as service_role_can_ingest,
  not has_function_privilege('anon', 'public.ingest_pandascore_fixture_batch(text,jsonb)', 'execute')
    as anonymous_ingestion_blocked,
  not has_function_privilege('authenticated', 'public.ingest_pandascore_fixture_batch(text,jsonb)', 'execute')
    as browser_ingestion_blocked;
