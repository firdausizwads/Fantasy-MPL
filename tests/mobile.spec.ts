import { expect, test } from '@playwright/test';

async function enterLocalDashboard(page: import('@playwright/test').Page) {
  await page.goto('/');
  await page.getByLabel('FULL NAME *').fill('Mobile Test Manager');
  await page.getByLabel('MANAGER NAME *').fill('MobileManager');
  await page.getByLabel('EMAIL ADDRESS').fill('mobile@example.com');
  await page.getByLabel('PASSWORD').fill('test-password');
  await page.getByLabel('COUNTRY').selectOption('PH');
  await page.getByRole('button', { name: /CREATE ACCOUNT →/ }).click();
  await page.getByRole('button', { name: /MPL Philippines/i }).click();
  await expect(page.getByText(/WELCOME BACK, MOBILEMANAGER/i)).toBeVisible();
}

test.describe('mobile navigation', () => {
  test.skip(({ isMobile }) => !isMobile, 'Mobile project only');

  test('drawer exposes grouped navigation and hides admin for regular users', async ({ page }) => {
    await enterLocalDashboard(page);
    await page.getByRole('button', { name: 'Open navigation' }).click();
    const drawer = page.locator('.mobileDrawer');
    await expect(drawer.getByText('PLAY', { exact: true })).toBeVisible();
    await expect(drawer.getByText('COMPETE', { exact: true })).toBeVisible();
    await expect(drawer.getByText('COMMUNITY', { exact: true })).toBeVisible();
    await expect(drawer.getByText('ACCOUNT', { exact: true })).toBeVisible();
    await expect(drawer.getByRole('button', { name: /Admin Console/i })).toHaveCount(0);
  });

  test('mobile league cards retain their open action', async ({ page }) => {
    await enterLocalDashboard(page);
    await page.getByRole('button', { name: 'Open navigation' }).click();
    await page.getByRole('button', { name: /My Leagues/i }).click();
    await expect(page.getByRole('heading', { name: /Play with your people/i })).toBeVisible();

    await page.getByRole('button', { name: /Create private league/i }).click();
    await page.getByLabel('LEAGUE NAME').fill('Mobile Rivals');
    await page.getByRole('button', { name: /Create league & get invite code/i }).click();
    await page.locator('.leagueRoom .close').click();

    await expect(page.getByRole('button', { name: /Open league/i })).toBeVisible();
  });
});
