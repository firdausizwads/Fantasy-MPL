# Fantasy MPL — Region Reliability & Prizes Dark-Mode Fix

Commit: `0c42189 Harden region switching and finish prizes dark mode`

## Fixed

### Region selection reliability

- Switching to a region already joined is now immediate and does not make an unnecessary Supabase insert request.
- Joining a new region retries transient network failures up to three times with an eight-second timeout per attempt.
- Raw `TypeError: Load failed` messages are replaced by a clear, safe retry message.
- The current region remains unchanged if a new membership cannot be confirmed.
- Region cards are disabled while a join is being confirmed, preventing duplicate requests.
- A visible `CONNECTING SECURELY…` state is shown during the request.
- The behavior is covered on both desktop and mobile.

### Prizes dark mode

Dark styling now covers the complete page, including:

- prize notice;
- Fantasy Dust container and inner panels;
- daily check-in cards;
- reward wheel;
- legal notice;
- all 1st–8th prize cards; and
- sponsor panel.

No large white surfaces remain and there is no page-level horizontal overflow at desktop or mobile widths.

## Files changed

- `app/page.tsx`
- `app/globals.css`
- `app/dark-mode-hardening.css`
- `tests/public.spec.ts`

No files need to be deleted for this update.

## Audit results

- TypeScript: passed
- Production build: passed
- Asset verification: passed (`133/133` hero portraits)
- Desktop Playwright: `15 passed`, `3 mobile-only skipped`
- Mobile Playwright: `15 passed`, `3 intentionally skipped`
- Dark-surface audit: passed on all 11 primary authenticated pages on desktop and mobile
- Page-level horizontal overflow: none across all 22 desktop/mobile page checks
- Runtime/page errors during the 22-page audit: none
- Production smoke test: `22/22` live routes passed
- Production dependency audit: `0 vulnerabilities`

Intentionally unresolved verified portrait gaps remain unchanged: Cull, Vin, Zehn, and Miguel.

## Apply with GitHub Desktop

1. Make sure the previous Creator Hub/dark-page update has already been applied.
2. Close any running local Fantasy MPL development server.
3. Extract `Fantasy-MPL-region-prizes-fix.zip`.
4. Copy the extracted `app` and `tests` folders into the root of your Fantasy MPL repository.
5. Choose **Replace/Overwrite** when asked.
6. Open GitHub Desktop and confirm the four changed files listed above.
7. Commit with: `Harden region switching and finish prizes dark mode`
8. Push to GitHub.
9. Let Vercel redeploy, then test region switching and the Prizes page in dark mode.

Do not add `.env.local`, Supabase server secrets, PandaScore tokens, or RoneAI tokens to the commit.
