import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { randomUUID } from 'node:crypto';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DATA_DIR = path.join(__dirname, 'data');
const UPLOADS_DIR = path.join(__dirname, 'uploads');
const STORE_FILE = path.join(DATA_DIR, 'promociones.json');

const DEFAULT_PROMOS = [
  {
    id: 'promo-2x1-cocteles',
    type: 'promocion_nueva',
    title: '2x1 en cócteles',
    body: 'Promoción destacada todos los viernes en Nexus Nightclub.',
    imageUrl: '/uploads/promo-default.svg',
    deepLink: '/inicio',
    expiresAt: '2026-12-31T23:59:59.000Z',
    createdAt: '2026-06-01T12:00:00.000Z',
  },
];

export async function ensurePromoStorage() {
  await fs.mkdir(DATA_DIR, { recursive: true });
  await fs.mkdir(UPLOADS_DIR, { recursive: true });

  try {
    await fs.access(STORE_FILE);
  } catch {
    await fs.writeFile(STORE_FILE, JSON.stringify(DEFAULT_PROMOS, null, 2), 'utf-8');
  }

  const defaultImage = path.join(UPLOADS_DIR, 'promo-default.jpg');
  try {
    await fs.access(defaultImage);
  } catch {
    // Placeholder SVG servido como recurso estático de demo.
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
    await fs.writeFile(path.join(UPLOADS_DIR, 'promo-default.svg'), svg, 'utf-8');
  }
}

async function readPromos() {
  const raw = await fs.readFile(STORE_FILE, 'utf-8');
  return JSON.parse(raw);
}

async function writePromos(promos) {
  await fs.writeFile(STORE_FILE, JSON.stringify(promos, null, 2), 'utf-8');
}

export async function listPromociones() {
  const promos = await readPromos();
  return promos.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
}

export async function getLatestPromocion() {
  const promos = await listPromociones();
  const now = Date.now();
  const active = promos.filter((p) => new Date(p.expiresAt).getTime() > now);
  return active[0] ?? null;
}

export async function createPromocion({ title, body, imageUrl, deepLink, expiresAt }) {
  const promos = await readPromos();
  const promo = {
    id: `promo-${randomUUID().slice(0, 8)}`,
    type: 'promocion_nueva',
    title: title.trim(),
    body: body.trim(),
    imageUrl,
    deepLink: deepLink?.trim() || '/inicio',
    expiresAt: expiresAt || new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
    createdAt: new Date().toISOString(),
  };

  promos.unshift(promo);
  await writePromos(promos);
  return promo;
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
