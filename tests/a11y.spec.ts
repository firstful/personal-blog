/**
 * Accessibility tests for the candidate-search terminal — WCAG contrast.
 *
 * Run: npx playwright test tests/a11y.spec.ts
 */

import { test, expect } from '@playwright/test';
import { navigateToTerminal, selectOption, waitForMatch } from './helpers';

// ── Colour helpers ──────────────────────────────────────────────────

/** Parse an rgb/rgba string, blending alpha over black background. */
function parseRgb(s: string): [number, number, number] {
  // Handle "transparent" keyword → rgba(0,0,0,0)
  if (s === 'transparent') return [0, 0, 0];
  const m = s.match(/([\d.]+)/g);
  if (!m || m.length < 3) throw new Error(`Cannot parse colour: "${s}"`);
  let [r, g, b] = [Number(m[0]), Number(m[1]), Number(m[2])];
  const a = m.length >= 4 ? Number(m[3]) : 1;
  // Alpha-blend over black (#000)
  r = Math.round(a * r + (1 - a) * 0);
  g = Math.round(a * g + (1 - a) * 0);
  b = Math.round(a * b + (1 - a) * 0);
  return [r, g, b];
}

/** Linearise an sRGB channel (0-255 → 0-1 linear). */
function linearize(c: number): number {
  const v = c / 255;
  return v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4;
}

/** Relative luminance of an [r,g,b] tuple. */
function luminance(rgb: [number, number, number]): number {
  const [r, g, b] = rgb;
  return 0.2126 * linearize(r) + 0.7152 * linearize(g) + 0.0722 * linearize(b);
}

/** WCAG contrast ratio between two colours. */
function contrastRatio(fg: string, bg: string): number {
  const f = luminance(parseRgb(fg));
  const b = luminance(parseRgb(bg));
  const lighter = Math.max(f, b);
  const darker = Math.min(f, b);
  return (lighter + 0.05) / (darker + 0.05);
}

/** Assert a text/background combo meets the threshold. */
async function expectContrast(
  page: Page,
  elementSelector: string,
  threshold = 4.5, // WCAG AA normal text
): Promise<void> {
  const colors = await page.evaluate((sel: string) => {
    const el = document.querySelector(sel);
    if (!el) return null;
    const style = getComputedStyle(el);
    return { color: style.color, background: style.backgroundColor };
  }, elementSelector);

  expect(colors, `Element "${elementSelector}" not found`).toBeTruthy();
  const { color, background } = colors!;
  console.log(`[CONTRAST] ${elementSelector}: fg=${color} bg=${background}`);
  expect(color, `Missing color on ${elementSelector}`).toBeTruthy();
  expect(background, `Missing background on ${elementSelector}`).toBeTruthy();

  const ratio = contrastRatio(color!, background!);
  const pass = ratio >= threshold;

  test.info().annotations.push({
    type: pass ? 'pass' : 'fail',
    description: `${elementSelector}: fg=${color} bg=${background} ratio=${ratio.toFixed(2)}:1 ${pass ? '✓' : `✗ (need ${threshold}:1)`}`,
  });

  expect.soft(ratio, `${elementSelector} contrast ${ratio.toFixed(2)}:1`).toBeGreaterThanOrEqual(threshold);
}

// ── Pairs to check ──────────────────────────────────────────────────

interface ContrastPair {
  selector: string;
  threshold: number;      // 4.5 AA normal text, 3.0 AA large text
  label: string;
}

const PAIRS: ContrastPair[] = [
  // Title bar (splash lines)
  { selector: '#cs-screen .cs-line.cs-sys',        threshold: 4.5, label: 'System text (splash)' },
  // Question prompt text
  { selector: '#cs-screen .cs-line.cs-prompt',      threshold: 4.5, label: 'Prompt text' },
  // Option text (default state)
  { selector: '#cs-screen .cs-option',              threshold: 4.5, label: 'Option text' },
  // Option text when active/hovered
  { selector: '#cs-screen .cs-option.active',       threshold: 4.5, label: 'Active option' },
  // Echoed choice text
  { selector: '#cs-screen .cs-line.cs-echo',        threshold: 4.5, label: 'Echo text' },
  // Hint text ("[↑/↓] move ...")
  { selector: '#cs-screen .cs-hint',                threshold: 4.5, label: 'Hint text' },
  // "MATCH FOUND" header
  { selector: '#cs-screen .cs-match-head',          threshold: 4.5, label: 'Match head' },
  // Pre-formatted candidate info
  { selector: '#cs-screen .cs-match-id',            threshold: 4.5, label: 'Match ID block' },
  // Match note (variant description)
  { selector: '#cs-screen .cs-match-note',          threshold: 4.5, label: 'Match note' },
  // Primary action button (download resume)
  { selector: '#cs-screen a.cs-btn.primary',        threshold: 4.5, label: 'Primary btn' },
  // Ghost action button (restart — always present after match)
  { selector: '#cs-restart',                     threshold: 4.5, label: 'Restart btn' },
  // Contact line
  { selector: '#cs-screen .cs-contact',             threshold: 4.5, label: 'Contact line' },
];

// ── Tests ───────────────────────────────────────────────────────────

test.describe('Colour contrast', () => {
  test.beforeEach(async ({ page }) => {
    await navigateToTerminal(page);
  });

  for (const pair of PAIRS) {
    test(`${pair.label} (${pair.selector})`, async ({ page }) => {
      const isPostMatch =
        pair.selector.includes('cs-match') ||
        pair.selector.includes('cs-btn') ||
        pair.selector.includes('cs-contact') ||
        pair.selector.includes('cs-restart');

      const needsEcho = pair.selector.includes('cs-echo');
      const needsActive = pair.selector.includes('.active');

      if (needsActive) {
        await page.keyboard.press('ArrowDown');
        await page.keyboard.press('ArrowUp');
        await expect(page.locator('#cs-screen .cs-option.active')).toBeVisible();
      }

      if (needsEcho) {
        // Click the first option to produce the echo line
        await selectOption(page, 'Yes — I recruit');
        await expect(page.locator('#cs-screen .cs-line.cs-echo')).toBeVisible();
      }

      if (isPostMatch) {
        // Click through: hiring manager → Yes → Backend
        await selectOption(page, 'hiring manager');
        await expect(page.locator('#cs-screen .cs-line.cs-echo')).toBeVisible();
        await selectOption(page, 'Yes');
        await expect(page.locator('#cs-screen .cs-line.cs-echo')).toBeVisible();
        await selectOption(page, 'Backend');
        await expect(page.locator('#cs-screen .cs-match-head')).toBeVisible();
      }

      await expectContrast(page, pair.selector, pair.threshold);
    });
  }
});
