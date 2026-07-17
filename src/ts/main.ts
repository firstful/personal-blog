import { initThemeTransitions } from './theme';
import { initConfettiOnToggle } from './confetti';
import { initClickRipple } from './ripple';
import { initReadProgress } from './progress';
import { initHomePage } from './hero';
import { initConsoleEaster } from './console-easter';
import { initBootSequence } from './boot';
import { initTypingAnimation } from './typing';
import { initArticlePage } from './article';

// Initialize BBS boot sequence on every page
initBootSequence();

// Defer all interactions until boot completes
document.addEventListener('boot:complete', () => {
  initTypingAnimation();
  initArticlePage();
  initThemeTransitions();
  initConfettiOnToggle();
  initClickRipple();
  initReadProgress();
  initHomePage();
  initConsoleEaster();
}, { once: true });
