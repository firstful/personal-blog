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
import { markArticleRead, applyNewBadges } from './read-tracker';
import { initConsoleTray } from './console-tray';
import { initForumThreads } from './forum-threads';

// Initialize BBS boot sequence on every page
initBootSequence();

// Defer all interactions until boot completes
document.addEventListener('boot:complete', () => {
  initTypingAnimation();
  initArticleChat();
  initGridNav();
  initConsoleTray();
  initForumThreads();

  // Read tracking
  markArticleRead();
  applyNewBadges();

  initThemeTransitions();
  initConfettiOnToggle();
  initClickRipple();
  initReadProgress();
  initHomePage();
  initConsoleEaster();
}, { once: true });
