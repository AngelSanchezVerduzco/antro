import 'package:flutter/material.dart';

import '../models/promocion.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'promo_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.apiService,
    required this.notificationService,
  });

  final ApiService apiService;
  final NotificationService notificationService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _titleController = TextEditingController(text: '2x1 en cócteles');
  final _bodyController = TextEditingController(text: 'Nueva promo todos los viernes en Nexus.');

  bool _loading = false;
  String? _status;
  Promocion? _lastPromo;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndNotify() async {
    setState(() {
      _loading = true;
      _status = null;
    });

    try {
      final promo = await widget.apiService.fetchLatestPromocion();
      await widget.notificationService.showPromocion(
        id: promo.id,
        title: promo.title,
        body: promo.body,
        imageUrl: promo.imageUrl,
      );

      setState(() {
        _lastPromo = promo;
        _status = 'Notificación enviada: ${promo.title}';
      });
    } catch (err) {
      setState(() => _status = err.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _publishPromo() async {
    setState(() {
      _loading = true;
      _status = null;
    });

    try {
      final promo = await widget.apiService.createPromocion(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
      );

      await widget.notificationService.showPromocion(
        id: promo.id,
        title: promo.title,
        body: promo.body,
        imageUrl: promo.imageUrl,
      );

      setState(() {
        _lastPromo = promo;
        _status = 'Promoción publicada y notificación enviada.';
      });
    } catch (err) {
      setState(() => _status = err.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openDetail(Promocion promo) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PromoDetailScreen(promocion: promo)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexus Widget'),
        backgroundColor: const Color(0xFF5B21B6),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Simulador de wearable / smart TV',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Consulta el backend de Nexus, dispara una notificación local y al abrirla muestra la imagen de la promoción.',
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título de la promoción',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _loading ? null : _publishPromo,
            icon: const Icon(Icons.campaign_outlined),
            label: const Text('Publicar promo y notificar'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _loading ? null : _fetchAndNotify,
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Buscar última promo y notificar'),
          ),
          if (_loading) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_status != null) ...[
            const SizedBox(height: 16),
            Text(_status!, style: TextStyle(color: _status!.startsWith('Notificación') || _status!.startsWith('Promoción') ? Colors.green.shade700 : Colors.red.shade700)),
          ],
          if (_lastPromo != null) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_lastPromo!.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_lastPromo!.body),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => _openDetail(_lastPromo!),
                      child: const Text('Ver imagen de la promoción'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
