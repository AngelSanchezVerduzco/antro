import { SITE_DOCUMENTS } from './content.mjs';
import { query, getPool } from './db.mjs';

const DEFAULT_PROMO = {
  id: 'promo-2x1-cocteles',
  type: 'promocion_nueva',
  title: '2x1 en cócteles',
  body: 'Promoción destacada todos los viernes en Nexus Nightclub.',
  image_url: '/uploads/promo-default.svg',
  deep_link: '/inicio',
  expires_at: '2026-12-31T23:59:59.000Z',
};

async function seedCatalog() {
  for (const doc of SITE_DOCUMENTS) {
    await query(
      `INSERT INTO catalog_items (id, tipo, titulo, descripcion, categoria, ruta, tags)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       ON CONFLICT (id) DO UPDATE SET
         tipo = EXCLUDED.tipo,
         titulo = EXCLUDED.titulo,
         descripcion = EXCLUDED.descripcion,
         categoria = EXCLUDED.categoria,
         ruta = EXCLUDED.ruta,
         tags = EXCLUDED.tags`,
      [doc.id, doc.tipo, doc.titulo, doc.descripcion, doc.categoria, doc.ruta, doc.tags],
    );
  }
  console.log(`Catalogo: ${SITE_DOCUMENTS.length} items`);
}

async function seedPromos() {
  await query(
    `INSERT INTO promociones (id, type, title, body, image_url, deep_link, expires_at)
     VALUES ($1, $2, $3, $4, $5, $6, $7)
     ON CONFLICT (id) DO NOTHING`,
    [
      DEFAULT_PROMO.id,
      DEFAULT_PROMO.type,
      DEFAULT_PROMO.title,
      DEFAULT_PROMO.body,
      DEFAULT_PROMO.image_url,
      DEFAULT_PROMO.deep_link,
      DEFAULT_PROMO.expires_at,
    ],
  );
  console.log('Promociones: seed inicial listo');
}

async function main() {
  getPool();
  console.log('Sembrando Supabase...');
  await seedCatalog();
  await seedPromos();
  console.log('Listo. Ejecuta tambien: npm run es:seed');
  await getPool().end();
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
