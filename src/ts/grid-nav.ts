/**
 * SUTLIFF BBS — Multi-column Grid Keyboard Navigation
 *
 * Arrow keys move focus between post cards on the homepage.
 * Enter/Space opens the focused article.
 */

export function initGridNav(): void {
  const grid = document.querySelector('.page');
  if (!grid) return;

  const cards = Array.from(grid.querySelectorAll<HTMLAnchorElement>('.bbs-post-card'));
  if (cards.length === 0) return;

  // Make cards focusable via tab, but also handle arrow keys
  cards.forEach(card => card.setAttribute('tabindex', '0'));

  // Calculate columns from computed style
  function getColCount(): number {
    const style = getComputedStyle(grid!);
    const template = style.gridTemplateColumns;
    return template.split(' ').filter(s => s.trim() && s !== 'none').length;
  }

  function focusCard(idx: number): void {
    if (idx < 0) idx = cards.length - 1;
    if (idx >= cards.length) idx = 0;
    cards[idx].focus();
  }

  function getFocusedIndex(): number {
    const active = document.activeElement;
    if (!active) return -1;
    return cards.indexOf(active as HTMLAnchorElement);
  }

  grid.addEventListener('keydown', (e: KeyboardEvent) => {
    const idx = getFocusedIndex();
    if (idx === -1) return;

    const cols = getColCount();

    switch (e.key) {
      case 'ArrowRight':
      case 'l':
      case 'L':
        e.preventDefault();
        focusCard(idx + 1);
        break;
      case 'ArrowLeft':
      case 'h':
      case 'H':
        e.preventDefault();
        focusCard(idx - 1);
        break;
      case 'ArrowDown':
      case 'j':
      case 'J':
        e.preventDefault();
        focusCard(idx + cols);
        break;
      case 'ArrowUp':
      case 'k':
      case 'K':
        e.preventDefault();
        focusCard(idx - cols);
        break;
      case 'Enter':
      case ' ':
        e.preventDefault();
        cards[idx].click();
        break;
      case 'Home':
      case 'g':
        e.preventDefault();
        focusCard(0);
        break;
      case 'End':
      case 'G':
        e.preventDefault();
        focusCard(cards.length - 1);
        break;
    }
  });

  // Auto-focus first card when user starts typing navigation keys
  // (so they don't have to tab in first)
  document.addEventListener('keydown', function firstKey(e: KeyboardEvent) {
    if (['h', 'j', 'k', 'l', 'g', 'G', 'ArrowRight', 'ArrowLeft', 'ArrowDown', 'ArrowUp'].includes(e.key)) {
      // Only if nothing else is focused
      if (!document.activeElement || document.activeElement === document.body) {
        // But only if we're on a listing page (not in an article)
        if (!window.location.pathname.match(/\/blog\/(opinions|tutorials)\/.+/)) {
          focusCard(0);
          // Re-trigger the event
          const newIdx = getFocusedIndex();
          if (newIdx === 0) {
            // Dispatch to the grid handler
            setTimeout(() => cards[0].focus(), 10);
          }
        }
      }
      document.removeEventListener('keydown', firstKey);
    }
  });
}
