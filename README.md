# Fantasy MPL

Fantasy MPL is an independent, mobile-first fantasy esports and prediction platform for separate MPL Malaysia, MPL Indonesia and MPL Philippines competitions.

> **Beta status:** The platform is under active development. Advanced experiences remain gated until their official data sources and competition rules are verified.

## Current functionality

- Supabase email/password authentication and confirmed sessions
- Public manager profiles and private personal details protected by Row Level Security
- Cloud avatar uploads and self-service account export/deletion
- Separate MY, ID and PH memberships, feature controls and leaderboards
- Season 18 teams, rosters, sourced player portraits, fixtures and regional fantasy lineups
- Complete 131-hero local portrait catalog for Live Draft Lab
- Server-locked match, Weekly MVP and Meta Lab predictions
- Prediction and fantasy scoring ledgers
- Realtime league drafts, player ownership, lineups, transfers and chat foundations
- Custom and official playoff bracket modes
- Public Live Draft Lab with evidence-gated recommendations and authorized OpenMLBB/RoneAI integration terms
- Administrator fixture, scoring, regional operations and PandaScore tools

## Technology

- Next.js 16 and React 19
- TypeScript in strict mode
- Supabase Auth, PostgreSQL, Storage, Realtime and Row Level Security
- Vercel deployment and analytics
- Playwright end-to-end tests

## Local development

```bash
npm ci
cp .env.example .env.local
npm run dev
```

Fill in the public Supabase values in `.env.local`. Server integration variables are needed only when testing PandaScore synchronization locally.

Never commit `.env.local`. Never place a secret key, service-role key, database password or provider token in a `NEXT_PUBLIC_` variable.

## Quality checks

```bash
npm run typecheck
npm run test:assets
npm run build
npm run test:e2e
npm audit --omit=dev
```

To check the deployed site:

```bash
npm run test:production
```

## Database migrations

Migrations are stored in `supabase/migrations`. Apply them in numerical order. The current schema ends at:

```text
030_age_and_terms_acceptance.sql
```

Migration 029 requires the updated Vercel route and `SUPABASE_SERVICE_ROLE_KEY`. Migration 030 records the registration age/guardian and terms confirmation. Follow [DEPLOYMENT.md](./DEPLOYMENT.md) for the safe deployment order.

Test future migrations in a separate Supabase project before applying them to production. Once a migration has been applied, fix it with a new forward migration rather than editing production history.

## Security model

- Row Level Security is enabled on user and competition tables.
- Private profile fields are stored separately from public profile fields.
- Prediction, fantasy and Meta Lab locks use PostgreSQL server time.
- Draft ownership, roster and scoring constraints are validated in PostgreSQL.
- Administrator RPCs verify the authenticated account role.
- PandaScore ingestion is callable only by the server-side Supabase role after migration 029.
- The Supabase publishable key is intentionally public; server secrets are not.
- Security headers are configured in `next.config.ts`.

## OpenMLBB / RoneAI

Fantasy MPL has written permission for current non-commercial production use, server-side caching, derived recommendations and public display. Review [RONEAI-INTEGRATION.md](./RONEAI-INTEGRATION.md) before connecting the server token or changing the business model.

Required attribution:

> Powered by MLBB Public Data API • Data © Moonton (Mobile Legends) • API maintained by ridwaanhall / RoneAI.

## Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md) for GitHub Desktop, Vercel, Supabase migration, custom-domain and rollback instructions.

Production health endpoint:

```text
https://fantasy-mpl-phi.vercel.app/api/health
```

Set `NEXT_PUBLIC_SITE_URL` when moving to a custom domain. Metadata, canonical URLs, robots and sitemap output will update from that value.

## Important legal notice

Fantasy MPL is an independent community project and must not imply official affiliation without written authorization. MPL, MLBB, team logos, player images and related competition assets belong to their respective owners. Obtain the necessary permissions and data licences before commercial launch.

No prize is guaranteed until a campaign publishes funding, eligibility, territory, age and reward rules. Fantasy Dust is non-transferable, cannot be purchased, has no cash value and is not redeemable for cash.

Public policies are available at `/privacy`, `/terms`, `/rules` and `/community-guidelines`.
