/**
 * SUTLIFF BBS — Candidate Search Simulator
 *
 * A fake terminal that IS the About page. On load it plays a scripted
 * shell session dumping the bio/profile (whoami, cat profile.txt, career
 * wins, free-time), skippable with any key/click. Then the visitor
 * answers a short series of yes/no (and one role-select) prompts,
 * navigating with Arrow keys + Enter or by clicking. It ends in a
 * "MATCH FOUND" candidate dossier with a resume download tailored to
 * their answers.
 *
 * Replaces the old emoji quiz. Pure vanilla TS, terminal-themed.
 */

interface Option {
  label: string;
  /** id of the next step, or a terminal action */
  next: string;
  /** optional side-effect key */
  effect?: 'recruiter' | { variant: string };
}

interface Step {
  /** printed prompt lines shown above the options */
  lines: string[];
  options: Option[];
}

const VARIANT_LABELS: Record<string, string> = {
  'backend-developer': 'Backend Developer',
  'fullstack-developer': 'Full-Stack Developer',
  'agentic-engineer': 'Agentic Engineer',
  'forward-deployed-swe': 'Forward-Deployed SWE',
  base: 'Software Engineer',
};

const VARIANT_MATCH: Record<string, string> = {
  'backend-developer': 'Backend depth: C#, SQL, .NET, event-driven systems. 15x latency wins on record.',
  'fullstack-developer': 'Ships end-to-end: Blazor + .NET + Node. Owns the feature from schema to CSS.',
  'agentic-engineer': 'Automation & LLM tooling. Kills toil, rebuilds crusty workflows into pipelines.',
  'forward-deployed-swe': 'Client-facing and fast. Drops into your team and delivers without hand-holding.',
  base: 'Full-stack generalist, comfortable across the stack and client-facing delivery.',
};

const STEPS: Record<string, Step> = {
  start: {
    lines: [
      'Initialize candidate search? This will scan the local talent pool',
      'for engineers matching your open role.',
    ],
    options: [
      { label: 'Yes — run the search', next: 'who' },
      { label: 'No — just browsing', next: 'browsing' },
    ],
  },
  browsing: {
    lines: [
      'No problem. For the record, the pool currently contains exactly',
      'one (1) highly available candidate. Run the search anyway?',
    ],
    options: [
      { label: 'Yes, go on then', next: 'who' },
      { label: 'No, I really am just looking', next: 'who' },
    ],
  },
  who: {
    lines: ['Are you hiring on behalf of a company (recruiter)?'],
    options: [
      { label: 'Yes — I recruit', next: 'need', effect: 'recruiter' },
      { label: 'No — hiring manager / tech lead', next: 'need' },
    ],
  },
  need: {
    lines: ['Does your team currently need another engineer?'],
    options: [
      { label: 'Yes', next: 'role' },
      { label: 'No', next: 'convince' },
    ],
  },
  convince: {
    lines: [
      'Understood. But would you *want* one who ships finished features',
      'you can hand off and forget about?',
    ],
    options: [
      { label: 'Yes, fair point', next: 'role' },
      { label: 'No', next: 'convince2' },
    ],
  },
  convince2: {
    lines: ['What if the search is already done and the match is a strong one?'],
    options: [
      { label: 'Okay, you have my attention', next: 'role' },
      { label: 'Fine, convince me', next: 'role' },
    ],
  },
  role: {
    lines: ['What is your team missing? (select the closest match)'],
    options: [
      { label: 'Backend that stops falling over', next: 'match', effect: { variant: 'backend-developer' } },
      { label: 'A whole feature built end-to-end', next: 'match', effect: { variant: 'fullstack-developer' } },
      { label: 'Automation / better dev workflows', next: 'match', effect: { variant: 'agentic-engineer' } },
      { label: 'Someone to embed & ship with the team', next: 'match', effect: { variant: 'forward-deployed-swe' } },
    ],
  },
};

interface State {
  isRecruiter: boolean;
  variant: string;
  path: string[];
}

const state: State = { isRecruiter: false, variant: 'base', path: [] };

let screen: HTMLElement;
let cursor = 0;
let currentOptions: Option[] = [];
let busy = false;

/** true while the scripted profile dump is playing and can be fast-forwarded */
let skipRequested = false;
let skipDisposers: Array<() => void> = [];

const sleep = (ms: number): Promise<void> => new Promise((r) => setTimeout(r, ms));

function appendLine(text = '', cls = ''): HTMLElement {
  const el = document.createElement('div');
  el.className = `cs-line${cls ? ' ' + cls : ''}`;
  el.textContent = text;
  screen.appendChild(el);
  screen.scrollTop = screen.scrollHeight;
  return el;
}

/** Like appendLine but for trusted, pre-built HTML (links, etc.) */
function appendHTML(html: string, cls = ''): HTMLElement {
  const el = document.createElement('div');
  el.className = `cs-line${cls ? ' ' + cls : ''}`;
  el.innerHTML = html;
  screen.appendChild(el);
  screen.scrollTop = screen.scrollHeight;
  return el;
}

