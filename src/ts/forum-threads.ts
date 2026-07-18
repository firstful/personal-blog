/**
 * SUTLIFF BBS — Forum Thread List
 *
 * Renders the homepage article list as forum-style thread entries,
 * filtered by read/unread status (tracked via bbs_read cookie).
 * Fetches articles.json generated at build time.
 */

const ARTICLE_JSON = '/assets/articles.json';
const COOKIE_NAME = 'bbs_read';
const COOKIE_EXPIRY_DAYS = 90;

interface Article {
  title: string;
  slug: string;
  date: string;
  tags: string[];
  description: string;
  starter: string;
  posts: number;
  category: string;
}

interface ReadMap {
  [path: string]: string;
}

/* ── Cookie helpers ── */

function getReadMap(): ReadMap {
  const m = document.cookie.match(new RegExp(`(?:^|; )${COOKIE_NAME}=([^;]*)`));
  if (!m) return {};
  try { return JSON.parse(decodeURIComponent(m[1])); }
  catch { return {}; }
}

function setReadMap(map: ReadMap): void {
  const encoded = encodeURIComponent(JSON.stringify(map));
  const expires = new Date();
  expires.setDate(expires.getDate() + COOKIE_EXPIRY_DAYS);
  document.cookie = `${COOKIE_NAME}=${encoded}; path=/; expires=${expires.toUTCString()}; SameSite=Lax`;
}

function markRead(slug: string): void {
  const map = getReadMap();
  const path = `/blog/${slug}`;
  if (map[path]) return;
  map[path] = new Date().toISOString();
  setReadMap(map);
}

/* ── Render helpers ── */

function personaBadge(handle: string): string {
  return `<span class="thread-author">${handle}</span>`;
}

function formatDate(iso: string): string {
  if (!iso) return '';
  const d = new Date(iso);
  return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
}

function tagHtml(tag: string): string {
  const t = tag.replace(/[^a-z0-9-]/gi, '').toLowerCase();
  return `<span class="thread-tag" data-tag="${t}">[${tag}]</span>`;
}

/* ── Main renderer ── */

function renderThreadList(articles: Article[], readMap: ReadMap): void {
  const container = document.getElementById('forum-thread-list');
  if (!container) return;

  const unread: Article[] = [];
  const read: Article[] = [];

  for (const a of articles) {
    const path = `/${a.slug}`;
    if (readMap[path]) {
      read.push(a);
    } else {
      unread.push(a);
    }
  }

  let html = '';

  // Unread section
  if (unread.length > 0) {
    html += `<div class="thread-section-header"><span>UNREAD MESSAGES (${unread.length})</span></div>`;
    for (const a of unread) {
      html += renderThread(a, true);
    }
  }

  // Read section
  if (read.length > 0) {
    html += `<div class="thread-section-header"><span>READ MESSAGES (${read.length})</span></div>`;
    for (const a of read) {
      html += renderThread(a, false);
    }
  }

  if (!html) {
    html = '<div class="thread-empty">No threads found.</div>';
  }

  container.innerHTML = html;

  // Attach click-to-mark-read handlers
  container.querySelectorAll('.forum-thread').forEach(el => {
    el.addEventListener('click', (e) => {
      const slug = (el as HTMLElement).dataset.slug;
      if (slug) {
        markRead(slug);
        // Navigate to the article
        window.location.href = `/blog/${slug}/`;
      }
    });
  });
}

function renderThread(a: Article, isUnread: boolean): string {
  const badge = isUnread ? '<span class="thread-new-badge">NEW</span>' : '';
  const date = formatDate(a.date);
  const starterHtml = a.starter ? personaBadge(a.starter) : '<span class="thread-author" style="color:var(--term-fg-dim)">System</span>';
  const tagsHtml = a.tags.map(tag => tagHtml(tag)).join(' ');

  return `
    <div class="forum-thread ${isUnread ? 'forum-thread-unread' : 'forum-thread-read'}" data-slug="${a.slug}">
      <div class="thread-icon ${isUnread ? 'thread-icon-unread' : 'thread-icon-read'}">${isUnread ? '▶' : '●'}</div>
      <div class="thread-body">
        <div class="thread-title">${badge} ${a.title}</div>
        <div class="thread-meta">
          ${starterHtml} · ${date} · <span class="thread-replies">${a.posts} ${a.posts === 1 ? 'reply' : 'replies'}</span>
        </div>
        <div class="thread-desc">${a.description}</div>
        <div class="thread-tags">${tagsHtml}</div>
      </div>
    </div>
  `;
}

/* ── Init ── */

export function initForumThreads(): void {
  const container = document.getElementById('forum-thread-list');
  if (!container) return;

  fetch(ARTICLE_JSON)
    .then(r => r.json())
    .then((articles: Article[]) => {
      // Sort by date descending (newest first)
      articles.sort((a, b) => b.date.localeCompare(a.date));
      const readMap = getReadMap();
      renderThreadList(articles, readMap);
    })
    .catch(err => {
      console.error('Failed to load articles.json:', err);
      container.innerHTML = '<div class="thread-empty">Could not load threads.</div>';
    });
}
