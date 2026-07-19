/**
 * SUTLIFF BBS — Typing Animation
 *
 * Types out hero taglines and article headers character by character.
 * Uses a terminal-style typewriter effect with variable speed.
 */

export function initTypingAnimation(): void {
  const heroTagline = document.querySelector('.tagline.typing');
  if (!heroTagline) return;

  const text = heroTagline.textContent || '';
  (heroTagline as HTMLElement).textContent = '';
  (heroTagline as HTMLElement).style.display = 'inline';

  // Add cursor element
  const cursor = document.createElement('span');
  cursor.className = 'cursor';
  cursor.style.display = 'none'; // hidden until typing starts
  heroTagline.after(cursor);

  let index = 0;
  const charsPerTick = 1;
  const baseDelay = 35; // ms per character — crisp but not too fast

  function typeTick(): void {
    if (index >= text.length) {
      cursor.style.display = 'inline-block';
      return;
    }

    const next = text.slice(index, index + charsPerTick);
    heroTagline!.textContent = text.slice(0, index + charsPerTick);
    index += charsPerTick;

    // Variable speed — slight randomness for realism
    const jitter = Math.random() * 20;
    const delay = baseDelay + jitter;
    setTimeout(typeTick, delay);
  }

  // Start typing after boot sequence completes
  const startTyping = (): void => {
    setTimeout(() => {
      cursor.style.display = 'inline-block';
      typeTick();
    }, 400);
  };

  if (document.querySelector('#boot-screen')) {
    document.addEventListener('boot:complete', startTyping, { once: true });
  } else {
    startTyping();
  }
}

/**
 * Animate a single element with typewriter effect.
 * Used for page titles on article pages.
 */
function typewriter(el: HTMLElement, text?: string, speed: number = 30): Promise<void> {
  const target = text || el.textContent || '';
  el.textContent = '';
  el.style.display = 'inline';

  return new Promise((resolve) => {
    let i = 0;
    function tick(): void {
      if (i >= target.length) {
        resolve();
        return;
      }
      el.textContent = target.slice(0, i + 1);
      i++;
      const jitter = Math.random() * 15;
      setTimeout(tick, speed + jitter);
    }
    tick();
  });
}
