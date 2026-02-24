import { test, expect } from '@playwright/test';

/**
 * EPAM Client Work navigation test
 * Steps:
 * 1. Navigate to https://www.epam.com/
 * 2. Select "Services" from the header menu
 * 3. Click the "Explore Our Client Work" link
 * 4. Verify that the "Client Work" text is visible on the page
 *
 * Notes:
 * - Uses resilient locators (getByRole / text locators)
 * - Waits for networkidle where appropriate for stability
 */

test.describe('EPAM Client Work navigation', () => {
  test('should navigate from Services to Client Work and verify visibility', async ({ page }) => {
    // Navigate to EPAM homepage
    await page.goto('https://www.epam.com/', { waitUntil: 'networkidle' });

    // Locate the "Services" entry in the header. Try link first, fallback to button if needed.
    let servicesLocator = page.getByRole('link', { name: /Services/i });
    if (await servicesLocator.count() === 0) {
      servicesLocator = page.getByRole('button', { name: /Services/i });
    }

    // Click Services to reveal the submenu or navigate
    await servicesLocator.first().click();

    // Locate the "Explore Our Client Work" link using a case-insensitive regex
    let exploreLocator = page.getByRole('link', { name: /Explore Our Client Work/i });
    // Some pages may render the link as plain text or a different role. Fallback to text locator.
    if (await exploreLocator.count() === 0) {
      exploreLocator = page.locator('text=/Explore\\s*Our\\s*Client\\s*Work/i');
    }

    // Click the Explore Our Client Work link
    await exploreLocator.first().click();

    // Wait for navigation/load
    await page.waitForLoadState('networkidle');

    // Verify that the "Client Work" text is visible on the page
    const clientWorkHeading = page.getByText(/Client Work/i);
    await expect(clientWorkHeading).toBeVisible({ timeout: 10000 });
  });
});
