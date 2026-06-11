import http from 'node:http';
import fs from 'node:fs/promises';
import path from 'node:path';
import { URL } from 'node:url';
import { searchDocuments, esReady } from './es-client.mjs';
import {
  ensurePromoStorage,
  listPromociones,
  getLatestPromocion,
  createPromocion,
  saveUploadedImage,
  getUploadsDir,
  buildWidgetManifest,
} from './promociones.mjs';

const PORT = Number(process.env.API_PORT ?? 3000);
const PUBLIC_BASE_URL = process.env.PUBLIC_BASE_URL ?? `http://localhost:${PORT}`;

function corsHeaders(extra = {}) {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, X-Filename',
    ...extra,
  };
}

function sendJson(res, status, body) {
  res.writeHead(status, corsHeaders({ 'Content-Type': 'application/json; charset=utf-8' }));
  res.end(JSON.stringify(body));
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on('data', (chunk) => chunks.push(chunk));
    req.on('end', () => resolve(Buffer.concat(chunks)));
    req.on('error', reject);
  });
}

function absolutizeImageUrl(imageUrl) {
  if (!imageUrl) return imageUrl;
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) return imageUrl;
  return `${PUBLIC_BASE_URL}${imageUrl.startsWith('/') ? '' : '/'}${imageUrl}`;
}

function withAbsoluteImage(promo) {
  if (!promo) return null;
  return { ...promo, imageUrl: absolutizeImageUrl(promo.imageUrl) };
}

async function serveStaticUpload(res, pathname) {
  const uploadsDir = getUploadsDir();
  const filePath = path.join(uploadsDir, pathname.replace('/uploads/', ''));

  if (!filePath.startsWith(uploadsDir)) {
    sendJson(res, 403, { error: 'Acceso denegado' });
    return true;
  }

  try {
    const data = await fs.readFile(filePath);
    const ext = path.extname(filePath).toLowerCase();
    const types = {
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.webp': 'image/webp',
      '.gif': 'image/gif',
      '.svg': 'image/svg+xml',
    };
    res.writeHead(200, corsHeaders({ 'Content-Type': types[ext] ?? 'application/octet-stream' }));
    res.end(data);
    return true;
  } catch {
    return false;
  }
}

const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') {
    sendJson(res, 204, {});
    return;
  }

  const url = new URL(req.url ?? '/', `http://localhost:${PORT}`);

  if (req.method === 'GET' && url.pathname.startsWith('/uploads/')) {
    const served = await serveStaticUpload(res, url.pathname);
    if (!served) sendJson(res, 404, { error: 'Archivo no encontrado' });
    return;
  }

  if (req.method === 'GET' && url.pathname === '/api/health') {
    const elasticsearch = await esReady();
    sendJson(res, 200, { ok: true, elasticsearch });
    return;
  }

  if (req.method === 'GET' && url.pathname === '/api/widget/manifest') {
    sendJson(res, 200, buildWidgetManifest(PUBLIC_BASE_URL));
    return;
  }

  if (req.method === 'GET' && url.pathname === '/api/promociones/latest') {
    const promo = await getLatestPromocion();
    if (!promo) {
      sendJson(res, 404, { error: 'No hay promociones activas' });
      return;
    }
    sendJson(res, 200, withAbsoluteImage(promo));
    return;
  }

  if (req.method === 'GET' && url.pathname === '/api/promociones') {
    const promos = await listPromociones();
    sendJson(res, 200, {
      total: promos.length,
      items: promos.map(withAbsoluteImage),
    });
    return;
  }

  if (req.method === 'POST' && url.pathname === '/api/promociones/upload') {
    try {
      const buffer = await readBody(req);
      const filename = req.headers['x-filename'] ?? 'promo-upload.jpg';
      const imagePath = await saveUploadedImage(String(filename), buffer);
      sendJson(res, 201, { imageUrl: absolutizeImageUrl(imagePath) });
    } catch (err) {
      sendJson(res, 500, { error: err.message });
    }
    return;
  }

  if (req.method === 'POST' && url.pathname === '/api/promociones') {
    try {
      const buffer = await readBody(req);
      const payload = JSON.parse(buffer.toString('utf-8'));
      const { title, body, imageUrl, imageBase64, deepLink, expiresAt } = payload;

      if (!title?.trim() || !body?.trim()) {
        sendJson(res, 400, { error: 'title y body son obligatorios' });
        return;
      }

      let resolvedImageUrl = imageUrl?.trim();

      if (imageBase64?.startsWith('data:')) {
        const [, meta, data] = imageBase64.match(/^data:([^;]+);base64,(.+)$/) ?? [];
        if (meta && data) {
          const ext = meta.includes('png') ? 'png' : meta.includes('webp') ? 'webp' : 'jpg';
          const imageBuffer = Buffer.from(data, 'base64');
          resolvedImageUrl = await saveUploadedImage(`promo.${ext}`, imageBuffer);
        }
      }

      if (!resolvedImageUrl) {
        resolvedImageUrl = '/uploads/promo-default.svg';
      }

      const promo = await createPromocion({
        title,
        body,
        imageUrl: resolvedImageUrl,
        deepLink,
        expiresAt,
      });

      sendJson(res, 201, withAbsoluteImage(promo));
    } catch (err) {
      sendJson(res, 400, { error: err.message });
    }
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

await ensurePromoStorage();

server.listen(PORT, () => {
  console.log(`API Nexus en http://localhost:${PORT}`);
  console.log('  GET  /api/health');
  console.log('  GET  /api/search?q=coctel');
  console.log('  GET  /api/promociones');
  console.log('  GET  /api/promociones/latest');
  console.log('  GET  /api/widget/manifest');
  console.log('  POST /api/promociones');
  console.log('  POST /api/promociones/upload');
});
