/**
 * SUTLIFF BBS — Read/unread tracking
 *
 * Tracks which articles have been viewed using localStorage.
 * On listing pages, unread articles get a [NEW] badge.
 */

import { getReadMap, markRead } from './storage';

/** Mark the current article as read. Call on article pages. */
export function markArticleRead(): void {
  const path = window.location.pathname;
  if (!path.match(/\/blog\/.+|\/opinions\/.|\/tutorials\/./)) return;

  markRead(path);
  document.dispatchEvent(new CustomEvent('bbs:read-update', { detail: { path } }));
}

/** Apply [NEW] badges to unread post cards on listing pages */
export function applyNewBadges(): void {
  const map = getReadMap();
  const cards = document.querySelectorAll<HTMLAnchorElement>('.bbs-post-card');

  const statusBar = document.querySelector('.bbs-header-status');
  if (statusBar) {
    let unread = 0;
    cards.forEach(card => {
      const href = card.getAttribute('href');
      if (!href) return;
      const path = href.startsWith('http') ? new URL(href).pathname : href;
      if (!map[path]) unread++;
    });
    const existing = statusBar.querySelector('.unread-count');
    if (existing) {
      existing.textContent = `${unread} unread`;
    } else {
      const span = document.createElement('span');
      span.className = 'unread-count';
      span.textContent = `${unread} unread`;
      span.style.cssText = 'color:var(--term-fg-bright);margin-left:8px;';
      statusBar.appendChild(span);
    }
  }

  cards.forEach(card => {
    const href = card.getAttribute('href');
    if (!href) return;
    const path = href.startsWith('http') ? new URL(href).pathname : href;

    if (!map[path]) {
      card.classList.add('bbs-unread');
      let badge = card.querySelector('.bbs-new-badge');
      if (!badge) {
        badge = document.createElement('span');
        badge.className = 'bbs-new-badge';
        badge.textContent = 'NEW';
        card.prepend(badge);
      }
    } else {
      card.classList.remove('bbs-unread');
      const badge = card.querySelector('.bbs-new-badge');
      if (badge) badge.remove();
    }
  });
}
