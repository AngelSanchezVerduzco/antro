import 'package:flutter/material.dart';

import '../models/promocion.dart';
import '../services/api_service.dart';
import '../services/local_pin_service.dart';
import '../services/mensaje_red.dart';
import '../services/notification_service.dart';
import '../theme/nexus_theme.dart';
import '../widgets/promo_network_image.dart';
import 'promo_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.apiService,
    required this.notificationService,
    required this.onLogout,
    required this.pinService,
    this.linkedEmail,
  });

  final ApiService apiService;
  final NotificationService notificationService;
  final VoidCallback onLogout;
  final LocalPinService pinService;
  final String? linkedEmail;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _loading = false;
  bool _imagenLista = false;
  String? _status;
  bool _statusError = false;
  Promocion? _lastPromo;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  String _mensajeRed(Object err) => mensajeDeRed(err);

  Future<void> _fetchLatest() async {
    setState(() {
      _loading = true;
      _status = null;
    });

    try {
      final promo = await widget.apiService.fetchLatestPromocion();
      setState(() {
        _lastPromo = promo;
        _status = 'Última promoción lista.';
        _statusError = false;
      });
    } catch (err) {
      setState(() {
        _status = _mensajeRed(err);
        _statusError = true;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _publishPromo() async {
    final titulo = _titleController.text.trim();
    final cuerpo = _bodyController.text.trim();

    if (titulo.isEmpty || cuerpo.isEmpty) {
      setState(() {
        _status = 'Completa título y descripción.';
        _statusError = true;
      });
      return;
    }

    setState(() {
      _loading = true;
      _status = null;
    });

    try {
      final promo = await widget.apiService.createPromocion(
        title: titulo,
        body: cuerpo,
      );

      setState(() {
        _lastPromo = promo;
        _status = 'Ya puedes ver la promoción publicada.';
        _statusError = false;
      });
    } catch (err) {
      setState(() {
        _status = _mensajeRed(err);
        _statusError = true;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
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
        title: const Text('Nexus'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: NexusColors.purpleSoft,
                child: Icon(Icons.smartphone, color: NexusColors.purple),
              ),
              title: Text(
                widget.linkedEmail == null
                    ? 'Celular listo'
                    : 'Vinculado: ${widget.linkedEmail}',
              ),
              subtitle: const Text('Ya puedes subir promociones'),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nueva promoción',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Título, descripción e imagen. Se guarda en el servidor de Nexus.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Título de la promoción'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Descripción'),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _imagenLista = true),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
              child: _imagenLista
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 48, color: NexusColors.purple),
                        SizedBox(height: 8),
                        Text('Imagen lista (se usará la imagen por defecto del servidor)'),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Toca para agregar una imagen'),
                        Text(
                          'Toca para usar la imagen por defecto',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _loading ? null : _publishPromo,
            icon: const Icon(Icons.campaign_outlined),
            label: const Text('Publicar promoción'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _loading ? null : _fetchLatest,
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Ver última promoción'),
          ),
          if (_loading) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator(color: NexusColors.purple)),
          ],
          if (_status != null) ...[
            const SizedBox(height: 16),
            NexusStatusBanner(texto: _status!, error: _statusError),
          ],
          const SizedBox(height: 24),
          if (_lastPromo == null && !_loading)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Aún no hay una promoción para mostrar. Publícala o consúltala cuando haya red.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            )
          else if (_lastPromo != null)
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: PromoNetworkImage(
                        url: _lastPromo!.imageUrl,
                        height: 140,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _lastPromo!.title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    Text(_lastPromo!.body),
                    TextButton(
                      onPressed: () => _openDetail(_lastPromo!),
                      child: const Text('Ver detalle'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
