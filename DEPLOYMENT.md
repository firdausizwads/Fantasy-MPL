# Fantasy MPL deployment guide

This project deploys from GitHub to Vercel and uses Supabase for Auth, PostgreSQL, Storage and Realtime.

## 1. Work safely with GitHub Desktop

1. Open **GitHub Desktop**.
2. Select the `Fantasy-MPL` repository.
3. Select **Fetch origin**, then **Pull origin** if offered.
4. Select **Current branch → New branch**.
5. Name the branch, for example `production-hardening`.
6. Copy the changed project files into the repository folder.
7. Review the changed-file list in GitHub Desktop.
8. Commit with a clear message, such as `Harden production and improve mobile performance`.
9. Select **Push origin**.
10. On GitHub, open a pull request into `main` and wait for **Quality checks** to pass.

Do not commit `.env`, `.env.local`, Supabase secret keys, database passwords, PandaScore tokens or GitHub tokens.

## 2. Configure Vercel environment variables

Open **Vercel → fantasy-mpl → Settings → Environment Variables**. Add the variables to Production and Preview as appropriate:

| Variable | Visibility | Purpose |
| --- | --- | --- |
| `NEXT_PUBLIC_SITE_URL` | Public | Canonical production URL, without a trailing slash |
| `NEXT_PUBLIC_PRIVACY_EMAIL` | Public | Email shown in the Privacy Policy for user requests |
| `NEXT_PUBLIC_SUPABASE_URL` | Public | Supabase project URL |
| `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` | Public | Supabase publishable browser key |
| `SUPABASE_SERVICE_ROLE_KEY` | **Secret, server only** | Server-side fixture ingestion |
| `PANDASCORE_API_TOKEN` | **Secret, server only** | PandaScore API access |
| `RONEAI_API_TOKEN` | **Secret, server only** | OpenMLBB/RoneAI Draft Intelligence access |
| `RONEAI_API_BASE_URL` | Server configuration | Approved OpenMLBB production base URL |
| `PANDASCORE_SYNC_SECRET` | **Secret, server only** | Protects the database ingestion RPC; at least 32 random characters |
| `CRON_SECRET` | **Secret, server only** | Protects scheduled synchronization requests |

Never prefix a secret with `NEXT_PUBLIC_`. Never paste a secret or service-role key into frontend code, GitHub, screenshots or chat.

Generate independent secrets locally, for example:

```bash
openssl rand -hex 32
```

After changing Vercel environment variables, redeploy the latest deployment so the build receives the updated values.

## 3. Apply Supabase migrations

Migrations live in `supabase/migrations` and must be applied in numerical order.

For an existing project already on migration 028:

1. Add `SUPABASE_SERVICE_ROLE_KEY` to Vercel first.
2. Deploy the updated application code and verify `/api/health`.
3. Open **Supabase → SQL Editor → New query**.
4. Paste and run `supabase/migrations/029_server_only_fixture_ingestion.sql`.
5. Confirm the final query returns `true` for all three checks.
6. Paste and run `supabase/migrations/030_age_and_terms_acceptance.sql`.
7. Confirm its final three checks return `true`.
8. Create a test account and verify the age/guardian checkbox is required.
9. From an administrator account, run PandaScore synchronization once and review the staging queue.

This order avoids interrupting fixture sync and signups: the updated Vercel code starts sending server credentials and acceptance metadata before the database permissions and acceptance trigger are tightened.

For a new Supabase project, apply every numbered migration from `001` through `030` in order. Test migrations in a separate project before production whenever possible.

## 4. Verify the deployment

After the Vercel deployment is ready, run locally:

```bash
npm ci
npm run typecheck
npm run build
npm run test:e2e
npm run test:production
```

Then check:

- `https://YOUR_DOMAIN/api/health` reports `status: ok`;
- registration and email confirmation work;
- sign-in survives a refresh;
- MY, ID and PH regional routes load;
- a regular account cannot see or call administrator tools;
- an administrator can run PandaScore sync after migration 029;
- `/robots.txt`, `/sitemap.xml`, `/manifest.webmanifest` and `/favicon.ico` return 200.

## 5. Add a custom domain

1. Open **Vercel → fantasy-mpl → Settings → Domains**.
2. Add the domain you own and follow Vercel's DNS instructions.
3. Set `NEXT_PUBLIC_SITE_URL` to `https://your-domain.example`.
4. Redeploy Production.
5. Confirm the canonical link, sitemap and robots file use the custom domain.
6. Add the custom URL to **Supabase → Authentication → URL Configuration** as the Site URL and an allowed redirect URL.

Keep the existing `vercel.app` domain as a redirect or deployment fallback.

## 6. Rollback

If a deployment fails:

1. Open **Vercel → Deployments**.
2. Select the previous healthy deployment.
3. Choose **Promote to Production**.
4. In GitHub Desktop, revert the faulty commit rather than deleting history.

Database migrations should be fixed with a new forward migration. Do not edit an already-applied production migration in place.
