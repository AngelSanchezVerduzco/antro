# Microservicio Auth (bck-ms-a) — Supabase + Smartwatch

Login, register, JWT y **vinculacion de smartwatch** (Practicas 11-12).

## Requisitos

- Java 17+
- Proyecto **Supabase** creado
- Script SQL ejecutado

## 1. Configurar Supabase

1. Crea proyecto en [supabase.com](https://supabase.com)
2. **SQL Editor** → pega y ejecuta `supabase/schema.sql`
3. **Project Settings → Database** → copia host, user y password

## 2. Variables de entorno (sin H2)

PowerShell:

```powershell
cd bck-ms-a
$env:SUPABASE_DB_URL="jdbc:postgresql://db.TU_PROYECTO.supabase.co:5432/postgres?sslmode=require"
$env:SUPABASE_DB_USER="postgres"
$env:SUPABASE_DB_PASSWORD="tu_password"
$env:JWT_SECRET="nexus-dev-secret-key-minimo-32-caracteres-cambiar-en-prod"
.\mvnw.cmd spring-boot:run
```

Copia `.env.example` como referencia.

## Endpoints Auth

| Metodo | Ruta | Auth |
|--------|------|------|
| POST | `/api/auth/register` | No |
| POST | `/api/auth/login` | No |
| GET | `/api/auth/me` | Bearer JWT |

## Endpoints Smartwatch (vinculacion estilo Netflix)

| Metodo | Ruta | Auth | Descripcion |
|--------|------|------|-------------|
| POST | `/api/device/request-pairing` | No | Reloj pide codigo de 6 digitos |
| POST | `/api/device/confirm-pairing` | Bearer JWT | Usuario confirma codigo |
| GET | `/api/device/status?deviceId=...` | No | Reloj consulta si ya vinculo |
| POST | `/api/device/validate-session` | No | Valida token del dispositivo |
| POST | `/api/device/revoke` | No | Desvincula reloj |

### Flujo Postman

1. **Register/Login** → copia JWT
2. En Flutter: pantalla vincular → codigo `482913` (ejemplo)
3. Postman:
   ```
   POST http://localhost:8080/api/device/confirm-pairing
   Authorization: Bearer TU_JWT
   { "pairingCode": "482913" }
   ```
4. Flutter detecta vinculacion automaticamente (poll cada 3s)

## Seguridad

- Passwords y codigos PIN de vinculacion: **BCrypt** (no texto plano en BD)
- PIN local del reloj: **SHA-256 + salt** en `flutter_secure_storage` (solo en dispositivo)
- Token de dispositivo: hash en BD, entrega one-time via `/status`

## Flutter (`antro/flutter_app`)

```powershell
cd antro/flutter_app
flutter pub get
flutter run -d windows --dart-define=AUTH_BASE_URL=http://localhost:8080
```

Flujo app: **Crear PIN → Login PIN/biometria → Vincular reloj → Home promos → Logout**
