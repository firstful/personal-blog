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
    typeEl.style.cssText = "margin-bottom: 1.5em; font-size: 0.95em; color: var(--md-typeset-color);";
    typeEl.innerHTML = '<span>I work with&nbsp;</span><span class="hero-typewriter"></span>';
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
    { text: "[NET] Connected \u2014 Node: PICKERINGTON, OH 57600 baud", cls: "ok", delay: 150 },
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
  function initArticlePage() {
    const isArticle = window.location.pathname.match(/\/blog\/(opinions|tutorials)\/.+/);
    if (!isArticle) return;
    const titleEl = document.querySelector(".md-content__inner h1");
    if (!titleEl) return;
    const articleContent = document.querySelector(".md-content__inner .md-typeset");
    if (!articleContent) return;
    const pageTitle = titleEl.textContent || "Untitled";
    const header = document.createElement("div");
    header.className = "bbs-article-header";
    header.innerHTML = `
    <div>\u250C\u2500 File: ${window.location.pathname.replace(/^\//, "")}</div>
    <div>\u2502  Author: Reed Sutliff</div>
    <div>\u2502  Path: ${window.location.pathname}</div>
    <div>\u2514\u2500</div>
  `;
    titleEl.parentNode?.insertBefore(header, titleEl);
    const existingNav = document.querySelector(".md-content__inner .md-typeset + nav, .md-content__inner nav:last-child");
    if (existingNav) {
      existingNav.classList.add("bbs-article-nav");
    }
  }

  // src/ts/main.ts
  initBootSequence();
  document.addEventListener("boot:complete", () => {
    initTypingAnimation();
    initArticlePage();
    initThemeTransitions();
    initConfettiOnToggle();
    initClickRipple();
    initReadProgress();
    initHomePage();
    initConsoleEaster();
  }, { once: true });
})();
