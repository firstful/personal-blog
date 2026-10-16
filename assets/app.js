/**
 * Reed Sutliff — Homelab Dashboard
 * SPA logic: fetches data from Azure Functions API, renders sections.
 */

(function () {
  'use strict';

  // ===== Config =====
  const CACHE_TTL = 15 * 60 * 1000; // 15 minutes
  const HEATMAP_CACHE_TTL = 24 * 60 * 60 * 1000; // 24 hours
  const MAX_RECENT = 10;

  // ===== Utilities =====
  function cacheGet(key, ttl) {
    try {
      const raw = localStorage.getItem(key);
      if (!raw) return null;
      const { data, ts } = JSON.parse(raw);
      if (Date.now() - ts > ttl) return null;
      return data;
    } catch {
      return null;
    }
  }

  function cacheSet(key, data) {
    try {
      localStorage.setItem(key, JSON.stringify({ data, ts: Date.now() }));
    } catch { /* quota exceeded — fine */ }
  }

  async function fetchJSON(url, cacheKey, ttl) {
    const cached = cacheKey ? cacheGet(cacheKey, ttl) : null;
    if (cached) return cached;
    const res = await fetch(url);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    if (cacheKey) cacheSet(cacheKey, data);
    return data;
  }

  function formatDate(dateStr) {
    const d = new Date(dateStr);
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  }

  function escapeHtml(str) {
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }

  function formatTimestamp(ts) {
    if (!ts) return '';
    const d = new Date(ts);
    return `Updated ${d.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}`;
  }

  // ===== Intersection Observer for Animations =====
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('animate-in');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1 });

  function observeElements(selector) {
    document.querySelectorAll(selector).forEach(el => observer.observe(el));
  }

  // ===== Recent Work =====
  async function loadRecentWork() {
    const container = document.getElementById('recent-work-list');
    try {
      const entries = await fetchJSON('/data/recent-work.json', 'recent-work-cache', CACHE_TTL);
      const items = Array.isArray(entries) ? entries.slice(0, MAX_RECENT) : [];

      if (items.length === 0) {
        container.innerHTML = '<div class="empty-state">No recent activity yet.</div>';
        return;
      }

      // Sort by date descending
      items.sort((a, b) => new Date(b.date) - new Date(a.date));

      container.innerHTML = items.map(item => {
        const catClass = `category-${(item.category || '').replace(/\s+/g, '-')}`;
        return `
          <div class="work-card">
            <div class="work-card-header">
              <h3>${escapeHtml(item.title)}</h3>
              <span class="work-date">${formatDate(item.date)}</span>
            </div>
            <span class="work-category ${catClass}">${escapeHtml(item.category || 'general')}</span>
            <p>${escapeHtml(item.summary)}</p>
          </div>
        `;
      }).join('');

      observeElements('.work-card');
    } catch (err) {
      container.innerHTML = `
        <div class="error-message">
          <p>Could not load recent work.</p>
          <p><span class="retry-link" onclick="location.reload()">Retry</span></p>
        </div>`;
      console.error('Failed to load recent work:', err);
    }
  }

  // ===== Cluster Status =====
  async function loadClusterStatus(forceRefresh) {
    if (forceRefresh) {
      localStorage.removeItem('cluster-overview-cache');
      localStorage.removeItem('cluster-services-cache');
    }

    const overviewEl = document.getElementById('cluster-overview');
    const servicesEl = document.getElementById('cluster-services');
    const tsEl = document.getElementById('cluster-last-updated');

    try {
      const [overview, services] = await Promise.all([
        fetchJSON('/api/overview', 'cluster-overview-cache', CACHE_TTL),
        fetchJSON('/api/services', 'cluster-services-cache', CACHE_TTL)
      ]);

      // Timestamp
      const cachedOverview = JSON.parse(localStorage.getItem('cluster-overview-cache') || '{}');
      tsEl.textContent = formatTimestamp(cachedOverview.ts);

      renderOverview(overview);
      renderServices(services);
    } catch (err) {
      overviewEl.innerHTML = `
        <div class="error-message">
          <p>Could not load cluster status.</p>
          <p><span class="retry-link" onclick="window.loadClusterStatus(true)">Retry</span></p>
        </div>`;
      servicesEl.innerHTML = '';
      console.error('Failed to load cluster status:', err);
    }
  }

  function renderOverview(data) {
    const container = document.getElementById('cluster-overview');
    const nodes = data.nodes || [];

    // Nodes card
    const nodesHtml = `
      <div class="overview-card">
        <h3>Nodes (${nodes.length})</h3>
        ${nodes.map(n => `
          <div class="node-item" data-node='${JSON.stringify(n)}' style="cursor:pointer">
            <div>
              <span class="node-name">${escapeHtml(n.name)}</span>
              <span class="node-role">${escapeHtml(n.role || '')}</span>
            </div>
            <div class="node-meta">
              <span class="node-version">${escapeHtml(n.version || '')}</span>
              <span class="status-dot ${n.ready ? 'ready' : 'not-ready'}" title="${n.ready ? 'Ready' : 'Not Ready'}"></span>
            </div>
          </div>
        `).join('')}
      </div>
    `;

    // Summary card
    const totalDeployments = (data.deployments || []).length;
    const readyDeployments = (data.deployments || []).filter(d => d.ready).length;
    const totalServices = (data.services || data.endpoints || []).length;
    const healthyServices = (data.services || data.endpoints || []).filter(s => s.healthy !== false).length;

    const summaryHtml = `
      <div class="overview-card">
        <h3>Summary</h3>
        <div class="node-item">
          <span class="node-name">Nodes Online</span>
          <span class="node-meta">
            <span class="status-dot ${nodes.every(n => n.ready) ? 'ready' : 'not-ready'}"></span>
            ${nodes.filter(n => n.ready).length}/${nodes.length}
          </span>
        </div>
        <div class="node-item">
          <span class="node-name">Deployments Ready</span>
          <span class="node-meta">${readyDeployments}/${totalDeployments}</span>
        </div>
        <div class="node-item">
          <span class="node-name">Services Healthy</span>
          <span class="node-meta">${healthyServices}/${totalServices}</span>
        </div>
      </div>
    `;

    container.innerHTML = nodesHtml + summaryHtml;

    // Click handler for node details
    container.querySelectorAll('.node-item[data-node]').forEach(el => {
      el.addEventListener('click', () => {
        try {
          const node = JSON.parse(el.dataset.node);
          openModal('Node Details', renderNodeDetail(node));
        } catch { /* ignore */ }
      });
    });
  }

  function renderNodeDetail(node) {
    const entries = Object.entries(node);
    return `
      <div style="display:flex;flex-direction:column;gap:8px;">
        ${entries.map(([k, v]) => `
          <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid var(--border);">
            <span style="color:var(--text-muted);font-size:13px;text-transform:capitalize;">${escapeHtml(k)}</span>
            <span style="font-family:var(--font-mono);font-size:13px;">${escapeHtml(String(v))}</span>
          </div>
        `).join('')}
      </div>
    `;
  }

  function renderServices(data) {
    const container = document.getElementById('cluster-services');
    const services = Array.isArray(data) ? data : (data.services || data.endpoints || []);

    if (services.length === 0) {
      container.innerHTML = '<div class="empty-state">No services found.</div>';
      return;
    }

    container.innerHTML = `
      <table class="services-table">
        <thead>
          <tr>
            <th>Host</th>
            <th>Status</th>
            <th>Latency</th>
          </tr>
        </thead>
        <tbody>
          ${services.map(s => {
            const latency = s.latency_ms ?? s.latency ?? null;
            let latencyClass = '';
            if (latency !== null) {
              if (latency < 200) latencyClass = 'latency-good';
              else if (latency < 500) latencyClass = 'latency-warn';
              else latencyClass = 'latency-bad';
            }
            const isHealthy = s.healthy !== false && s.status !== 'down';
            return `
              <tr>
                <td class="host-cell">
                  ${s.url ? `<a href="${escapeHtml(s.url)}" target="_blank" rel="noopener">${escapeHtml(s.host || s.name || '')}</a>` : escapeHtml(s.host || s.name || '')}
                </td>
                <td class="status-cell">
                  <span class="status-dot ${isHealthy ? 'ready' : 'not-ready'}"></span>
                  ${isHealthy ? 'Healthy' : 'Down'}
                </td>
                <td class="${latencyClass}">${latency !== null ? `${latency}ms` : '—'}</td>
              </tr>
            `;
          }).join('')}
        </tbody>
      </table>
    `;
  }

  // ===== Contributions Heatmap =====
  async function loadHeatmap() {
    const container = document.getElementById('heatmap-container');
    try {
      const rawData = await fetchJSON('/api/heatmap', 'heatmap-cache', HEATMAP_CACHE_TTL);

      // API returns either an array of {date, count} or the pre-aggregated form
      const entries = Array.isArray(rawData) ? rawData : [];

      // Build a date→count map
      const countMap = {};
      entries.forEach(e => {
        // Handle both {date, count} and {timestamp, count} formats
        const dateStr = e.date || (e.timestamp ? new Date(e.timestamp * 1000).toISOString().slice(0, 10) : null);
        if (dateStr) {
          countMap[dateStr] = (countMap[dateStr] || 0) + (e.count || 0);
        }
      });

      renderHeatmap(container, countMap);
    } catch (err) {
      container.innerHTML = `
        <div class="error-message">
          <p>Could not load contribution data.</p>
          <p><span class="retry-link" onclick="window.loadHeatmap()">Retry</span></p>
        </div>`;
      console.error('Failed to load heatmap:', err);
    }
  }

  function renderHeatmap(container, countMap) {
    // Build ~6 months of weeks (26 weeks)
    const today = new Date();
    const weeks = [];
    const monthLabels = [];
    let currentDate = new Date(today);
    currentDate.setDate(currentDate.getDate() - (currentDate.getDay())); // Start on Sunday

    const startDate = new Date(currentDate);
    startDate.setDate(startDate.getDate() - (26 * 7)); // Go back ~26 weeks
    // Align to Sunday
    startDate.setDate(startDate.getDate() - startDate.getDay());

    let current = new Date(startDate);
    let lastMonth = -1;

    while (current <= today) {
      const week = [];
      const weekStart = new Date(current);
      const month = current.getMonth();

      // Track month boundaries for labels
      if (month !== lastMonth) {
        const monthName = current.toLocaleDateString('en-US', { month: 'short' });
        monthLabels.push({ index: weeks.length, name: monthName });
        lastMonth = month;
      }

      for (let d = 0; d < 7; d++) {
        const dateStr = current.toISOString().slice(0, 10);
        const count = countMap[dateStr] || 0;
        let level = 0;
        if (count >= 1 && count <= 3) level = 1;
        else if (count >= 4 && count <= 6) level = 2;
        else if (count >= 7 && count <= 10) level = 3;
        else if (count >= 11) level = 4;

        week.push({
          date: dateStr,
          count,
          level,
          future: current > today
        });
        current.setDate(current.getDate() + 1);
      }
      weeks.push(week);
    }

    // Build month label row
    const monthLabelHtml = monthLabels.map(m => {
      return `<span class="heatmap-month-label" style="margin-left:${m.index * 16}px;position:absolute;">${m.name}</span>`;
    }).join('');

    // Day labels
    const dayLabels = ['', 'Mon', '', 'Wed', '', 'Fri', ''];

    container.innerHTML = `
      <div class="heatmap-scroll">
        <div style="position:relative;height:18px;margin-bottom:4px;">
          ${monthLabelHtml}
        </div>
        <div style="display:flex;">
          <div class="heatmap-day-labels">
            ${dayLabels.map(l => `<span>${l}</span>`).join('')}
          </div>
          <div class="heatmap-grid">
            ${weeks.map(week => `
              <div class="heatmap-week">
                ${week.map(day => `
                  <div class="heatmap-day ${day.future ? '' : `level-${day.level}`}"
                       title="${day.future ? '' : `${day.date}: ${day.count} contribution${day.count !== 1 ? 's' : ''}`}"
                       ${day.future ? 'style="opacity:0.2"' : ''}
                  ></div>
                `).join('')}
              </div>
            `).join('')}
          </div>
        </div>
        <div class="heatmap-legend">
          <span>Less</span>
          <div class="heatmap-legend-box heatmap-day" style="margin:0 2px;"></div>
          <div class="heatmap-legend-box heatmap-day level-1" style="margin:0 2px;"></div>
          <div class="heatmap-legend-box heatmap-day level-2" style="margin:0 2px;"></div>
          <div class="heatmap-legend-box heatmap-day level-3" style="margin:0 2px;"></div>
          <div class="heatmap-legend-box heatmap-day level-4" style="margin:0 2px;"></div>
          <span>More</span>
        </div>
      </div>
    `;
  }

  // ===== Modal =====
  function openModal(title, bodyHtml) {
    const modal = document.getElementById('cluster-modal');
    document.getElementById('modal-title').textContent = title;
    document.getElementById('modal-body').innerHTML = bodyHtml;
    modal.hidden = false;
    document.body.style.overflow = 'hidden';
  }

  function closeModal() {
    const modal = document.getElementById('cluster-modal');
    modal.hidden = true;
    document.body.style.overflow = '';
  }

  document.getElementById('modal-close').addEventListener('click', closeModal);
  document.getElementById('cluster-modal').addEventListener('click', (e) => {
    if (e.target === e.currentTarget) closeModal();
  });
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeModal();
  });

  // ===== Refresh Button =====
  document.getElementById('refresh-cluster').addEventListener('click', () => {
    loadClusterStatus(true);
  });

  // ===== Expose for retry links =====
  window.loadClusterStatus = loadClusterStatus;
  window.loadHeatmap = loadHeatmap;

  // ===== Init =====
  async function init() {
    // Fire all sections in parallel
    await Promise.allSettled([
      loadRecentWork(),
      loadClusterStatus(false),
      loadHeatmap()
    ]);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();