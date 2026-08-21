# Fantasy MPL — Dark Mode Consistency & Fantasy Picker Fix

Commit: `9112f08` — **Unify dark mode and modernize fantasy player picker**

## Dark-mode cleanup

I audited the visible surfaces across:

- Dashboard
- Predictions
- My Fantasy Team
- Leaderboards
- Teams & Players
- Schedule & Standings
- Playoffs
- Meta Lab
- Creator Hub
- Live Draft Lab
- Profile
- Prizes

### Light surfaces removed

The remaining white/light sections were replaced with consistent dark surfaces, including:

- Prediction winner buttons
- Required exact-score rows
- Prediction and MVP countdown badges
- Fantasy roster-rules strip
- Schedule week filters
- Match-center buttons
- Directory logo and source containers
- Cloud lineup cards and status rows
- Meta Lab cards, range choices and scoring cards
- Dashboard cloud fixture and leaderboard rows
- Mobile menu button

An automated browser regression now checks Predictions, Fantasy, Competition, Directory and Playoffs on desktop and mobile. It fails if a visible surface larger than 2,500 square pixels uses a near-white background.

Current audit result: **zero large white surface leaks**.

### Text contrast

- Primary headings and important values are white in dark mode.
- Supporting copy uses a consistent blue-grey rather than low-contrast dark text.
- Filled regional controls now use darker region-specific shades so their white labels remain readable.
- MY uses a darker blue fill, ID a darker crimson fill and PH a darker royal-blue fill while keeping the brighter ambient glow around the workspace.

## Modern Fantasy Team player selection

The official Supabase regional fantasy selector no longer uses a plain `<select>` as the main interaction.

### Role cards

Each EXP, Jungle, Mid, Gold and Roam slot now has:

- numbered role identity;
- selected player portrait;
- team logo and team code;
- player handle and team name;
- captain control;
- modern **Choose Player** or **Change Player** action;
- clear empty-slot presentation.

### Player picker

Selecting a role opens a modern dark player-picker panel containing:

- player portrait;
- team logo;
- handle, team and role;
- selected state;
- team-conflict state;
- disabled players when that professional team is already used;
- responsive two-column desktop and one-column mobile layouts.

The original database validation remains in place: one player per role and one player per professional team.

## Verification

- TypeScript: passed
- Production build: passed
- npm audit: 0 vulnerabilities
- Desktop Playwright: 14 passed, 3 mobile-only skipped
- Mobile Playwright: 14 passed, 3 intentionally skipped
- Dark surface regression: passed desktop and mobile
- Startup regression: passed desktop and mobile
- Hero asset audit: 133/133

## Files changed

- `app/dark-mode.css`
- `app/regional-fantasy.css`
- `app/regional-fantasy.tsx`
- `tests/public.spec.ts`
- `README.md`

## GitHub Desktop installation

1. Fetch and pull your latest `main`.
2. Create a branch named `darkmode-fantasy-fix`.
3. Extract `Fantasy-MPL-darkmode-fantasy-fix.zip`.
4. Copy the included files into your repository, replacing matching files.
5. Commit: `Unify dark mode and modernize fantasy player picker`.
6. Push and wait for the green GitHub check.
7. Test the Vercel Preview on desktop and mobile.
8. Check Predictions, My Fantasy Team, Schedule & Standings and the mobile navigation drawer.
9. Merge into `main`.

No Supabase migration or Vercel environment-variable change is required.
