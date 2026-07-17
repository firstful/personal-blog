/**
 * SUTLIFF BBS — Cookie-based read/unread tracking
 *
 * Uses a JSON cookie to track which articles have been viewed.
 * On listing pages, unread articles get a [NEW] badge.
 */

const COOKIE_NAME = 'bbs_read';
const COOKIE_EXPIRY_DAYS = 90;

interface ReadMap {
  [path: string]: string; // path -> ISO date string
}

function getReadMap(): ReadMap {
  const match = document.cookie.match(new RegExp(`(?:^|; )${COOKIE_NAME}=([^;]*)`));
  if (!match) return {};
  try {
    return JSON.parse(decodeURIComponent(match[1]));
  } catch {
    return {};
  }
}

function setReadMap(map: ReadMap): void {
  const encoded = encodeURIComponent(JSON.stringify(map));
  const expires = new Date();
  expires.setDate(expires.getDate() + COOKIE_EXPIRY_DAYS);
  document.cookie = `${COOKIE_NAME}=${encoded}; path=/; expires=${expires.toUTCString()}; SameSite=Lax`;
}

/** Mark the current article as read. Call on article pages. */
export function markArticleRead(): void {
  const path = window.location.pathname;
  // Only track blog paths
  if (!path.match(/\/blog\/.+|\/opinions\/.|\/tutorials\/./)) return;

  const map = getReadMap();
  if (map[path]) return; // already tracked

  map[path] = new Date().toISOString();
  setReadMap(map);

  // Also dispatch event so other parts of the page can react
  document.dispatchEvent(new CustomEvent('bbs:read-update', { detail: { path } }));
}

/** Get the count of unread articles on the current listing page */
export function getUnreadCount(): number {
  const map = getReadMap();
  const cards = document.querySelectorAll<HTMLAnchorElement>('.bbs-post-card');
  let unread = 0;
  cards.forEach(card => {
    const href = card.getAttribute('href');
    if (!href) return;
    // Normalize href to path
    const path = href.startsWith('http') ? new URL(href).pathname : href;
    if (!map[path]) unread++;
  });
  return unread;
}

/** Apply [NEW] badges to unread post cards on listing pages */
export function applyNewBadges(): void {
  const map = getReadMap();
  const cards = document.querySelectorAll<HTMLAnchorElement>('.bbs-post-card');

  // Update header with unread count
  const statusBar = document.querySelector('.bbs-header-status');
  if (statusBar) {
    let unread = 0;
    cards.forEach(card => {
      const href = card.getAttribute('href');
      if (!href) return;
      const path = href.startsWith('http') ? new URL(href).pathname : href;
      if (!map[path]) unread++;
    });
    // Replace or append unread count
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

  // Apply badges
  cards.forEach(card => {
    const href = card.getAttribute('href');
    if (!href) return;
    const path = href.startsWith('http') ? new URL(href).pathname : href;

    if (!map[path]) {
      card.classList.add('bbs-unread');
      // Add [NEW] badge
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