async function typeLine(text: string, cls = '', speed = 12): Promise<void> {
  const el = appendLine('', cls);
  if (skipRequested) {
    el.textContent = text;
    screen.scrollTop = screen.scrollHeight;
    return;
  }
  for (let i = 0; i < text.length; i++) {
    el.textContent += text[i];
    screen.scrollTop = screen.scrollHeight;
    // eslint-disable-next-line no-await-in-loop
    await sleep(speed);
  }
}

/**
 * Arm the fast-forward affordance for the scripted profile dump: any key
 * or a click on the terminal instantly completes the remaining lines.
 */
function armSkip(hint: HTMLElement): void {
  skipRequested = false;
  const onKey = (): void => { skipRequested = true; };
  const onClick = (): void => { skipRequested = true; };
  document.addEventListener('keydown', onKey);
  screen.addEventListener('click', onClick);
  skipDisposers = [
    () => document.removeEventListener('keydown', onKey),
    () => screen.removeEventListener('click', onClick),
    () => hint.remove(),
  ];
}

function disarmSkip(): void {
  skipDisposers.forEach((d) => d());
  skipDisposers = [];
}

function renderOptions(): void {
  const old = screen.querySelector('.cs-options');
  if (old) old.remove();

  const wrap = document.createElement('div');
  wrap.className = 'cs-options';
  wrap.setAttribute('role', 'listbox');
  wrap.setAttribute('tabindex', '0');
  wrap.setAttribute('aria-label', 'Answer options — use arrow keys and Enter, or click');

  currentOptions.forEach((opt, i) => {
    const row = document.createElement('div');
    row.className = 'cs-option';
    row.setAttribute('role', 'option');
    row.dataset.idx = String(i);
    row.innerHTML = `<span class="cs-caret">${i === cursor ? '>' : '\u00a0'}</span><span class="cs-opt-label">${opt.label}</span>`;
    row.addEventListener('mouseenter', () => setCursor(i));
    row.addEventListener('click', () => choose(i));
    wrap.appendChild(row);
  });

  const hint = document.createElement('div');
  hint.className = 'cs-hint';
  hint.textContent = '[\u2191/\u2193] move   [enter] select   or click';
  wrap.appendChild(hint);

  screen.appendChild(wrap);
  screen.scrollTop = screen.scrollHeight;
  (wrap as HTMLElement).focus();
}

function setCursor(i: number): void {
  cursor = i;
  const rows = screen.querySelectorAll<HTMLElement>('.cs-option');
  rows.forEach((row, idx) => {
    const caret = row.querySelector('.cs-caret');
    if (caret) caret.textContent = idx === cursor ? '>' : '\u00a0';
    row.classList.toggle('active', idx === cursor);
  });
}

async function choose(i: number): Promise<void> {
  if (busy) return;
  const opt = currentOptions[i];
  if (!opt) return;
  busy = true;

  // Lock in the choice visually as an echoed command
  const opts = screen.querySelector('.cs-options');
  if (opts) opts.remove();
  await typeLine(`recruit@ffilt.us:~$ ${opt.label}`, 'cs-echo', 6);

  if (opt.effect === 'recruiter') state.isRecruiter = true;
  else if (opt.effect && typeof opt.effect === 'object') state.variant = opt.effect.variant;

  state.path.push(opt.label);
  busy = false;

  if (opt.next === 'match') {
    await runMatch();
  } else {
    await gotoStep(opt.next);
  }
}

function onKey(e: KeyboardEvent): void {
  if (!currentOptions.length || busy) return;
  if (e.key === 'ArrowDown' || e.key === 'j') {
    e.preventDefault();
    setCursor((cursor + 1) % currentOptions.length);
  } else if (e.key === 'ArrowUp' || e.key === 'k') {
    e.preventDefault();
    setCursor((cursor - 1 + currentOptions.length) % currentOptions.length);
  } else if (e.key === 'Enter' || e.key === ' ') {
    e.preventDefault();
    void choose(cursor);
  }
}

async function gotoStep(id: string): Promise<void> {
  const step = STEPS[id];
  if (!step) return;
  busy = true;
  appendLine();
  for (const line of step.lines) {
    // eslint-disable-next-line no-await-in-loop
    await typeLine(line, 'cs-prompt');
  }
  currentOptions = step.options;
  cursor = 0;
  busy = false;
  renderOptions();
}

