/**
 * SUTLIFF BBS — Article Page as Chat Conversation
 *
 * Transforms blog article content into a fake chat log between
 * ffiltus (the author) and generated sock-puppet users.
 * DISCLAIMER: All conversations are fictional.
 */

const SOCK_PUPPETS = [
  'cypher_punk', 'null_pointer', 'stack_trace', 'kernel_panic',
  'root_access', 'packet_loss', 'segfault_42', 'syntax_error',
  'fork_bomb', 'dead_lock', 'bit_rot', 'race_condition',
  'buffer_overflow', 'cache_miss', 'zombie_proc',
];

function pickSockPuppets(title: string): string[] {
  // Deterministic selection based on article title so it's stable per page
  let hash = 0;
  for (let i = 0; i < title.length; i++) {
    hash = ((hash << 5) - hash) + title.charCodeAt(i);
    hash |= 0;
  }
  const count = 1 + (Math.abs(hash) % 2); // 1 or 2 sock puppets
  const names: string[] = [];
  for (let i = 0; i < count; i++) {
    const idx = (Math.abs(hash) + i * 7) % SOCK_PUPPETS.length;
    names.push(SOCK_PUPPETS[idx]);
  }
  return names;
}

function generateTimestamp(index: number, baseDate: Date, totalMessages: number): string {
  const windowMs = 3 * 60 * 60 * 1000;
  const jitter = (index * 997) % 60000;
  const offset = Math.round((index / Math.max(totalMessages - 1, 1)) * windowMs) + jitter;
  const ts = new Date(baseDate.getTime() + offset);
  return ts.toLocaleString('en-US', {
    month: 'short', day: 'numeric', year: 'numeric',
    hour: '2-digit', minute: '2-digit', hour12: false,
  });
}

