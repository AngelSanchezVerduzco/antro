# Nexus Widget (Flutter)

App Flutter que actúa como **widget / wearable** para el sitio Nexus Nightclub.

## Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) instalado
- API de Nexus corriendo: `npm run api` (desde la raíz del repo)

## Primera vez

```bash
cd flutter_app
flutter create . --project-name nexus_widget
flutter pub get
```

## Ejecutar

```bash
# Windows (API en localhost)
flutter run -d windows

# Android emulator (API en la máquina host)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

## Qué hace la app

1. **Publicar promo y notificar** — `POST /api/promociones` + notificación local
2. **Buscar última promo** — `GET /api/promociones/latest` + notificación
3. **Tocar la notificación** — abre la pantalla con la imagen (`imageUrl`)

## Dashboard de tareas (Flutter Web → Angular)

Entry point separado para el dashboard embebido en el sitio Angular:

```bash
# Desde la raíz del repo (requiere Flutter SDK)
npm run flutter:build:dashboard

# Vista previa solo del dashboard en Chrome
npm run flutter:run:dashboard
```

Luego abre `http://localhost:4200/dashboard` con `npm start` en la raíz.

Archivos clave:

- `lib/main_dashboard.dart` — entry point web
- `lib/widgets/stats_widget.dart` — widget de estadísticas
- `lib/screens/tasks_dashboard_screen.dart` — dashboard completo

## Estructura

- `lib/services/api_service.dart` — consume el backend
- `lib/services/notification_service.dart` — notificaciones locales
- `lib/screens/promo_detail_screen.dart` — imagen al desplegar la noti
