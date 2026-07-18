# PRÁCTICA 12

## Reporte de pruebas de seguridad de la aplicación para smartwatch Nexus Widget

**Proyecto:** Nexus Nightclub — Nexus Widget  
**Alumno:** [Tu nombre]  
**Matrícula:** [Tu matrícula]  
**Repositorio Git:** [URL de tu repositorio]  
**Fecha:** Julio de 2026  

---

## 1. Introducción

Este documento presenta los resultados de las pruebas de seguridad realizadas a **Nexus Widget**, una aplicación Flutter que simula el funcionamiento de una aplicación para smartwatch o wearable vinculada al sitio Nexus Nightclub.

La aplicación permite consultar promociones y mostrar notificaciones con imágenes. Debido a que el dispositivo queda relacionado con el perfil de un usuario, se agregó autenticación local mediante PIN, vinculación del smartwatch con una cuenta y administración de sesión.

La aplicación fue ejecutada en Google Chrome como simulador del wearable. La biometría se dejó implementada como función opcional, pero no pudo probarse en este entorno web porque depende del soporte del dispositivo o emulador.

---

## 2. Objetivo

Verificar que:

1. No sea posible entrar a la pantalla principal sin autenticación local.
2. El PIN, las contraseñas y los códigos de vinculación no se almacenen en texto plano.
3. El smartwatch solamente pueda vincularse a un usuario autenticado.
4. La sesión tenga duración limitada y pueda cerrarse.
5. Se identifiquen vulnerabilidades, riesgos y recomendaciones antes de publicar la aplicación.

---

## 3. Alcance

Se revisaron los siguientes componentes:

| Componente | Tecnología | Función |
|---|---|---|
| Nexus Widget | Flutter | PIN, sesión local, vinculación y pantalla protegida |
| Microservicio de autenticación | Spring Boot | Registro, login, JWT y vinculación de dispositivos |
| Base de datos | Supabase/PostgreSQL | Usuarios, códigos temporales y dispositivos vinculados |
| Pruebas de API | Postman | Confirmación de respuestas y autorización |
| Navegador | Google Chrome | Simulación de la aplicación wearable |

No se incluyó una prueba de biometría real porque Chrome no proporciona el mismo soporte que un smartwatch, teléfono o emulador compatible.

---

## 4. Arquitectura implementada

```text
Usuario
  |
  | crea/ingresa PIN local
  v
Nexus Widget (Flutter)
  |
  | solicita código temporal de seis dígitos
  v
Spring Boot Auth (localhost:8080)
  |
  | usuario confirma el código utilizando JWT
  v
Supabase (users, device_pairing_codes, linked_devices)
  |
  | dispositivo vinculado
  v
Pantalla protegida de promociones
```

El microservicio Node de promociones continúa funcionando por separado en el puerto 3000. Spring Boot se encarga de usuarios y vinculación; Flutter consume ambos servicios.

---

## 5. Controles de seguridad implementados

### 5.1 PIN local

- Longitud permitida: cuatro a seis dígitos.
- Se solicita dos veces durante la configuración inicial.
- No se guarda el PIN original.
- Se genera una sal aleatoria y se almacena el resultado de `SHA-256(salt:PIN)`.
- El valor se guarda mediante `flutter_secure_storage`.

### 5.2 Pantalla principal protegida

La clase `AppGate` decide qué pantalla mostrar:

1. Configuración de PIN si todavía no existe.
2. Login con PIN si no hay una sesión activa.
3. Vinculación si el dispositivo aún no pertenece a una cuenta.
4. Home de promociones únicamente cuando las validaciones anteriores se cumplen.

### 5.3 Biometría opcional

Se agregó el paquete `local_auth`. La opción solo aparece cuando el sistema reporta biometría disponible. En Chrome no pudo validarse, por lo que la autenticación principal de las pruebas fue el PIN.

### 5.4 Vinculación estilo Netflix

- El smartwatch genera un código aleatorio de seis dígitos.
- El código expira después de cinco minutos.
- Spring almacena el código con BCrypt, no en texto plano.
- El endpoint de confirmación exige un JWT de usuario válido.
- Al confirmarse, el dispositivo se relaciona con el usuario en Supabase.

### 5.5 Administración de sesión

- La sesión local tiene una duración de 15 minutos.
- El botón de cierre de sesión elimina la sesión y el token local.
- El cierre también intenta revocar la vinculación en el backend.
- La contraseña de la cuenta y el token permanente del dispositivo se almacenan como hashes BCrypt en la base.

---

## 6. Entorno de pruebas

| Elemento | Configuración |
|---|---|
| Sistema operativo | Windows 11 |
| Flutter | Canal estable 3.44.2 |
| Dispositivo de prueba | Google Chrome, simulación web |
| Backend | Spring Boot 4.1.0, puerto 8080 |
| Base de datos | Supabase PostgreSQL |
| Cliente de API | Postman |
| Cuenta utilizada | admin@nexus.com, rol ADMIN |

