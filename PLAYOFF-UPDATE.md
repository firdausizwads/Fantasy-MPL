# Fantasy MPL — Playoff Predictor Update

Commit: `ba3d7ae` — **Redesign playoff access and custom seeding**

## What changed

### 1. Official Predictor countdown

- The Official Predictor tab is now always clickable.
- Before it opens, it displays a full days/hours/minutes/seconds countdown.
- It automatically becomes accessible when the countdown reaches zero.
- The countdown uses server time from `/api/playoff-access`, not only the visitor's browser time.
- The API refreshes every 60 seconds while the visible countdown updates every second.

Current schedule rules:

- BO1/BO3 matches are treated as regular-season series.
- BO5/BO7 matches are treated as playoff series.
- The regular-season closing time uses the final result's `finalized_at` when available.
- For a future/unfinalized final series, it reserves a four-hour series window after `scheduled_at`.
- The first imported BO5/BO7 date is shown separately as the playoff start.

With the current Supabase data, this produces a real countdown to each region's final regular-season window in October 2026.

### 2. New six-seed studio

- Replaced the six cramped selects with clean seed cards.
- Each card shows seed number, team logo, team name, code and bracket route.
- Desktop uses a spacious three-column layout.
- Tablet uses two columns.
- Mobile uses a clean one-column layout with 16px selects.
- Selecting an already-used team swaps the two seeds automatically.
- Added **Reset Seeds**.
- Custom seed order is included when the bracket is saved.

### 3. Seeding preview moved after the bracket

- The seed preview now appears below the complete bracket.
- It displays all six teams and their routes.
- The export/share control now sits with the post-bracket preview.

### 4. Custom brackets never lock

- Custom seeds, winners and exact scores remain editable.
- Custom mode has **Save Custom Bracket** and **Export & Share**.
- Old saved custom brackets with a locked flag are automatically treated as editable.
- The lock button appears only in Official Predictor mode.
- Official mode changes to a locked state after **Lock Official Prediction**.

## Files included

- `app/playoff-predictor.tsx`
- `app/playoff-experience.css`
- `app/api/playoff-access/route.ts`
- `app/layout.tsx`
- `tests/public.spec.ts`
- `scripts/production-smoke.mjs`

## Verification

- TypeScript check: passed
- Production build: passed
- Desktop Playwright: 12 passed, 3 mobile-only skipped
- Mobile Playwright: 12 passed, 3 intentionally skipped
- New custom/official playoff test passed on desktop and mobile
- npm production audit: 0 vulnerabilities

## Install with GitHub Desktop

1. Fetch and pull the latest `main`.
2. Create a branch named `playoff-experience`.
3. Extract `Fantasy-MPL-playoff-update.zip`.
4. Copy its `app`, `tests` and `scripts` folders into your local repository, replacing matching files.
5. Review the six changed files in GitHub Desktop.
6. Commit with: `Redesign playoff access and custom seeding`.
7. Push the branch and check the green GitHub action.
8. Test the Vercel Preview on desktop and mobile.
9. Merge into `main` and allow Vercel to deploy Production.

No new Supabase SQL migration or environment variable is required for this update.

After deployment, check:

```text
https://fantasy-mpl-phi.vercel.app/api/playoff-access?region=MY
https://fantasy-mpl-phi.vercel.app/api/playoff-access?region=ID
https://fantasy-mpl-phi.vercel.app/api/playoff-access?region=PH
```

Each should return JSON containing `state`, `opens_at`, `regular_matches`, `completed_regular_matches` and `server_now`.
