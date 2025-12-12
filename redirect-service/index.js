const express = require('express');
const app = express();

// Configuration - Update these values after deploying Grafana
const GRAFANA_BASE_URL = process.env.GRAFANA_BASE_URL || 'https://your-grafana.railway.app';

// Route mappings: subdomain -> { dashboard, orgId }
// Update these after creating organizations and dashboards in Grafana
const ROUTES = {
  'projecta': {
    dashboard: 'projecta-main',
    orgId: 2,
    name: 'Project A'
  },
  'projectb': {
    dashboard: 'projectb-main',
    orgId: 3,
    name: 'Project B'
  },
  'projectc': {
    dashboard: 'projectc-main',
    orgId: 4,
    name: 'Project C'
  }
};

// Kiosk mode options:
// - 'tv'    : Hides all navigation, full screen dashboard
// - 'true'  : Hides side menu, keeps top nav
// - ''      : Full Grafana UI visible
const DEFAULT_KIOSK_MODE = process.env.KIOSK_MODE || 'tv';

// Extract subdomain from hostname
function getSubdomain(hostname) {
  const parts = hostname.split('.');
  if (parts.length >= 2) {
    return parts[0].toLowerCase();
  }
  return null;
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Main redirect handler
app.get('*', (req, res) => {
  const hostname = req.hostname || req.headers.host?.split(':')[0] || '';
  const subdomain = getSubdomain(hostname);

  console.log(`Request: ${hostname}${req.path} -> subdomain: ${subdomain}`);

  // Check if subdomain matches a configured route
  if (subdomain && ROUTES[subdomain]) {
    const route = ROUTES[subdomain];
    const kioskParam = DEFAULT_KIOSK_MODE ? `&kiosk=${DEFAULT_KIOSK_MODE}` : '';
    const redirectUrl = `${GRAFANA_BASE_URL}/d/${route.dashboard}?orgId=${route.orgId}${kioskParam}`;

    console.log(`Redirecting to: ${redirectUrl}`);
    return res.redirect(302, redirectUrl);
  }

  // If no matching subdomain, show available routes or redirect to main Grafana
  if (req.path === '/' || req.path === '') {
    // Return a simple landing page with links
    const routeLinks = Object.entries(ROUTES)
      .map(([key, value]) => `<li><a href="https://${key}.yourdomain.com">${value.name}</a></li>`)
      .join('\n');

    return res.send(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>Grafana Dashboard Portal</title>
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            max-width: 600px;
            margin: 50px auto;
            padding: 20px;
            background: #1a1a2e;
            color: #eee;
          }
          h1 { color: #ff6b35; }
          ul { list-style: none; padding: 0; }
          li { margin: 10px 0; }
          a {
            color: #4ecdc4;
            text-decoration: none;
            padding: 10px 20px;
            display: inline-block;
            background: #16213e;
            border-radius: 5px;
            transition: background 0.3s;
          }
          a:hover { background: #0f3460; }
          .info { color: #888; font-size: 14px; margin-top: 30px; }
        </style>
      </head>
      <body>
        <h1>Grafana Dashboard Portal</h1>
        <p>Select your project dashboard:</p>
        <ul>
          ${routeLinks}
        </ul>
        <p class="info">
          Or access Grafana directly at:
          <a href="${GRAFANA_BASE_URL}">${GRAFANA_BASE_URL}</a>
        </p>
      </body>
      </html>
    `);
  }

  // Pass through to Grafana for any other paths
  return res.redirect(302, `${GRAFANA_BASE_URL}${req.path}`);
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Grafana redirect service running on port ${PORT}`);
  console.log(`Grafana base URL: ${GRAFANA_BASE_URL}`);
  console.log('Configured routes:');
  Object.entries(ROUTES).forEach(([subdomain, config]) => {
    console.log(`  - ${subdomain}.* -> /d/${config.dashboard}?orgId=${config.orgId}`);
  });
});
