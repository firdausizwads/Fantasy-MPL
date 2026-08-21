# Fantasy MPL — Draft Intelligence Sources Modernization

Commit: `f78aefa Modernize Draft Intelligence source governance`

## Fixed

The nested **Admin Console → Draft Intelligence → Sources** workspace has been rebuilt instead of only recolored.

### Source governance overview

- Added a clear governance summary explaining why sources must be reviewed.
- Added visible counts for registered, approved, commercially permitted and primary sources.
- Pending or unconfirmed sources are clearly described as blocked from model activation.

### Modern source library

Each provider now has a structured source card showing:

- approval status;
- primary-source status;
- provider URL;
- recorded licence;
- commercial-use permission;
- terms link;
- exact public attribution; and
- a warning when attribution is missing.

The commercial-use field keeps its original security meaning. It was not weakened or automatically enabled.

### Guided source review

The old flat form is now divided into three understandable steps:

1. Provider identity
2. Rights and public credit
3. Review decision

Improvements include:

- full-width responsive form controls;
- clearer field descriptions;
- modern permission cards;
- explicit pending/approved/rejected/suspended status;
- review-safety guidance;
- improved required URL validation; and
- clearer save progress text.

### Dark and light themes

- Removed the remaining white nested panels from dark mode.
- Added deep navy cards, inputs, permission controls and attribution panels.
- Fixed the active Draft Intelligence tab and other admin accent controls in light mode.
- Light mode now uses clean white cards and soft blue-grey form sections.
- Desktop and mobile layouts have no page-level horizontal overflow.

## Files changed

- `app/admin-console-modern.css`
- `app/admin-draft-intelligence.tsx`
- `tests/public.spec.ts`

No file deletion, Supabase migration or new environment variable is required.

## Audit results

- TypeScript/build compilation: passed
- Production build: passed
- Hero assets: `133/133`
- Desktop Playwright: `17 passed`, `3 mobile-only skipped`
- Mobile Playwright: `17 passed`, `3 intentionally skipped`
- Sources theme regression: passed on desktop and mobile in dark and light mode
- Dark Sources large white surfaces: `0`
- Source form controls: confirmed full-width
- Page-level horizontal overflow: `0`
- Dependency vulnerabilities: `0`

## Apply with GitHub Desktop

1. Apply the previous `Fantasy-MPL-modern-admin-console.zip` update first.
2. Extract `Fantasy-MPL-draft-sources-fix.zip`.
3. Copy the extracted `app` and `tests` folders into your Fantasy MPL repository.
4. Choose **Replace/Overwrite**.
5. In GitHub Desktop, confirm the three changed files listed above.
6. Commit with:
   `Modernize Draft Intelligence source governance`
7. Push to GitHub and wait for Vercel to redeploy.
8. Sign in as an administrator and open:
   **Admin Console → Draft Intelligence → Sources**
9. Check the page once in dark mode and once in light mode.

Do not commit `.env.local`, Supabase server secrets, PandaScore tokens or RoneAI tokens.
