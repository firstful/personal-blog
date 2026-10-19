const { app } = require('@azure/functions');

const DASH_URL = process.env.DASH_URL || 'https://dash.ffilt.us';
const CF_CLIENT_ID = process.env.CF_ACCESS_CLIENT_ID || '';
const CF_CLIENT_SECRET = process.env.CF_ACCESS_CLIENT_SECRET || '';

// In-memory server-side cache
let cached = null;
let cacheTime = 0;
const CACHE_TTL = 15 * 60 * 1000; // 15 minutes

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
      cached = data;
      cacheTime = now;

      return {
        status: 200,
        headers: getCorsHeaders(900),
        jsonBody: data
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