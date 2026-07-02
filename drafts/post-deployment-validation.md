---
tags:
    - Tutorial
    - DevOps
    - Validation
    - Automation
    - Deployment
description: |
    What can go wrong between git push and live site — and how to catch it
    automatically. A practical guide to post-deployment validation for solo
    infrastructure engineers.
image: https://blog.ffilt.us/assets/logo.png
---

# Post-Deployment Validation: What I Check After Every Automated Deploy

I have a cron job that pushes content to a static site, waits fifteen seconds, then curls the production URL to check the HTTP status code. It's one line of shell — `curl -s -o /dev/null -w "%{http_code}"` — and it catches more deploy failures than any CI pipeline I've ever configured.

The CI pipeline told me the build succeeded. The curl told me the site was actually serving content. Those are not the same thing.

## Why Post-Deploy Validation Matters

Continuous deployment gives you a dangerous superpower: the ability to ship broken software faster than ever before. The CI pipeline checks that the code compiles, the tests pass, and the artifacts are built. It does not check that the running service is healthy after the deploy. It cannot, because the deploy target is a different system.

This gap is where most of my production incidents have lived:

- **Azure Static Web Apps builds succeed even when the site configuration is broken.** Your framework compiles fine. Your custom 404 page has a syntax error. Congratulations, your site deploys and returns 500s for every route. The CI pipeline reports green.

- **DNS propagation doesn't happen on CI's timeline.** The new deployment is healthy on the staging URL but the production domain still points at the old slot. Your curl to the production URL returns last week's content. The CI pipeline calls it a success.

- **Edge caching can mask failures.** Cloudflare, Fastly, or Azure Front Door serve stale cache while your origin is on fire. Users see the old, working site. You see green dashboards. The cache TTL expires and suddenly everyone sees the error page. The gap between "deploy succeeded" and "deploy is visible to users" can be hours.

The solution is not to fix CI — CI is doing its job. The solution is a second verification layer that checks the system from the outside, the way a user would.

## The Three-Layer Validation Model

I've settled on a pattern I call "three-layer validation" — three checks that each cover a different failure mode, ordered by cost and complexity:

### Layer 1: HTTP Status Check (Cheap, Fast)

This is the fifteen-second curl. It costs nothing to run and catches the most common failure: the server is returning errors.

```bash
STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://blog.ffilt.us/)
if [ "$STATUS" != "200" ]; then
  echo "Deploy failed: status $STATUS"
  exit 1
fi
```

This catches:
- 500-series errors from broken configs
- 404s from missing index files
- 302 redirect loops
- 4xx from auth/access control misconfiguration

It does NOT catch:
- Wrong content being served (a 200 with last week's homepage)
- Missing assets (CSS, JS, images returning 404)
- Broken navigation or internal links

### Layer 2: Content Fingerprint (Moderate)

The status check tells you the server is running. It doesn't tell you it's running the right thing. For static sites, the simplest content fingerprint is an RSS feed check — parse the most recent entry and verify it matches what you just deployed.

```bash
RECENT=$(curl -s https://blog.ffilt.us/feed_rss_created.xml \
  | grep -o '<title>[^<]*</title>' | head -1)
if echo "$RECENT" | grep -q "$EXPECTED_TITLE"; then
  echo "Content confirmed: $RECENT"
else
  echo "Content mismatch — possible stale deploy"
fi
```

This catches:
- Stale cache serving old content
- Wrong slot being active (slot-swap failures)
- Build that succeeded but produced incorrect output

For non-static sites, check a known API response body, a database row count, or a metric that changes with every deploy (deploy timestamp, version header, etc.).

### Layer 3: UX Smoke Test (Expensive, Thorough)

Every few deploys — or immediately after infrastructure changes — I'll run a browser-based smoke test that loads the page, checks for JavaScript errors, verifies that critical CSS is loaded, and clicks through the main navigation paths. This is overkill for every deploy but essential after:

- Framework or theme upgrades
- CDN or edge configuration changes
- Domain or certificate renewals
- Template refactors

Playwright makes this straightforward:

```javascript
const { chromium } = require('playwright');

async function smokeTest() {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  
  page.on('console', msg => {
    if (msg.type() === 'error') console.log('JS Error:', msg.text());
  });

  await page.goto('https://blog.ffilt.us/');
  const title = await page.title();
  console.log('Page title:', title);

  // Check critical paths load 200
  const responses = await Promise.all([
    page.goto('https://blog.ffilt.us/blog/'),
    page.goto('https://blog.ffilt.us/feed_rss_created.xml'),
  ]);
  responses.forEach(r => console.log(r.url(), r.status()));

  await browser.close();
}
```

## Integrating Validation into a Deployment Pipeline

The key insight is that validation should block the next step in the pipeline, not just log a warning. A warning in the logs is noise. A failed validation that stops the deployment is a signal.

My blog pipeline works like this:

1. **Content push** → triggers Azure SWA build
2. **Wait 15 seconds** (Azure SWA takes ~10s from trigger to deploy)
3. **Layer 1 check** → if not 200, abort and report
4. **Layer 2 check** → if content mismatch, log but don't abort (stale cache usually resolves within a minute)
5. **Write report** → summarize what was deployed, what was checked, and what the site returned

The abort on Layer 1 is important. If the site returns 500 after a deploy, I want to know immediately so I can either roll back or investigate before the broken site accumulates traffic. The fifteen-second delay is empirical — it's the minimum time I've found between "build complete" and "site serves the new content."

## What Validation Has Caught

In the last month of running this pipeline:

- **Three cache-stale incidents** where Cloudflare served an old version for 30-90 seconds after deploy (Layer 2 caught these)
- **One MkDocs config regression** where a theme plugin update broke the RSS feed generation (Layer 1 caught it because the build succeeded but the site returned 500 for the root path)
- **Two false alarms** where the validation ran before Azure SWA finished deploying (increased the wait time from 10s to 15s — haven't seen a false alarm since)

The false alarms are worth noting. If your validation runs before the deploy is complete, it will report failures that aren't real. The fix isn't to remove validation — it's to add retries with backoff:

```bash
for i in 1 2 3; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
  if [ "$STATUS" == "200" ]; then
    echo "Site healthy (attempt $i)"
    break
  fi
  echo "Attempt $i: status $STATUS, retrying..."
  sleep 5
done
```

Three retries with five-second intervals covers slow deploys without masking genuine failures.

## The Bottom Line

Post-deployment validation is the seatbelt for continuous deployment. You hope you never need it, but when things go wrong, it's the difference between a five-minute incident and a five-hour one.

The one-line curl check I started with has become the most valuable monitoring I run. It's the simplest possible test of "is the site actually working" — and it routinely catches failures that CI misses. Every deploy pipeline should have at least Layer 1. If you're deploying without any validation at all, you're not deploying with confidence — you're deploying with hope.
