# Arranque MVP Nexus (Supabase real)

## 1. Supabase SQL

En SQL Editor ejecuta el schema completo:

`bck-ms-a/supabase/schema.sql`

(incluye `promociones`, `catalog_items`, `reservaciones` ademas de users/devices)

## 2. Spring Auth (8080)

```powershell
cd antro\bck-ms-a
$env:SUPABASE_DB_URL="jdbc:postgresql://aws-1-us-east-2.pooler.supabase.com:5432/postgres?sslmode=require"
$env:SUPABASE_DB_USER="postgres.twocruxkdwheedfyrwtk"
$env:SUPABASE_DB_PASSWORD="TU_PASSWORD"
$env:JWT_SECRET="nexus-dev-secret-key-minimo-32-caracteres-cambiar-en-prod"
.\mvnw.cmd spring-boot:run
```

## 3. Node API (3000) + seed

Usa **las mismas variables que Spring** (evita errores si el password tiene `@` u otros simbolos):

```powershell
cd C:\Users\ravsi\proyecto_dedos\antro

$env:SUPABASE_DB_URL="jdbc:postgresql://aws-1-us-east-2.pooler.supabase.com:5432/postgres?sslmode=require"
$env:SUPABASE_DB_USER="postgres.twocruxkdwheedfyrwtk"
$env:SUPABASE_DB_PASSWORD="TU_PASSWORD_REAL"

npm run db:seed
npm run es:up
npm run es:seed
npm run api
```

Al arrancar deberias ver en consola algo como:
`[db] conectando como postgres.twocruxkdwheedfyrwtk@aws-1-us-east-2.pooler.supabase.com:5432/postgres`

Si dice `user "postgres"` (sin el `.twocrux...`), el user esta mal o la URI se rompio: usa las 3 vars de arriba.

## 4. Angular (4200)

```powershell
cd antro
npm start
```

## 5. Flutter widget (opcional)

```powershell
cd antro\flutter_app
C:\Users\ravsi\flutter\bin\flutter.bat run -d chrome --dart-define=AUTH_BASE_URL=http://localhost:8080
```

## Demo rapida

1. Register/Login en http://localhost:4200/register
2. Vincular reloj: Flutter muestra codigo → Angular `/vincular-dispositivo`
3. Admin publica promo en `/promociones`
4. Carta/Eventos/Galeria/Reservas leen Supabase
