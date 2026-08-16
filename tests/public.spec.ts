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
  });

  test('every open match requires winner and exact score', async ({ page }) => {
    await page.goto('/');
    await page.getByLabel('FULL NAME *').fill('Prediction Test Manager');
    await page.getByLabel('MANAGER NAME *').fill('PredictionManager');
    await page.getByLabel('EMAIL ADDRESS').fill('prediction@example.com');
    await page.getByLabel('PASSWORD').fill('test-password');
    await page.getByLabel('COUNTRY').selectOption('MY');
    await page.getByRole('button', { name: /CREATE ACCOUNT →/ }).click();
    await page.getByRole('button', { name: /MPL Malaysia/i }).click();
    await page.getByRole('button', { name: /Make this week's picks/i }).click();

    const submit = page.getByRole('button', { name: /SUBMIT PREDICTIONS/i });
    await expect(submit).toBeDisabled();

    const matches = page.locator('.fullMatch');
    for (let index = 0; index < await matches.count(); index++) {
      const match = matches.nth(index);
      await match.locator('.winnerControls button').first().click();
      await match.locator('.mandatoryScore button').first().click();
    }

    await page.locator('.mvpCard').first().click();
    await expect(submit).toBeEnabled();
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

  test('security headers are attached to application pages', async ({ request }) => {
    const response = await request.get('/');
    expect(response.headers()['content-security-policy']).toContain("default-src 'self'");
    expect(response.headers()['x-content-type-options']).toBe('nosniff');
    expect(response.headers()['x-frame-options']).toBe('DENY');
    expect(response.headers()['referrer-policy']).toBe('strict-origin-when-cross-origin');
  });
});
