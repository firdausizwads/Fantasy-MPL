import { expect, test } from '@playwright/test';

async function enterLocalDashboard(page: import('@playwright/test').Page) {
  await page.goto('/');
  await page.getByLabel('FULL NAME *').fill('Mobile Test Manager');
  await page.getByLabel('MANAGER NAME *').fill('MobileManager');
  await page.getByLabel('EMAIL ADDRESS').fill('mobile@example.com');
  await page.getByLabel('PASSWORD').fill('test-password');
  await page.getByLabel('COUNTRY').selectOption('PH');
  await page.getByLabel(/AGE AND GUARDIAN CONFIRMATION/i).check();
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

  test('mobile hero picker scrolls through the complete catalog without auto zoom', async ({ page }) => {
    await page.goto('/live-draft');
    await page.getByRole('button', { name: 'BAN slot 1', exact: true }).first().click();
    const picker = page.locator('.guidedHeroPicker');
    await expect(picker).toBeVisible();
    await expect(picker.locator('.heroPortrait img')).toHaveCount(131);
    await expect(picker.locator('.heroPortrait img').first()).toHaveAttribute('src', /\/heroes\/.+\.webp$/);
    await expect(page.locator('.heroPickerTools input')).not.toBeFocused();
    await expect(page.locator('.heroPickerTools input')).toHaveCSS('font-size', '16px');
    const dimensions = await picker.evaluate(element => ({ scrollHeight: element.scrollHeight, clientHeight: element.clientHeight }));
    expect(dimensions.scrollHeight).toBeGreaterThan(dimensions.clientHeight);
    await picker.evaluate(element => { element.scrollTop = element.scrollHeight; });
    await expect(page.getByRole('button', { name: /ZILONG.*EXP/i })).toBeVisible();
  });

  test('mobile navigation opens Live Draft Lab and hides deferred leagues', async ({ page }) => {
    await enterLocalDashboard(page);
    await page.getByRole('button', { name: 'Open navigation' }).click();
    const drawer = page.locator('.mobileDrawer');
    await expect(drawer.getByRole('button', { name: /My Leagues/i })).toHaveCount(0);
    await drawer.getByRole('button', { name: /Live Draft Lab/i }).click();
    await expect(page.getByRole('heading', { name: /Build the draft/i })).toBeVisible();
    await expect(page.getByRole('button', { name: /DRAFT/i }).first()).toBeVisible();
    await page.getByRole('button', { name: 'MODEL', exact: true }).click();
    await expect(page.getByText(/Recommendation data pending/i)).toBeVisible();
  });
});
