import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { randomUUID } from 'node:crypto';
import { query } from './db.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const UPLOADS_DIR = path.join(__dirname, 'uploads');

function mapPromo(row) {
  return {
    id: row.id,
    type: row.type,
    title: row.title,
    body: row.body,
    imageUrl: row.image_url,
    deepLink: row.deep_link,
    expiresAt: row.expires_at instanceof Date ? row.expires_at.toISOString() : row.expires_at,
    createdAt: row.created_at instanceof Date ? row.created_at.toISOString() : row.created_at,
  };
}

export async function ensurePromoStorage() {
  await fs.mkdir(UPLOADS_DIR, { recursive: true });

  const svgPath = path.join(UPLOADS_DIR, 'promo-default.svg');
  try {
    await fs.access(svgPath);
  } catch {
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="800" height="450" viewBox="0 0 800 450">
      <defs>
        <linearGradient id="g" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" style="stop-color:#7c3aed"/>
          <stop offset="100%" style="stop-color:#db2777"/>
        </linearGradient>
      </defs>
      <rect width="800" height="450" fill="url(#g)"/>
      <text x="400" y="210" fill="#fff" font-size="42" font-family="Arial" text-anchor="middle">2x1 COCTELES</text>
      <text x="400" y="260" fill="#f5d0fe" font-size="24" font-family="Arial" text-anchor="middle">NEXUS NIGHTCLUB</text>
    </svg>`;
    await fs.writeFile(svgPath, svg, 'utf-8');
  }
}

export async function listPromociones() {
  const result = await query(
    `SELECT * FROM promociones ORDER BY created_at DESC`,
  );
  return result.rows.map(mapPromo);
}

export async function getLatestPromocion() {
  const result = await query(
    `SELECT * FROM promociones
     WHERE expires_at > NOW()
     ORDER BY created_at DESC
     LIMIT 1`,
  );
  return result.rows[0] ? mapPromo(result.rows[0]) : null;
}

export async function createPromocion({ title, body, imageUrl, deepLink, expiresAt }) {
  const id = `promo-${randomUUID().slice(0, 8)}`;
  const expires =
    expiresAt || new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString();
  const result = await query(
    `INSERT INTO promociones (id, type, title, body, image_url, deep_link, expires_at)
     VALUES ($1, 'promocion_nueva', $2, $3, $4, $5, $6)
     RETURNING *`,
    [
      id,
      title.trim(),
      body.trim(),
      imageUrl || '/uploads/promo-default.svg',
      deepLink?.trim() || '/inicio',
      expires,
    ],
  );
  return mapPromo(result.rows[0]);
}

export async function deletePromocion(id) {
  const result = await query(`DELETE FROM promociones WHERE id = $1 RETURNING id`, [id]);
  return result.rowCount > 0;
}

export async function saveUploadedImage(filename, buffer) {
  const safeName = filename.replace(/[^a-zA-Z0-9._-]/g, '_');
  const storedName = `${Date.now()}-${safeName}`;
  const fullPath = path.join(UPLOADS_DIR, storedName);
  await fs.writeFile(fullPath, buffer);
  return `/uploads/${storedName}`;
}

export function getUploadsDir() {
  return UPLOADS_DIR;
}

export function buildWidgetManifest(baseUrl) {
  return {
    name: 'Nexus Nightclub Widget',
    short_name: 'NexusWidget',
    description: 'Enlace entre el sitio Nexus y dispositivos inteligentes (wearable / smart TV).',
    version: '1.0.0',
    api: {
      latestPromocion: `${baseUrl}/api/promociones/latest`,
      listPromociones: `${baseUrl}/api/promociones`,
      health: `${baseUrl}/api/health`,
    },
    supportedDevices: ['wearable', 'smart-tv', 'mobile'],
    notificationTypes: ['promocion_nueva'],
    dataSchema: {
      type: 'string — identificador del evento (promocion_nueva)',
      id: 'string — id único de la promoción',
      title: 'string — título de la notificación',
      body: 'string — cuerpo de la notificación',
      imageUrl: 'string — URL de la imagen a mostrar al expandir',
      deepLink: 'string — ruta en el sitio web',
      expiresAt: 'ISO-8601 — vigencia de la promoción',
      createdAt: 'ISO-8601 — fecha de publicación',
    },
  };
}
