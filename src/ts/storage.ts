/**
 * SUTLIFF BBS — Shared storage utilities
 *
 * Centralizes read/unread tracking using localStorage.
 * Replaces the old cookie-based approach which hit size limits.
 */

const STORAGE_KEY = 'bbs_read';
const COOKIE_NAME = 'bbs_read';

export interface ReadMap {
  [path: string]: string; // path -> ISO date string
}

/** Migrate data from old cookie to localStorage (one-time) */
function migrateCookieIfNeeded(): void {
  try {
    if (localStorage.getItem(STORAGE_KEY)) return;
    const match = document.cookie.match(new RegExp(`(?:^|; )${COOKIE_NAME}=([^;]*)`));
    if (!match) return;
    const data = JSON.parse(decodeURIComponent(match[1]));
    if (data && typeof data === 'object') {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
    }
    // Delete the old cookie
    document.cookie = `${COOKIE_NAME}=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT`;
  } catch {
    // Silently ignore migration failures
  }
}

export function getReadMap(): ReadMap {
  migrateCookieIfNeeded();
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEY) || '{}');
  } catch {
    return {};
  }
}

export function setReadMap(map: ReadMap): void {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(map));
  } catch {
    // localStorage full or unavailable — degrade silently
  }
}

export function markRead(path: string): void {
  const map = getReadMap();
  if (map[path]) return;
  map[path] = new Date().toISOString();
  setReadMap(map);
}
