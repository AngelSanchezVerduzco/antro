# PRÁCTICA 13

## Administración de cuentas de usuario — Nexus Nightclub

**Proyecto:** Nexus Nightclub  
**Alumno:** [Tu nombre]  
**Matrícula:** [Tu matrícula]  
**Fecha:** 23 de julio de 2026  

---

## 1. Introducción

Esta práctica trata sobre la administración de cuentas de usuario: creación, habilitación, deshabilitación y verificación de estados, así como las implicaciones de seguridad.

En el sistema operativo, una cuenta puede estar **habilitada** (puede autenticarse) o **deshabilitada** (sigue existiendo, pero no puede iniciar sesión). Deshabilitar es preferible a eliminar cuando se quiere conservar información, auditoría o la posibilidad de reactivar al usuario.

En **Nexus Nightclub** se aplicó el mismo concepto sobre las cuentas de la aplicación (tabla `users` en Supabase + microservicio Spring Auth + pantalla web Angular):

| Concepto SO | En Nexus |
|-------------|----------|
| Usuario del sistema | Fila en `users` |
| Habilitado / deshabilitado | Campo `enabled` |
| Grupo | Rol `USER` / `ADMIN` |
| No puede iniciar sesión | Spring rechaza el login |
| Conservar datos | No se borra el usuario |

---

## 2. Objetivo

1. Comprender la diferencia entre habilitar, deshabilitar y eliminar una cuenta.  
2. Aplicar habilitación/deshabilitación en el sistema Nexus.  
3. Verificar con evidencias que una cuenta deshabilitada no puede iniciar sesión.  
4. Responder los casos empresariales y las preguntas conceptuales de la práctica.

---

## 3. Implementación en Nexus

### 3.1 Base de datos (Supabase)

Se agregaron columnas a `users`:

- `enabled` — cuenta activa o no  
- `must_change_password` — si debe cambiar contraseña  
- `last_login_at` — último inicio de sesión  

### 3.2 Backend (Spring Boot, puerto 8080)

- Al hacer login, si `enabled = false` → error *Cuenta deshabilitada*.  
- Endpoints solo para ADMIN:
  - `GET /api/users`
  - `POST /api/users/{id}/disable`
  - `POST /api/users/{id}/enable`

### 3.3 Frontend (Angular)

Pantalla **Usuarios** (`/usuarios`), visible solo para administradores, con tabla:

| Columna | Significado |
|---------|-------------|
| Usuario | Correo |
| Nombre | Nombre completo |
| Habilitado | Sí / No |
| Grupo | Rol (`USER` / `ADMIN`) |
| Cambio password | Sí / No |
| Creado | Fecha de creación |
| Último login | Último acceso |

---

## 4. Usuarios de prueba

Se utilizaron cuentas existentes en el sistema (mismo nivel USER e invitado/profe, más el administrador):

| Usuario | Nombre completo | Estado | Grupo | Cambio de contraseña |
|---------|-----------------|--------|-------|----------------------|
| profe@gmail.com | profe | Habilitado / Deshabilitado (prueba) | USER | No |
| angel@gmail.com | angel | Habilitado | USER | No |
| admin@nexus.com | Admin Nexus | Habilitado | ADMIN | No |

Tabla solicitada por la práctica (resumen):

| usuario | habilitado | grupo | cambio de contraseña |
|---------|------------|-------|----------------------|
| profe@gmail.com | Sí → No (prueba) → Sí | USER | No |
| angel@gmail.com | Sí | USER | No |
| admin@nexus.com | Sí | ADMIN | No |

---

## 5. Evidencias de la práctica

### 5.1 Listado de usuarios (cuentas habilitadas)

Como administrador se visualiza la tabla de cuentas. Todas las cuentas aparecen habilitadas antes de la prueba de deshabilitación.

<div class="evidence">
  <img src="file:///C:/Users/ravsi/.cursor/projects/c-Users-ravsi-proyecto-dedos/assets/c__Users_ravsi_AppData_Roaming_Cursor_User_workspaceStorage_4f7fc902223d461fbd24474d1bfbce09_images_image-eeb20554-7e38-495f-8ae1-f52982e88394.png" />
  <p>Figura 1. Pantalla Usuarios con cuentas activas (ADMIN: admin@nexus.com).</p>
</div>

### 5.2 Deshabilitar un usuario del mismo nivel

Se deshabilitó la cuenta `profe@gmail.com` (rol USER, mismo nivel que otras cuentas no admin). En la tabla aparece **Habilitado = NO** y el botón cambia a **Habilitar**.

<div class="evidence">
  <img src="file:///C:/Users/ravsi/.cursor/projects/c-Users-ravsi-proyecto-dedos/assets/c__Users_ravsi_AppData_Roaming_Cursor_User_workspaceStorage_4f7fc902223d461fbd24474d1bfbce09_images_image-f754da4f-b4ab-4129-9a57-d51efed934a1.png" />
  <p>Figura 2. Cuenta profe@gmail.com deshabilitada. Mensaje: ya no puede iniciar sesión.</p>
