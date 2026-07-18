-- Ejecutar en Supabase Dashboard -> SQL Editor

CREATE TABLE IF NOT EXISTS users (
    id            BIGSERIAL PRIMARY KEY,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name     VARCHAR(255) NOT NULL,
    role          VARCHAR(50)  NOT NULL DEFAULT 'USER',
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT users_role_check CHECK (role IN ('USER', 'ADMIN'))
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);

-- Codigos temporales de vinculacion smartwatch (estilo Netflix)
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

-- Dispositivos vinculados a un usuario
CREATE TABLE IF NOT EXISTS linked_devices (
    id                BIGSERIAL PRIMARY KEY,
    device_id         VARCHAR(64)  NOT NULL UNIQUE,
    user_id           BIGINT       NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    device_token_hash VARCHAR(255) NOT NULL,
    delivery_token     VARCHAR(128),
    linked_at         TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    last_active_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    revoked           BOOLEAN      NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_linked_devices_user ON linked_devices (user_id);
