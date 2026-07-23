import { query } from './db.mjs';

function mapItem(row) {
  return {
    id: row.id,
    tipo: row.tipo,
    titulo: row.titulo,
    descripcion: row.descripcion,
    categoria: row.categoria,
    ruta: row.ruta,
    tags: row.tags ?? [],
    createdAt: row.created_at instanceof Date ? row.created_at.toISOString() : row.created_at,
  };
}

export async function listCatalog({ tipo, categoria } = {}) {
  const clauses = [];
  const params = [];

  if (tipo) {
    params.push(tipo);
    clauses.push(`tipo = $${params.length}`);
  }
  if (categoria) {
    params.push(categoria);
    clauses.push(`categoria = $${params.length}`);
  }

  const where = clauses.length ? `WHERE ${clauses.join(' AND ')}` : '';
  const result = await query(
    `SELECT * FROM catalog_items ${where} ORDER BY titulo ASC`,
    params,
  );
  return result.rows.map(mapItem);
}

export async function getCatalogById(id) {
  const result = await query(`SELECT * FROM catalog_items WHERE id = $1`, [id]);
  return result.rows[0] ? mapItem(result.rows[0]) : null;
}
