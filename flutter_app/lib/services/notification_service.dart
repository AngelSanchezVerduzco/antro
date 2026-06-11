import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef NotificationTapHandler = void Function(String? payload);

class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  NotificationTapHandler? _onTap;

  Future<void> init({required NotificationTapHandler onTap}) async {
    _onTap = onTap;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _onTap?.call(response.payload);
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showPromocion({
    required String id,
    required String title,
    required String body,
    required String imageUrl,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'nexus_promos',
      'Promociones Nexus',
      channelDescription: 'Notificaciones de promociones nuevas del antro.',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );

    await _plugin.show(
      id.hashCode,
      title,
      body,
      const NotificationDetails(android: androidDetails),
      payload: '$id|$imageUrl|$title|$body',
    );
  }
}
