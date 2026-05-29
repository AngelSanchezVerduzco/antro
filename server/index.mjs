import http from 'node:http';
import { URL } from 'node:url';
import { searchDocuments, esReady } from './es-client.mjs';

const PORT = Number(process.env.API_PORT ?? 3000);

function sendJson(res, status, body) {
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  });
  res.end(JSON.stringify(body));
}

const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') {
    sendJson(res, 204, {});
    return;
  }

  const url = new URL(req.url ?? '/', `http://localhost:${PORT}`);

  if (req.method === 'GET' && url.pathname === '/api/health') {
    const elasticsearch = await esReady();
    sendJson(res, 200, { ok: true, elasticsearch });
    return;
  }

  if (req.method === 'GET' && url.pathname === '/api/search') {
    const q = url.searchParams.get('q') ?? '';

    if (!q.trim()) {
      sendJson(res, 200, { total: 0, hits: [] });
      return;
    }

    try {
      const elasticsearch = await esReady();
      if (!elasticsearch) {
        sendJson(res, 503, {
          error: 'Elasticsearch no está disponible. Ejecuta: npm run es:up && npm run es:seed',
          total: 0,
          hits: [],
        });
        return;
      }

      const result = await searchDocuments(q);
      sendJson(res, 200, result);
    } catch (err) {
      sendJson(res, 500, { error: err.message, total: 0, hits: [] });
    }
    return;
  }

  sendJson(res, 404, { error: 'No encontrado' });
});

server.listen(PORT, () => {
  console.log(`API de búsqueda en http://localhost:${PORT}`);
  console.log('  GET /api/health');
  console.log('  GET /api/search?q=coctel');
});
