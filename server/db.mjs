import pg from 'pg';

const { Pool } = pg;

let pool;

function stripJdbc(raw) {
  return raw.startsWith('jdbc:') ? raw.replace(/^jdbc:/, '') : raw;
}

/**
 * Preferimos user/password separados (igual que Spring).
 * Asi el password puede tener @ # % sin romper la URI.
 */
function buildPoolConfig() {
  const user = process.env.SUPABASE_DB_USER || process.env.PGUSER;
  const password = process.env.SUPABASE_DB_PASSWORD || process.env.PGPASSWORD;
  const hostEnv = process.env.SUPABASE_DB_HOST || process.env.PGHOST;
  const portEnv = process.env.SUPABASE_DB_PORT || process.env.PGPORT;
  const database = process.env.SUPABASE_DB_NAME || process.env.PGDATABASE || 'postgres';

  const rawUrl = process.env.DATABASE_URL || process.env.SUPABASE_DB_URL;

  if (user && password) {
    let host = hostEnv || 'aws-1-us-east-2.pooler.supabase.com';
    let port = Number(portEnv || 5432);

    if (rawUrl) {
      try {
        const parsed = new URL(stripJdbc(rawUrl));
        if (!hostEnv) host = parsed.hostname;
        if (!portEnv && parsed.port) port = Number(parsed.port);
      } catch {
        // host por defecto
      }
    }

    console.log(`[db] conectando como ${user}@${host}:${port}/${database}`);
    return {
      host,
      port,
      user,
      password,
      database,
      ssl: { rejectUnauthorized: false },
      max: 8,
    };
  }

  if (!rawUrl) {
    throw new Error(
      'Falta conexion a Supabase. Define SUPABASE_DB_USER + SUPABASE_DB_PASSWORD ' +
        '(recomendado, igual que Spring) o DATABASE_URL.',
    );
  }

  // Fallback: URI completa. Si el password tiene @, usa vars separadas.
  let url = stripJdbc(rawUrl);
  try {
    const parsed = new URL(url);
    parsed.searchParams.delete('sslmode');
    parsed.searchParams.delete('ssl');
    parsed.searchParams.delete('sslrootcert');
    url = parsed.toString();
    console.log(`[db] conectando con URI user=${decodeURIComponent(parsed.username)} host=${parsed.hostname}`);
  } catch {
    // se pasa tal cual
  }

  return {
    connectionString: url,
    ssl: { rejectUnauthorized: false },
    max: 8,
  };
}

export function getPool() {
  if (pool) return pool;

  pool = new Pool(buildPoolConfig());
  pool.on('error', (err) => {
    console.error('[db] error en cliente idle:', err.message);
  });

  return pool;
}

export async function query(text, params = []) {
  return getPool().query(text, params);
}
