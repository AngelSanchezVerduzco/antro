import 'dart:async';

import 'package:flutter/material.dart';

import '../services/device_auth_api.dart';
import '../services/local_pin_service.dart';

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

  Future<void> _startPairing() async {
    setState(() {
      _loading = true;
      _statusMessage = null;
    });

    try {
      final deviceId = await widget.pinService.getOrCreateDeviceId();
      final result = await widget.deviceAuthApi.requestPairing(deviceId);

      setState(() {
        _deviceId = deviceId;
        _pairingCode = result['pairingCode'] as String?;
        _statusMessage = 'En tu celular o PC (logueado), confirma este codigo en Postman.';
      });

      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pollStatus());
    } catch (err) {
      setState(() => _statusMessage = err.toString());
    } finally {
      setState(() => _loading = false);
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
      // Sigue intentando hasta que el usuario confirme el codigo.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vincular reloj'), backgroundColor: const Color(0xFF5B21B6), foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Estilo Netflix: muestra este codigo y confirmalo desde tu cuenta (Spring Auth).',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_pairingCode != null) ...[
              Text(_pairingCode!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 8)),
              const SizedBox(height: 16),
              Text('Device ID: $_deviceId', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
            if (_statusMessage != null) ...[
              const SizedBox(height: 24),
              Text(_statusMessage!, textAlign: TextAlign.center),
            ],
            const Spacer(),
            OutlinedButton(onPressed: _startPairing, child: const Text('Generar nuevo codigo')),
          ],
        ),
      ),
    );
  }
}
