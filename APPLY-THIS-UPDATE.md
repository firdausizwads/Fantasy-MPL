# Fantasy MPL — Live Draft Report & Hero Picker Fix

Commit: `16ef08b Fix Draft Report dark mode and hero picker layout`

## Fixed

### Draft Report dark mode

The report container was dark, but several nested legacy surfaces were still light. Dark mode now covers the complete report:

- draft estimate area;
- blue and red draft profile cards;
- individual metric cells;
- selected hero pills;
- estimate progress bars;
- complete action timeline;
- every timeline action card; and
- model-limitation notice.

The report now uses deep navy surfaces, white primary text, blue-grey secondary text and a controlled dark-gold limitation notice.

### Hero pick/ban window

The hero selector has been rebuilt as a real viewport-safe modal dialog.

Improvements:

- centered desktop window with a maximum readable width;
- guaranteed fit inside the browser viewport;
- responsive sizing for desktop, laptop, tablet and mobile;
- dedicated backdrop instead of the previous pseudo-element workaround;
- page scrolling is locked while the selector is open;
- the hero grid scrolls independently while the heading, filters and guidance stay available;
- mobile safe-area support;
- compact mobile guidance panel;
- two-column mobile hero grid;
- responsive desktop hero columns;
- close button, backdrop click and Escape-key support;
- accessible dialog name, hero-search label and available-hero region;
- body scrolling is restored after selecting a hero or closing the window; and
- no mobile auto-focus/zoom regression.

### Tablet layout

At widths below 900px, the Live Draft workspace and completed report now stack cleanly. This removes the horizontal overflow previously seen around 721–900px.

## Files changed

- `app/draft-final-fixes.css` — new
- `app/draft-lab.tsx`
- `app/layout.tsx`
- `tests/mobile.spec.ts`
- `tests/public.spec.ts`

No file deletion, Supabase migration or new environment variable is required.

## Audit results

- TypeScript: passed
- Production build: passed
- Hero assets: `133/133`
- Picker portraits loaded during the interaction test: `133/133`
- Desktop Playwright: `18 passed`, `3 mobile-only skipped`
- Mobile Playwright: `18 passed`, `3 intentionally skipped`
- Picker viewport matrix passed at:
  - 1920×1080
  - 1440×900
  - 1280×720
  - 1024×768
  - 768×1024
  - 430×932
  - 375×812
  - 320×700
- Picker page overflow: `0`
- Picker escapes viewport: `0`
- Dark Draft Report large white surfaces: `0`
- Report overflow: `0` across desktop, tablet and mobile checks
- Dependency vulnerabilities: `0`

## Apply with GitHub Desktop

1. Apply the previous Draft Intelligence Sources fix first.
2. Extract `Fantasy-MPL-live-draft-final-fix.zip`.
3. Copy the extracted `app` and `tests` folders into the root of your Fantasy MPL repository.
4. Choose **Replace/Overwrite**.
5. Open GitHub Desktop and confirm the five changed files listed above.
6. Commit with:
   `Fix Draft Report dark mode and hero picker layout`
7. Push to GitHub and wait for Vercel to redeploy.
8. Test:
   - Live Draft Lab → choose the active ban/pick slot;
   - scroll the hero list and choose a hero;
   - complete/open a saved draft report in dark mode;
   - repeat once on mobile.

Do not commit `.env.local`, Supabase server secrets, PandaScore tokens or RoneAI tokens.
