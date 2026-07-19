export function initThemeTransitions(): void {
  const html = document.documentElement;

  const observer = new MutationObserver(() => {
    requestAnimationFrame(() => {
      html.classList.add('color-transition');
      setTimeout(() => html.classList.remove('color-transition'), 350);
    });
  });

  observer.observe(html, {
    attributes: true,
    attributeFilter: ['data-md-color-scheme'],
  });
}

/** Toggle between default (light) and slate (dark) color schemes */
export function initThemeToggle(): void {
  (window as any).toggleTheme = function () {
    const html = document.documentElement;
    const current = html.getAttribute('data-md-color-scheme');
    const next = current === 'slate' ? 'default' : 'slate';
    html.setAttribute('data-md-color-scheme', next);
    try { localStorage.setItem('bbs_scheme', next); } catch {}
  };

  // Restore saved scheme
  try {
    const saved = localStorage.getItem('bbs_scheme');
    if (saved === 'slate' || saved === 'default') {
      document.documentElement.setAttribute('data-md-color-scheme', saved);
    }
  } catch {}
}
