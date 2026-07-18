# PRÁCTICA 9

## Documentación para la aplicación del widget en la versión Git del sitio web Nexus Nightclub

### Conexión con Smart TV y dispositivos inteligentes

**Proyecto:** Nexus Nightclub  
**Repositorio Git:** [URL de tu repositorio]  
**Alumno:** [Tu nombre]  
**Matrícula:** [Tu matrícula]  
**Fecha:** Junio 2026  

---

## 1. Introducción

El presente documento describe cómo se integra el **widget de Nexus Nightclub** dentro de la versión actual del repositorio Git del sitio web, con el objetivo de permitir la **conexión con dispositivos inteligentes**, incluyendo **Smart TV**, wearables y móviles.

Esta actualización forma parte del módulo de dispositivos inteligentes y se apoya en componentes ya implementados en el repositorio:

- Sitio web Angular (`antro/`)
- Microservicio de promociones y widget (`antro/server/`)
- Aplicación Flutter widget (`antro/flutter_app/`)

---

## 2. Objetivo de la actualización

Permitir que, al publicarse una promoción en Nexus Nightclub, un dispositivo conectado (Smart TV, wearable o móvil) pueda:

1. **Descubrir automáticamente** dónde consultar la API del sitio.
2. **Recibir la última promoción activa** del antro.
3. **Mostrar una notificación** con título y descripción.
4. **Desplegar la imagen** asociada a la promoción al abrir la notificación.

---

## 3. Estructura del repositorio Git relacionada con el widget

```
proyecto_dedos/
├── antro/                          # Sitio web Angular
│   ├── src/
│   │   ├── index.html              # Meta tags y manifest del widget
│   │   └── app/layout/app-shell/   # Footer con enlace al widget
│   ├── server/                     # Microservicio Node (promos + widget)
│   │   ├── index.mjs
│   │   ├── promociones.mjs
│   │   ├── data/promociones.json
│   │   └── uploads/
│   ├── flutter_app/                # App widget (Smart TV / wearable)
│   └── docker-compose.yml          # Elasticsearch para buscador
└── bck-ms-a/                       # Microservicio Spring (auth)
```

---

## 4. Detalle de la actualización implementada

### 4.1 Actualización del DOM del sitio web

Se modificó el archivo `antro/src/index.html` para declarar públicamente el enlace hacia la API del widget:

```html
<link rel="manifest" href="/api/widget/manifest" />
<meta name="nexus-widget-api" content="http://localhost:3000/api/promociones/latest" />
<meta name="nexus-widget-manifest" content="http://localhost:3000/api/widget/manifest" />
<meta name="nexus-supported-devices" content="wearable,smart-tv,mobile" />
```

**Propósito de cada elemento:**

| Elemento | Función |
|----------|---------|
| link rel="manifest" | Indica la ruta del manifiesto del widget |
| meta nexus-widget-api | URL para obtener la última promoción |
| meta nexus-widget-manifest | URL del manifiesto de configuración |
| meta nexus-supported-devices | Dispositivos compatibles: wearable, smart-tv, mobile |

Adicionalmente, en `app-shell.html` se agregó un bloque visible en el footer con el atributo `data-nexus-widget="true"` y enlaces a `/api/promociones/latest` y `/api/widget/manifest`.

---

### 4.2 Actualización del microservicio de promociones (Node.js)

Endpoints implementados en `antro/server/`:

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | /api/promociones/latest | Devuelve la última promoción activa |
| GET | /api/promociones | Lista todas las promociones |
| POST | /api/promociones | Publica una promoción nueva |
| POST | /api/promociones/upload | Sube imagen de promoción |
| GET | /api/widget/manifest | Manifiesto del widget para dispositivos |
| GET | /api/health | Estado del servicio |

**Ejemplo de respuesta de /api/promociones/latest:**

```json
{
  "id": "promo-0b8e845b",
  "type": "promocion_nueva",
  "title": "Ladies Night",
  "body": "Cover gratis antes de las 11 PM",
  "imageUrl": "http://localhost:3000/uploads/promo-default.svg",
  "deepLink": "/inicio",
  "expiresAt": "2026-07-29T19:28:10.893Z",
  "createdAt": "2026-06-29T19:28:10.893Z"
}
```

---

### 4.3 Actualización de la app widget (Flutter)

En `antro/flutter_app/` se desarrolló la aplicación que simula el dispositivo inteligente:

1. Consulta GET /api/promociones/latest
2. Muestra notificación local con título y cuerpo
3. Al abrir la notificación, despliega la imagen desde imageUrl

**Compatibilidad Smart TV:**

| Entorno | URL de la API |
|---------|---------------|
| Windows / pruebas locales | http://localhost:3000 |
| Emulador Android | http://10.0.2.2:3000 |
| Smart TV en red local | http://IP_DEL_SERVIDOR:3000 |
| Producción | https://api.nexus.com |

---

### 4.4 Flujo de conexión sitio web ↔ Smart TV

```
Sitio Angular (4200)  →  declara URLs en DOM
        ↓
API Node (3000)       →  /api/promociones/latest + /api/widget/manifest
        ↓
App Flutter (Widget)  →  Notificación + Imagen en Smart TV / Wearable
```

---

## 5. Procedimiento de despliegue desde Git

### Requisitos previos

Node.js 18+, Flutter SDK, Docker Desktop, Git

### Pasos

1. `git clone [URL_DEL_REPOSITORIO]`
2. `cd antro && npm install`
3. `npm run es:up && npm run es:seed` (Elasticsearch)
4. `npm run api` (API promociones, puerto 3000)
5. `npm start` (Angular, puerto 4200)
6. `cd flutter_app && flutter pub get && flutter run -d windows`

### Verificación con Postman

| Paso | Método | URL |
|------|--------|-----|
| 1 | POST | http://localhost:3000/api/promociones |
| 2 | GET | http://localhost:3000/api/promociones/latest |
| 3 | GET | http://localhost:3000/api/widget/manifest |

---

## 6. Actualización para producción (Smart TV en red real)

1. Actualizar URLs en `src/index.html` (cambiar localhost por URL pública)
2. Compilar Flutter: `flutter build apk --dart-define=API_BASE_URL=https://api.nexus.com`
3. El manifiesto se genera dinámicamente según PUBLIC_BASE_URL

---

## 7. Control de versiones en Git

| Versión | Cambio |
|---------|--------|
| v1.0 | Sitio Angular base |
| v1.1 | API Node promociones + widget |
| v1.2 | Enlace DOM + manifest + footer |
| v1.3 | App Flutter widget |
| v1.4 | Documentación Práctica 9 |

---

## 8. Conclusión

La actualización del widget integrada en la versión Git del sitio Nexus Nightclub permite la conexión con **Smart TV y otros dispositivos inteligentes** mediante declaración en el DOM, microservicio Node de promociones, app Flutter como cliente widget y manifiesto de configuración para registro automático.
