/**
 * Candidate Search Terminal — Playwright tests
 *
 * Run against prod:     npx playwright test
 * Run against local:   BASE_URL=http://localhost:8000 npx playwright test
 * Run in UI mode:      npx playwright test --ui
 * Run a single test:   npx playwright test -g "splash screen"
 */

import { test, expect } from '@playwright/test';
import {
  navigateToTerminal,
  selectOption,
  waitForEcho,
  waitForMatch,
  expectQuestion,
  expectMatchRole,
  expectRecruiterBadge,
  expectNoRecruiterBadge,
  clickRestart,
  setupConsoleCapture,
  expectNoJsErrors,
} from './helpers';

// Every test navigates to page; on a fresh session the full BBS boot
// animation plays (~4-6s). Use test.describe.configure to give it room.
// --------------------------------------------------------------------
// Boot & Splash
// --------------------------------------------------------------------

test.describe('Boot & Splash', () => {
  test('splash screen loads on page visit', async ({ page }) => {
    const msgs = setupConsoleCapture(page);
    await navigateToTerminal(page);
    expectNoJsErrors(msgs);
  });

  test('skips preamble — first question is "who" step', async ({ page }) => {
    await navigateToTerminal(page);
    await expectQuestion(page, 'Are you hiring on behalf of a company');
  });

  test('first step has exactly 2 options', async ({ page }) => {
    await navigateToTerminal(page);
    const options = page.locator('#cs-screen .cs-option');
    await expect(options).toHaveCount(2);
  });

  test('options contain expected labels', async ({ page }) => {
    await navigateToTerminal(page);
    await expect(page.locator('#cs-screen .cs-option').nth(0)).toContainText('Yes — I recruit');
    await expect(page.locator('#cs-screen .cs-option').nth(1)).toContainText('No — hiring manager / tech lead');
  });

  test('first option is highlighted by default', async ({ page }) => {
    await navigateToTerminal(page);
    const caret = page.locator('#cs-screen .cs-option').nth(0).locator('.cs-caret');
    await expect(caret).toHaveText('>');
  });

  test('hint text is visible', async ({ page }) => {
    await navigateToTerminal(page);
    await expect(page.locator('#cs-screen .cs-hint')).toContainText('[↑/↓] move');
  });
});

// --------------------------------------------------------------------
// Keyboard Navigation
// --------------------------------------------------------------------

test.describe('Keyboard Navigation', () => {
  test('arrow down moves cursor to second option', async ({ page }) => {
    await navigateToTerminal(page);
    await page.keyboard.press('ArrowDown');
    await expect(page.locator('#cs-screen .cs-option').nth(1).locator('.cs-caret')).toHaveText('>');
  });

  test('arrow up wraps to last option', async ({ page }) => {
    await navigateToTerminal(page);
    await page.keyboard.press('ArrowUp');
    await expect(
      page.locator('#cs-screen .cs-option').nth(1).locator('.cs-caret')
    ).toHaveText('>');
  });

  test('j key moves down (vim-style)', async ({ page }) => {
    await navigateToTerminal(page);
    await page.keyboard.press('j');
    await expect(page.locator('#cs-screen .cs-option').nth(1).locator('.cs-caret')).toHaveText('>');
  });

  test('k key moves up (vim-style)', async ({ page }) => {
    await navigateToTerminal(page);
    await page.keyboard.press('j');
    await page.keyboard.press('k');
    await expect(page.locator('#cs-screen .cs-option').nth(0).locator('.cs-caret')).toHaveText('>');
  });

  test('space key selects highlighted option', async ({ page }) => {
    await navigateToTerminal(page);
    await page.keyboard.press(' ');
    await waitForEcho(page);
    // After selecting the first option (Yes — I recruit), should move to next question
    await expectQuestion(page, 'Does your team currently need');
  });
});

// --------------------------------------------------------------------
// Flow: Hiring Manager → Needs → Backend Developer
// --------------------------------------------------------------------

