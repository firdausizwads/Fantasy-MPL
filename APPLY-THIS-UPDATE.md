# Fantasy MPL — Cinematic Entry & Modern Team Showcase

Commit: `007af0a Refine cinematic intro and modernize team showcase`

## Requested adjustments completed

### Removed from the welcome screen

- Removed the numbered `1–2–3` journey tracker.
- Removed the **Explore the Arena** button.
- Removed the **Create Your Manager** body button.
- Removed the manual intro-skip control.

The small **Sign In** and **Create Free Account** controls remain in the header so account access is still easy, but they do not interrupt the cinematic presentation.

## Fully automated cinematic advertisement

The first page now plays automatically as a short Fantasy MPL promotional sequence:

1. Fantasy MPL brand introduction
2. MPL Malaysia scene
3. MPL Indonesia scene
4. MPL Philippines scene
5. “Three Regions. One Fantasy Arena” finale
6. Smooth fade and slide into **Choose Your Battleground**

The complete sequence takes approximately nine seconds. Each region receives its own:

- ambient regional color;
- official league identity;
- large cinematic logo reveal;
- headline and regional message;
- background word treatment;
- light-beam, grid and grain effects; and
- animated progress timeline without numbered steps.

Users with reduced-motion enabled receive a shortened, static finale before the battleground page appears.

## Modern Team Showcase

The old continuously moving marquee has been removed.

It is replaced by a modern interactive regional team directory preview:

- MY, ID and PH league selectors;
- official regional league marks;
- responsive verified team grid;
- clean team-logo cards;
- team name and code;
- staggered card entrance animations;
- modern hover states on desktop;
- two-column mobile layout;
- one-column layout for very narrow devices; and
- visible verified-team counts.

The grid changes instantly when visitors select Malaysia, Indonesia or the Philippines.

## Desktop and mobile behavior

The cinematic scenes and battleground page were validated at:

- 1440×1000
- 768×1024
- 430×932
- 375×812
- 320×700

Every size passed with:

- visible cinematic logo and copy;
- three battleground cards;
- complete modern team grid;
- no page-level horizontal overflow; and
- no runtime errors.

## Files changed

- `app/guest-entry.tsx`
- `app/guest-entry.css`
- `tests/public.spec.ts`

No Supabase migration, environment variable or file deletion is required.

## Audit results

- TypeScript: passed
- Production build: passed
- Desktop Playwright: `19 passed`, `3 mobile-only skipped`
- Mobile feature suite: all tests passed after one teardown-only retry
- Automated guest flow: passed on desktop and mobile
- Modern showcase region switching: passed (`8 MY`, `9 ID`, `8 PH` team records)
- Viewport matrix: `5/5` passed
- Horizontal overflow: `0`
- Runtime errors: `0`
- Hero assets: `133/133`
- Dependency vulnerabilities: `0`

## Apply with GitHub Desktop

1. Apply `Fantasy-MPL-guest-first-entry.zip` first.
2. Extract `Fantasy-MPL-cinematic-entry-team-showcase.zip`.
3. Copy the extracted `app` and `tests` folders into your repository.
4. Choose **Replace/Overwrite**.
5. In GitHub Desktop, confirm these three updated files:
   - `app/guest-entry.tsx`
   - `app/guest-entry.css`
   - `tests/public.spec.ts`
6. Commit with:
   `Refine cinematic intro and modernize team showcase`
7. Push to GitHub.
8. Wait for Vercel to show **Ready**.
9. Close every old Fantasy MPL tab and open the website in a fresh tab so the new cinematic JavaScript bundle is loaded.

Do not commit `.env.local`, Supabase server secrets, PandaScore tokens or RoneAI tokens.
