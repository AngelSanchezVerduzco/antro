import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/local_pin_service.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key, required this.pinService, required this.onCompleted});

  final LocalPinService pinService;
  final VoidCallback onCompleted;

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _savePin() async {
    final pin = _pinController.text.trim();
    final confirm = _confirmController.text.trim();

    if (pin != confirm) {
      setState(() => _error = 'Los PIN no coinciden.');
      return;
    }

    try {
      await widget.pinService.setupPin(pin);
      await widget.pinService.openSession();
      widget.onCompleted();
    } catch (err) {
      setState(() => _error = err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear PIN'), backgroundColor: const Color(0xFF5B21B6), foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Protege tu smartwatch con un PIN de 4 a 6 digitos.', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'PIN', border: OutlineInputBorder(), counterText: ''),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Confirmar PIN', border: OutlineInputBorder(), counterText: ''),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Colors.red.shade700)),
            ],
            const Spacer(),
            FilledButton(onPressed: _savePin, child: const Text('Guardar PIN')),
          ],
        ),
      ),
    );
  }
}
