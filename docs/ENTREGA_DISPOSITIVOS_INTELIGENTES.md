# Tarea: Enlace sitio web ↔ dispositivos inteligentes

**Proyecto:** Nexus Nightclub (`antro`)  
**Alumno:** [Tu nombre]  
**Fecha:** Junio 2026

---

## 1. Objetivo de la tarea

Desarrollar el enlace entre el sitio web **Nexus Nightclub** y un **dispositivo inteligente** (wearable / smart TV simulado), mediante:

1. Elementos en el **DOM** del sitio que declaran la API del widget.
2. Un **backend** que expone los datos de promociones.
3. Una **app Flutter** que consume ese backend, muestra una notificación y despliega la imagen de la promoción.
4. Documentación del **tipo de datos transferidos** y su propósito.

---

## 2. Problema resuelto

Cuando se publica una **promoción nueva** en el antro, el dispositivo inteligente debe:

1. Recibir una **notificación** con título y descripción.
2. Al **abrir/desplegar** la notificación, mostrar la **imagen** asociada a esa promoción.

Ejemplo probado: promoción **"Ladies Night — Cover gratis antes de las 11 PM"**.

---

## 3. Arquitectura implementada

```
┌─────────────────────┐
│  Sitio Angular      │  DOM: meta + manifest + footer con URLs de API
│  (localhost:4200)   │
└──────────┬──────────┘
           │ declara enlace
           ▼
┌─────────────────────┐     GET /api/promociones/latest
│  Backend Node.js    │◄────────────────────────────────┐
│  (localhost:3000)   │     POST /api/promociones        │
└──────────┬──────────┘                                    │
           │ sirve JSON + imágenes                         │
           ▼                                               │
┌─────────────────────┐                          ┌────────┴────────┐
│  /uploads/*.svg     │                          │  App Flutter    │
│  imágenes de promo  │                          │  (widget/wearable)│
└─────────────────────┘                          └─────────────────┘
```

---

## 4. Enlace desde el DOM

El sitio web declara públicamente cómo conectarse al dispositivo inteligente.

### `src/index.html`

```html
<link rel="manifest" href="/api/widget/manifest" />
<meta name="nexus-widget-api" content="http://localhost:3000/api/promociones/latest" />
<meta name="nexus-widget-manifest" content="http://localhost:3000/api/widget/manifest" />
<meta name="nexus-supported-devices" content="wearable,smart-tv,mobile" />
```

### Footer del sitio (`app-shell.html`)

Bloque visible con atributo `data-nexus-widget="true"` y enlaces a:

- `/api/promociones/latest` — última promoción activa
- `/api/widget/manifest` — manifiesto del widget

**Propósito:** cualquier dispositivo (wearable, smart TV, app companion) puede leer el DOM del sitio y descubrir automáticamente dónde consumir los datos.

---

## 5. Backend — endpoints implementados

| Método | Ruta | Descripción |
|--------|------|-------------|
| `GET` | `/api/promociones/latest` | Última promoción activa (lo que consume el widget) |
| `GET` | `/api/promociones` | Lista todas las promociones |
| `POST` | `/api/promociones` | Publica una promoción nueva |
| `POST` | `/api/promociones/upload` | Sube imagen binaria |
| `GET` | `/api/widget/manifest` | Manifiesto del widget |
| `GET` | `/uploads/*` | Sirve imágenes de promociones |

**Archivos del backend:**

- `server/index.mjs` — servidor HTTP y rutas
- `server/promociones.mjs` — lógica de promociones y almacenamiento
- `server/data/promociones.json` — persistencia (generado en runtime)
- `server/uploads/` — imágenes subidas

---

## 6. Datos transferidos al dispositivo

### Respuesta de `GET /api/promociones/latest`

```json
{
  "id": "promo-85daf09b",
  "type": "promocion_nueva",
  "title": "Ladies Night",
  "body": "Cover gratis antes de las 11 PM",
  "imageUrl": "http://localhost:3000/uploads/promo-default.svg",
  "deepLink": "/inicio",
  "expiresAt": "2026-07-11T19:36:39.863Z",
  "createdAt": "2026-06-11T19:36:39.863Z"
}
```

| Campo | Tipo | Propósito en el dispositivo |
|-------|------|------------------------------|
| `type` | `string` | Identifica el evento como promoción nueva; el widget decide qué UI mostrar |
| `id` | `string` | ID único; evita mostrar la misma notificación dos veces |
| `title` | `string` | Título de la notificación push |
| `body` | `string` | Texto corto bajo el título en la notificación |
| `imageUrl` | `string` | URL de la imagen que se despliega al abrir la notificación |
| `deepLink` | `string` | Ruta del sitio web para abrir más información |
| `expiresAt` | ISO-8601 | Fecha de vencimiento; el widget ignora promos expiradas |
| `createdAt` | ISO-8601 | Fecha de publicación; ordena promociones por recencia |

