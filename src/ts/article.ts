/**
 * SUTLIFF BBS — Article Page Enhancer
 *
 * On blog article pages, injects a BBS-style file header showing
 * metadata (author, date, tags) in a terminal-style box.
 * Also handles the post navigation (prev/next) in BBS style.
 */

export function initArticlePage(): void {
  const isArticle = window.location.pathname.match(/\/blog\/(opinions|tutorials)\/.+/);
  if (!isArticle) return;

  // Find the article title
  const titleEl = document.querySelector<HTMLElement>('.md-content__inner h1');
  if (!titleEl) return;

  // Determine if this is a blog post (has date in URL or frontmatter)
  // Find meta info - look for tags, date displayed in the page
  const articleContent = document.querySelector('.md-content__inner .md-typeset');
  if (!articleContent) return;

  // Extract metadata from page
  const pageTitle = titleEl.textContent || 'Untitled';

  // Build the BBS file header
  const header = document.createElement('div');
  header.className = 'bbs-article-header';
  header.innerHTML = `
    <div>┌─ File: ${window.location.pathname.replace(/^\//, '')}</div>
    <div>│  Author: Reed Sutliff</div>
    <div>│  Path: ${window.location.pathname}</div>
    <div>└─</div>
  `;

  // Insert before the title
  titleEl.parentNode?.insertBefore(header, titleEl);

  // Add BBS-style nav (prev/next) at bottom if it exists
  const existingNav = document.querySelector('.md-content__inner .md-typeset + nav, .md-content__inner nav:last-child');
  if (existingNav) {
    existingNav.classList.add('bbs-article-nav');
  }
}