test.describe('Flow: Hiring Manager → Needs → Backend Developer', () => {
  test('completes full path to match', async ({ page }) => {
    const msgs = setupConsoleCapture(page);
    await navigateToTerminal(page);

    // Q1: Who are you? → Hiring manager
    await selectOption(page, 'hiring manager');
    await waitForEcho(page);

    // Q2: Need another engineer? → Yes
    await expectQuestion(page, 'Does your team currently need');
    await selectOption(page, 'Yes');
    await waitForEcho(page);

    // Q3: What is your team missing? → Backend
    await expectQuestion(page, 'What is your team missing');
    await selectOption(page, 'Backend that stops falling over');
    await waitForEcho(page);

    // Match result
    await waitForMatch(page);
    await expectMatchRole(page, 'Backend Developer');
    await expectNoRecruiterBadge(page);

    // Verify dossier contents
    await expect(page.locator('#cs-screen .cs-match-id')).toContainText('Reed Sutliff');
    await expect(page.locator('#cs-screen .cs-match-id')).toContainText('AVAILABLE');
    await expect(page.locator('#cs-screen .cs-match-id')).toContainText('Columbus, OH');
    await expect(page.locator('#cs-screen .cs-match-id')).toContainText('98%');

    // Verify resume download link
    await expect(page.locator('#cs-screen a.cs-btn.primary')).toContainText('download resume');

    // Verify no anonymized resume (not a recruiter)
    await expect(page.locator('#cs-restart')).toBeVisible();
    await expect(page.locator('#cs-screen a[href*="anon"]')).toHaveCount(0);

    // Verify email link
    await expect(page.locator('#cs-screen a[href^="mailto:"]')).toContainText('email me');

    // Verify restart button
    await expect(page.locator('#cs-restart')).toBeVisible();

    expectNoJsErrors(msgs);
  });
});

// --------------------------------------------------------------------
// Flow: Recruiter → No → Convinced → Full-Stack Developer
// --------------------------------------------------------------------

test.describe('Flow: Recruiter → No → Convinced → Full-Stack Developer', () => {
  test('recruiter path shows recruiter badge and anon resume', async ({ page }) => {
    await navigateToTerminal(page);

    // Q1: → Recruiter
    await selectOption(page, 'Yes — I recruit');
    await waitForEcho(page);

    // Q2: Need engineer? → No
    await expectQuestion(page, 'Does your team currently need');
    await selectOption(page, 'No');
    await waitForEcho(page);

    // Q3: But would you want one? → Yes, fair point
    await expectQuestion(page, 'would you');
    await selectOption(page, 'Yes, fair point');
    await waitForEcho(page);

    // Q4: Role → Full-Stack
    await expectQuestion(page, 'What is your team missing');
    await selectOption(page, 'A whole feature built end-to-end');
    await waitForEcho(page);

    // Match
    await waitForMatch(page);
    await expectMatchRole(page, 'Full-Stack Developer');
    await expectRecruiterBadge(page);

    // Anonymized resume link present for recruiters
    await expect(page.locator('#cs-screen a[href*="anon"]')).toContainText('anonymized');
  });
});

// --------------------------------------------------------------------
// Flow: Double-convince path (No → No → OK)
// --------------------------------------------------------------------

test.describe('Flow: Double-convince path', () => {
  test('fully unconvinced user gets convinced through two rounds', async ({ page }) => {
    await navigateToTerminal(page);

    // Q1: → Hiring manager
    await selectOption(page, 'hiring manager');
    await waitForEcho(page);

    // Q2: Need engineer? → No
    await selectOption(page, 'No');
    await waitForEcho(page);

    // Q3: Would you want one? → No (second No)
    await expectQuestion(page, 'would you');
    await selectOption(page, 'No');
    await waitForEcho(page);

    // Q4 (convince2): What if the search is already done? → "Okay, you have my attention"
    await expectQuestion(page, 'What if the search');
    await selectOption(page, 'you have my attention');
    await waitForEcho(page);

    // Q5: Role → Agentic Engineer
    await expectQuestion(page, 'What is your team missing');
    await selectOption(page, 'Automation');
    await waitForEcho(page);

    await waitForMatch(page);
    await expectMatchRole(page, 'Agentic Engineer');
  });
});

// --------------------------------------------------------------------
// All Role Variants
// --------------------------------------------------------------------

