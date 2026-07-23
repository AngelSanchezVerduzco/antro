-- Ejecutar en Supabase Dashboard -> SQL Editor (completo o solo tablas nuevas)

CREATE TABLE IF NOT EXISTS users (
    id                    BIGSERIAL PRIMARY KEY,
    email                 VARCHAR(255) NOT NULL UNIQUE,
    password_hash         VARCHAR(255) NOT NULL,
    full_name             VARCHAR(255) NOT NULL,
    role                  VARCHAR(50)  NOT NULL DEFAULT 'USER',
    enabled               BOOLEAN      NOT NULL DEFAULT TRUE,
    must_change_password  BOOLEAN      NOT NULL DEFAULT FALSE,
    last_login_at         TIMESTAMPTZ,
    created_at            TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT users_role_check CHECK (role IN ('USER', 'ADMIN'))
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);

-- Migracion practica 13 (bases ya creadas)
ALTER TABLE users ADD COLUMN IF NOT EXISTS enabled BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS must_change_password BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMPTZ;

CREATE TABLE IF NOT EXISTS device_pairing_codes (
    id         BIGSERIAL PRIMARY KEY,
    device_id  VARCHAR(64)  NOT NULL,
    code_hash  VARCHAR(255) NOT NULL,
    expires_at TIMESTAMPTZ  NOT NULL,
    used       BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pairing_device ON device_pairing_codes (device_id);
CREATE INDEX IF NOT EXISTS idx_pairing_expires ON device_pairing_codes (expires_at);

CREATE TABLE IF NOT EXISTS linked_devices (
    id                BIGSERIAL PRIMARY KEY,
    device_id         VARCHAR(64)  NOT NULL UNIQUE,
    user_id           BIGINT       NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    device_token_hash VARCHAR(255) NOT NULL,
    delivery_token    VARCHAR(128),
    linked_at         TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    last_active_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    revoked           BOOLEAN      NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_linked_devices_user ON linked_devices (user_id);

CREATE TABLE IF NOT EXISTS promociones (
    id          VARCHAR(50) PRIMARY KEY,
    type        VARCHAR(50) NOT NULL DEFAULT 'promocion_nueva',
    title       VARCHAR(255) NOT NULL,
    body        TEXT NOT NULL,
    image_url   VARCHAR(500),
    deep_link   VARCHAR(255) DEFAULT '/inicio',
    expires_at  TIMESTAMPTZ NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_promociones_expires ON promociones (expires_at DESC);
CREATE INDEX IF NOT EXISTS idx_promociones_created ON promociones (created_at DESC);

CREATE TABLE IF NOT EXISTS catalog_items (
    id          VARCHAR(80) PRIMARY KEY,
    tipo        VARCHAR(50) NOT NULL,
    titulo      VARCHAR(255) NOT NULL,
    descripcion TEXT NOT NULL,
    categoria   VARCHAR(80) NOT NULL,
    ruta        VARCHAR(255) NOT NULL DEFAULT '/inicio',
    tags        TEXT[] NOT NULL DEFAULT '{}',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_catalog_tipo ON catalog_items (tipo);
CREATE INDEX IF NOT EXISTS idx_catalog_categoria ON catalog_items (categoria);

CREATE TABLE IF NOT EXISTS reservaciones (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT REFERENCES users (id) ON DELETE SET NULL,
    full_name   VARCHAR(255) NOT NULL,
    email       VARCHAR(255) NOT NULL,
    phone       VARCHAR(40),
    party_size  INT NOT NULL DEFAULT 2,
    reserved_at TIMESTAMPTZ NOT NULL,
    notes       TEXT,
    status      VARCHAR(40) NOT NULL DEFAULT 'pending',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reservaciones_email ON reservaciones (email);
CREATE INDEX IF NOT EXISTS idx_reservaciones_at ON reservaciones (reserved_at);
