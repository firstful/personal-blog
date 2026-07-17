import { initThemeTransitions } from './theme';
import { initConfettiOnToggle } from './confetti';
import { initClickRipple } from './ripple';
import { initReadProgress } from './progress';
import { initHomePage } from './hero';
import { initConsoleEaster } from './console-easter';
import { initBootSequence } from './boot';
import { initTypingAnimation } from './typing';
import { initArticleChat } from './article';
import { initGridNav } from './grid-nav';

// Initialize BBS boot sequence on every page
initBootSequence();

// Defer all interactions until boot completes
document.addEventListener('boot:complete', () => {
  initTypingAnimation();
  initArticleChat();
  initGridNav();
  initThemeTransitions();
  initConfettiOnToggle();
  initClickRipple();
  initReadProgress();
  initHomePage();
  initConsoleEaster();
}, { once: true });
