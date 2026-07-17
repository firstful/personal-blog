/**
 * SUTLIFF BBS — Console Tray
 *
 * Persistent terminal tray at the bottom of the page.
 * - Intercepts link clicks → types `nav <slug>` then navigates
 * - Accepts real commands like `/help`, `/tasks`, `nav`, etc.
 * - Maintains a persistent task list in localStorage.
 */

const TYPING_SPEED = 30;
const STORAGE_KEY = 'bbs_tasks';

// ── Task persistence ──

interface Task {
  id: number;
  text: string;
  done: boolean;
  createdAt: string;
}

let tasks: Task[] = [];
let nextTaskId = 1;

function loadTasks(): void {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) {
      tasks = JSON.parse(raw);
      nextTaskId = tasks.length > 0 ? Math.max(...tasks.map(t => t.id)) + 1 : 1;
    }
  } catch { tasks = []; }
}

function saveTasks(): void {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(tasks));
}

// ── Console state ──

let outputEl: HTMLElement | null = null;
let inputEl: HTMLInputElement | null = null;
let trayEl: HTMLElement | null = null;
let cmdHistory: string[] = [];
let historyIdx = -1;

// ── Helpers ──

function pathToSlug(href: string): string {
  try {
    const url = new URL(href, window.location.origin);
    let path = url.pathname.replace(/\/$/, '');
    if (!path || path === '') return 'home';
    const parts = path.split('/').filter(Boolean);
    return parts.join('/');
  } catch { return '?'; }
}

function writeln(text: string, cls = ''): void {
  if (!outputEl) return;
  const line = document.createElement('div');
  line.className = `bbs-console-line${cls ? ' ' + cls : ''}`;
  line.textContent = text;
  outputEl.appendChild(line);
  outputEl.scrollTop = outputEl.scrollHeight;
}

function typeToConsole(text: string, onDone: () => void): void {
  if (!outputEl) { onDone(); return; }
  const line = document.createElement('div');
  line.className = 'bbs-console-line bbs-console-cmd';
  outputEl.appendChild(line);
  let i = 0;
  function tick(): void {
    if (i >= text.length) {
      onDone();
      return;
    }
    line.textContent += text[i];
    i++;
    outputEl!.scrollTop = outputEl!.scrollHeight;
    setTimeout(tick, TYPING_SPEED + Math.random() * 15);
  }
  tick();
}

function formatTasks(): string {
  if (tasks.length === 0) return 'No tasks. Use /addtask <description> to create one.';
  return tasks.map((t, i) =>
    `  ${i + 1}. [${t.done ? '✓' : ' '}] ${t.text}`
  ).join('\n');
}

// ── Command dispatch ──

function executeCommand(cmd: string): void {
  const trimmed = cmd.trim();
  if (!trimmed) return;

  writeln(`ffilt.us:~$ ${trimmed}`, 'bbs-console-input-line');

  const parts = trimmed.split(/\s+/);
  const verb = parts[0].toLowerCase();
  const args = parts.slice(1);

  switch (verb) {
    case '/help':
      writeln([
        'Available commands:',
        '  /help          — Show this help',
        '  /tasks         — List all tasks',
        '  /addtask <txt> — Add a new task',
        '  /donetask <n>  — Mark task N as done',
        '  /deltask <n>   — Delete task N',
        '  nav <path>     — Navigate to a page',
        '  clear          — Clear the console',
        '  echo <text>    — Echo text back',
      ].join('\n'), 'bbs-console-response');
      break;

    case '/tasks':
      writeln(formatTasks(), 'bbs-console-response');
      break;

    case '/addtask':
    case '/add':
      if (args.length === 0) {
        writeln('Usage: /addtask <description>', 'bbs-console-error');
        break;
      }
      const task: Task = {
        id: nextTaskId++,
        text: args.join(' '),
        done: false,
        createdAt: new Date().toISOString(),
      };
      tasks.push(task);
      saveTasks();
      writeln(`Task added: "${task.text}" (#${task.id})`, 'bbs-console-response');
      break;

    case '/donetask':
    case '/done':
    case '/check':
      {
        const n = parseInt(args[0], 10);
        if (isNaN(n) || n < 1 || n > tasks.length) {
          writeln('Usage: /donetask <N> (see /tasks for numbers)', 'bbs-console-error');
          break;
        }
        tasks[n - 1].done = true;
        saveTasks();
        writeln(`Task ${n} marked done: "${tasks[n - 1].text}"`, 'bbs-console-response');
      }
      break;

    case '/deltask':
    case '/del':
    case '/rm':
      {
        const n = parseInt(args[0], 10);
        if (isNaN(n) || n < 1 || n > tasks.length) {
          writeln('Usage: /deltask <N> (see /tasks for numbers)', 'bbs-console-error');
          break;
        }
        const removed = tasks.splice(n - 1, 1)[0];
        saveTasks();
        writeln(`Task deleted: "${removed.text}"`, 'bbs-console-response');
      }
      break;

    case 'clear':
    case 'cls':
      if (outputEl) outputEl.innerHTML = '';
      break;

    case 'echo':
      writeln(args.join(' '), 'bbs-console-response');
      break;

    case 'nav':
      if (args.length === 0) {
        writeln('Usage: nav <path> (e.g. "nav blog/opinions")', 'bbs-console-error');
        break;
      }
      const target = args[0];
      writeln(`Navigating to /${target}...`, 'bbs-console-response');
      setTimeout(() => { window.location.href = `/${target}`; }, 300);
      break;

    default:
      writeln(`Unknown command: ${verb}. Type /help for available commands.`, 'bbs-console-error');
      break;
  }
}

