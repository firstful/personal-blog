const { app } = require('@azure/functions');

const GITEA_URL = process.env.GITEA_URL || 'https://gitea.ffilt.us';
const CF_CLIENT_ID = process.env.CF_ACCESS_CLIENT_ID || '';
const CF_CLIENT_SECRET = process.env.CF_ACCESS_CLIENT_SECRET || '';

let cached = null;
let cacheTime = 0;
const CACHE_TTL = 24 * 60 * 60 * 1000; // 24 hours

app.http('heatmap', {
  methods: ['GET'],
  authLevel: 'anonymous',
  handler: async (request, context) => {
    try {
      const now = Date.now();
      if (cached && (now - cacheTime) < CACHE_TTL) {
        return {
          status: 200,
          headers: getCorsHeaders(86400),
          jsonBody: cached
        };
      }

      const headers = {};
      if (CF_CLIENT_ID) headers['CF-Access-Client-Id'] = CF_CLIENT_ID;
      if (CF_CLIENT_SECRET) headers['CF-Access-Client-Secret'] = CF_CLIENT_SECRET;

      const res = await fetch(`${GITEA_URL}/api/v1/users/reeds/heatmap`, { headers });
      if (!res.ok) {
        return {
          status: 502,
          headers: getCorsHeaders(0),
          jsonBody: { error: `Gitea returned ${res.status}` }
        };
      }

      const raw = await res.json();

      // Gitea returns [{timestamp: unix, count: N}, ...]
      // Aggregate hourly entries to daily counts
      const dailyMap = {};
      for (const entry of raw) {
        const date = new Date(entry.timestamp * 1000).toISOString().slice(0, 10);
        dailyMap[date] = (dailyMap[date] || 0) + (entry.contributions || entry.count || 0);
      }

      const aggregated = Object.entries(dailyMap).map(([date, count]) => ({
        date,
        count
      }));

      cached = aggregated;
      cacheTime = now;

      return {
        status: 200,
        headers: getCorsHeaders(86400),
        jsonBody: aggregated
      };
    } catch (err) {
      context.log.error('heatmap proxy error:', err.message);
      return {
        status: 502,
        headers: getCorsHeaders(0),
        jsonBody: { error: 'Failed to fetch contribution heatmap' }
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