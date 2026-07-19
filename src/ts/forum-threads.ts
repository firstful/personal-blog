/**
 * SUTLIFF BBS — Forum Thread List
 *
 * Renders the homepage article list as forum-style thread entries,
 * filtered by read/unread status (tracked via localStorage).
 * Fetches articles.json generated at build time.
 */

import { getReadMap, markRead } from './storage';

const ARTICLE_JSON = '/assets/articles.json';

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

function renderThreadList(articles: Article[], readMap: ReturnType<typeof getReadMap>): void {
  const container = document.getElementById('forum-thread-list');
  if (!container) return;

  const todayStr = new Date().toISOString().slice(0, 10);

  const todaysPosts: Article[] = [];
  const unread: Article[] = [];
  const read: Article[] = [];

  for (const a of articles) {
    if (a.slug.startsWith('daily/') && a.date.startsWith(todayStr)) {
      todaysPosts.push(a);
      continue;
    }
    const path = `/blog/${a.slug}`;
    if (readMap[path]) {
      read.push(a);
    } else {
      unread.push(a);
    }
  }

  let html = '';

  if (todaysPosts.length > 0) {
    html += `<div class="thread-section-header today-header"><span>📰 TODAY'S DAILY POSTS (${todaysPosts.length})</span></div>`;
    for (const a of todaysPosts) {
      const isUnread = !readMap[`/blog/${a.slug}`];
      html += renderThread(a, isUnread);
    }
  }

  if (unread.length > 0) {
    html += `<div class="thread-section-header"><span>UNREAD MESSAGES (${unread.length})</span></div>`;
    for (const a of unread) {
      html += renderThread(a, true);
    }
  }

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

  const staticList = document.querySelector('.bbs-static-list') as HTMLElement;
  if (staticList) staticList.style.display = 'none';

  container.querySelectorAll('.forum-thread').forEach(el => {
    el.addEventListener('click', () => {
      const slug = (el as HTMLElement).dataset.slug;
      if (slug) {
        markRead(`/blog/${slug}`);
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

/* ── Loading skeleton ── */

function renderSkeleton(): string {
  let html = '';
  for (let i = 0; i < 4; i++) {
    html += `
      <div class="forum-thread thread-skeleton">
        <div class="thread-icon skeleton-icon">●</div>
        <div class="thread-body">
          <div class="thread-title"><span class="skeleton-bar" style="width:${60 + Math.random() * 30}%"></span></div>
          <div class="thread-meta"><span class="skeleton-bar" style="width:120px"></span></div>
          <div class="thread-desc"><span class="skeleton-bar" style="width:${80 + Math.random() * 15}%"></span></div>
        </div>
      </div>
    `;
  }
  return html;
}

/* ── Init ── */

export function initForumThreads(): void {
  const container = document.getElementById('forum-thread-list');
  if (!container) return;

  container.innerHTML = renderSkeleton();

  fetch(ARTICLE_JSON)
    .then(r => r.json())
    .then((articles: Article[]) => {
      articles.sort((a, b) => b.date.localeCompare(a.date));
      const readMap = getReadMap();
      renderThreadList(articles, readMap);
    })
    .catch(err => {
      console.error('Failed to load articles.json:', err);
      container.innerHTML = '<div class="thread-empty">Could not load threads.</div>';
    });
}
