import { query } from './db.mjs';

function mapReserva(row) {
  return {
    id: row.id,
    userId: row.user_id,
    fullName: row.full_name,
    email: row.email,
    phone: row.phone,
    partySize: row.party_size,
    reservedAt: row.reserved_at instanceof Date ? row.reserved_at.toISOString() : row.reserved_at,
    notes: row.notes,
    status: row.status,
    createdAt: row.created_at instanceof Date ? row.created_at.toISOString() : row.created_at,
  };
}

export async function listReservaciones({ email } = {}) {
  if (email) {
    const result = await query(
      `SELECT * FROM reservaciones WHERE LOWER(email) = LOWER($1) ORDER BY reserved_at DESC`,
      [email],
    );
    return result.rows.map(mapReserva);
  }

  const result = await query(`SELECT * FROM reservaciones ORDER BY reserved_at DESC LIMIT 100`);
  return result.rows.map(mapReserva);
}

export async function createReservacion({
  userId,
  fullName,
  email,
  phone,
  partySize,
  reservedAt,
  notes,
}) {
  const result = await query(
    `INSERT INTO reservaciones
      (user_id, full_name, email, phone, party_size, reserved_at, notes, status)
     VALUES ($1, $2, $3, $4, $5, $6, $7, 'pending')
     RETURNING *`,
    [
      userId ?? null,
      fullName.trim(),
      email.trim().toLowerCase(),
      phone?.trim() || null,
      Number(partySize) || 2,
      reservedAt,
      notes?.trim() || null,
    ],
  );
  return mapReserva(result.rows[0]);
}
