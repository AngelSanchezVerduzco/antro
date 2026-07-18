import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/biometric_service.dart';
import '../services/local_pin_service.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({
    super.key,
    required this.pinService,
    required this.biometricService,
    required this.onUnlocked,
  });

  final LocalPinService pinService;
  final BiometricService biometricService;
  final VoidCallback onUnlocked;

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final _pinController = TextEditingController();
  String? _error;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final available = await widget.biometricService.isAvailable();
    if (mounted) setState(() => _biometricAvailable = available);
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _unlockWithPin() async {
    final ok = await widget.pinService.verifyPin(_pinController.text.trim());
    if (!ok) {
      setState(() => _error = 'PIN incorrecto.');
      return;
    }

    await widget.pinService.openSession();
    widget.onUnlocked();
  }

  Future<void> _unlockWithBiometric() async {
    final ok = await widget.biometricService.authenticate();
    if (!ok) {
      setState(() => _error = 'Biometria no disponible o cancelada.');
      return;
    }

    await widget.pinService.openSession();
    widget.onUnlocked();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Desbloquear'), backgroundColor: const Color(0xFF5B21B6), foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Ingresa tu PIN para ver promociones y datos protegidos.', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'PIN', border: OutlineInputBorder(), counterText: ''),
              onSubmitted: (_) => _unlockWithPin(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Colors.red.shade700)),
            ],
            const SizedBox(height: 16),
            FilledButton(onPressed: _unlockWithPin, child: const Text('Entrar')),
            if (_biometricAvailable) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _unlockWithBiometric,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Usar biometria'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
