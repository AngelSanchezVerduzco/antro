# PRÁCTICA 10

## Documentación para la implementación de una base de datos estable en el sitio web Nexus Nightclub

**Proyecto:** Nexus Nightclub  
**Repositorio Git:** [URL de tu repositorio]  
**Alumno:** [Tu nombre]  
**Matrícula:** [Tu matrícula]  
**Fecha:** Junio 2026  

---

## 1. Introducción

El presente documento describe el plan de implementación de una **base de datos estable** para el sitio web Nexus Nightclub, migrando desde el almacenamiento temporal actual (archivos JSON y base en memoria) hacia **Supabase (PostgreSQL)** en la nube.

Esta actualización complementa la arquitectura de **microservicios** del proyecto y sienta las bases para un sistema completo con datos persistentes.

---

## 2. Situación actual (antes de la base de datos estable)

| Componente | Almacenamiento actual | Limitación |
|------------|----------------------|------------|
| Usuarios (login/register) | H2 en memoria (Spring Boot) | Se borran al reiniciar |
| Promociones | promociones.json (Node) | Archivo local, no escalable |
| Buscador (13 documentos) | content.mjs → Elasticsearch | Datos precargados |
| Carta, eventos, galería | HTML hardcodeado | No editable sin código |
| Reservaciones | Contenido estático | Sin backend |

---

## 3. Arquitectura objetivo con base de datos estable

```
Angular (4200)
    ├── MS-1 Auth (Spring, 8080) ──→ Supabase (users)
    └── MS-2 Promos (Node, 3000)   ──→ Supabase (promociones)
                                              ↓
                                    Elasticsearch (Docker, buscador)
```

---

## 4. Enlace a la base de datos (Supabase)

### 4.1 Microservicio Auth (Spring Boot — bck-ms-a)

**Configuración:** `bck-ms-a/src/main/resources/application-supabase.properties`

**Script SQL:** `bck-ms-a/supabase/schema.sql`

```sql
CREATE TABLE IF NOT EXISTS users (
    id            BIGSERIAL PRIMARY KEY,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name     VARCHAR(255) NOT NULL,
    role          VARCHAR(50)  NOT NULL DEFAULT 'USER',
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT users_role_check CHECK (role IN ('USER', 'ADMIN'))
);
```

### 4.2 Microservicio Promociones (Node — planificado)

```sql
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
```

### 4.3 Tablas futuras

| Tabla | Microservicio | Contenido |
|-------|---------------|-----------|
| eventos | MS-3 Catálogo | Fiestas y fechas |
| carta | MS-3 Catálogo | Menú del antro |
| galeria | MS-3 Catálogo | Imágenes |
| reservaciones | MS-4 Reservaciones | Mesas VIP |

---

## 5. Elementos ya solucionados

| Elemento | Estado |
|----------|--------|
| Microservicio Auth (Spring Boot) | Implementado |
| Endpoints Auth (register, login, me) | Implementado |
| Script SQL usuarios | Implementado |
| Perfil Supabase en Spring | Configurado |
| Microservicio Promos (Node) | Implementado |
| Buscador Elasticsearch | Implementado |
| Enlace DOM ↔ widget | Implementado |
| App Flutter widget | Implementado |
| Pruebas Postman Auth y Promos | Verificadas |

---

## 6. Posibles errores y soluciones

| Error | Causa | Solución |
|-------|-------|----------|
| 409 El correo ya esta registrado | Email duplicado | Usar Login |
| 401 Credenciales invalidas | Password incorrecto | Verificar datos |
| 404 No encontrado en /latest | Espacio en URL | Quitar espacios al final |
| 503 Elasticsearch no disponible | Docker apagado | npm run es:up |
| Invalid protocol: post http | POST en la URL | Método en dropdown |
| Usuarios desaparecen | H2 en memoria | Conectar Supabase |
| Promos no persisten | JSON local | Migrar a Supabase |
| Flutter sin imagen | API apagada | npm run api |
| Buscador vacío | Sin seed | npm run es:seed |
| CORS error | Puertos distintos | proxy.conf.json |
| Supabase falla | Credenciales mal | Verificar env vars |

---

## 7. Calendario de actualizaciones

| Fase | Periodo | Actividad | Estado |
|------|---------|-----------|--------|
| Fase 1 | Semana 1 | Auth Spring + Postman (H2) | Completado |
| Fase 2 | Semana 1 | Promos Node + Flutter + DOM | Completado |
| Fase 3 | Semana 2 | Conectar Spring a Supabase | Pendiente |
| Fase 4 | Semana 2 | Promos JSON → Supabase | Pendiente |
| Fase 5 | Semana 3 | MS-3 Catálogo | Pendiente |
| Fase 6 | Semana 3 | MS-4 Reservaciones | Pendiente |
| Fase 7 | Semana 4 | Pantallas Angular | Pendiente |
| Fase 8 | Semana 4 | Supabase → Elasticsearch | Pendiente |
| Fase 9 | Semana 5 | Despliegue producción | Pendiente |
| Fase 10 | Semana 5 | Documentación final | Pendiente |

---

## 8. Procedimiento de migración

1. Crear proyecto en Supabase
2. Ejecutar schema.sql en SQL Editor
3. Copiar credenciales (Host, User, Password)
4. Arrancar Spring con perfil supabase
5. Verificar Register/Login en Postman
6. Reiniciar Spring y confirmar que usuarios persisten
7. Migrar promociones a Supabase (fase siguiente)
8. Sincronizar buscador con datos reales

---

## 9. Microservicios del sistema completo

| # | Microservicio | Tecnología | BD | Estado |
|---|---------------|------------|-----|--------|
| MS-1 | Autenticación | Spring Boot | Supabase (users) | Implementado |
| MS-2 | Promociones / Widget | Node.js | JSON → Supabase | API lista |
| MS-3 | Catálogo | Por definir | Supabase | Pendiente |
| MS-4 | Reservaciones | Por definir | Supabase | Pendiente |
| — | Buscador | Elasticsearch | Índice sync | Implementado |

---

## 10. Conclusión

La implementación de Supabase (PostgreSQL) permitirá persistir usuarios, almacenar promociones, gestionar contenido del sitio, sincronizar el buscador y escalar la arquitectura de microservicios. La migración será gradual por fases, manteniendo la operatividad en cada etapa.

**Referencias:** antro/docs/DISPOSITIVOS_INTELIGENTES.md, bck-ms-a/README.md, bck-ms-a/supabase/schema.sql
