const { app } = require('@azure/functions');

const DASH_URL = process.env.DASH_URL || 'https://dash.ffilt.us';
const CF_CLIENT_ID = process.env.CF_ACCESS_CLIENT_ID || '';
const CF_CLIENT_SECRET = process.env.CF_ACCESS_CLIENT_SECRET || '';

let cached = null;
let cacheTime = 0;
const CACHE_TTL = 15 * 60 * 1000; // 15 minutes

// ---------------------------------------------------------------------------
// Public redaction.
//
// The upstream dash service enumerates every IngressRoute hostname in the
// homelab (49 of them at the time of writing), each with its backing
// namespace, service name and ClusterIP probe URL. On a public page that is
// a ready-made target list, so the hostname / namespace / service / url /
// probe-detail fields are all stripped here.
//
// Only aggregate counts are published. Note the upstream probe is unreliable
// (it probes the Service ClusterIP directly, which most pods refuse because
// they only listen on their targetPort), so the healthy-count is derived from
// the upstream `probe.up` flag and reported as-is rather than re-derived.
// ---------------------------------------------------------------------------
function redactServices(data) {
  const services = Array.isArray(data.services) ? data.services : [];
  const probed = services.filter(s => s && s.probe);

  return {
    services: {
      total: services.length,
      healthy: probed.filter(s => s.probe.up).length,
      unhealthy: probed.filter(s => !s.probe.up).length
    },
    fetched_at: data.fetched_at
  };
}

app.http('services', {
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

      const res = await fetch(`${DASH_URL}/api/services`, { headers });
      if (!res.ok) {
        return {
          status: 502,
          headers: getCorsHeaders(0),
          jsonBody: { error: `Upstream returned ${res.status}` }
        };
      }

      const data = await res.json();
      const redacted = redactServices(data);
      cached = redacted;
      cacheTime = now;

      return {
        status: 200,
        headers: getCorsHeaders(900),
        jsonBody: redacted
      };
    } catch (err) {
      context.log.error('services proxy error:', err.message);
      return {
        status: 502,
        headers: getCorsHeaders(0),
        jsonBody: { error: 'Failed to fetch services status' }
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
