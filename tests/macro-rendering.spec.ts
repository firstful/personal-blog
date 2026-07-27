import { test, expect } from '@playwright/test';

// Blog posts known to use forum_post and persona_profile macros.
// Adding more here is the fastest way to catch regressions.
const BLOG_POSTS = [
  '/blog/opinions/it-works-on-my-machine/',
  '/blog/opinions/let-your-infrastructure-be-boring/',
  '/blog/opinions/code-review-when-ai-writes-first-draft/',
  '/blog/opinions/configuration-as-code-is-a-lie/',
  '/blog/daily/2026-07-21-github-code-quality-paywall/',
  '/blog/daily/2026-07-22-american-ai-locked-down-losing/',
  '/blog/daily/2026-07-25-open-weight-ai-letter/',
  '/blog/daily/2026-07-26-chatgpt-global-outage/',
  '/blog/daily/2026-07-24-us-army-unlimited-ai-tokens/',
];

const PERSONA_PROFILES = [
  '/personas/kernel_panic/',
  '/personas/hype_cycle/',
  '/personas/ffiltus/',
  '/personas/cobol_kid/',
];

test.describe('Macro rendering', () => {
  for (const path of BLOG_POSTS) {
    test(`blog post renders without macro error: ${path}`, async ({ page }) => {
      await page.goto(path);
      // The macro error banner is injected by mkdocs-macros when a Jinja
      // template fails.  Its presence means the page is broken.
      await expect(page.locator('.macro-rendering-error, .admonition-title:has-text("Macro Rendering Error")')).toHaveCount(0);
      // Forum posts must exist and contain the persona color CSS variable.
      const posts = page.locator('.forum-post');
      const count = await posts.count();
      expect(count).toBeGreaterThan(0);
      // Each post must have a persona-color style set.
      for (let i = 0; i < count; i++) {
        const style = await posts.nth(i).getAttribute('style');
        expect(style).toMatch(/--persona-color:/);
      }
    });
  }

  for (const path of PERSONA_PROFILES) {
    test(`persona profile renders without macro error: ${path}`, async ({ page }) => {
      await page.goto(path);
      await expect(page.locator('.macro-rendering-error, .admonition-title:has-text("Macro Rendering Error")')).toHaveCount(0);
      // Profile page should have persona profile content.
      await expect(page.locator('.forum-post')).toHaveCount(1);
    });
  }
});
