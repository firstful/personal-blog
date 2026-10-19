const { app } = require('@azure/functions');

const DASH_URL = process.env.DASH_URL || 'https://dash.ffilt.us';
const CF_CLIENT_ID = process.env.CF_ACCESS_CLIENT_ID || '';
const CF_CLIENT_SECRET = process.env.CF_ACCESS_CLIENT_SECRET || '';

// In-memory server-side cache
let cached = null;
let cacheTime = 0;
const CACHE_TTL = 15 * 60 * 1000; // 15 minutes

// ---------------------------------------------------------------------------
// Public redaction.
//
// The upstream dash service returns the raw k3s cluster state: node names,
// node internal IPs, kubelet versions, namespace names, deployment names and
// pod names. None of that belongs on a public, employer-facing page — it maps
// the homelab's internal topology for anyone who opens devtools.
//
// This function is the only public door onto that data, so the redaction
// happens HERE, server-side. The browser never receives the raw payload; it
// only ever sees the aggregate counts below.
// ---------------------------------------------------------------------------
function redactOverview(data) {
  const nodes = Array.isArray(data.nodes)
    ? data.nodes.filter(n => n && typeof n.ready === 'boolean')
    : [];
  const namespaces = Array.isArray(data.namespaces) ? data.namespaces : [];
  const deployments = Array.isArray(data.deployments)
    ? data.deployments.filter(d => d && typeof d.ready === 'number')
    : [];
  const pods = Array.isArray(data.pods)
    ? data.pods.filter(p => p && typeof p.phase === 'string')
    : [];

  return {
    nodes: {
      total: nodes.length,
      ready: nodes.filter(n => n.ready).length
    },
    namespaces: {
      total: namespaces.length
    },
    deployments: {
      total: deployments.length,
      ready: deployments.filter(d => d.ready > 0).length
    },
    pods: {
      total: pods.length,
      running: pods.filter(p => p.phase === 'Running').length
    },
    fetched_at: data.fetched_at
  };
}

app.http('overview', {
  methods: ['GET'],
  authLevel: 'anonymous',
  handler: async (request, context) => {
    try {
      const now = Date.now();
      if (cached && (now - cacheTime) < CACHE_TTL) {
        return {
          status: 200,
          headers: getCorsHeaders(900),
          jsonBody: cached
        };
      }

      const headers = {};
      if (CF_CLIENT_ID) headers['CF-Access-Client-Id'] = CF_CLIENT_ID;
      if (CF_CLIENT_SECRET) headers['CF-Access-Client-Secret'] = CF_CLIENT_SECRET;

      const res = await fetch(`${DASH_URL}/api/overview`, { headers });
      if (!res.ok) {
        return {
          status: 502,
          headers: getCorsHeaders(0),
          jsonBody: { error: `Upstream returned ${res.status}` }
        };
      }

      const data = await res.json();
      const redacted = redactOverview(data);
      cached = redacted;
      cacheTime = now;

      return {
        status: 200,
        headers: getCorsHeaders(900),
        jsonBody: redacted
      };
    } catch (err) {
      context.log.error('overview proxy error:', err.message);
      return {
        status: 502,
        headers: getCorsHeaders(0),
        jsonBody: { error: 'Failed to fetch cluster overview' }
      };
    }
  }
});

function getCorsHeaders(maxAge) {
  return {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Cache-Control': maxAge > 0 ? `public, max-age=${maxAge}` : 'no-cache'
  };
}