async function runMatch(): Promise<void> {
  busy = true;
  currentOptions = [];
  const v = state.variant;
  const label = VARIANT_LABELS[v] || 'Software Engineer';

  appendLine();
  await typeLine(`> scanning talent pool for role: ${label}...`, 'cs-sys', 8);
  const bar = appendLine('  [                    ] 0%', 'cs-sys');
  for (let p = 0; p <= 20; p++) {
    const filled = '='.repeat(p);
    const pct = Math.round((p / 20) * 100);
    bar.textContent = `  [${(filled + ' '.repeat(20)).slice(0, 20)}] ${pct}%`;
    // eslint-disable-next-line no-await-in-loop
    await sleep(45);
  }
  await sleep(200);
  await typeLine('> 1 candidate matched. compiling dossier...', 'cs-sys', 8);
  await sleep(300);

  const card = document.createElement('div');
  card.className = 'cs-match';
  card.style.setProperty('--persona-color', 'var(--term-fg-bright)');
  const anonBtn = state.isRecruiter
    ? `<a class="cs-btn ghost" href="/assets/resume/${v}-anon.pdf">[ download anonymized (for submission) ]</a>`
    : '';
  const badge = state.isRecruiter ? '<span class="cs-badge">RECRUITER</span>' : '';
  card.innerHTML = `
    <div class="cs-match-head">*** MATCH FOUND *** ${badge}</div>
    <pre class="cs-match-id">
 name    : Reed Sutliff
 role    : ${label}
 status  : AVAILABLE
 location: Columbus, OH
 match   : 98%</pre>
    <div class="cs-match-note">${VARIANT_MATCH[v] || VARIANT_MATCH.base}</div>
    <div class="cs-actions">
      <a class="cs-btn primary" href="/assets/resume/${v}.pdf">[ download resume ]</a>
      ${anonBtn}
      <a class="cs-btn" href="mailto:sutliff.reed@gmail.com">[ email me ]</a>
      <button class="cs-btn ghost" type="button" id="cs-restart">[ run again ]</button>
    </div>
    <div class="cs-contact">
      linkedin.com/in/reed-sutliff-21213b114 &nbsp;·&nbsp; github.com/reedsutliff &nbsp;·&nbsp; ffilt.us
    </div>`;
  screen.appendChild(card);
  screen.scrollTop = screen.scrollHeight;

  const restart = card.querySelector<HTMLButtonElement>('#cs-restart');
  restart?.addEventListener('click', () => void boot(true));

  busy = false;
}

// ── Scripted profile dump (all the About-page bio, in the shell) ─────

const PROFILE_LINES: string[] = [
  'builds backends, automation platforms, and event-driven systems.',
  'cares about the boring parts: observability, clean API contracts,',
  'and infrastructure that stays up without paging anyone at 3 am.',
  '',
  'likes open source, small sharp tools, and talking to stakeholders',
  'as much as reading a flame graph. equally at home in a design',
  'review or a postmortem — prefers the ones where nothing actually',
  'caught fire.',
];

const HIT_LINES: string[] = [
  '[hit] cut API latency 15x across a fleet of services',
  '[hit] standardized SDKs — teams stop reinventing the wheel',
  '[hit] shipped automation for work nobody wanted to do by hand',
  '[hit] things survived contact with production',
];

async function shellCmd(prompt: string, cmd: string): Promise<void> {
  await typeLine(`${prompt}:~$ ${cmd}`, 'cs-echo', 20);
}

async function playProfile(): Promise<void> {
  screen.dataset.phase = 'profile';
  const hint = appendLine('[ press any key to skip intro ]', 'cs-hint');
  armSkip(hint);

  const prompt = 'reed@ffilt.us';
  await shellCmd(prompt, 'whoami');
  await typeLine('Reed Sutliff — software engineer — Columbus, OH', 'cs-hl');

  await shellCmd(prompt, 'cat profile.txt');
  for (const line of PROFILE_LINES) {
    // eslint-disable-next-line no-await-in-loop
    await typeLine(line, 'cs-out');
  }

  await shellCmd(prompt, 'tail -n 4 career/wins.log');
  for (const line of HIT_LINES) {
    // eslint-disable-next-line no-await-in-loop
    await typeLine(line, 'cs-hl');
  }

  await shellCmd(prompt, 'ps aux | grep -i free-time');
  await typeLine("self-hosting something he definitely didn't need", 'cs-out');
  await sleep(150);
  await appendHTML(
    'arguing about it with the regulars on the <a class="cs-link" href="/personas/">BBS</a>',
    'cs-out'
  );
  await sleep(250);
  await typeLine('── incoming connection: careers@yourcompany.com ──', 'cs-sys');

  disarmSkip();
}

async function boot(restart = false): Promise<void> {
  screen.innerHTML = '';
  delete screen.dataset.phase;
  state.isRecruiter = false;
  state.variant = 'base';
  state.path = [];
  cursor = 0;
  currentOptions = [];
  skipRequested = false;

  await typeLine('SUTLIFF TALENT DB v1.0 — candidate-search', 'cs-sys', 6);
  await typeLine(restart ? 'session reset. ready.' : 'connection established. ready.', 'cs-sys', 6);

  if (!restart) {
    await playProfile();
  }

  screen.dataset.phase = 'wizard';
  await gotoStep('who');
}

export function initCandidateSearch(): void {
  const el = document.getElementById('cs-screen');
  if (!el) return;
  screen = el;
  // Handle keys whenever the option list (or something inside the terminal)
  // holds focus. renderOptions() focuses the list, so arrows work immediately.
  document.addEventListener('keydown', (e) => {
    if (!currentOptions.length) return;
    if (screen.contains(document.activeElement)) onKey(e);
  });
  void boot();
}
