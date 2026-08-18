import { expect, test } from '@playwright/test';

test.describe('public experience', () => {
  test('registration page renders core identity and controls', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveTitle(/Fantasy MPL/i);
    await expect(page.getByRole('heading', { name: /Build your roster/i })).toBeVisible();
    await expect(page.getByRole('button', { name: 'CREATE ACCOUNT', exact: true })).toBeVisible();
    await expect(page.getByRole('button', { name: 'SIGN IN', exact: true })).toBeVisible();
    await expect(page.getByText('SEASON 18 TEAM SHOWCASE')).toBeVisible();
  });

  test('local fallback registration reaches regional onboarding', async ({ page }) => {
    await page.goto('/');
    await page.getByLabel('FULL NAME *').fill('Fantasy Test Manager');
    await page.getByLabel('MANAGER NAME *').fill('TestManager');
    await page.getByLabel('EMAIL ADDRESS').fill('test@example.com');
    await page.getByLabel('PASSWORD').fill('test-password');
    await page.getByLabel('COUNTRY').selectOption('MY');
    await page.getByRole('button', { name: /CREATE ACCOUNT →/ }).click();

    await expect(page.getByRole('heading', { name: 'CHOOSE YOUR BATTLEGROUND' })).toBeVisible();
    await page.getByRole('button', { name: /MPL Malaysia/i }).click();
    await expect(page.getByText(/WELCOME BACK, TESTMANAGER/i)).toBeVisible();
    await expect(page.getByText('1,248', { exact: true })).toHaveCount(0);
    await expect(page.getByText('#284', { exact: true })).toHaveCount(0);
    await expect(page.getByText('Borneo Rivals', { exact: true })).toHaveCount(0);
    await expect(page.getByText(/NO VERIFIED DATA/i)).toBeVisible();
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
    await page.getByRole('button', { name: /ATLAS.*ROAM/i }).click();
    await expect(page.getByRole('button', { name: /BAN slot 1: ATLAS/i })).toBeVisible();
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

    for (const route of ['/robots.txt', '/sitemap.xml', '/manifest.webmanifest', '/icon.png']) {
      const response = await request.get(route);
      expect(response.status()).toBe(200);
    }
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
