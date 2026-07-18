import 'package:flutter/material.dart';

import 'models/promocion.dart';
import 'screens/app_gate.dart';
import 'screens/promo_detail_screen.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';

final _apiService = ApiService();
final _notificationService = NotificationService();
final _navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _notificationService.init(
    onTap: (payload) {
      if (payload == null || !payload.contains('|')) return;

      final parts = payload.split('|');
      if (parts.length < 4) return;

      final promo = Promocion(
        id: parts[0],
        type: 'promocion_nueva',
        title: parts[2],
        body: parts[3],
        imageUrl: parts[1],
        deepLink: '/inicio',
        expiresAt: '',
        createdAt: '',
      );

      _navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => PromoDetailScreen(promocion: promo)),
      );
    },
  );

  runApp(const NexusWidgetApp());
}

class NexusWidgetApp extends StatelessWidget {
  const NexusWidgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Nexus Widget',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C3AED)),
        useMaterial3: true,
      ),
      home: AppGate(
        apiService: _apiService,
        notificationService: _notificationService,
      ),
    );
  }
}
