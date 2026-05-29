import { SITE_DOCUMENTS } from './content.mjs';
import { bulkIndex, createIndex, esReady } from './es-client.mjs';

async function main() {
  console.log('Comprobando Elasticsearch...');
  const ready = await esReady();
  if (!ready) {
    console.error(
      'Elasticsearch no está disponible en http://localhost:9200\n' +
        'Inicia Docker con: npm run es:up\n' +
        'Espera ~30 s y vuelve a ejecutar: npm run es:seed',
    );
    process.exit(1);
  }

  console.log('Creando índice nexus...');
  await createIndex();

  console.log(`Indexando ${SITE_DOCUMENTS.length} documentos...`);
  await bulkIndex(SITE_DOCUMENTS);

  console.log('Listo. Prueba buscar: coctel, edm, vip, ubicación');
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