test.describe('All Role Variants', () => {
  const variants: Array<{ label: string; expected: string; match: string }> = [
    {
      label: 'Backend that stops falling over',
      expected: 'Backend Developer',
      match: 'latency',
    },
    {
      label: 'A whole feature built end-to-end',
      expected: 'Full-Stack Developer',
      match: 'Ships end-to-end',
    },
    {
      label: 'Automation / better dev workflows',
      expected: 'Agentic Engineer',
      match: 'Kills toil',
    },
    {
      label: 'Someone to embed & ship with the team',
      expected: 'Forward-Deployed SWE',
      match: 'Client-facing',
    },
  ];

  for (const v of variants) {
    test(`variant: ${v.expected}`, async ({ page }) => {
      await navigateToTerminal(page);

      // Quick path: hiring manager → Yes → role
      await selectOption(page, 'hiring manager');
      await waitForEcho(page);
      await selectOption(page, 'Yes');
      await waitForEcho(page);

      await expectQuestion(page, 'What is your team missing');
      await selectOption(page, v.label);
      await waitForEcho(page);

      await waitForMatch(page);
      await expectMatchRole(page, v.expected);
      await expect(page.locator('#cs-screen .cs-match-note')).toContainText(v.match);
    });
  }
});

// --------------------------------------------------------------------
// Restart
// --------------------------------------------------------------------

test.describe('Restart', () => {
  test('run again resets terminal to initial question', async ({ page }) => {
    await navigateToTerminal(page);

    // Quick path to match
    await selectOption(page, 'hiring manager');
    await waitForEcho(page);
    await selectOption(page, 'Yes');
    await waitForEcho(page);
    await selectOption(page, 'Backend');
    await waitForEcho(page);
    await waitForMatch(page);

    // Click restart
    await clickRestart(page);

    // Should be back at first question
    await expectQuestion(page, 'Are you hiring on behalf of a company');
    await expect(page.locator('#cs-screen .cs-option')).toHaveCount(2);
  });

  test('restart state is clean — no leftover match content', async ({ page }) => {
    await navigateToTerminal(page);

    // Quick path to match
    await selectOption(page, 'hiring manager');
    await waitForEcho(page);
    await selectOption(page, 'Yes');
    await waitForEcho(page);
    await selectOption(page, 'Someone to embed');
    await waitForEcho(page);
    await waitForMatch(page);

    // Restart
    await clickRestart(page);

    // No match cards should remain
    await expect(page.locator('#cs-screen .cs-match')).toHaveCount(0);
    // Splash should have "session reset" message
    await expect(page.locator('#cs-screen .cs-line.cs-sys').nth(1)).toContainText('session reset');
  });
});

// --------------------------------------------------------------------
// Console & Errors
// --------------------------------------------------------------------

test.describe('Console & Errors', () => {
  test('no page errors during full flow', async ({ page }) => {
    const msgs = setupConsoleCapture(page);
    await navigateToTerminal(page);

    // Run through all steps of the longest path
    await selectOption(page, 'No — hiring manager / tech lead');
    await waitForEcho(page);
    await selectOption(page, 'No');
    await waitForEcho(page);
    await selectOption(page, 'No');
    await waitForEcho(page);
    await selectOption(page, 'Fine, convince me');
    await waitForEcho(page);
    await selectOption(page, 'Automation');
    await waitForEcho(page);
    await waitForMatch(page);

    // Restart
    await clickRestart(page);

    // Run a recruiter path
    await selectOption(page, 'Yes — I recruit');
    await waitForEcho(page);
    await selectOption(page, 'Yes');
    await waitForEcho(page);
    await selectOption(page, 'A whole feature');
    await waitForEcho(page);
    await waitForMatch(page);

    expectNoJsErrors(msgs);
  });

  test('404 on resume PDF link does not break terminal', async ({ page }) => {
    // The resume PDF links point to /assets/resume/{variant}.pdf which may
    // or may not exist in the build. This should not cause JS errors.
    const msgs = setupConsoleCapture(page);
    await navigateToTerminal(page);

    // Fast path to match
    await selectOption(page, 'hiring manager');
    await waitForEcho(page);
    await selectOption(page, 'Yes');
    await waitForEcho(page);
    await selectOption(page, 'Backend');
    await waitForEcho(page);
    await waitForMatch(page);

    // Verify the download link exists and doesn't break the page
    const href = await page.locator('#cs-screen a.cs-btn.primary').getAttribute('href');
    expect(href).toBeTruthy();
    if (href) {
      // Use request API to check the link (goto triggers download on PDF links)
      const resp = await page.request.get(href);
      // PDF might 404 if the asset isn't built — that's OK, just shouldn't break JS
      expect(resp).not.toBeNull();
    }

    expectNoJsErrors(msgs);
  });
});
