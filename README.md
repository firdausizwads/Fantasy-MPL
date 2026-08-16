# Fantasy MPL

Fantasy MPL is an independent, mobile-first fantasy esports and prediction platform for separate MPL Malaysia, MPL Indonesia, and MPL Philippines competitions.

> **Beta status:** The platform is under active development. Several advanced experiences remain demonstration interfaces until their server-side data sources are connected.

## Current functionality

- Supabase email/password authentication and confirmed sessions
- Public manager profiles and private personal details
- Cloud avatar uploads
- Separate regional memberships
- Verified Season 18 teams, rosters, logos, portraits, and Week 1 fixtures
- Server-locked match and Weekly MVP predictions
- Prediction and fantasy scoring ledgers
- Regional standings and tie-break rules
- Private league creation and eight-character invite codes
- Realtime draft architecture, player ownership, and chat tables
- Weekly fantasy lineups, captains, transfers, and roster validation
- Playoff bracket predictor and 1920×1080 export cards
- Meta Lab and role-based scoring concepts
- Dynamic Weekend, Hero-Lock, Survivor, and H2H formats
- Creator Hub and explainable Lineup Advisor concepts
- Admin fixture and scoring interfaces

## Technology

- Next.js 16
- React 19
- TypeScript in strict mode
- Supabase Auth, PostgreSQL, Storage, Realtime, and Row Level Security
- Vercel deployment

## Local development

```bash
npm install
npm run dev
```

Create `.env.local` locally—never commit it:

```text
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=sb_publishable_YOUR_KEY
```

Do not place a secret key, service-role key, database password, or GitHub token in a `NEXT_PUBLIC_` variable.

## Quality checks

```bash
npm run typecheck
npm run build
npm audit --omit=dev
```

## Database migrations

Run migrations in numerical order from `supabase/migrations`:

1. Profiles and regions
2. Competitions, predictions, and scoring
3. Verified Season 18 seed
4. Fantasy leagues and drafts
5. Realtime draft
6. Weekly lineups
7. Fantasy scoring
8. Prediction scoring
9. Cloud transfers
10. Roster completion
11. Fixture management
12. Profile privilege hardening

Test migrations in a separate Supabase project before applying future changes to production.

## Security model

- Supabase Row Level Security is enabled on user and competition tables.
- Private profile fields are separated from public profile fields.
- Prediction and lineup locks use server timestamps.
- Draft ownership and roster constraints are validated in PostgreSQL.
- Administrator writes require an authorized account role.
- No service-role credential is used in browser code.

## Important legal notice

Fantasy MPL is an independent community project and must not imply official affiliation without written authorization. MPL, MLBB, team logos, player images, and related competition assets belong to their respective owners. Obtain the necessary permissions and data licenses before commercial launch.

No prize is guaranteed until a campaign publishes funding, eligibility, territory, and reward rules. Fantasy Dust is non-transferable, cannot be purchased, has no cash value, and is not redeemable for cash.

## Public policies

- `/privacy`
- `/terms`
- `/rules`
- `/community-guidelines`

## Deployment

The production site is deployed at:

https://fantasy-mpl-phi.vercel.app

Vercel environment variables must be configured for Production, Preview, and Development scopes.
