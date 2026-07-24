import { initThemeTransitions, initThemeToggle } from './theme';
import { initConfettiOnToggle } from './confetti';
import { initReadProgress } from './progress';
import { initHomePage } from './hero';
import { initConsoleEaster } from './console-easter';
import { initBootSequence } from './boot';
import { initTypingAnimation } from './typing';
import { initArticleChat } from './article';
import { initGridNav } from './grid-nav';
import { markArticleRead, applyNewBadges } from './read-tracker';

import { initForumThreads } from './forum-threads';
import { initCandidateSearch } from './candidate-search';

// skip: console-tray.ts — decoupled until UX is refined (ct had task commands removed)

// Initialize BBS boot sequence on every page
initBootSequence();
initThemeToggle();

// Defer all interactions until boot completes
document.addEventListener('boot:complete', () => {
  initTypingAnimation();
  initArticleChat();
  initGridNav();

  initForumThreads();

  // Read tracking
  markArticleRead();
  applyNewBadges();

  initThemeTransitions();
  initConfettiOnToggle();
  initReadProgress();
  initHomePage();
  initConsoleEaster();
  initCandidateSearch();
}, { once: true });
