/**
 * SUTLIFF BBS — Boot Sequence
 *
 * Full-screen terminal boot animation that plays once per browser
 * session (tab/window).  Subsequent navigations within the same
 * session skip the animation via a session cookie.
 */

const BOOT_COOKIE = 'bbs_booted';

/** Get a cookie value by name. */
function getCookie(name: string): string | null {
  const m = document.cookie.match(new RegExp(`(?:^|; )${name}=([^;]*)`));
  return m ? decodeURIComponent(m[1]) : null;
}

/** Set a session cookie (no expiry — cleared when tab/window closes). */
function setSessionCookie(name: string, value: string): void {
  document.cookie = `${name}=${encodeURIComponent(value)}; path=/; SameSite=Lax`;
}

const BOOT_LINES: Array<{ text: string; cls: string; delay: number }> = [
  { text: '[SUTLIFF BBS v1.0]', cls: 'info', delay: 300 },
  { text: '', cls: '', delay: 100 },
  { text: 'Initializing memory.................... OK', cls: 'ok', delay: 200 },
  { text: 'Loading kernel........................ OK', cls: 'ok', delay: 150 },
  { text: 'Mounting filesystem................... OK', cls: 'ok', delay: 180 },
  { text: 'Starting services....................', cls: '', delay: 100 },
  { text: '  [CRT] Display subsystem............. OK', cls: 'ok', delay: 120 },
  { text: '  [KEY] Keyboard controller........... OK', cls: 'ok', delay: 80 },
  { text: '  [CLK] System clock................. OK', cls: 'ok', delay: 100 },
  { text: '', cls: '', delay: 80 },
  { text: '[NET] Connecting to FFILT.US BBS......', cls: '', delay: 300 },
  { text: '[NET] Resolving host.................. OK', cls: 'ok', delay: 200 },
  { text: '[NET] Handshake....................... OK', cls: 'ok', delay: 250 },
  { text: '[NET] Connected — Node: COLUMBUS, OH 57600 baud', cls: 'ok', delay: 150 },
  { text: '', cls: '', delay: 80 },
  { text: '[AUTH] Authenticating user............', cls: '', delay: 400 },
  { text: '[AUTH] Identity verified............... OK', cls: 'ok', delay: 100 },
  { text: '[AUTH] Access level: SYSOP', cls: 'info', delay: 100 },
  { text: '[AUTH] Last login: ' + new Date().toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }), cls: 'info', delay: 100 },
  { text: '', cls: '', delay: 150 },
  { text: '═══════════════════════════════════════════════', cls: 'info', delay: 100 },
  { text: '  Welcome to Sutliff BBS!', cls: 'info', delay: 200 },
  { text: '  SYSOP online  —  ffilt.us  —  57600 baud', cls: 'info', delay: 80 },
  { text: '═══════════════════════════════════════════════', cls: 'info', delay: 200 },
];

export function initBootSequence(): void {
  // Skip animation if already shown this session
  if (getCookie(BOOT_COOKIE)) {
    // Defer dispatch so the boot:complete listener (registered after this
    // function returns, in the same script block) has a chance to attach.
    setTimeout(() => document.dispatchEvent(new CustomEvent('boot:complete')), 0);
    return;
  }

  const existing = document.getElementById('boot-screen');
  if (existing) {
    existing.remove();
  }

  const bootScreen = document.createElement('div');
  bootScreen.id = 'boot-screen';
  bootScreen.innerHTML = '<div class="boot-content" id="boot-content"></div>';
  document.body.appendChild(bootScreen);

  const bootContent = document.getElementById('boot-content')!;
  let totalDelay = 0;
  let lineIndex = 0;

  function addLine(line: typeof BOOT_LINES[0]): void {
    const p = document.createElement('p');
    p.className = `boot-line ${line.cls}`;
    p.textContent = line.text;
    bootContent.appendChild(p);

    // Trigger fade-in
    requestAnimationFrame(() => {
      p.classList.add('visible');
    });
  }

  function addPrompt(): void {
    const promptDiv = document.createElement('div');
    promptDiv.className = 'boot-prompt';
    promptDiv.innerHTML = `<span class="input-text">${window.location.hostname}:~$ </span><span class="cursor">▌</span>`;
    bootContent.appendChild(promptDiv);
  }

  function tick(): void {
    if (lineIndex >= BOOT_LINES.length) {
      // All lines shown — show prompt, then fade
      addPrompt();

      setTimeout(() => {
        bootScreen.classList.add('hidden');
        setTimeout(() => {
          bootScreen.remove();
        }, 900);
      }, 2000);

      // Start typing the hero text now
      setSessionCookie(BOOT_COOKIE, '1');
      document.dispatchEvent(new CustomEvent('boot:complete'));
      return;
    }

    const line = BOOT_LINES[lineIndex];
    addLine(line);
    lineIndex++;

    // Some lines have variable delays built in; use the delay prop as extra
    const baseInterval = 40 + Math.random() * 30; // jitter like old terminals
    const delay = Math.max(baseInterval, line.delay || baseInterval);
    setTimeout(tick, delay);
  }

  // Start
  tick();
}
