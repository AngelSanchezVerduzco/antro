-- Ejecutar en Supabase SQL Editor (practica 13: habilitar/deshabilitar cuentas)

ALTER TABLE users ADD COLUMN IF NOT EXISTS enabled BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS must_change_password BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMPTZ;

UPDATE users SET enabled = TRUE WHERE enabled IS NULL;
