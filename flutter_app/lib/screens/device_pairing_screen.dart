import 'dart:async';

import 'package:flutter/material.dart';

import '../services/device_auth_api.dart';
import '../services/local_pin_service.dart';
import '../theme/nexus_theme.dart';

class DevicePairingScreen extends StatefulWidget {
  const DevicePairingScreen({
    super.key,
    required this.pinService,
    required this.deviceAuthApi,
    required this.onLinked,
  });

  final LocalPinService pinService;
  final DeviceAuthApi deviceAuthApi;
  final VoidCallback onLinked;

  @override
  State<DevicePairingScreen> createState() => _DevicePairingScreenState();
}

class _DevicePairingScreenState extends State<DevicePairingScreen> {
  String? _deviceId;
  String? _pairingCode;
  String? _statusMessage;
  bool _error = false;
  Timer? _pollTimer;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _startPairing();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  String _mensajeAmigable(Object err) {
    final texto = err.toString().toLowerCase();
    if (texto.contains('socket') ||
        texto.contains('failed host') ||
        texto.contains('connection') ||
        texto.contains('timed out') ||
        texto.contains('network')) {
      return 'Sin red. En la fase 2 se conecta al servidor; por ahora puedes generar otro código.';
    }
    return 'No se pudo generar el código. Intenta de nuevo.';
  }

  Future<void> _startPairing() async {
    setState(() {
      _loading = true;
      _statusMessage = null;
      _error = false;
    });

    try {
      final deviceId = await widget.pinService.getOrCreateDeviceId();
      final result = await widget.deviceAuthApi.requestPairing(deviceId);
      final code = result['pairingCode'] as String?;

      if (code == null || code.length != 6) {
        throw Exception('El servidor no devolvió un código válido.');
      }

      setState(() {
        _deviceId = deviceId;
        _pairingCode = code;
        _statusMessage =
            'Confirma este código en tu cuenta Nexus (sitio web → Vincular dispositivo). El celular espera solo.';
        _error = false;
      });

      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pollStatus());
    } catch (err) {
      // Nunca mostrar un código inventado: la web no podría confirmarlo.
      setState(() {
        _pairingCode = null;
        _statusMessage = _mensajeAmigable(err);
        _error = true;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pollStatus() async {
    if (_deviceId == null) return;

    try {
      final result = await widget.deviceAuthApi.pollStatus(_deviceId!);
      final status = result['status'] as String?;

      if (status == 'linked') {
        final token = result['deviceToken'] as String?;
        final email = result['userEmail'] as String?;

        if (token != null && email != null) {
          await widget.pinService.saveDeviceLink(deviceToken: token, email: email);
          _pollTimer?.cancel();
          widget.onLinked();
        }
      }
    } catch (_) {
      // Sigue intentando hasta que confirmen el código o se genere otro.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vincula tu celular')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Para subir promociones, este celular tiene que quedar ligado a tu cuenta.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_loading) ...[
                      const CircularProgressIndicator(color: NexusColors.purple),
                      const SizedBox(height: 16),
                      const Text('Generando código...'),
                    ] else ...[
                      const Text(
                        'Código de acceso',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _pairingCode ?? '------',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 8,
                          color: NexusColors.purple,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_statusMessage != null)
                        NexusStatusBanner(texto: _statusMessage!, error: _error),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _loading ? null : _startPairing,
              child: const Text('Generar nuevo código'),
            ),
          ],
        ),
      ),
    );
  }
}
