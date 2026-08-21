# Fantasy MPL — Guest-First Entry Experience

Commit: `6f19f62 Add animated guest-first regional browsing`

## Main change

Visitors are no longer forced to register or sign in before seeing Fantasy MPL.

A new visitor can now:

1. See the welcoming Fantasy MPL introduction.
2. Continue through the animated regional battleground selection.
3. Choose MPL Malaysia, MPL Indonesia or MPL Philippines.
4. Enter the regional dashboard in Guest Preview mode.
5. Browse the website’s main features before deciding whether to create an account.

Authentication, Supabase RLS and administrator permissions remain unchanged.

## New 1–2–3 visual journey

### Step 1 — Welcome

- New cinematic welcome page.
- Fantasy MPL identity and three-region orbit visual.
- Explains which features can be explored.
- Automatic fade transition after approximately six seconds.
- Manual **Explore the Arena** and **Skip Intro** controls.
- Persistent **Sign In** and **Create Free Account** access.

### Step 2 — Choose your battleground

- Three region cards appear using a staggered 1–2–3 pop animation.
- Existing MY, ID and PH regional identities are preserved.
- Each region clearly explains what the visitor can explore.
- Visitors can switch regions later from the normal region selector.

### Step 3 — Arena ready

- Selected regional league logo is displayed.
- Short loading transition opens the guest regional command center.
- An **Enter Now** option is also available.

## Team showcase

The region-selection page now includes a moving Season 18 team showcase below the battleground cards.

- Uses the existing verified team identity assets.
- Covers Malaysia, Indonesia and the Philippines.
- Pauses when hovered on desktop.
- Uses a static accessible layout when reduced-motion mode is enabled.

## Guest Preview mode

Guests can browse:

- Dashboard
- Predictions
- My Fantasy Team
- Live Draft Lab
- Schedule & Standings
- Playoff Predictor
- Meta Lab
- Leaderboards preview
- Teams & Players
- Prizes

Guest preview state is stored in `sessionStorage`, allowing a page refresh without forcing the visitor back to the welcome screen. A new browser session still begins with the welcome experience.

## Registration and sign-in access

Account controls are available from:

- welcome-page header;
- welcome-page calls to action;
- guest desktop top bar;
- guest preview information banner;
- desktop guest sidebar card;
- mobile navigation drawer;
- leaderboard account prompt; and
- protected save/submit actions.

The authentication page now includes **Continue Exploring**, allowing visitors to return to the feature they were viewing.

## Guest safety and account boundaries

- Guests may explore interfaces and local preview interactions.
- Official prediction submission redirects to account creation.
- Meta Lab save and submission redirect to account creation.
- Guest Profile and Admin Console navigation are hidden.
- Verified leaderboard participation requires an account.
- No guest access bypasses Supabase authentication, RLS or server-side security.

## Files changed

- `app/guest-entry.tsx` — new
- `app/guest-entry.css` — new
- `app/layout.tsx`
- `app/page.tsx`
- `app/meta-lab.tsx`
- `tests/public.spec.ts`
- `tests/mobile.spec.ts`

No file deletion, Supabase migration or new environment variable is required.

## Audit results

- TypeScript: passed
- Production build: passed
- Desktop Playwright: `19 passed`, `3 mobile-only skipped`
- Mobile Playwright: `19 passed`, `3 intentionally skipped`
- Guest feature audit: `20/20` desktop/mobile page checks passed
- Guest page runtime errors: `0`
- Guest page horizontal overflow: `0`
- Entry experience passed at:
  - 1440×1000
  - 768×1024
  - 430×932
  - 375×812
  - 320×700
- Hero assets: `133/133`
- Dependency vulnerabilities: `0`

## Apply with GitHub Desktop

1. Apply the previous Live Draft Report and Hero Picker update first.
2. Extract `Fantasy-MPL-guest-first-entry.zip`.
3. Copy the extracted `app` and `tests` folders into your Fantasy MPL repository.
4. Choose **Replace/Overwrite**.
5. Open GitHub Desktop and confirm the seven changed files listed above.
6. Commit with:
   `Add animated guest-first regional browsing`
7. Push to GitHub.
8. Wait until the Vercel deployment status is **Ready**.
9. Close old Fantasy MPL browser tabs and open the website in a new tab.
10. Test the complete welcome → battleground → guest dashboard journey once on desktop and once on mobile.

Do not commit `.env.local`, Supabase server secrets, PandaScore tokens or RoneAI tokens.
