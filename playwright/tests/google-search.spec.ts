import { test, expect } from '@playwright/test';

test.describe('Google search', () => {
  test('searches for hello', async ({ page }) => {
    // Navigate to Google
    await page.goto('https://www.google.com/', { waitUntil: 'domcontentloaded' });

    // Handle cookie/consent if present (try common button texts)
    const consentButtons = [
      'button:has-text("I agree")',
      'button:has-text("Accept all")',
      'button:has-text("Accept")',
      'text=I agree',
      'text=Agree',
    ];

    for (const sel of consentButtons) {
      const btn = page.locator(sel);
      if (await btn.count() > 0) {
        await btn.first().click().catch(() => {});
        break;
      }
    }

    // Type into the search box and submit
    await page.fill('input[name="q"]', 'hello');
    await page.keyboard.press('Enter');

    // Wait for results and assertions
    await page.waitForSelector('#search, div#rso', { timeout: 5000 });
    await expect(page.locator('input[name="q"]')).toHaveValue('hello');
    await expect(page.locator('#search, div#rso')).toBeVisible();
  });
});