// ── Link interception ──

function handleLinkClick(e: MouseEvent): void {
  const link = (e.target as HTMLElement).closest<HTMLAnchorElement>('a');
  if (!link) return;
  const href = link.getAttribute('href');
  if (!href) return;

  const url = new URL(href, window.location.origin);
  if (url.origin !== window.location.origin) return;
  if (url.pathname === window.location.pathname && url.hash) return;

  const skipPatterns = [/\.(xml|rss|pdf|zip|png|jpg|svg|ico)$/i, /\/feed_/];
  if (skipPatterns.some(p => p.test(href))) return;
  if (href.includes('feed_rss')) return;

  e.preventDefault();
  const slug = pathToSlug(href);
  typeToConsole(`nav ${slug}`, () => {
    setTimeout(() => { window.location.href = href; }, 200);
  });
}

// ── Input handling ──

function onInputKeydown(e: KeyboardEvent): void {
  if (!inputEl) return;

  if (e.key === 'Enter') {
    const cmd = inputEl.value;
    inputEl.value = '';
    historyIdx = -1;
    if (cmd.trim()) {
      cmdHistory.push(cmd.trim());
      executeCommand(cmd);
    }
    return;
  }

  if (e.key === 'ArrowUp') {
    e.preventDefault();
    if (cmdHistory.length === 0) return;
    historyIdx = Math.min(historyIdx + 1, cmdHistory.length - 1);
    inputEl.value = cmdHistory[cmdHistory.length - 1 - historyIdx];
    return;
  }

  if (e.key === 'ArrowDown') {
    e.preventDefault();
    if (historyIdx <= 0) {
      historyIdx = -1;
      inputEl.value = '';
      return;
    }
    historyIdx--;
    inputEl.value = cmdHistory[cmdHistory.length - 1 - historyIdx];
    return;
  }
}

// ── Init ──

function createConsoleTray(): void {
  loadTasks();

  trayEl = document.createElement('div');
  trayEl.className = 'bbs-console-tray';
  trayEl.innerHTML = `
    <div class="bbs-console-output" tabindex="-1"></div>
    <div class="bbs-console-input-line">
      <span class="bbs-console-prompt-text">ffilt.us:~$&nbsp;</span>
      <input type="text" class="bbs-console-input" spellcheck="false" autocomplete="off" />
    </div>
  `;
  document.body.appendChild(trayEl);

  outputEl = trayEl.querySelector('.bbs-console-output') as HTMLElement;
  inputEl = trayEl.querySelector('.bbs-console-input') as HTMLInputElement;

  // Keep the input focused when clicking anywhere in the tray
  trayEl.addEventListener('click', () => inputEl?.focus());
  inputEl.addEventListener('keydown', onInputKeydown);

  // Welcome message
  writeln('SUTLIFF BBS v1.0 — Type /help for commands.', 'bbs-console-welcome');
}

export function initConsoleTray(): void {
  createConsoleTray();

  const attach = (): void => {
    document.addEventListener('click', handleLinkClick);
  };

  if (document.querySelector('#boot-screen')) {
    document.addEventListener('boot:complete', attach, { once: true });
  } else {
    attach();
  }
}
