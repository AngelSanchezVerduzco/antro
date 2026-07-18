import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/biometric_service.dart';
import '../services/device_auth_api.dart';
import '../services/local_pin_service.dart';
import '../services/notification_service.dart';
import 'device_pairing_screen.dart';
import 'home_screen.dart';
import 'pin_login_screen.dart';
import 'pin_setup_screen.dart';

enum AppGateStep { loading, pinSetup, pinLogin, pairing, home }

class AppGate extends StatefulWidget {
  const AppGate({
    super.key,
    required this.apiService,
    required this.notificationService,
  });

  final ApiService apiService;
  final NotificationService notificationService;

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  final _pinService = LocalPinService();
  final _biometricService = BiometricService();
  final _deviceAuthApi = DeviceAuthApi();

  AppGateStep _step = AppGateStep.loading;
  String? _linkedEmail;

  @override
  void initState() {
    super.initState();
    _resolveStep();
  }

  Future<void> _resolveStep() async {
    final hasPin = await _pinService.hasPinConfigured();

    if (!hasPin) {
      setState(() => _step = AppGateStep.pinSetup);
      return;
    }

    final hasSession = await _pinService.hasActiveSession();
    if (!hasSession) {
      setState(() => _step = AppGateStep.pinLogin);
      return;
    }

    final linked = await _pinService.isDeviceLinked();
    if (!linked) {
      setState(() => _step = AppGateStep.pairing);
      return;
    }

    final email = await _pinService.linkedEmail();
    setState(() {
      _linkedEmail = email;
      _step = AppGateStep.home;
    });
  }

  Future<void> _logout() async {
    final deviceId = await _pinService.getOrCreateDeviceId();
    try {
      await _deviceAuthApi.revokeDevice(deviceId);
    } catch (_) {}

    await _pinService.closeSession();
    await _pinService.unlinkDevice();
    setState(() => _step = AppGateStep.pinLogin);
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case AppGateStep.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AppGateStep.pinSetup:
        return PinSetupScreen(
          pinService: _pinService,
          onCompleted: _resolveStep,
        );
      case AppGateStep.pinLogin:
        return PinLoginScreen(
          pinService: _pinService,
          biometricService: _biometricService,
          onUnlocked: _resolveStep,
        );
      case AppGateStep.pairing:
        return DevicePairingScreen(
          pinService: _pinService,
          deviceAuthApi: _deviceAuthApi,
          onLinked: _resolveStep,
        );
      case AppGateStep.home:
        return HomeScreen(
          apiService: widget.apiService,
          notificationService: widget.notificationService,
          linkedEmail: _linkedEmail,
          onLogout: _logout,
          pinService: _pinService,
        );
    }
  }
}