export function initArticleChat(): void {
  const isArticle = window.location.pathname.match(/\/blog\/(opinions|tutorials)\/.+/) ||
                    window.location.pathname.match(/\/opinions\/(?!$)/) ||
                    window.location.pathname.match(/\/tutorials\/(?!$)/);
  if (!isArticle) return;

  const content = document.querySelector('.md-content__inner .md-typeset');
  if (!content) return;

  const titleEl = content.querySelector('h1');
  if (!titleEl) return;

  const articleTitle = titleEl.textContent || 'Untitled';
  const socks = pickSockPuppets(articleTitle);
  const participants = ['ffiltus', ...socks];

  // Build chat wrapper completely replacing the original content
  const chat = document.createElement('div');
  chat.className = 'bbs-chat';

  // --- Disclaimer ---
  const disclaimer = document.createElement('div');
  disclaimer.className = 'bbs-chat-disclaimer';
  disclaimer.innerHTML = `<strong>⚠ FICTIONAL DIALOGUE</strong> — This article is presented as a conversation between <strong>ffiltus</strong> and fictional sock-puppet accounts for illustrative purposes. None of the participants except the author (ffiltus) are real people.`;
  chat.appendChild(disclaimer);

  // --- Chat Header ---
  const header = document.createElement('div');
  header.className = 'bbs-chat-header';
  const topic = articleTitle.length > 60 ? articleTitle.slice(0, 60) + '…' : articleTitle;
  header.innerHTML = `
    <div class="chat-title">#${articleTitle}</div>
    <div class="chat-participants">
      Participants: ${participants.map(p =>
        `<span class="chat-participant ${p === 'ffiltus' ? 'ffiltus' : 'sock'}">${p}</span>`
      ).join('')}
    </div>`;
  chat.appendChild(header);

  // --- Messages ---
  let msgIndex = 0;
  const children = Array.from(content.children);

  const publishedMeta = document.querySelector('meta[name="article:published_time"]');
  const publishDate = publishedMeta ? new Date(publishedMeta.getAttribute('content')!) : new Date();

  // First pass: count total messages to distribute timestamps evenly
  let totalMessages = 0;
  for (const el of children) {
    if (el.tagName === 'H1') continue;
    if (el.classList.contains('bbs-article-header')) continue;
    if (el.tagName === 'STYLE') continue;
    if (el.tagName === 'BLOCKQUOTE') { totalMessages++; continue; }
    if (el.classList.contains('bbs-article-nav')) continue;
    if (el.classList.contains('md-tags')) continue;
    if (el.tagName === 'HR') continue;
    if (el.tagName === 'P' || el.tagName === 'UL' || el.tagName === 'OL' ||
        el.tagName === 'PRE' || el.tagName === 'TABLE' ||
        el.tagName === 'H2' || el.tagName === 'H3' || el.tagName === 'H4' ||
        el.tagName === 'DIV' || el.tagName === 'DL') {
      totalMessages++;
    }
  }

  for (let i = 0; i < children.length; i++) {
    const el = children[i];

    // Skip h1 (already used as title), hidden elements
    if (el.tagName === 'H1') continue;
    if (el.classList.contains('bbs-article-header')) continue;
    if (el.tagName === 'STYLE') continue;

    // Process blockquotes as sock-puppet messages
    if (el.tagName === 'BLOCKQUOTE') {
      const currentSock = socks[msgIndex % socks.length];
      const msg = createChatMessage(currentSock, el.innerHTML, msgIndex, 'sock', false, publishDate, totalMessages);
      chat.appendChild(msg);
      msgIndex++;
      continue;
    }

    // Skip navigation elements, tags container, etc.
    if (el.classList.contains('bbs-article-nav')) continue;
    if (el.classList.contains('md-tags')) continue;

    // Regular paragraphs become ffiltus messages
    // Group consecutive non-blockquote, non-heading elements into one message
    if (el.tagName === 'P' || el.tagName === 'UL' || el.tagName === 'OL' ||
        el.tagName === 'PRE' || el.tagName === 'TABLE' ||
        el.tagName === 'HR' || el.tagName === 'H2' || el.tagName === 'H3' ||
        el.tagName === 'H4' || el.tagName === 'DIV' || el.tagName === 'DL') {

      // If it's an hr or a heading, use as section break
      if (el.tagName === 'HR') {
        const divider = document.createElement('div');
        divider.style.cssText = 'border-top:1px solid var(--term-fg-dark); margin:12px 0;';
        chat.appendChild(divider);
        continue;
      }

      // For headings inside chat, make them transitional messages
      if (el.tagName === 'H2' || el.tagName === 'H3' || el.tagName === 'H4') {
        const msg = createChatMessage('ffiltus', el.outerHTML, msgIndex, 'ffiltus', true, publishDate, totalMessages);
        chat.appendChild(msg);
        msgIndex++;
        continue;
      }

      // Regular content - create ffiltus message
      const msg = createChatMessage('ffiltus', el.outerHTML, msgIndex, 'ffiltus', false, publishDate, totalMessages);
      chat.appendChild(msg);
      msgIndex++;
    }
  }

  // --- Input prompt (decorative) ---
  const inputBar = document.createElement('div');
  inputBar.className = 'bbs-chat-input';
  inputBar.innerHTML = `<span class="input-prompt">></span> <span>/reply to continue the conversation...</span><span class="input-cursor"></span>`;
  chat.appendChild(inputBar);

  // --- Footer ---
  const footer = document.createElement('div');
  footer.className = 'bbs-chat-footer';
  footer.textContent = `— End of chat log — ${articleTitle} · ${participants.length} participants · ${msgIndex} messages —`;
  chat.appendChild(footer);

  // Replace original content with chat
  content.innerHTML = '';
  content.appendChild(chat);
}

function createChatMessage(
  username: string,
  innerHtml: string,
  index: number,
  side: 'ffiltus' | 'sock',
  isHeading: boolean = false,
  publishDate?: Date,
  totalMessages?: number
): HTMLDivElement {
  const container = document.createElement('div');
  container.className = `bbs-chat-msg from-${side}`;

  const avatar = document.createElement('div');
  avatar.className = 'bbs-chat-avatar';
  avatar.textContent = username.charAt(0).toUpperCase();

  const bubble = document.createElement('div');
  bubble.className = 'bbs-chat-bubble';

  const nameEl = document.createElement('div');
  nameEl.className = 'bbs-chat-username';
  nameEl.textContent = username;

  const textEl = document.createElement('div');
  textEl.className = 'bbs-chat-text';
  if (isHeading) {
    // Headings get special treatment
    textEl.innerHTML = innerHtml;
    textEl.style.cssText += 'background:transparent; border-color:transparent; font-weight:700;';
    textEl.querySelector('h2, h3, h4')?.style.setProperty('margin', '0');
  } else {
    textEl.innerHTML = innerHtml;
  }

  const timeEl = document.createElement('div');
  timeEl.className = 'bbs-chat-time';
  timeEl.textContent = generateTimestamp(index, publishDate ?? new Date(), totalMessages ?? 1);

  bubble.appendChild(nameEl);
  bubble.appendChild(textEl);
  bubble.appendChild(timeEl);

  container.appendChild(avatar);
  container.appendChild(bubble);

  return container;
}