</div>

**Verificación:**

| Pregunta | Resultado |
|----------|-----------|
| ¿Aparece como deshabilitado? | Sí (badge NO) |
| ¿Puede iniciar sesión? | No |

### 5.3 Intento de inicio de sesión con cuenta deshabilitada

Se cerró sesión de admin e se intentó entrar con `profe@gmail.com`. El sistema respondió:

> Cuenta deshabilitada. Contacta al administrador.

<div class="evidence">
  <img src="file:///C:/Users/ravsi/.cursor/projects/c-Users-ravsi-proyecto-dedos/assets/c__Users_ravsi_AppData_Roaming_Cursor_User_workspaceStorage_4f7fc902223d461fbd24474d1bfbce09_images_image-256f019e-5603-4560-a5c6-e15d457b06af.png" />
  <p>Figura 3. Login rechazado porque la cuenta está deshabilitada.</p>
</div>

### 5.4 Volver a habilitar

Desde la cuenta ADMIN se pulsó **Habilitar** sobre `profe@gmail.com`.

| Pregunta | Resultado |
|----------|-----------|
| ¿Puede iniciar sesión? | Sí, después de habilitar |
| ¿Qué propiedad cambió? | `enabled` pasó de `false` a `true` (Habilitado: NO → SI). Los datos del usuario se conservaron. |

---

## 6. Tabla comparativa: deshabilitar vs eliminar

| Acción | ¿Se conserva la información? | ¿Puede iniciar sesión? | ¿Puede recuperarse fácilmente? |
|--------|------------------------------|------------------------|--------------------------------|
| Deshabilitar usuario | Sí | No | Sí (habilitar de nuevo) |
| Eliminar usuario | No (se pierde configuración e historial asociado) | No | No / es difícil |

---

## 7. Casos empresariales

| Empleado | Situación | ¿Eliminar? | ¿Deshabilitar? | Justificación |
|----------|-----------|------------|----------------|---------------|
| Ana | Vacaciones por 6 meses | No | Sí | Regresa; conviene conservar su cuenta y datos. |
| Luis | Renunció definitivamente | No de inmediato | Sí primero | Deshabilitar bloquea el acceso ya. Eliminar solo si la política de retención lo permite después. |
| Pedro | Suspendido durante una investigación | No | Sí | Puede reactivarse según el resultado; se necesita auditoría. |
| María | Cambio temporal de departamento | No | No | Sigue activa; lo que cambia son permisos o grupo, no el estado de la cuenta. |

---

## 8. Preguntas conceptuales

### ¿Cuál es la diferencia entre deshabilitar y eliminar un usuario?

**Deshabilitar** mantiene la cuenta y sus datos, pero impide el inicio de sesión.  
**Eliminar** quita la cuenta del sistema (y a menudo su configuración e historial), lo que complica la auditoría y la recuperación.

### ¿Qué ventajas ofrece deshabilitar una cuenta?

- Conserva información y evidencia.  
- Se puede reactivar rápido.  
- Evita problemas de auditoría.  
- Sirve en vacaciones, suspensiones o sospecha de actividad indebida.

### ¿Qué riesgos existen si nunca se deshabilitan cuentas antiguas?

- Ex-empleados o usuarios antiguos podrían seguir entrando.  
- Mayor superficie de ataque.  
- Cuentas olvidadas con contraseñas débiles o filtradas.  
- Dificultad para saber quién realmente necesita acceso.

### ¿Qué sucede con los archivos personales de un usuario deshabilitado?

En un sistema operativo, los archivos del perfil suelen **conservarse** aunque la cuenta no pueda iniciar sesión.  
En Nexus, la fila del usuario y sus datos relacionados **siguen en la base de datos**; solo se bloquea la autenticación.

### ¿En qué escenarios empresariales se recomienda esta práctica?

- Empleado de vacaciones o licencia.  
- Suspensión por investigación.  
- Baja temporal.  
- Detección de actividad sospechosa.  
- Conservar cuentas de alumnos o clientes que podrían regresar.  
- Periodo de retención antes de borrar definitivamente.

---

## 9. Conclusión

Se demostró en Nexus Nightclub el ciclo completo de administración de cuentas:

1. Listar usuarios y su estado.  
2. Deshabilitar una cuenta de nivel USER.  
3. Comprobar que el login es rechazado.  
4. Habilitar de nuevo y recuperar el acceso sin perder datos.

Esto equivale, a nivel de aplicación, a las buenas prácticas de administración de cuentas del sistema operativo descritas en la práctica 13.

---

## 10. Referencias técnicas

- Frontend: Angular — ruta `/usuarios`  
- Auth: Spring Boot — `bck-ms-a`  
- Base de datos: Supabase PostgreSQL — tabla `users`  
- Documento de arranque: `antro/docs/PRACTICA_13_CUENTAS_USUARIO.md`
