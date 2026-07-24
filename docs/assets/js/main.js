(() => {
  // src/ts/theme.ts
  function initThemeTransitions() {
    const html = document.documentElement;
    const observer = new MutationObserver(() => {
      requestAnimationFrame(() => {
        html.classList.add("color-transition");
        setTimeout(() => html.classList.remove("color-transition"), 350);
      });
    });
    observer.observe(html, {
      attributes: true,
      attributeFilter: ["data-md-color-scheme"]
    });
  }
  function initThemeToggle() {
    window.toggleTheme = function() {
      const html = document.documentElement;
      const current = html.getAttribute("data-md-color-scheme");
      const next = current === "slate" ? "default" : "slate";
      html.setAttribute("data-md-color-scheme", next);
      try {
        localStorage.setItem("bbs_scheme", next);
      } catch {
      }
    };
    try {
      const saved = localStorage.getItem("bbs_scheme");
      if (saved === "slate" || saved === "default") {
        document.documentElement.setAttribute("data-md-color-scheme", saved);
      }
    } catch {
    }
  }

  // src/ts/confetti.ts
  var COLORS = ["#b8895a", "#c4b094", "#dbbc8c", "#e8dfd0", "#e8d5b5", "#f0e0c8", "#7a6b50", "#c4956a"];
  function confettiBurst() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    const count = 60;
    const container = document.createElement("div");
    container.style.cssText = [
      "position: fixed; top: 0; left: 0; width: 100%; height: 100%;",
      "pointer-events: none; z-index: 9998; overflow: hidden;"
    ].join("");
    document.body.appendChild(container);
    for (let i = 0; i < count; i++) {
      const piece = document.createElement("div");
      const color = COLORS[Math.floor(Math.random() * COLORS.length)];
      const size = Math.random() * 8 + 4;
      const startX = Math.random() * 100;
      const delay = Math.random() * 0.3;
      const duration = Math.random() * 1.5 + 1;
      const br = Math.random() > 0.5 ? "50%" : "0%";
      piece.style.cssText = [
        "position: absolute;",
        "top: 45%;",
        `left: ${startX}%;`,
        `width: ${size}px;`,
        `height: ${size * (Math.random() * 0.6 + 0.6)}px;`,
        `background: ${color};`,
        `border-radius: ${br};`,
        `animation: confetti-drop ${duration}s ease-out ${delay}s forwards;`,
        `transform: rotate(${Math.random() * 360}deg);`,
        "opacity: 0;"
      ].join("");
      container.appendChild(piece);
    }
    setTimeout(() => {
      if (container.parentNode) container.parentNode.removeChild(container);
    }, 3500);
  }
  function initConfettiOnToggle() {
    const html = document.documentElement;
    const observer = new MutationObserver(() => confettiBurst());
    observer.observe(html, { attributes: true, attributeFilter: ["data-md-color-scheme"] });
  }

  // src/ts/progress.ts
  function initReadProgress() {
    const bar = document.createElement("div");
    bar.id = "read-progress";
    document.body.prepend(bar);
    function update() {
      const scrollTop = window.scrollY;
      const docHeight = document.documentElement.scrollHeight - window.innerHeight;
      if (docHeight > 100) {
        bar.style.width = `${Math.min(scrollTop / docHeight * 100, 100)}%`;
      }
    }
    window.addEventListener("scroll", update);
    window.addEventListener("resize", update);
  }

  // src/ts/hero.ts
  function initHeroGradient() {
    const hero = document.querySelector(".md-content__inner");
    if (hero) hero.classList.add("home-hero");
  }
  function initElephantGlitch() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    const banner = document.querySelector(".ascii-banner");
    if (!banner || banner.querySelector(".glitch-layer")) return;
    const art = banner.textContent ?? "";
    for (const cls of ["layer-a", "layer-b"]) {
      const layer = document.createElement("span");
      layer.className = `glitch-layer ${cls}`;
      layer.setAttribute("aria-hidden", "true");
      layer.textContent = art;
      banner.appendChild(layer);
    }
  }
  function initAccentBar(introPara) {
    const bar = document.createElement("div");
    bar.className = "hero-accent-bar";
    introPara.parentNode.insertBefore(bar, introPara.nextSibling);
  }
  function initTypewriter(introPara) {
    const typeEl = document.createElement("div");
    typeEl.className = "term-prompt";
    typeEl.style.cssText = "margin-bottom: 1.5em; font-size: 0.95em;";
    typeEl.innerHTML = '<span style="color:var(--term-fg-dim)">$ I work with&nbsp;</span><span class="hero-typewriter" style="color:var(--term-fg-bright)"></span><span class="terminal-underscore-cursor">_</span>';
    introPara.parentNode.insertBefore(typeEl, introPara.nextSibling);
    const tagSpan = typeEl.querySelector(".hero-typewriter");
    const tags = ["TypeScript", "Python", "C#", "OpenAPI", "AsyncAPI", "Cloud", "Open Source"];
    let ti = 0, ci = 0, del = false;
    function type() {
      const cur = tags[ti];
      tagSpan.textContent = del ? cur.substring(0, --ci) : cur.substring(0, ++ci);
      if (!del && ci === cur.length) {
        del = true;
        setTimeout(type, 1800);
        return;
      }
      if (del && ci === 0) {
        del = false;
        ti = (ti + 1) % tags.length;
        setTimeout(type, 400);
        return;
      }
      setTimeout(type, del ? 35 : 70);
    }
    type();
  }
  function initCardEntrance() {
    const cards = Array.from(document.querySelectorAll(".blog-override-post"));
    cards.forEach((c, i) => {
      c.style.opacity = "0";
      c.style.animationDelay = `${0.1 + i * 0.08}s`;
      requestAnimationFrame(() => c.classList.add("card-enter"));
    });
    returnCards(cards);
  }
  function returnCards(cards) {
    if (!window.matchMedia("(hover: hover)").matches || window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    cards.forEach((card) => {
      card.classList.add("card-tilt");
      card.addEventListener("mousemove", (e) => {
        const r = card.getBoundingClientRect();
        const x = e.clientX - r.left;
        const y = e.clientY - r.top;
        const rx = (y / r.height - 0.5) * -12;
        const ry = (x / r.width - 0.5) * 12;
        card.style.transform = `perspective(600px) rotateX(${rx}deg) rotateY(${ry}deg)`;
      });
      card.addEventListener("mouseleave", () => {
        card.style.transform = "perspective(600px) rotateX(0) rotateY(0)";
      });
    });
  }
  function initHomePage() {
    const isHome = window.location.pathname === "/" || window.location.pathname === "";
    if (!isHome) return;
    initHeroGradient();
    initElephantGlitch();
    const introPara = document.querySelector(".md-content__inner > p");
    if (!introPara) return;
    initAccentBar(introPara);
    initTypewriter(introPara);
    initCardEntrance();
  }

  // src/ts/console-easter.ts
  function initConsoleEaster() {
    setTimeout(() => {
      const styles = [
        "color: #bea88b",
        "font-size: 16px",
        "font-weight: bold",
        "padding: 8px"
      ].join(";");
      console.log("%c  sutliff  ", styles);
      console.log("%cHey, thanks for peeking under the hood!", "color: #a38256; font-size: 13px;");
      console.log(
        "%cThis site is built with MkDocs + Material. The source is at github.com/reedsutliff",
        "color: #888; font-size: 11px;"
      );
    }, 100);
  }

  // src/ts/boot.ts
  var BOOT_COOKIE = "bbs_booted";
  function getCookie(name) {
    const m = document.cookie.match(new RegExp(`(?:^|; )${name}=([^;]*)`));
    return m ? decodeURIComponent(m[1]) : null;
  }
  function setSessionCookie(name, value) {
    document.cookie = `${name}=${encodeURIComponent(value)}; path=/; SameSite=Lax`;
  }
  var BOOT_LINES = [
    { text: "[SUTLIFF BBS v1.0]", cls: "info", delay: 300 },
    { text: "", cls: "", delay: 100 },
    { text: "Initializing memory.................... OK", cls: "ok", delay: 200 },
    { text: "Loading kernel........................ OK", cls: "ok", delay: 150 },
    { text: "Mounting filesystem................... OK", cls: "ok", delay: 180 },
    { text: "Starting services....................", cls: "", delay: 100 },
    { text: "  [CRT] Display subsystem............. OK", cls: "ok", delay: 120 },
    { text: "  [KEY] Keyboard controller........... OK", cls: "ok", delay: 80 },
    { text: "  [CLK] System clock................. OK", cls: "ok", delay: 100 },
    { text: "", cls: "", delay: 80 },
    { text: "[NET] Connecting to FFILT.US BBS......", cls: "", delay: 300 },
    { text: "[NET] Resolving host.................. OK", cls: "ok", delay: 200 },
    { text: "[NET] Handshake....................... OK", cls: "ok", delay: 250 },
    { text: "[NET] Connected \u2014 Node: COLUMBUS, OH 57600 baud", cls: "ok", delay: 150 },
    { text: "", cls: "", delay: 80 },
    { text: "[AUTH] Authenticating user............", cls: "", delay: 400 },
    { text: "[AUTH] Identity verified............... OK", cls: "ok", delay: 100 },
    { text: "[AUTH] Access level: SYSOP", cls: "info", delay: 100 },
    { text: "[AUTH] Last login: " + (/* @__PURE__ */ new Date()).toLocaleDateString("en-US", { weekday: "long", year: "numeric", month: "long", day: "numeric" }), cls: "info", delay: 100 },
    { text: "", cls: "", delay: 150 },
    { text: "\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550", cls: "info", delay: 100 },
    { text: "  Welcome to Sutliff BBS!", cls: "info", delay: 200 },
    { text: "  SYSOP online  \u2014  ffilt.us  \u2014  57600 baud", cls: "info", delay: 80 },
    { text: "\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550", cls: "info", delay: 200 }
  ];
  function initBootSequence() {
    if (getCookie(BOOT_COOKIE)) {
      document.dispatchEvent(new CustomEvent("boot:complete"));
      return;
    }
    const existing = document.getElementById("boot-screen");
    if (existing) {
      existing.remove();
    }
    const bootScreen = document.createElement("div");
    bootScreen.id = "boot-screen";
    bootScreen.innerHTML = '<div class="boot-content" id="boot-content"></div>';
    document.body.appendChild(bootScreen);
    const bootContent = document.getElementById("boot-content");
    let totalDelay = 0;
    let lineIndex = 0;
    function addLine(line) {
      const p = document.createElement("p");
      p.className = `boot-line ${line.cls}`;
      p.textContent = line.text;
      bootContent.appendChild(p);
      requestAnimationFrame(() => {
        p.classList.add("visible");
      });
    }
    function addPrompt() {
      const promptDiv = document.createElement("div");
      promptDiv.className = "boot-prompt";
      promptDiv.innerHTML = `<span class="input-text">${window.location.hostname}:~$ </span><span class="cursor">\u258C</span>`;
      bootContent.appendChild(promptDiv);
    }
    function tick() {
      if (lineIndex >= BOOT_LINES.length) {
        addPrompt();
        setTimeout(() => {
          bootScreen.classList.add("hidden");
          setTimeout(() => {
            bootScreen.remove();
          }, 900);
        }, 2e3);
        setSessionCookie(BOOT_COOKIE, "1");
        document.dispatchEvent(new CustomEvent("boot:complete"));
        return;
      }
      const line = BOOT_LINES[lineIndex];
      addLine(line);
      lineIndex++;
      const baseInterval = 40 + Math.random() * 30;
      const delay = Math.max(baseInterval, line.delay || baseInterval);
      setTimeout(tick, delay);
    }
    tick();
  }

  // src/ts/typing.ts
  function initTypingAnimation() {
    const heroTagline = document.querySelector(".tagline.typing");
    if (!heroTagline) return;
    const text = heroTagline.textContent || "";
    heroTagline.textContent = "";
    heroTagline.style.display = "inline";
    const cursor2 = document.createElement("span");
    cursor2.className = "cursor";
    cursor2.style.display = "none";
    heroTagline.after(cursor2);
    let index = 0;
    const charsPerTick = 1;
    const baseDelay = 35;
    function typeTick() {
      if (index >= text.length) {
        cursor2.style.display = "inline-block";
        return;
      }
      const next = text.slice(index, index + charsPerTick);
      heroTagline.textContent = text.slice(0, index + charsPerTick);
      index += charsPerTick;
      const jitter = Math.random() * 20;
      const delay = baseDelay + jitter;
      setTimeout(typeTick, delay);
    }
    const startTyping = () => {
      setTimeout(() => {
        cursor2.style.display = "inline-block";
        typeTick();
      }, 400);
    };
    if (document.querySelector("#boot-screen")) {
      document.addEventListener("boot:complete", startTyping, { once: true });
    } else {
      startTyping();
    }
  }

  // src/ts/article.ts
  var SOCK_PUPPETS = [
    "cypher_punk",
    "null_pointer",
    "stack_trace",
    "kernel_panic",
    "root_access",
    "packet_loss",
    "segfault_42",
    "syntax_error",
    "fork_bomb",
    "dead_lock",
    "bit_rot",
    "race_condition",
    "buffer_overflow",
    "cache_miss",
    "zombie_proc"
  ];
  function pickSockPuppets(title) {
    let hash = 0;
    for (let i = 0; i < title.length; i++) {
      hash = (hash << 5) - hash + title.charCodeAt(i);
      hash |= 0;
    }
    const count = 1 + Math.abs(hash) % 2;
    const names = [];
    for (let i = 0; i < count; i++) {
      const idx = (Math.abs(hash) + i * 7) % SOCK_PUPPETS.length;
      names.push(SOCK_PUPPETS[idx]);
    }
    return names;
  }
  function generateTimestamp(index, baseDate, totalMessages) {
    const windowMs = 3 * 60 * 60 * 1e3;
    const jitter = index * 997 % 6e4;
    const offset = Math.round(index / Math.max(totalMessages - 1, 1) * windowMs) + jitter;
    const ts = new Date(baseDate.getTime() + offset);
    return ts.toLocaleString("en-US", {
      month: "short",
      day: "numeric",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
      hour12: false
    });
  }
  function initArticleChat() {
    const isArticle = window.location.pathname.match(/\/blog\/(opinions|tutorials)\/.+/) || window.location.pathname.match(/\/opinions\/(?!$)/) || window.location.pathname.match(/\/tutorials\/(?!$)/);
    if (!isArticle) return;
    const content = document.querySelector(".md-content__inner .md-typeset");
    if (!content) return;
    const titleEl = content.querySelector("h1");
    if (!titleEl) return;
    const articleTitle = titleEl.textContent || "Untitled";
    const socks = pickSockPuppets(articleTitle);
    const participants = ["ffiltus", ...socks];
    const chat = document.createElement("div");
    chat.className = "bbs-chat";
    const disclaimer = document.createElement("div");
    disclaimer.className = "bbs-chat-disclaimer";
    disclaimer.innerHTML = `<strong>\u26A0 FICTIONAL DIALOGUE</strong> \u2014 This article is presented as a conversation between <strong>ffiltus</strong> and fictional sock-puppet accounts for illustrative purposes. None of the participants except the author (ffiltus) are real people.`;
    chat.appendChild(disclaimer);
    const header = document.createElement("div");
    header.className = "bbs-chat-header";
    const topic = articleTitle.length > 60 ? articleTitle.slice(0, 60) + "\u2026" : articleTitle;
    header.innerHTML = `
    <div class="chat-title">#${articleTitle}</div>
    <div class="chat-participants">
      Participants: ${participants.map(
      (p) => `<span class="chat-participant ${p === "ffiltus" ? "ffiltus" : "sock"}">${p}</span>`
    ).join("")}
    </div>`;
    chat.appendChild(header);
    let msgIndex = 0;
    const children = Array.from(content.children);
    const publishedMeta = document.querySelector('meta[name="article:published_time"]');
    const publishDate = publishedMeta ? new Date(publishedMeta.getAttribute("content")) : /* @__PURE__ */ new Date();
    let totalMessages = 0;
    for (const el of children) {
      if (el.tagName === "H1") continue;
      if (el.classList.contains("bbs-article-header")) continue;
      if (el.tagName === "STYLE") continue;
      if (el.tagName === "BLOCKQUOTE") {
        totalMessages++;
        continue;
      }
      if (el.classList.contains("bbs-article-nav")) continue;
      if (el.classList.contains("md-tags")) continue;
      if (el.tagName === "HR") continue;
      if (el.tagName === "P" || el.tagName === "UL" || el.tagName === "OL" || el.tagName === "PRE" || el.tagName === "TABLE" || el.tagName === "H2" || el.tagName === "H3" || el.tagName === "H4" || el.tagName === "DIV" || el.tagName === "DL") {
        totalMessages++;
      }
    }
    for (let i = 0; i < children.length; i++) {
      const el = children[i];
      if (el.tagName === "H1") continue;
      if (el.classList.contains("bbs-article-header")) continue;
      if (el.tagName === "STYLE") continue;
      if (el.tagName === "BLOCKQUOTE") {
        const currentSock = socks[msgIndex % socks.length];
        const msg = createChatMessage(currentSock, el.innerHTML, msgIndex, "sock", false, publishDate, totalMessages);
        chat.appendChild(msg);
        msgIndex++;
        continue;
      }
      if (el.classList.contains("bbs-article-nav")) continue;
      if (el.classList.contains("md-tags")) continue;
      if (el.tagName === "P" || el.tagName === "UL" || el.tagName === "OL" || el.tagName === "PRE" || el.tagName === "TABLE" || el.tagName === "HR" || el.tagName === "H2" || el.tagName === "H3" || el.tagName === "H4" || el.tagName === "DIV" || el.tagName === "DL") {
        if (el.tagName === "HR") {
          const divider = document.createElement("div");
          divider.style.cssText = "border-top:1px solid var(--term-fg-dark); margin:12px 0;";
          chat.appendChild(divider);
          continue;
        }
        if (el.tagName === "H2" || el.tagName === "H3" || el.tagName === "H4") {
          const msg2 = createChatMessage("ffiltus", el.outerHTML, msgIndex, "ffiltus", true, publishDate, totalMessages);
          chat.appendChild(msg2);
          msgIndex++;
          continue;
        }
        const msg = createChatMessage("ffiltus", el.outerHTML, msgIndex, "ffiltus", false, publishDate, totalMessages);
        chat.appendChild(msg);
        msgIndex++;
      }
    }
    const inputBar = document.createElement("div");
    inputBar.className = "bbs-chat-input";
    inputBar.innerHTML = `<span class="input-prompt">></span> <span>/reply to continue the conversation...</span><span class="input-cursor"></span>`;
    chat.appendChild(inputBar);
    const footer = document.createElement("div");
    footer.className = "bbs-chat-footer";
    footer.textContent = `\u2014 End of chat log \u2014 ${articleTitle} \xB7 ${participants.length} participants \xB7 ${msgIndex} messages \u2014`;
    chat.appendChild(footer);
    content.innerHTML = "";
    content.appendChild(chat);
  }
  function createChatMessage(username, innerHtml, index, side, isHeading = false, publishDate, totalMessages) {
    const container = document.createElement("div");
    container.className = `bbs-chat-msg from-${side}`;
    const avatar = document.createElement("div");
    avatar.className = "bbs-chat-avatar";
    avatar.textContent = username.charAt(0).toUpperCase();
    const bubble = document.createElement("div");
    bubble.className = "bbs-chat-bubble";
    const nameEl = document.createElement("div");
    nameEl.className = "bbs-chat-username";
    nameEl.textContent = username;
    const textEl = document.createElement("div");
    textEl.className = "bbs-chat-text";
    if (isHeading) {
      textEl.innerHTML = innerHtml;
      textEl.style.cssText += "background:transparent; border-color:transparent; font-weight:700;";
      textEl.querySelector("h2, h3, h4")?.style.setProperty("margin", "0");
    } else {
      textEl.innerHTML = innerHtml;
    }
    const timeEl = document.createElement("div");
    timeEl.className = "bbs-chat-time";
    timeEl.textContent = generateTimestamp(index, publishDate ?? /* @__PURE__ */ new Date(), totalMessages ?? 1);
    bubble.appendChild(nameEl);
    bubble.appendChild(textEl);
    bubble.appendChild(timeEl);
    container.appendChild(avatar);
    container.appendChild(bubble);
    return container;
  }

  // src/ts/grid-nav.ts
  function initGridNav() {
    const grid = document.querySelector(".page");
    if (!grid) return;
    const cards = Array.from(grid.querySelectorAll(".bbs-post-card"));
    if (cards.length === 0) return;
    cards.forEach((card) => card.setAttribute("tabindex", "0"));
    function getColCount() {
      const style = getComputedStyle(grid);
      const template = style.gridTemplateColumns;
      return template.split(" ").filter((s) => s.trim() && s !== "none").length;
    }
    function focusCard(idx) {
      if (idx < 0) idx = cards.length - 1;
      if (idx >= cards.length) idx = 0;
      cards[idx].focus();
    }
    function getFocusedIndex() {
      const active = document.activeElement;
      if (!active) return -1;
      return cards.indexOf(active);
    }
    grid.addEventListener("keydown", (e) => {
      const idx = getFocusedIndex();
      if (idx === -1) return;
      const cols = getColCount();
      switch (e.key) {
        case "ArrowRight":
        case "l":
        case "L":
          e.preventDefault();
          focusCard(idx + 1);
          break;
        case "ArrowLeft":
        case "h":
        case "H":
          e.preventDefault();
          focusCard(idx - 1);
          break;
        case "ArrowDown":
        case "j":
        case "J":
          e.preventDefault();
          focusCard(idx + cols);
          break;
        case "ArrowUp":
        case "k":
        case "K":
          e.preventDefault();
          focusCard(idx - cols);
          break;
        case "Enter":
        case " ":
          e.preventDefault();
          cards[idx].click();
          break;
        case "Home":
        case "g":
          e.preventDefault();
          focusCard(0);
          break;
        case "End":
        case "G":
          e.preventDefault();
          focusCard(cards.length - 1);
          break;
      }
    });
    document.addEventListener("keydown", function firstKey(e) {
      if (["h", "j", "k", "l", "g", "G", "ArrowRight", "ArrowLeft", "ArrowDown", "ArrowUp"].includes(e.key)) {
        if (!document.activeElement || document.activeElement === document.body) {
          if (!window.location.pathname.match(/\/blog\/(opinions|tutorials)\/.+/)) {
            focusCard(0);
            const newIdx = getFocusedIndex();
            if (newIdx === 0) {
              setTimeout(() => cards[0].focus(), 10);
            }
          }
        }
        document.removeEventListener("keydown", firstKey);
      }
    });
  }

  // src/ts/storage.ts
  var STORAGE_KEY = "bbs_read";
  var COOKIE_NAME = "bbs_read";
  function migrateCookieIfNeeded() {
    try {
      if (localStorage.getItem(STORAGE_KEY)) return;
      const match = document.cookie.match(new RegExp(`(?:^|; )${COOKIE_NAME}=([^;]*)`));
      if (!match) return;
      const data = JSON.parse(decodeURIComponent(match[1]));
      if (data && typeof data === "object") {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
      }
      document.cookie = `${COOKIE_NAME}=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT`;
    } catch {
    }
  }
  function getReadMap() {
    migrateCookieIfNeeded();
    try {
      return JSON.parse(localStorage.getItem(STORAGE_KEY) || "{}");
    } catch {
      return {};
    }
  }
  function setReadMap(map) {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(map));
    } catch {
    }
  }
  function markRead(path) {
    const map = getReadMap();
    if (map[path]) return;
    map[path] = (/* @__PURE__ */ new Date()).toISOString();
    setReadMap(map);
  }

  // src/ts/read-tracker.ts
  function markArticleRead() {
    const path = window.location.pathname;
    if (!path.match(/\/blog\/.+|\/opinions\/.|\/tutorials\/./)) return;
    markRead(path);
    document.dispatchEvent(new CustomEvent("bbs:read-update", { detail: { path } }));
  }
  function applyNewBadges() {
    const map = getReadMap();
    const cards = document.querySelectorAll(".bbs-post-card");
    const statusBar = document.querySelector(".bbs-header-status");
    if (statusBar) {
      let unread = 0;
      cards.forEach((card) => {
        const href = card.getAttribute("href");
        if (!href) return;
        const path = href.startsWith("http") ? new URL(href).pathname : href;
        if (!map[path]) unread++;
      });
      const existing = statusBar.querySelector(".unread-count");
      if (existing) {
        existing.textContent = `${unread} unread`;
      } else {
        const span = document.createElement("span");
        span.className = "unread-count";
        span.textContent = `${unread} unread`;
        span.style.cssText = "color:var(--term-fg-bright);margin-left:8px;";
        statusBar.appendChild(span);
      }
    }
    cards.forEach((card) => {
      const href = card.getAttribute("href");
      if (!href) return;
      const path = href.startsWith("http") ? new URL(href).pathname : href;
      if (!map[path]) {
        card.classList.add("bbs-unread");
        let badge = card.querySelector(".bbs-new-badge");
        if (!badge) {
          badge = document.createElement("span");
          badge.className = "bbs-new-badge";
          badge.textContent = "NEW";
          card.prepend(badge);
        }
      } else {
        card.classList.remove("bbs-unread");
        const badge = card.querySelector(".bbs-new-badge");
        if (badge) badge.remove();
      }
    });
  }

  // src/ts/forum-threads.ts
  var ARTICLE_JSON = "/assets/articles.json";
  function personaBadge(handle) {
    return `<span class="thread-author">${handle}</span>`;
  }
  function formatDate(iso) {
    if (!iso) return "";
    const d = new Date(iso);
    return d.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" });
  }
  function tagHtml(tag) {
    const t = tag.replace(/[^a-z0-9-]/gi, "").toLowerCase();
    return `<span class="thread-tag" data-tag="${t}">[${tag}]</span>`;
  }
  function renderThreadList(articles, readMap) {
    const container = document.getElementById("forum-thread-list");
    if (!container) return;
    const todayStr = (/* @__PURE__ */ new Date()).toISOString().slice(0, 10);
    const todaysPosts = [];
    const unread = [];
    const read = [];
    for (const a of articles) {
      if (a.slug.startsWith("daily/") && a.date.startsWith(todayStr)) {
        todaysPosts.push(a);
        continue;
      }
      const path = `/blog/${a.slug}`;
      if (readMap[path]) {
        read.push(a);
      } else {
        unread.push(a);
      }
    }
    let html = "";
    if (todaysPosts.length > 0) {
      html += `<div class="thread-section-header today-header"><span>\u{1F4F0} TODAY'S DAILY POSTS (${todaysPosts.length})</span></div>`;
      for (const a of todaysPosts) {
        const isUnread = !readMap[`/blog/${a.slug}`];
        html += renderThread(a, isUnread);
      }
    }
    if (unread.length > 0) {
      html += `<div class="thread-section-header"><span>UNREAD MESSAGES (${unread.length})</span></div>`;
      for (const a of unread) {
        html += renderThread(a, true);
      }
    }
    if (read.length > 0) {
      html += `<div class="thread-section-header"><span>READ MESSAGES (${read.length})</span></div>`;
      for (const a of read) {
        html += renderThread(a, false);
      }
    }
    if (!html) {
      html = '<div class="thread-empty">No threads found.</div>';
    }
    container.innerHTML = html;
    const staticList = document.querySelector(".bbs-static-list");
    if (staticList) staticList.style.display = "none";
    container.querySelectorAll(".forum-thread").forEach((el) => {
      el.addEventListener("click", () => {
        const slug = el.dataset.slug;
        if (slug) {
          markRead(`/blog/${slug}`);
          window.location.href = `/blog/${slug}/`;
        }
      });
    });
  }
  function renderThread(a, isUnread) {
    const badge = isUnread ? '<span class="thread-new-badge">NEW</span>' : "";
    const date = formatDate(a.date);
    const starterHtml = a.starter ? personaBadge(a.starter) : '<span class="thread-author" style="color:var(--term-fg-dim)">System</span>';
    const tagsHtml = a.tags.map((tag) => tagHtml(tag)).join(" ");
    return `
    <div class="forum-thread ${isUnread ? "forum-thread-unread" : "forum-thread-read"}" data-slug="${a.slug}">
      <div class="thread-icon ${isUnread ? "thread-icon-unread" : "thread-icon-read"}">${isUnread ? "\u25B6" : "\u25CF"}</div>
      <div class="thread-body">
        <div class="thread-title">${badge} ${a.title}</div>
        <div class="thread-meta">
          ${starterHtml} \xB7 ${date} \xB7 <span class="thread-replies">${a.posts} ${a.posts === 1 ? "reply" : "replies"}</span>
        </div>
        <div class="thread-desc">${a.description}</div>
        <div class="thread-tags">${tagsHtml}</div>
      </div>
    </div>
  `;
  }
  function renderSkeleton() {
    let html = "";
    for (let i = 0; i < 4; i++) {
      html += `
      <div class="forum-thread thread-skeleton">
        <div class="thread-icon skeleton-icon">\u25CF</div>
        <div class="thread-body">
          <div class="thread-title"><span class="skeleton-bar" style="width:${60 + Math.random() * 30}%"></span></div>
          <div class="thread-meta"><span class="skeleton-bar" style="width:120px"></span></div>
          <div class="thread-desc"><span class="skeleton-bar" style="width:${80 + Math.random() * 15}%"></span></div>
        </div>
      </div>
    `;
    }
    return html;
  }
  function initForumThreads() {
    const container = document.getElementById("forum-thread-list");
    if (!container) return;
    container.innerHTML = renderSkeleton();
    fetch(ARTICLE_JSON).then((r) => r.json()).then((articles) => {
      articles.sort((a, b) => b.date.localeCompare(a.date));
      const readMap = getReadMap();
      renderThreadList(articles, readMap);
    }).catch((err) => {
      console.error("Failed to load articles.json:", err);
      container.innerHTML = '<div class="thread-empty">Could not load threads.</div>';
    });
  }

  // src/ts/candidate-search.ts
  var VARIANT_LABELS = {
    "backend-developer": "Backend Developer",
    "fullstack-developer": "Full-Stack Developer",
    "agentic-engineer": "Agentic Engineer",
    "forward-deployed-swe": "Forward-Deployed SWE",
    base: "Software Engineer"
  };
  var VARIANT_MATCH = {
    "backend-developer": "Backend depth: C#, SQL, .NET, event-driven systems. 15x latency wins on record.",
    "fullstack-developer": "Ships end-to-end: Blazor + .NET + Node. Owns the feature from schema to CSS.",
    "agentic-engineer": "Automation & LLM tooling. Kills toil, rebuilds crusty workflows into pipelines.",
    "forward-deployed-swe": "Client-facing and fast. Drops into your team and delivers without hand-holding.",
    base: "Full-stack generalist, comfortable across the stack and client-facing delivery."
  };
  var STEPS = {
    start: {
      lines: [
        "Initialize candidate search? This will scan the local talent pool",
        "for engineers matching your open role."
      ],
      options: [
        { label: "Yes \u2014 run the search", next: "who" },
        { label: "No \u2014 just browsing", next: "browsing" }
      ]
    },
    browsing: {
      lines: [
        "No problem. For the record, the pool currently contains exactly",
        "one (1) highly available candidate. Run the search anyway?"
      ],
      options: [
        { label: "Yes, go on then", next: "who" },
        { label: "No, I really am just looking", next: "who" }
      ]
    },
    who: {
      lines: ["Are you hiring on behalf of a company (recruiter)?"],
      options: [
        { label: "Yes \u2014 I recruit", next: "need", effect: "recruiter" },
        { label: "No \u2014 hiring manager / tech lead", next: "need" }
      ]
    },
    need: {
      lines: ["Does your team currently need another engineer?"],
      options: [
        { label: "Yes", next: "role" },
        { label: "No", next: "convince" }
      ]
    },
    convince: {
      lines: [
        "Understood. But would you *want* one who ships finished features",
        "you can hand off and forget about?"
      ],
      options: [
        { label: "Yes, fair point", next: "role" },
        { label: "No", next: "convince2" }
      ]
    },
    convince2: {
      lines: ["What if the search is already done and the match is a strong one?"],
      options: [
        { label: "Okay, you have my attention", next: "role" },
        { label: "Fine, convince me", next: "role" }
      ]
    },
    role: {
      lines: ["What is your team missing? (select the closest match)"],
      options: [
        { label: "Backend that stops falling over", next: "match", effect: { variant: "backend-developer" } },
        { label: "A whole feature built end-to-end", next: "match", effect: { variant: "fullstack-developer" } },
        { label: "Automation / better dev workflows", next: "match", effect: { variant: "agentic-engineer" } },
        { label: "Someone to embed & ship with the team", next: "match", effect: { variant: "forward-deployed-swe" } }
      ]
    }
  };
  var state = { isRecruiter: false, variant: "base", path: [] };
  var screen;
  var cursor = 0;
  var currentOptions = [];
  var busy = false;
  var sleep = (ms) => new Promise((r) => setTimeout(r, ms));
  function appendLine(text = "", cls = "") {
    const el = document.createElement("div");
    el.className = `cs-line${cls ? " " + cls : ""}`;
    el.textContent = text;
    screen.appendChild(el);
    screen.scrollTop = screen.scrollHeight;
    return el;
  }
  async function typeLine(text, cls = "", speed = 12) {
    const el = appendLine("", cls);
    for (let i = 0; i < text.length; i++) {
      el.textContent += text[i];
      screen.scrollTop = screen.scrollHeight;
      await sleep(speed);
    }
  }
  function renderOptions() {
    const old = screen.querySelector(".cs-options");
    if (old) old.remove();
    const wrap = document.createElement("div");
    wrap.className = "cs-options";
    wrap.setAttribute("role", "listbox");
    wrap.setAttribute("tabindex", "0");
    wrap.setAttribute("aria-label", "Answer options \u2014 use arrow keys and Enter, or click");
    currentOptions.forEach((opt, i) => {
      const row = document.createElement("div");
      row.className = "cs-option";
      row.setAttribute("role", "option");
      row.dataset.idx = String(i);
      row.innerHTML = `<span class="cs-caret">${i === cursor ? ">" : "\xA0"}</span><span class="cs-opt-label">${opt.label}</span>`;
      row.addEventListener("mouseenter", () => setCursor(i));
      row.addEventListener("click", () => choose(i));
      wrap.appendChild(row);
    });
    const hint = document.createElement("div");
    hint.className = "cs-hint";
    hint.textContent = "[\u2191/\u2193] move   [enter] select   or click";
    wrap.appendChild(hint);
    screen.appendChild(wrap);
    screen.scrollTop = screen.scrollHeight;
    wrap.focus();
  }
  function setCursor(i) {
    cursor = i;
    const rows = screen.querySelectorAll(".cs-option");
    rows.forEach((row, idx) => {
      const caret = row.querySelector(".cs-caret");
      if (caret) caret.textContent = idx === cursor ? ">" : "\xA0";
      row.classList.toggle("active", idx === cursor);
    });
  }
  async function choose(i) {
    if (busy) return;
    const opt = currentOptions[i];
    if (!opt) return;
    busy = true;
    const opts = screen.querySelector(".cs-options");
    if (opts) opts.remove();
    await typeLine(`recruit@ffilt.us:~$ ${opt.label}`, "cs-echo", 6);
    if (opt.effect === "recruiter") state.isRecruiter = true;
    else if (opt.effect && typeof opt.effect === "object") state.variant = opt.effect.variant;
    state.path.push(opt.label);
    busy = false;
    if (opt.next === "match") {
      await runMatch();
    } else {
      await gotoStep(opt.next);
    }
  }
  function onKey(e) {
    if (!currentOptions.length || busy) return;
    if (e.key === "ArrowDown" || e.key === "j") {
      e.preventDefault();
      setCursor((cursor + 1) % currentOptions.length);
    } else if (e.key === "ArrowUp" || e.key === "k") {
      e.preventDefault();
      setCursor((cursor - 1 + currentOptions.length) % currentOptions.length);
    } else if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      void choose(cursor);
    }
  }
  async function gotoStep(id) {
    const step = STEPS[id];
    if (!step) return;
    busy = true;
    appendLine();
    for (const line of step.lines) {
      await typeLine(line, "cs-prompt");
    }
    currentOptions = step.options;
    cursor = 0;
    busy = false;
    renderOptions();
  }
  async function runMatch() {
    busy = true;
    currentOptions = [];
    const v = state.variant;
    const label = VARIANT_LABELS[v] || "Software Engineer";
    appendLine();
    await typeLine(`> scanning talent pool for role: ${label}...`, "cs-sys", 8);
    const bar = appendLine("  [                    ] 0%", "cs-sys");
    for (let p = 0; p <= 20; p++) {
      const filled = "=".repeat(p);
      const pct = Math.round(p / 20 * 100);
      bar.textContent = `  [${(filled + " ".repeat(20)).slice(0, 20)}] ${pct}%`;
      await sleep(45);
    }
    await sleep(200);
    await typeLine("> 1 candidate matched. compiling dossier...", "cs-sys", 8);
    await sleep(300);
    const card = document.createElement("div");
    card.className = "cs-match";
    card.style.setProperty("--persona-color", "var(--term-fg-bright)");
    const anonBtn = state.isRecruiter ? `<a class="cs-btn ghost" href="/assets/resume/${v}-anon.pdf">[ download anonymized (for submission) ]</a>` : "";
    const badge = state.isRecruiter ? '<span class="cs-badge">RECRUITER</span>' : "";
    card.innerHTML = `
    <div class="cs-match-head">*** MATCH FOUND *** ${badge}</div>
    <pre class="cs-match-id">
 name    : Reed Sutliff
 role    : ${label}
 status  : AVAILABLE
 location: Columbus, OH
 match   : 98%</pre>
    <div class="cs-match-note">${VARIANT_MATCH[v] || VARIANT_MATCH.base}</div>
    <div class="cs-actions">
      <a class="cs-btn primary" href="/assets/resume/${v}.pdf">[ download resume ]</a>
      ${anonBtn}
      <a class="cs-btn" href="mailto:sutliff.reed@gmail.com">[ email me ]</a>
      <button class="cs-btn ghost" type="button" id="cs-restart">[ run again ]</button>
    </div>
    <div class="cs-contact">
      linkedin.com/in/reed-sutliff-21213b114 &nbsp;\xB7&nbsp; github.com/reedsutliff &nbsp;\xB7&nbsp; ffilt.us
    </div>`;
    screen.appendChild(card);
    screen.scrollTop = screen.scrollHeight;
    const restart = card.querySelector("#cs-restart");
    restart?.addEventListener("click", () => void boot(true));
    busy = false;
  }
  async function boot(restart = false) {
    screen.innerHTML = "";
    state.isRecruiter = false;
    state.variant = "base";
    state.path = [];
    cursor = 0;
    currentOptions = [];
    await typeLine("SUTLIFF TALENT DB v1.0 \u2014 candidate-search", "cs-sys", 6);
    await typeLine(restart ? "session reset. ready." : "connection established. ready.", "cs-sys", 6);
    await gotoStep("who");
  }
  function initCandidateSearch() {
    const el = document.getElementById("cs-screen");
    if (!el) return;
    screen = el;
    document.addEventListener("keydown", (e) => {
      if (!currentOptions.length) return;
      if (screen.contains(document.activeElement)) onKey(e);
    });
    void boot();
  }

  // src/ts/main.ts
  initBootSequence();
  initThemeToggle();
  document.addEventListener("boot:complete", () => {
    initTypingAnimation();
    initArticleChat();
    initGridNav();
    initForumThreads();
    markArticleRead();
    applyNewBadges();
    initThemeTransitions();
    initConfettiOnToggle();
    initReadProgress();
    initHomePage();
    initConsoleEaster();
    initCandidateSearch();
  }, { once: true });
})();
