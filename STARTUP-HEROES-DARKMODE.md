# Fantasy MPL — Startup, Hero Catalog & Dark Mode Update

Latest commit: `5cfed0c` — **Fix startup flash and add regional dark mode**

This package also contains the previous seed-preview and hero/player-portrait updates so it can safely replace the relevant files in the current project.

## 1. Startup login/dashboard flash fixed

### Previous behavior

While Supabase checked an existing session, the initial server output rendered the registration/login screen. A returning user therefore saw login briefly before the dashboard appeared.

### New behavior

- Initial output is a neutral **Preparing Your Arena** screen.
- It restores the session, manager profile, active region and current workspace.
- Login is rendered only after Supabase confirms there is no session.
- Returning users transition directly from the startup screen to their dashboard.
- The startup screen uses a stable dark branded layout on desktop and mobile.
- Automated tests monitor DOM changes and confirm the login screen never appears during an authenticated-style startup.

## 2. Complete current hero catalog

- Added **Hirara**, the current Hero 133, as an Assassin/Jungler.
- Added **Alpha**, which was also absent from the previous Draft Lab pool.
- Draft Lab now contains **133/133 hero portraits**.
- Added `/heroes/hirara.webp` and `/heroes/alpha.webp`.
- All 133 portraits were regenerated to exactly **180 × 180 pixels**.
- Every portrait uses the same crop, dimensions, background treatment and WebP encoding.
- Removed lazy loading inside the picker so visible cards do not briefly appear blank while scrolling.
- Automated browser tests confirm all 133 images have loaded with a non-zero natural width.

## 3. Region-aware dark mode

Dark mode is now the default authenticated experience and can be changed at any time.

### Regional ambient palettes

- **MPL Malaysia:** deep navy, electric blue and restrained championship gold ambient light.
- **MPL Indonesia:** near-black navy with crimson and muted magenta ambient light.
- **MPL Philippines:** deep royal navy with blue and warm gold ambient light.

The ambient treatment appears behind the workspace rather than overpowering content.

### Updated areas

- Sidebar and navigation
- Top bar and profile menu
- Dashboard and prediction cards
- Teams & Players directory
- Fixtures and standings
- Live Draft Lab panels
- Playoff seed studio and bracket
- Forms, inputs, selects and secondary actions
- Mobile drawer and mobile navigation

### Controls

- Desktop: theme button in the top bar.
- Mobile: theme control inside the navigation drawer.
- User choice is stored in `fmpl_color_mode` and survives reloads.
- Light mode remains available.

## Verification

- TypeScript: passed
- Asset audit: **133/133 heroes**
- Production build: passed
- Desktop test suite: all applicable tests passed
- Mobile test suite: all applicable tests passed after the mobile drawer theme-control test
- Auth startup flash regression test: passed on desktop and mobile
- Hero image loading test: passed
- npm production audit: 0 vulnerabilities

Player portrait coverage remains:

- MPL MY: 50/50
- MPL ID: 60/61
- MPL PH: 37/40

Still intentionally pending because no verified individual image was available: Cull, Vin, Zehn and Miguel.

## Installation with GitHub Desktop

1. Fetch and pull your latest `main`.
2. Create a branch named `startup-darkmode-fix`.
3. Extract `Fantasy-MPL-startup-heroes-darkmode.zip`.
4. Copy every file and folder inside it into the repository, replacing matches.
5. Review the changes in GitHub Desktop.
6. Commit: `Fix startup flash and add regional dark mode`.
7. Push and wait for the green GitHub check.
8. Test the Vercel Preview:
   - returning-user startup;
   - desktop theme switch;
   - mobile drawer theme switch;
   - `/live-draft`, including Alpha and Hirara;
   - all three regional dashboards.
9. Merge into `main` after verification.

No Supabase SQL migration or new Vercel variable is required for this update.
