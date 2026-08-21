# Fantasy MPL — Dark Feature Pages & Creator Hub Removal

Commit: `561cdb6` — **Harden dark feature pages and remove Creator Hub**

## Dark-mode pages fixed

A final stylesheet is now loaded after every feature stylesheet so older light-theme rules cannot override dark mode.

### Live Draft Lab

Darkened and normalized:

- setup and first-side controls;
- blue and red draft columns;
- empty and selected pick/ban slots;
- Draft Analysis side column;
- recommendation-pending panel;
- model context and methodology rows;
- attribution and disclaimer rows;
- mobile Draft/Heroes/Model tabs.

The two team columns retain blue/red identity using dark tinted gradients instead of white or pastel columns.

### Meta Lab

Darkened and normalized:

- status and deadline strip;
- Draft Predictions / Scoring Rules tabs;
- How It Works row;
- four-step navigation;
- guided question panels;
- hero filters and selects;
- range choices;
- flex guide;
- review cards;
- role explorer and metric cards;
- footer controls.

### Leaderboards

Darkened and normalized:

- regional and league leaderboard containers;
- header and table columns;
- manager rows and the current-user highlight;
- empty states;
- point breakdown and history rows;
- week selector and rank badges.

### My Profile

Darkened and normalized:

- identity column;
- avatar border and upload control;
- public-profile information box;
- profile form and every input/select/textarea;
- privacy notice;
- account data controls;
- delete-account warning and confirmation panel.

All primary headings and important values use white text, while secondary information uses a consistent readable blue-grey.

## Creator Hub removed

Removed from:

- Desktop navigation
- Mobile drawer
- View routing
- Dynamic imports
- Application rendering
- Icon registry
- Community navigation group
- Community policy language specific to creator spaces
- Unused Creator Hub and Lineup Advisor CSS

The source file `app/creator-hub.tsx` is deleted.

## Regression coverage

The dark-mode surface test now scans the complete page—not only the first viewport—for:

- Live Draft Lab
- Meta Lab
- Leaderboards
- My Profile
- Predictions
- Fantasy
- Competition
- Directory
- Playoffs

It runs on desktop and mobile and fails if any visible large near-white surface appears.

Navigation tests also confirm Creator Hub is absent.

## Verification

- TypeScript: passed
- Production build: passed
- npm audit: 0 vulnerabilities
- Desktop Playwright: 14 passed, 3 mobile-only skipped
- Mobile Playwright: 14 passed, 3 intentionally skipped
- Full-height dark-surface regression: passed desktop and mobile
- Creator Hub navigation regression: passed

## Files changed

- `app/dark-mode-hardening.css` — new
- `app/layout.tsx`
- `app/page.tsx`
- `app/globals.css`
- `app/community-guidelines/page.tsx`
- `app/privacy/page.tsx`
- `app/rules/page.tsx`
- `tests/mobile.spec.ts`
- `tests/public.spec.ts`
- `app/creator-hub.tsx` — delete this file

## GitHub Desktop installation

1. Fetch and pull the latest `main`.
2. Create a branch named `dark-pages-fix`.
3. Extract `Fantasy-MPL-dark-pages-creator-removal.zip`.
4. Copy the included `app` and `tests` folders into your repository, replacing matching files.
5. **Delete `app/creator-hub.tsx` manually.** The ZIP cannot delete an existing file for you.
6. Confirm GitHub Desktop shows `creator-hub.tsx` as deleted.
7. Commit: `Harden dark feature pages and remove Creator Hub`.
8. Push and test the Vercel Preview on desktop and mobile.
9. Check Live Draft Lab, Meta Lab, Leaderboards, My Profile and both navigation menus.
10. Merge into `main`.

No Supabase migration or Vercel environment-variable change is required.
