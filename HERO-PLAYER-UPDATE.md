# Fantasy MPL — Hero & Player Portrait Update

Commits included:

- `4604d29` — Fix seed preview responsive layout
- `41aa70f` — Add Live Draft hero portraits and regional player photos

## Live Draft Lab hero portraits

- Added **131/131** hero portraits used by the current Draft Lab catalog.
- Hero cards now show a real portrait rather than two-letter initials.
- Selected ban and pick slots show the selected hero portrait.
- Recommendation cards are portrait-ready when the evidence model is active.
- Portraits are stored locally as compact WebP files; browsers do not hotlink external hero images.
- Every hero entry records its source URL in `app/hero-assets.json`.
- Hero image payload for all 131 local files is approximately 434 KB.

Hero assets were retrieved from MLBB/Moonton official web asset endpoints. The newest heroes that were absent from the older public hero list were matched against current official asset URLs.

## Player portraits

Current coverage after this update:

| Region | Portraits |
| --- | ---: |
| MPL Malaysia | **50 / 50** |
| MPL Indonesia | **60 / 61** |
| MPL Philippines | **37 / 40** |

New portraits added in this package:

- 37 MPL PH players
- 11 additional MPL ID players

The Teams & Players directory automatically displays these portraits. Photo provenance and roster-verification links are recorded in `app/player-photo-sources.json`.

### Intentionally unresolved

These players remain on the existing **PHOTO PENDING** card because I could not verify a correct individual portrait:

- MPL PH · Omega · **Cull**
- MPL PH · TNC · **Vin**
- MPL PH · TNC · **Zehn**
- MPL ID · Bigetron · **Miguel**

I did not substitute group photos, unrelated people or question-mark placeholders. These four can be added later when an official individual image becomes available.

## OpenMLBB / RoneAI approval

The authorization terms from the owner's email are recorded in `RONEAI-INTEGRATION.md`.

The exact required attribution now appears in Draft Lab:

> Powered by MLBB Public Data API • Data © Moonton (Mobile Legends) • API maintained by ridwaanhall / RoneAI.

The integration design respects the stated conditions:

- non-commercial production use;
- server-only token;
- Supabase snapshot caching;
- approximately 50 requests per day;
- public derived recommendations;
- deletion of cached RoneAI snapshots if access ends.

`RONEAI_API_TOKEN` and `RONEAI_API_BASE_URL` have been added to `.env.example` and the deployment documentation. **Do not send the token in chat or add it to GitHub.** Wait for RoneAI's full onboarding documentation before enabling live calls because the service is currently under-maintained.

## Asset verification

A new command verifies every local image path and documents unresolved players:

```bash
npm run test:assets
```

It is also included in GitHub Actions.

## Verification completed

- TypeScript: passed
- Asset audit: passed
- Production build: passed
- Desktop Draft Lab portrait test: passed
- Mobile hero-picker portrait test: passed
- npm production audit: 0 vulnerabilities

## Main files

- `app/hero-assets.json`
- `app/hero-portraits.css`
- `app/player-photo-sources.json`
- `app/official-players.json`
- `app/draft-lab.tsx`
- `public/heroes/*`
- `public/players/ph/*`
- `public/players/id/btr/*`
- `public/players/id/onicid/*`
- `RONEAI-INTEGRATION.md`
- `scripts/verify-assets.mjs`

The seed-preview fix is also included so this package can be applied directly to the current GitHub `main` branch.

## Install with GitHub Desktop

1. Fetch and pull the latest `main`.
2. Create a branch named `hero-player-portraits`.
3. Extract `Fantasy-MPL-hero-player-update.zip`.
4. Copy all folders and files inside it into the repository, replacing matching files.
5. Review the changes in GitHub Desktop.
6. Commit: `Add Live Draft hero portraits and regional player photos`.
7. Push and wait for the green GitHub check.
8. Inspect the Vercel Preview:
   - `/live-draft`
   - Teams & Players → MPL Philippines
9. Merge into `main` after testing.

No Supabase SQL migration is required for the image update.

## Before enabling live RoneAI requests

Reply to RoneAI and request the full technical onboarding details: production base URL, authentication header name, endpoint schemas, rank syntax, patch/time-window values, rate-limit reset headers, and snapshot-deletion process. Add the token only to Vercel as `RONEAI_API_TOKEN` after those details are confirmed.