### Payload de `POST /api/promociones`

```json
{
  "title": "Ladies Night",
  "body": "Cover gratis antes de las 11 PM",
  "imageUrl": "https://...",
  "imageBase64": "data:image/png;base64,..."
}
```

Si no se envía imagen, el backend usa `promo-default.svg` como placeholder.

---

## 7. App Flutter (widget especializado)

**Ubicación:** `flutter_app/`

Simula un **wearable / smart TV** sin necesidad de hardware físico.

### Flujo de la app

1. `ApiService` consulta `GET /api/promociones/latest`.
2. `NotificationService` muestra notificación local con título y cuerpo.
3. Al tocar la notificación → `PromoDetailScreen` carga `Image.network(imageUrl)`.

### Estructura

| Archivo | Responsabilidad |
|---------|-----------------|
| `lib/services/api_service.dart` | Consumo del backend |
| `lib/services/notification_service.dart` | Notificaciones locales |
| `lib/screens/home_screen.dart` | Publicar / consultar promos |
| `lib/screens/promo_detail_screen.dart` | Mostrar imagen al desplegar |

### Ejecución (sin emulador de reloj)

```bash
npm run flutter:setup
cd flutter_app
flutter run -d windows
```

Alternativa sin Flutter: probar el mismo contrato de datos con **Postman** (colección en `docs/postman-nexus-widget.json`).

---

## 8. Pruebas realizadas

### Con Postman

1. **`POST /api/promociones`** → `201 Created` con promo "Ladies Night".
2. **`GET /api/promociones/latest`** → JSON con la promo más reciente.
3. **`GET /uploads/promo-default.svg`** → imagen visible (gradiente morado/rosa, texto "2x1 COCTELES").
4. **`GET /api/widget/manifest`** → manifiesto con URLs y esquema de datos.

### Evidencia sugerida para entregar

- Captura del POST con respuesta `201`.
- Captura del GET `/latest` con JSON.
- Captura de la imagen servida desde `/uploads/`.
- Captura del footer del sitio con enlaces al API.
- (Opcional) Captura de la app Flutter en Windows.

---

## 9. Aprovechamiento del repositorio para despliegue

| Recurso en Git | Beneficio para dispositivos inteligentes |
|----------------|------------------------------------------|
| `server/` versionado | La API se despliega en un servidor (Render, Railway, VPS) y el widget apunta a una URL fija |
| `server/uploads/` | Imágenes de promos centralizadas; el `imageUrl` siempre es público |
| `flutter_app/` | Cliente independiente; se compila con `flutter build apk` para Android/Wear OS |
| `src/index.html` + footer | Al desplegar Angular, el DOM ya declara la URL de producción del API |
| `docs/postman-nexus-widget.json` | Colección reutilizable para validar el backend en cualquier entorno |
| `docker-compose.yml` | Patrón de despliegue reproducible del stack |

### Flujo de despliegue propuesto

1. `git push` al repositorio remoto.
2. Desplegar `server/` → `https://api.nexus.com`.
3. Desplegar Angular → `https://nexus.com` (actualizar `meta nexus-widget-api`).
4. Compilar Flutter con `--dart-define=API_BASE_URL=https://api.nexus.com`.
5. Distribuir APK al dispositivo wearable/smart TV.

---

## 10. Evolución futura (CRUD en Angular)

Actualmente la promo del inicio sigue hardcodeada en HTML. El siguiente paso es:

1. Pantalla admin en Angular para crear/editar/eliminar promociones.
2. Subida de imagen real desde el formulario.
3. El inicio consume `GET /api/promociones` en lugar de HTML fijo.
4. El widget Flutter **no cambia** — sigue usando el mismo endpoint y JSON.

---

## 11. Cómo ejecutar el proyecto

```bash
# Terminal 1 — API
npm run api

# Terminal 2 — Sitio web
npm start

# Terminal 3 — Flutter (opcional)
npm run flutter:setup
npm run flutter:run
```

---

## 12. Conclusión

Se implementó el enlace completo entre el sitio web Nexus y un dispositivo inteligente simulado:

- El **DOM** del sitio declara la API mediante `meta`, `manifest` y footer.
- El **backend Node.js** expone promociones en JSON con imagen incluida.
- La **app Flutter** consume esos datos, notifica al usuario y despliega la imagen.
- El **repositorio Git** centraliza web, API y cliente para un despliegue coordinado.

La prueba con Postman confirma que el contrato de datos funciona correctamente sin necesidad de emulador de smartwatch.
