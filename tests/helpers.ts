/**
 * Reusable helpers for candidate-search terminal tests.
 */

import { type Page, expect } from '@playwright/test';

/** URL path to the resume / about page */
export const ABOUT_PATH = '/resume/';

/** How long (ms) to wait for typewriter animation to finish a line (~12ms/char * ~50 chars) */
export const TYPE_WAIT = 2000;

/** How long (ms) for the MATCH FOUND animation + progress bar */
export const MATCH_ANIMATION_WAIT = 1500;

/**
 * Navigate to the candidate-search page and wait for it to be ready.
 * Plays through the full BBS boot animation (~4-6s on first visit per session).
 */
export async function navigateToTerminal(page: Page): Promise<void> {
  await page.goto(ABOUT_PATH);
  await waitForTerminal(page);
}

/**
 * Wait for the candidate-search terminal to fully boot:
 * splash header + connection/ready message + first question prompt + options rendered.
 *
 * Handles both initial boot ("connection established") and restart ("session reset").
 */
export async function waitForTerminal(page: Page): Promise<void> {
  // Wait for the terminal screen element
  await page.waitForSelector('#cs-screen', { state: 'attached' });

  // Wait for splash header to appear (typewriter animation finishes)
  await expect(page.locator('#cs-screen .cs-line.cs-sys').first()).toContainText(
    'SUTLIFF TALENT DB v1.0',
    { timeout: 10_000 }
  );

  // Wait for either "connection established" or "session reset" message
  const secondLine = page.locator('#cs-screen .cs-line.cs-sys').nth(1);
  await expect(async () => {
    const text = await secondLine.textContent();
    expect(text).toMatch(/connection established|session reset/);
  }).toPass({ timeout: 10_000 });

  // Wait for options to render (first question available)
  await expect(async () => {
    const opts = page.locator('#cs-screen .cs-options');
    await expect(opts).toBeVisible();
  }).toPass({ timeout: 10_000 });
}

/**
 * Verify the current question prompt text appears in the terminal.
 */
export async function expectQuestion(page: Page, text: string): Promise<void> {
  const prompts = page.locator('#cs-screen .cs-line.cs-prompt');
  await expect(prompts.last()).toContainText(text, { timeout: 3000 });
}

/**
 * Get all visible option labels in the current step.
 */
export async function getOptionLabels(page: Page): Promise<string[]> {
  return page.locator('#cs-screen .cs-opt-label').allTextContents();
}

/**
 * Select an option by its visible label.
 *
 * Uses page.evaluate to find the option and call its click handler directly,
 * avoiding all Playwright actionability / event-dispatch races with the
 * terminal's async typewriter and busy flag.
 */
export async function selectOption(page: Page, label: string): Promise<void> {
  // Wait for options to be visible and interactive
  await page.waitForSelector('#cs-screen .cs-option', { timeout: 5000 });
  
  // Small delay to ensure terminal is ready for interaction
  await page.waitForTimeout(100);

  const ok = await page.evaluate((targetLabel: string) => {
    const rows = document.querySelectorAll<HTMLElement>(
      '#cs-screen .cs-option .cs-opt-label'
    );
    for (const row of rows) {
      if (row.textContent?.includes(targetLabel)) {
        const opt = row.closest('.cs-option') as HTMLElement;
        if (opt) {
          opt.click();
          return true;
        }
      }
    }
    return false;
  }, label);

  if (!ok) throw new Error(`Option "${label}" not found`);
  
  // Wait for the typewriter animation to start
  await page.waitForTimeout(200);
}

/**
 * Navigate with keyboard: press ArrowDown `downs` times, then Enter.
 * Downs defaults to 0 – selects the first (currently highlighted) option.
 */
export async function keyboardSelect(page: Page, downs = 0): Promise<void> {
  for (let i = 0; i < downs; i++) {
    await page.keyboard.press('ArrowDown');
    await page.waitForTimeout(50);
  }
  await page.keyboard.press('Enter');
}

/**
 * Wait for any echoed command line to appear after choosing an option.
 */
export async function waitForEcho(page: Page): Promise<void> {
  await expect(page.locator('#cs-screen .cs-line.cs-echo').first()).toBeVisible({
    timeout: 3000,
  });
}

/**
 * Wait for the MATCH FOUND dossier to render.
 * Uses a poll to be resilient against transient navigations.
 */
export async function waitForMatch(page: Page): Promise<void> {
  await expect(async () => {
    const el = page.locator('#cs-screen .cs-match-head');
    await expect(el).toBeVisible();
    await expect(el).toContainText('MATCH FOUND');
  }).toPass({ timeout: MATCH_ANIMATION_WAIT + 5000 });
}

/**
 * Expect the match dossier to show a specific role label.
 */
export async function expectMatchRole(page: Page, role: string): Promise<void> {
  await expect(page.locator('#cs-screen .cs-match-id')).toContainText(role, {
    timeout: 3000,
  });
}

/**
 * Expect the match dossier to show the recruiter badge.
 */
export async function expectRecruiterBadge(page: Page): Promise<void> {
  await expect(page.locator('#cs-screen .cs-badge')).toContainText('RECRUITER', {
    timeout: 3000,
  });
}

/**
 * Expect the match dossier to NOT show the recruiter badge.
 */
export async function expectNoRecruiterBadge(page: Page): Promise<void> {
  await expect(page.locator('#cs-screen .cs-badge')).toHaveCount(0, {
    timeout: 3000,
  });
}

/**
 * Click the "run again" restart button and wait for terminal reset.
 */
export async function clickRestart(page: Page): Promise<void> {
  await page.locator('#cs-restart').click();
  // After restart, the terminal resets to the first question
  await waitForTerminal(page);
}

/**
 * Collect all console messages for error checking.
 */
export function setupConsoleCapture(page: Page): Array<{ type: string; text: string }> {
  const messages: Array<{ type: string; text: string }> = [];
  page.on('console', (msg) => {
    messages.push({ type: msg.type(), text: msg.text() });
  });
  page.on('pageerror', (err) => {
    messages.push({ type: 'pageerror', text: err.message });
  });
  return messages;
}

/**
 * Assert no JS errors were logged (warnings are okay).
 */
export function expectNoJsErrors(messages: Array<{ type: string; text: string }>): void {
  const errors = messages.filter(
    (m) => m.type === 'pageerror' || m.type === 'error'
  );
  expect(errors).toEqual([]);
}