---

## 7. Pruebas realizadas y resultados

### Prueba 1. Protección inicial mediante PIN

**Procedimiento:** abrir la aplicación por primera vez, crear un PIN válido e intentar continuar.  
**Resultado:** la aplicación no mostró directamente el Home; primero exigió configurar y validar el PIN.  
**Estado:** APROBADA.

### Prueba 2. Generación de código temporal de vinculación

**Procedimiento:** después de validar el PIN, solicitar la vinculación del smartwatch.  
**Resultado:** se generó el código `762719` y un identificador único de dispositivo. La aplicación quedó esperando la confirmación del usuario.  
**Estado:** APROBADA.

<div class="evidence">
  <img src="file:///C:/Users/ravsi/.cursor/projects/c-Users-ravsi-proyecto-dedos/assets/c__Users_ravsi_AppData_Roaming_Cursor_User_workspaceStorage_4f7fc902223d461fbd24474d1bfbce09_images_image-30aa8cc6-c61c-4ee3-a988-84316b4357ce.png" />
  <p><strong>Evidencia 1.</strong> Código temporal mostrado por Nexus Widget.</p>
</div>

### Prueba 3. Confirmación protegida mediante JWT

**Procedimiento:** iniciar sesión en Spring Boot, copiar el JWT y enviar el código a `POST /api/device/confirm-pairing` con el encabezado `Authorization: Bearer TOKEN`.  
**Resultado:** el servidor respondió `200 OK` y devolvió el usuario `admin@nexus.com` con rol `ADMIN`.  
**Estado:** APROBADA.

<div class="evidence">
  <img src="file:///C:/Users/ravsi/.cursor/projects/c-Users-ravsi-proyecto-dedos/assets/c__Users_ravsi_AppData_Roaming_Cursor_User_workspaceStorage_4f7fc902223d461fbd24474d1bfbce09_images_image-d77386c5-7fd8-4ced-89c1-6ead59aedf9b.png" />
  <p><strong>Evidencia 2.</strong> Confirmación de la vinculación con respuesta 200 OK.</p>
</div>

### Prueba 4. Acceso a la pantalla principal protegida

**Procedimiento:** esperar a que Flutter consultara el estado después de confirmar el código.  
**Resultado:** la aplicación cambió automáticamente al Home y mostró `Vinculado: admin@nexus.com`.  
**Estado:** APROBADA.

<div class="evidence">
  <img src="file:///C:/Users/ravsi/.cursor/projects/c-Users-ravsi-proyecto-dedos/assets/c__Users_ravsi_AppData_Roaming_Cursor_User_workspaceStorage_4f7fc902223d461fbd24474d1bfbce09_images_image-e2b06f28-592d-467c-85c6-5a90d64dd118.png" />
  <p><strong>Evidencia 3.</strong> Home protegido después de vincular el smartwatch.</p>
</div>

### Prueba 5. Rechazo de usuario duplicado

**Procedimiento:** intentar registrar nuevamente el mismo correo electrónico.  
**Resultado:** Spring respondió `409 Conflict` con el mensaje `El correo ya esta registrado`.  
**Estado:** APROBADA.

<div class="evidence">
  <img src="file:///C:/Users/ravsi/.cursor/projects/c-Users-ravsi-proyecto-dedos/assets/c__Users_ravsi_AppData_Roaming_Cursor_User_workspaceStorage_4f7fc902223d461fbd24474d1bfbce09_images_image-69816006-bc49-45eb-8d78-e16f07bed4d7.png" />
  <p><strong>Evidencia 4.</strong> Protección contra correos duplicados.</p>
</div>

### Prueba 6. Revisión del almacenamiento de credenciales

**Procedimiento:** revisar el código y el esquema de Supabase.  
**Resultado:** se encontraron columnas `password_hash`, `code_hash` y `device_token_hash`. El PIN local también se guarda como hash con sal.  
**Estado:** APROBADA CON OBSERVACIONES, debido a las vulnerabilidades descritas en la sección 8.

### Prueba 7. Persistencia en Supabase

**Procedimiento:** ejecutar el esquema SQL y conectar Spring Boot mediante el Session Pooler de Supabase.  
**Resultado:** las tablas `users`, `device_pairing_codes` y `linked_devices` fueron creadas y Spring inició correctamente con PostgreSQL, sin utilizar H2.  
**Estado:** APROBADA.

<div class="evidence">
  <img src="file:///C:/Users/ravsi/.cursor/projects/c-Users-ravsi-proyecto-dedos/assets/c__Users_ravsi_AppData_Roaming_Cursor_User_workspaceStorage_4f7fc902223d461fbd24474d1bfbce09_images_image-3ead55de-cfe9-475b-ab70-4c6b391515db.png" />
  <p><strong>Evidencia 5.</strong> Tablas de seguridad creadas en Supabase.</p>
</div>

### Pruebas pendientes de evidencia adicional

