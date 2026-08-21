import { expect, test } from '@playwright/test';

test.describe('public experience', () => {
  test('registration page renders core identity and controls', async ({ page, request }) => {
    const initial = await request.get('/');
    const initialMarkup = await initial.text();
    expect(initialMarkup).toContain('PREPARING YOUR ARENA');
    expect(initialMarkup).not.toContain('CREATE YOUR MANAGER PROFILE');
    await page.goto('/');
    await expect(page).toHaveTitle(/Fantasy MPL/i);
    await expect(page.getByRole('heading', { name: /Build your roster/i })).toBeVisible();
    await expect(page.getByRole('button', { name: 'CREATE ACCOUNT', exact: true })).toBeVisible();
    await expect(page.getByRole('button', { name: 'SIGN IN', exact: true })).toBeVisible();
    await expect(page.getByLabel(/AGE AND GUARDIAN CONFIRMATION/i)).toBeVisible();
    await expect(page.getByText('SEASON 18 TEAM SHOWCASE')).toBeVisible();
  });

  test('local fallback registration reaches regional onboarding', async ({ page }) => {
    await page.goto('/');
    await page.getByLabel('FULL NAME *').fill('Fantasy Test Manager');
    await page.getByLabel('MANAGER NAME *').fill('TestManager');
    await page.getByLabel('EMAIL ADDRESS').fill('test@example.com');
    await page.getByLabel('PASSWORD').fill('test-password');
    await page.getByLabel('COUNTRY').selectOption('MY');
    await page.getByLabel(/AGE AND GUARDIAN CONFIRMATION/i).check();
    await page.getByRole('button', { name: /CREATE ACCOUNT →/ }).click();

    await expect(page.getByRole('heading', { name: 'CHOOSE YOUR BATTLEGROUND' })).toBeVisible();
    await page.getByRole('button', { name: /MPL Malaysia/i }).click();
    await expect(page.getByText(/WELCOME BACK, TESTMANAGER/i)).toBeVisible();
    await expect(page.getByText('1,248', { exact: true })).toHaveCount(0);
    await expect(page.getByText('#284', { exact: true })).toHaveCount(0);
    await expect(page.getByText('Borneo Rivals', { exact: true })).toHaveCount(0);
    await expect(page.getByText(/NO VERIFIED DATA/i)).toBeVisible();
  });

  test('authenticated startup never flashes login and dark mode persists', async ({ page, isMobile }) => {
    await page.addInitScript(() => {
      (window as unknown as { __sawLogin: boolean }).__sawLogin = false;
      new MutationObserver(() => {
        if (document.body?.innerText.includes('CREATE YOUR MANAGER PROFILE')) {
          (window as unknown as { __sawLogin: boolean }).__sawLogin = true;
        }
      }).observe(document, { subtree: true, childList: true, characterData: true });
      localStorage.setItem('fmpl_session', JSON.stringify({
        dataVersion: 4, name: 'StartupManager', email: 'startup@example.com', country: 'MY',
        fullName: 'Startup Test Manager', address: '', bio: '', dob: '', avatar: '', termsAccepted: true,
        accountRole: 'user', joined: ['MY'], active: 'MY', picks: {}, exactScores: {}, submittedAt: {}, captains: {}, rosters: {}, transfers: {}
      }));
    });
    await page.goto('/my');
    await expect(page.getByText(/WELCOME BACK, STARTUPMANAGER/i)).toBeVisible();
    expect(await page.evaluate(() => (window as unknown as { __sawLogin: boolean }).__sawLogin)).toBeFalsy();
    await expect(page.locator('.shell')).toHaveClass(/darkMode/);
    if (isMobile) await page.getByRole('button', { name: 'Open navigation' }).click();
    await page.getByRole('button', { name: 'Switch to light mode' }).click();
    await expect(page.locator('.shell')).toHaveClass(/lightMode/);
    await page.reload();
    await expect(page.locator('.shell')).toHaveClass(/lightMode/);
    if (isMobile) await page.getByRole('button', { name: 'Open navigation' }).click();
    await page.getByRole('button', { name: 'Switch to dark mode' }).click();
    await expect(page.locator('.shell')).toHaveClass(/darkMode/);
  });

  test('regional entry lanes and cached model endpoint are available', async ({ page, request }) => {
    for (const route of ['/my', '/id', '/ph']) {
      const response = await request.get(route);
      expect(response.status()).toBe(200);
    }
    await page.goto('/my');
    await expect(page.getByRole('heading', { name: /Build your roster/i })).toBeVisible();
    const model = await request.get('/api/draft-model?region=MY');
    expect(model.status()).toBe(200);
    const payload = await model.json();
    expect(payload.status.region).toBe('MY');
    expect(Array.isArray(payload.metrics)).toBeTruthy();
  });

  test('custom playoffs stay editable and official predictor exposes its countdown', async ({ page, request }) => {
    await page.addInitScript(() => {
      localStorage.setItem('fmpl_session', JSON.stringify({
        dataVersion: 4,
        name: 'BracketManager',
        email: 'bracket@example.com',
        country: 'MY',
        fullName: 'Bracket Test Manager',
        address: '', bio: '', dob: '', avatar: '', termsAccepted: true,
        accountRole: 'user', joined: ['MY'], active: 'MY',
        picks: {}, exactScores: {}, submittedAt: {}, captains: {}, rosters: {}, transfers: {}
      }));
    });
    await page.goto('/my#playoffs');
    await expect(page.getByRole('heading', { name: /Road to the Grand Final/i })).toBeVisible();
    await expect(page.locator('.seedPickerCard')).toHaveCount(6);
    const seedOne = page.getByLabel('Seed 1');
    const alternate = await seedOne.locator('option').last().getAttribute('value');
    await seedOne.selectOption(alternate!);
    await expect(seedOne).toHaveValue(alternate!);
    await expect(page.getByRole('button', { name: 'SAVE CUSTOM BRACKET' })).toBeVisible();
    await expect(page.getByRole('button', { name: /LOCK OFFICIAL PREDICTION/i })).toHaveCount(0);
    const seedSummary = page.locator('.bracketScroll + .seedingSummary');
    await expect(seedSummary).toHaveCount(1);
    await expect(seedSummary.locator('.seedingSummaryGrid article')).toHaveCount(6);
    const summaryWidth = await seedSummary.evaluate(element => ({
      clientWidth: element.clientWidth,
      scrollWidth: element.scrollWidth
    }));
    expect(summaryWidth.scrollWidth).toBeLessThanOrEqual(summaryWidth.clientWidth + 1);

    await page.getByRole('button', { name: /OFFICIAL PREDICTOR/i }).click();
    await expect(page.getByRole('heading', { name: /Official Predictor Opens Soon/i })).toBeVisible();
    await expect(page.locator('.playoffCountdown')).toBeVisible();
    await expect(page.getByRole('button', { name: /BUILD A CUSTOM BRACKET NOW/i })).toBeVisible();

    const access = await request.get('/api/playoff-access?region=MY');
    expect(access.status()).toBe(200);
    expect((await access.json()).server_now).toBeTruthy();
  });

  test('every open match requires winner and exact score', async ({ page, isMobile }) => {
    test.skip(Boolean(isMobile), 'Desktop flow is automated; mobile scoring remains covered by manual beta QA.');
    // Mandatory BO score validation is also enforced server-side by
    // public.validate_mandatory_match_score() in Migration 013.
    await page.addInitScript(() => {
      localStorage.setItem('fmpl_session', JSON.stringify({
        dataVersion: 4,
        name: 'PredictionManager',
        email: 'prediction@example.com',
        country: 'MY',
        fullName: 'Prediction Test Manager',
        address: '',
        bio: '',
        dob: '',
        avatar: '',
        accountRole: 'user',
        joined: ['MY'],
        active: 'MY',
        picks: {},
        exactScores: {},
        submittedAt: {},
        captains: {},
        rosters: {},
        transfers: {}
      }));
    });

    await page.goto('/');
    await expect(page.locator('.heroActions .primary')).toBeVisible();
    await page.locator('.heroActions .primary').click();
    await expect(page.locator('.fullMatch').first()).toBeVisible();

    const submit = page.locator('.saveBar .primary');
    await expect(submit).toBeDisabled();

    const matches = page.locator('.fullMatch:not(.matchLocked)');
    const matchCount = await matches.count();
    expect(matchCount).toBeGreaterThan(0);

    for (let index = 0; index < matchCount; index++) {
      const match = matches.nth(index);
      await match.locator('.winnerControls button').first().click();
      await expect(match.locator('.mandatoryScore button').first()).toBeEnabled();
      await match.locator('.mandatoryScore button').first().click();
    }

    await page.locator('.mvpCard:not(:disabled)').first().click();
    await expect(submit).toBeEnabled();
  });

  test('profile save waits for confirmation and survives refresh', async ({ page, isMobile }) => {
    test.skip(Boolean(isMobile), 'Desktop persistence flow is sufficient for local fallback coverage.');
    await page.addInitScript(() => { if (!localStorage.getItem('fmpl_session')) localStorage.setItem('fmpl_session', JSON.stringify({
      dataVersion:4,name:'ProfileManager',email:'profile@example.com',country:'MY',fullName:'Profile Test Manager',
      address:'',bio:'',dob:'',avatar:'',accountRole:'user',joined:['MY'],active:'MY',picks:{},exactScores:{},
      submittedAt:{},captains:{},rosters:{},transfers:{}
    })); });
    await page.goto('/my#profile');
    await page.getByLabel('MANAGER NAME').fill('SavedManager');
    await page.getByLabel(/BIO · OPTIONAL/i).fill('Verified local persistence test.');
    await page.getByRole('button', { name: 'SAVE PROFILE CHANGES' }).click();
    await expect(page.getByText(/Profile updated and confirmed/i)).toBeVisible();
    await page.reload();
    await expect(page.getByLabel('MANAGER NAME')).toHaveValue('SavedManager');
    await expect(page.getByLabel(/BIO · OPTIONAL/i)).toHaveValue('Verified local persistence test.');
  });

  test('active section survives a full page refresh', async ({ page }) => {
    await page.addInitScript(() => {
      localStorage.setItem('fmpl_session', JSON.stringify({
        dataVersion: 4,
        name: 'RefreshManager',
        email: 'refresh@example.com',
        country: 'MY',
        fullName: 'Refresh Test Manager',
        address: '', bio: '', dob: '', avatar: '', accountRole: 'user',
        joined: ['MY'], active: 'MY', picks: {}, exactScores: {},
        submittedAt: {}, captains: {}, rosters: {}, transfers: {}
      }));
    });
    await page.goto('/my#predictions');
    await expect(page.getByRole('heading', { name: 'Prediction Hub' })).toBeVisible();
    await page.reload();
    await expect(page).toHaveURL(/\/my#predictions$/);
    await expect(page.getByRole('heading', { name: 'Prediction Hub' })).toBeVisible();
  });

  test('public Live Draft Lab records a legal draft action without login', async ({ page }) => {
    await page.goto('/live-draft');
    await expect(page.getByRole('heading', { name: /Build the draft/i })).toBeVisible();
    await expect.poll(() => page.evaluate(() => performance.getEntriesByType('resource').some(entry => entry.name.includes('/api/draft-model')))).toBeTruthy();
    await page.getByRole('button', { name: 'BAN slot 1', exact: true }).first().click();
    const heroPortraits = page.locator('.heroGrid .heroPortrait img');
    await expect(heroPortraits).toHaveCount(133);
    await expect.poll(() => heroPortraits.evaluateAll(images => images.every(image => (image as HTMLImageElement).naturalWidth > 0))).toBeTruthy();
    const hirara = page.getByRole('button', { name: /HIRARA.*JUNGLE/i });
    await hirara.scrollIntoViewIfNeeded();
    await expect(hirara).toBeVisible();
    await expect(hirara.locator('img')).toHaveAttribute('src', /\/heroes\/hirara\.webp$/);
    const atlas = page.getByRole('button', { name: /ATLAS.*ROAM/i });
    await expect(atlas.locator('img')).toHaveAttribute('src', /\/heroes\/atlas\.webp$/);
    await atlas.click();
    const selectedAtlas = page.getByRole('button', { name: /BAN slot 1: ATLAS/i });
    await expect(selectedAtlas).toBeVisible();
    await expect(selectedAtlas.locator('img')).toHaveAttribute('src', /\/heroes\/atlas\.webp$/);
    await expect(page.getByText(/Powered by MLBB Public Data API/i)).toBeVisible();
    await expect(page.locator('.draftTurn > span')).toHaveText('RED SIDE');
  });

  test('completed generic draft reveals an evidence-gated report', async ({ page, isMobile }) => {
    test.skip(Boolean(isMobile), 'Desktop report validates the shared completed-draft component.');
    await page.addInitScript(() => localStorage.setItem('fmpl_draft_tool', JSON.stringify({ firstSide:'BLUE', mode:'companion', actions:['AAMON','AKAI','ALDOUS','ALICE','ALUCARD','ANGELA','ARGUS','ARLOTT','ATLAS','AULUS','AURORA','BADANG','BALMOND','BANE','BARATS','BAXIA','BEATRIX','BELERICK','BENEDETTA','BRODY'] })));
    await page.goto('/live-draft');
    await expect(page.getByRole('heading', { name: 'Draft Report' })).toBeVisible();
    await expect(page.getByText(/MODEL LIMITATION/i)).toBeVisible();
    await expect(page.locator('.draftTimeline span')).toHaveCount(20);
  });

  test('policy pages and metadata routes are available', async ({ page, request }) => {
    for (const route of ['/privacy', '/terms', '/rules', '/community-guidelines']) {
      const response = await page.goto(route);
      expect(response?.status()).toBe(200);
      await expect(page.locator('h1')).toBeVisible();
    }

    for (const route of ['/robots.txt', '/sitemap.xml', '/manifest.webmanifest', '/icon.png', '/favicon.ico']) {
      const response = await request.get(route);
      expect(response.status()).toBe(200);
    }

    await page.goto('/');
    await expect(page.locator('link[rel="canonical"]')).toHaveAttribute('href', /^https:\/\//);
  });

  test('PandaScore synchronization endpoint rejects unauthenticated callers', async ({ request }) => {
    expect((await request.get('/api/integrations/pandascore/sync')).status()).toBe(401);
    expect((await request.post('/api/integrations/pandascore/sync')).status()).toBe(401);
  });

  test('security headers are attached to application pages', async ({ request }) => {
    const response = await request.get('/');
    expect(response.headers()['content-security-policy']).toContain("default-src 'self'");
    expect(response.headers()['x-content-type-options']).toBe('nosniff');
    expect(response.headers()['x-frame-options']).toBe('DENY');
    expect(response.headers()['referrer-policy']).toBe('strict-origin-when-cross-origin');
  });
});
