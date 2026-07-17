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

  // src/ts/ripple.ts
  function initClickRipple() {
    document.addEventListener("click", (e) => {
      if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
      const ripple = document.createElement("div");
      ripple.className = "click-ripple";
      ripple.style.left = `${e.clientX - 60}px`;
      ripple.style.top = `${e.clientY - 60}px`;
      document.body.appendChild(ripple);
      ripple.addEventListener("animationend", () => ripple.remove());
    });
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
    const cursor = document.createElement("span");
    cursor.className = "cursor";
    cursor.style.display = "none";
    heroTagline.after(cursor);
    let index = 0;
    const charsPerTick = 1;
    const baseDelay = 35;
    function typeTick() {
      if (index >= text.length) {
        cursor.style.display = "inline-block";
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
        cursor.style.display = "inline-block";
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
  function generateTimestamp(index) {
    const base = /* @__PURE__ */ new Date();
    base.setHours(20 + Math.floor(index / 20), index * 3 % 60);
    return base.toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit", hour12: false });
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
    for (let i = 0; i < children.length; i++) {
      const el = children[i];
      if (el.tagName === "H1") continue;
      if (el.classList.contains("bbs-article-header")) continue;
      if (el.tagName === "STYLE") continue;
      if (el.tagName === "BLOCKQUOTE") {
        const currentSock = socks[msgIndex % socks.length];
        const msg = createChatMessage(currentSock, el.innerHTML, msgIndex, "sock");
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
          const msg2 = createChatMessage("ffiltus", el.outerHTML, msgIndex, "ffiltus", true);
          chat.appendChild(msg2);
          msgIndex++;
          continue;
        }
        const msg = createChatMessage("ffiltus", el.outerHTML, msgIndex, "ffiltus");
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
  function createChatMessage(username, innerHtml, index, side, isHeading = false) {
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
    timeEl.textContent = generateTimestamp(index);
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

  // src/ts/read-tracker.ts
  var COOKIE_NAME = "bbs_read";
  var COOKIE_EXPIRY_DAYS = 90;
  function getReadMap() {
    const match = document.cookie.match(new RegExp(`(?:^|; )${COOKIE_NAME}=([^;]*)`));
    if (!match) return {};
    try {
      return JSON.parse(decodeURIComponent(match[1]));
    } catch {
      return {};
    }
  }
  function setReadMap(map) {
    const encoded = encodeURIComponent(JSON.stringify(map));
    const expires = /* @__PURE__ */ new Date();
    expires.setDate(expires.getDate() + COOKIE_EXPIRY_DAYS);
    document.cookie = `${COOKIE_NAME}=${encoded}; path=/; expires=${expires.toUTCString()}; SameSite=Lax`;
  }
  function markArticleRead() {
    const path = window.location.pathname;
    if (!path.match(/\/blog\/.+|\/opinions\/.|\/tutorials\/./)) return;
    const map = getReadMap();
    if (map[path]) return;
    map[path] = (/* @__PURE__ */ new Date()).toISOString();
    setReadMap(map);
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

  // src/ts/console-tray.ts
  var TYPING_SPEED = 30;
  var STORAGE_KEY = "bbs_tasks";
  var tasks = [];
  var nextTaskId = 1;
  function loadTasks() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw) {
        tasks = JSON.parse(raw);
        nextTaskId = tasks.length > 0 ? Math.max(...tasks.map((t) => t.id)) + 1 : 1;
      }
    } catch {
      tasks = [];
    }
  }
  function saveTasks() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(tasks));
  }
  var outputEl = null;
  var inputEl = null;
  var trayEl = null;
  var cmdHistory = [];
  var historyIdx = -1;
  function pathToSlug(href) {
    try {
      const url = new URL(href, window.location.origin);
      let path = url.pathname.replace(/\/$/, "");
      if (!path || path === "") return "home";
      const parts = path.split("/").filter(Boolean);
      return parts.join("/");
    } catch {
      return "?";
    }
  }
  function writeln(text, cls = "") {
    if (!outputEl) return;
    const line = document.createElement("div");
    line.className = `bbs-console-line${cls ? " " + cls : ""}`;
    line.textContent = text;
    outputEl.appendChild(line);
    outputEl.scrollTop = outputEl.scrollHeight;
  }
  function typeToConsole(text, onDone) {
    if (!outputEl) {
      onDone();
      return;
    }
    const line = document.createElement("div");
    line.className = "bbs-console-line bbs-console-cmd";
    outputEl.appendChild(line);
    let i = 0;
    function tick() {
      if (i >= text.length) {
        onDone();
        return;
      }
      line.textContent += text[i];
      i++;
      outputEl.scrollTop = outputEl.scrollHeight;
      setTimeout(tick, TYPING_SPEED + Math.random() * 15);
    }
    tick();
  }
  function formatTasks() {
    if (tasks.length === 0) return "No tasks. Use /addtask <description> to create one.";
    return tasks.map(
      (t, i) => `  ${i + 1}. [${t.done ? "\u2713" : " "}] ${t.text}`
    ).join("\n");
  }
  function executeCommand(cmd) {
    const trimmed = cmd.trim();
    if (!trimmed) return;
    writeln(`ffilt.us:~$ ${trimmed}`, "bbs-console-input-line");
    const parts = trimmed.split(/\s+/);
    const verb = parts[0].toLowerCase();
    const args = parts.slice(1);
    switch (verb) {
      case "/help":
        writeln([
          "Available commands:",
          "  /help          \u2014 Show this help",
          "  /tasks         \u2014 List all tasks",
          "  /addtask <txt> \u2014 Add a new task",
          "  /donetask <n>  \u2014 Mark task N as done",
          "  /deltask <n>   \u2014 Delete task N",
          "  nav <path>     \u2014 Navigate to a page",
          "  clear          \u2014 Clear the console",
          "  echo <text>    \u2014 Echo text back"
        ].join("\n"), "bbs-console-response");
        break;
      case "/tasks":
        writeln(formatTasks(), "bbs-console-response");
        break;
      case "/addtask":
      case "/add":
        if (args.length === 0) {
          writeln("Usage: /addtask <description>", "bbs-console-error");
          break;
        }
        const task = {
          id: nextTaskId++,
          text: args.join(" "),
          done: false,
          createdAt: (/* @__PURE__ */ new Date()).toISOString()
        };
        tasks.push(task);
        saveTasks();
        writeln(`Task added: "${task.text}" (#${task.id})`, "bbs-console-response");
        break;
      case "/donetask":
      case "/done":
      case "/check":
        {
          const n = parseInt(args[0], 10);
          if (isNaN(n) || n < 1 || n > tasks.length) {
            writeln("Usage: /donetask <N> (see /tasks for numbers)", "bbs-console-error");
            break;
          }
          tasks[n - 1].done = true;
          saveTasks();
          writeln(`Task ${n} marked done: "${tasks[n - 1].text}"`, "bbs-console-response");
        }
        break;
      case "/deltask":
      case "/del":
      case "/rm":
        {
          const n = parseInt(args[0], 10);
          if (isNaN(n) || n < 1 || n > tasks.length) {
            writeln("Usage: /deltask <N> (see /tasks for numbers)", "bbs-console-error");
            break;
          }
          const removed = tasks.splice(n - 1, 1)[0];
          saveTasks();
          writeln(`Task deleted: "${removed.text}"`, "bbs-console-response");
        }
        break;
      case "clear":
      case "cls":
        if (outputEl) outputEl.innerHTML = "";
        break;
      case "echo":
        writeln(args.join(" "), "bbs-console-response");
        break;
      case "nav":
        if (args.length === 0) {
          writeln('Usage: nav <path> (e.g. "nav blog/opinions")', "bbs-console-error");
          break;
        }
        const target = args[0];
        writeln(`Navigating to /${target}...`, "bbs-console-response");
        setTimeout(() => {
          window.location.href = `/${target}`;
        }, 300);
        break;
      default:
        writeln(`Unknown command: ${verb}. Type /help for available commands.`, "bbs-console-error");
        break;
    }
  }
  function handleLinkClick(e) {
    const link = e.target.closest("a");
    if (!link) return;
    const href = link.getAttribute("href");
    if (!href) return;
    const url = new URL(href, window.location.origin);
    if (url.origin !== window.location.origin) return;
    if (url.pathname === window.location.pathname && url.hash) return;
    const skipPatterns = [/\.(xml|rss|pdf|zip|png|jpg|svg|ico)$/i, /\/feed_/];
    if (skipPatterns.some((p) => p.test(href))) return;
    if (href.includes("feed_rss")) return;
    e.preventDefault();
    const slug = pathToSlug(href);
    typeToConsole(`nav ${slug}`, () => {
      setTimeout(() => {
        window.location.href = href;
      }, 200);
    });
  }
  function onInputKeydown(e) {
    if (!inputEl) return;
    if (e.key === "Enter") {
      const cmd = inputEl.value;
      inputEl.value = "";
      historyIdx = -1;
      if (cmd.trim()) {
        cmdHistory.push(cmd.trim());
        executeCommand(cmd);
      }
      return;
    }
    if (e.key === "ArrowUp") {
      e.preventDefault();
      if (cmdHistory.length === 0) return;
      historyIdx = Math.min(historyIdx + 1, cmdHistory.length - 1);
      inputEl.value = cmdHistory[cmdHistory.length - 1 - historyIdx];
      return;
    }
    if (e.key === "ArrowDown") {
      e.preventDefault();
      if (historyIdx <= 0) {
        historyIdx = -1;
        inputEl.value = "";
        return;
      }
      historyIdx--;
      inputEl.value = cmdHistory[cmdHistory.length - 1 - historyIdx];
      return;
    }
  }
  function createConsoleTray() {
    loadTasks();
    trayEl = document.createElement("div");
    trayEl.className = "bbs-console-tray";
    trayEl.innerHTML = `
    <div class="bbs-console-output" tabindex="-1"></div>
    <div class="bbs-console-input-line">
      <span class="bbs-console-prompt-text">ffilt.us:~$&nbsp;</span>
      <input type="text" class="bbs-console-input" spellcheck="false" autocomplete="off" />
    </div>
  `;
    document.body.appendChild(trayEl);
    outputEl = trayEl.querySelector(".bbs-console-output");
    inputEl = trayEl.querySelector(".bbs-console-input");
    trayEl.addEventListener("click", () => inputEl?.focus());
    inputEl.addEventListener("keydown", onInputKeydown);
    writeln("SUTLIFF BBS v1.0 \u2014 Type /help for commands.", "bbs-console-welcome");
  }
  function initConsoleTray() {
    createConsoleTray();
    const attach = () => {
      document.addEventListener("click", handleLinkClick);
    };
    if (document.querySelector("#boot-screen")) {
      document.addEventListener("boot:complete", attach, { once: true });
    } else {
      attach();
    }
  }

  // src/ts/main.ts
  initBootSequence();
  document.addEventListener("boot:complete", () => {
    initTypingAnimation();
    initArticleChat();
    initGridNav();
    initConsoleTray();
    markArticleRead();
    applyNewBadges();
    initThemeTransitions();
    initConfettiOnToggle();
    initClickRipple();
    initReadProgress();
    initHomePage();
    initConsoleEaster();
  }, { once: true });
})();
