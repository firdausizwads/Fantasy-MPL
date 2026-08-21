# Fantasy MPL — MLBB Cinematic Logo Reveal

Commit: `eb208da Add MLBB cinematic logo reveal and simplify finale marks`

## Changes completed

### Official MLBB logo in the welcome cinematic

The Fantasy MPL emblem displayed beside **Welcome to Fantasy MPL** has been replaced with the Mobile Legends: Bang Bang logo.

The same MLBB logo is also used as the central identity in the final **Three Regions. One Fantasy Arena** scene.

### Game-entry-inspired animation

The new logo does not appear as a static image. It uses an original game-entry-inspired reveal consisting of:

- blurred scale-in;
- bright golden logo flash;
- energy-cut line;
- moving golden light sweep;
- rotating portal rings;
- counter-rotating dashed inner ring;
- pulsing orange ambient glow; and
- controlled overshoot and settling motion.

The animation is original to Fantasy MPL and does not copy game files or a proprietary animation sequence.

### MY / ID / PH blue tags removed

The three regional league marks remain above the final MLBB logo, but the small blue text badges have been completely removed.

There are no longer any blue:

- `MY`
- `ID`
- `PH`

labels attached to those final-scene marks.

## Asset provenance

New asset:

- `public/brand/mobile-legends-bang-bang-logo.png`

Provenance record:

- `app/brand-asset-sources.json`

Recorded source information:

- Name: Mobile Legends: Bang Bang 2025 logo
- Author: Moonton
- Original source: `https://www.mobilelegends.com/`
- Reference page: `https://en.wikipedia.org/wiki/File:Mobile_Legends_Bang_Bang_2025_logo.png`
- Purpose: brand identification in the non-commercial Fantasy MPL welcome cinematic

The existing unofficial-platform disclaimer remains visible. Use of the logo identifies Mobile Legends: Bang Bang and does not claim affiliation or endorsement.

## Files changed

- `app/guest-entry.tsx`
- `app/guest-entry.css`
- `app/brand-asset-sources.json` — new
- `public/brand/mobile-legends-bang-bang-logo.png` — new
- `scripts/verify-assets.mjs`
- `tests/public.spec.ts`

No Supabase migration, environment variable or file deletion is required.

## Audit results

- TypeScript: passed
- Production build: passed
- Desktop Playwright: `19 passed`, `3 mobile-only skipped`
- Mobile functional suite: passed after one teardown-only retry
- MLBB intro logo path: verified
- MLBB finale logo path: verified
- Finale regional marks: `3`
- Finale MY/ID/PH badge elements: `0`
- Brand provenance records: `1/1`
- Hero assets: `133/133`
- Horizontal overflow: `0`
- Dependency vulnerabilities: `0`

## Apply with GitHub Desktop

1. Apply `Fantasy-MPL-cinematic-entry-team-showcase.zip` first.
2. Extract `Fantasy-MPL-mlbb-logo-cinematic-fix.zip`.
3. Copy the extracted folders into your Fantasy MPL repository.
4. Choose **Replace/Overwrite**.
5. In GitHub Desktop, confirm the six files listed above.
6. Commit with:
   `Add MLBB cinematic logo reveal and simplify finale marks`
7. Push to GitHub.
8. Wait until Vercel displays **Ready**.
9. Close every old Fantasy MPL browser tab and open the site in a new tab to load the new image, CSS and JavaScript bundles.

Do not commit `.env.local`, Supabase server secrets, PandaScore tokens or RoneAI tokens.