- Captura del mensaje producido por un PIN incorrecto.
- Captura de la aplicación después de cerrar sesión.
- Prueba de expiración automática después de 15 minutos.
- Prueba biométrica en dispositivo o emulador compatible.

Estas funciones están implementadas, pero deben capturarse manualmente antes de una entrega final si el docente exige evidencia visual de cada caso.

---

## 8. Vulnerabilidades encontradas

| ID | Vulnerabilidad | Riesgo | Nivel |
|---|---|---|---|
| V-01 | `/api/device/revoke` es público y recibe solo `deviceId` | Un tercero que conozca el identificador podría desvincular el reloj | Alto |
| V-02 | `/api/device/status` es público y puede entregar una vez el token del dispositivo | Si se filtra el `deviceId`, un atacante podría consultar primero y robar la sesión | Alto |
| V-03 | `delivery_token` se almacena temporalmente en texto plano en Supabase | Una lectura no autorizada de la tabla podría revelar el token antes de que Flutter lo consuma | Alto |
| V-04 | El PIN local utiliza SHA-256, que es rápido | Si alguien obtiene el hash y la sal, puede probar todos los PIN de 4–6 dígitos rápidamente | Medio |
| V-05 | No existe límite de intentos ni bloqueo temporal del PIN local | Permite intentos repetidos de fuerza bruta | Medio |
| V-06 | CORS permite cualquier origen | Un sitio no autorizado podría intentar consumir endpoints públicos desde el navegador | Medio |
| V-07 | Existe un valor JWT de desarrollo como alternativa en la configuración | Si se usa en producción, los tokens podrían falsificarse al conocer el secreto | Alto |
| V-08 | En Flutter Web, el almacenamiento seguro depende de las capacidades del navegador | Ofrece menos aislamiento que Android Keystore, iOS Keychain o un smartwatch real | Medio |

---

## 9. Recomendaciones

1. Exigir autenticación del dispositivo para `/status` y `/revoke`.
2. Sustituir la entrega por consulta pública del token por un intercambio seguro de un solo uso, ligado a una clave generada por el dispositivo.
3. No guardar `delivery_token` en texto plano; cifrarlo o reemplazarlo por un reto firmado.
4. Usar PBKDF2, Argon2id o scrypt para derivar el hash del PIN local.
5. Bloquear temporalmente después de cinco PIN incorrectos y aumentar el tiempo en fallos sucesivos.
6. Restringir CORS a las URLs reales de Angular y Flutter Web.
7. Hacer obligatoria la variable `JWT_SECRET`, con un valor aleatorio y administrado fuera de Git.
8. Aplicar RLS o restringir completamente el acceso de Data API a las tablas de seguridad.
9. Probar biometría y almacenamiento seguro en Android, Wear OS o emulador compatible.
10. Agregar pruebas automatizadas para códigos vencidos, JWT inválido, logout y acceso sin sesión.

---

## 10. Resultado general

| Criterio solicitado | Resultado |
|---|---|
| Pantalla de inicio de sesión | Cumplido mediante PIN local |
| PIN de cuatro o seis dígitos | Cumplido |
| Biometría | Implementada, no probada en Chrome |
| Pantalla principal protegida | Cumplido |
| Cierre de sesión | Implementado, falta captura específica |
| Credenciales fuera de texto plano | Cumplido parcialmente; existe una observación con `delivery_token` |
| Administración de sesión | Cumplida mediante sesión local de 15 minutos y revocación |
| Base de datos real | Cumplido con Supabase/PostgreSQL |
| Pruebas y evidencias | Cumplido parcialmente; faltan capturas de PIN incorrecto, timeout y logout |

---

## 11. Conclusión

Nexus Widget cumple el flujo principal solicitado: protege la pantalla principal mediante PIN, vincula el smartwatch con un usuario autenticado y mantiene la información en Supabase. Las pruebas realizadas confirmaron la generación del código temporal, su autorización mediante JWT y el acceso posterior al Home protegido.

Sin embargo, la revisión también encontró vulnerabilidades relevantes en la entrega y revocación del token del dispositivo, así como oportunidades de mejora en el almacenamiento del PIN y el control de intentos. Por ello, la aplicación es adecuada como prototipo académico, pero las vulnerabilidades de nivel alto deben corregirse antes de considerarla segura para producción.

---

## 12. Archivos principales

- `antro/flutter_app/lib/screens/app_gate.dart`
- `antro/flutter_app/lib/screens/pin_setup_screen.dart`
- `antro/flutter_app/lib/screens/pin_login_screen.dart`
- `antro/flutter_app/lib/screens/device_pairing_screen.dart`
- `antro/flutter_app/lib/services/local_pin_service.dart`
- `bck-ms-a/src/main/java/com/example/bck_ms_a/service/DeviceService.java`
- `bck-ms-a/src/main/java/com/example/bck_ms_a/config/SecurityConfig.java`
- `bck-ms-a/supabase/schema.sql`
