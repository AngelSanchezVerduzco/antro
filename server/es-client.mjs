const ES_URL = process.env.ELASTICSEARCH_URL ?? 'http://localhost:9200';
export const INDEX = 'nexus';

function stripHighlight(html) {
  return html?.replace(/<\/?em>/gi, '') ?? '';
}

export async function esReady() {
  try {
    const res = await fetch(`${ES_URL}/_cluster/health`);
    if (!res.ok) return false;
    const data = await res.json();
    return data.status === 'green' || data.status === 'yellow';
  } catch {
    return false;
  }
}

export async function createIndex() {
  const exists = await fetch(`${ES_URL}/${INDEX}`);
  if (exists.ok) {
    await fetch(`${ES_URL}/${INDEX}`, { method: 'DELETE' });
  }

  const res = await fetch(`${ES_URL}/${INDEX}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      mappings: {
        properties: {
          tipo: { type: 'keyword' },
          titulo: { type: 'text' },
          descripcion: { type: 'text' },
          categoria: { type: 'keyword' },
          ruta: { type: 'keyword' },
          tags: { type: 'text' },
        },
      },
    }),
  });

  if (!res.ok) {
    const err = await res.text();
    throw new Error(`No se pudo crear el índice: ${err}`);
  }
}

export async function bulkIndex(documents) {
  const lines = documents.flatMap((doc) => [
    JSON.stringify({ index: { _index: INDEX, _id: doc.id } }),
    JSON.stringify({
      tipo: doc.tipo,
      titulo: doc.titulo,
      descripcion: doc.descripcion,
      categoria: doc.categoria,
      ruta: doc.ruta,
      tags: doc.tags,
    }),
  ]);

  const body = `${lines.join('\n')}\n`;
  const res = await fetch(`${ES_URL}/_bulk`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-ndjson' },
    body,
  });

  if (!res.ok) {
    throw new Error(`Bulk falló: ${await res.text()}`);
  }

  const result = await res.json();
  if (result.errors) {
    throw new Error('Errores al indexar documentos en Elasticsearch');
  }

  await fetch(`${ES_URL}/${INDEX}/_refresh`, { method: 'POST' });
}

export async function searchDocuments(query, size = 8) {
  const trimmed = query.trim();
  if (!trimmed) {
    return { total: 0, hits: [] };
  }

  const res = await fetch(`${ES_URL}/${INDEX}/_search`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      size,
      query: {
        multi_match: {
          query: trimmed,
          fields: ['titulo^3', 'descripcion^2', 'tags', 'categoria'],
          fuzziness: 'AUTO',
        },
      },
      highlight: {
        fields: {
          titulo: {},
          descripcion: { fragment_size: 120, number_of_fragments: 1 },
        },
      },
    }),
  });

  if (!res.ok) {
    throw new Error(`Búsqueda falló: ${await res.text()}`);
  }

  const data = await res.json();
  const hits = (data.hits?.hits ?? []).map((hit) => ({
    id: hit._id,
    score: hit._score,
    tipo: hit._source.tipo,
    titulo: hit._source.titulo,
    descripcion: hit._source.descripcion,
    categoria: hit._source.categoria,
    ruta: hit._source.ruta,
    highlight: stripHighlight(
      hit.highlight?.descripcion?.[0] ??
        hit.highlight?.titulo?.[0] ??
        hit._source.descripcion,
    ),
  }));

  return {
    total: data.hits?.total?.value ?? hits.length,
    hits,
  };
}
