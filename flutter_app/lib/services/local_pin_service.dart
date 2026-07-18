import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// PIN local del smartwatch (hasheado, nunca en texto plano).
class LocalPinService {
  LocalPinService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _pinHashKey = 'nexus_pin_hash';
  static const _pinSaltKey = 'nexus_pin_salt';
  static const _sessionUntilKey = 'nexus_session_until';
  static const _deviceIdKey = 'nexus_device_id';
  static const _deviceTokenKey = 'nexus_device_token';
  static const _linkedEmailKey = 'nexus_linked_email';

  static const sessionDuration = Duration(minutes: 15);

  final FlutterSecureStorage _storage;
  final _uuid = const Uuid();

  Future<bool> hasPinConfigured() async {
    final hash = await _storage.read(key: _pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<void> setupPin(String pin) async {
    if (!_isValidPin(pin)) {
      throw Exception('El PIN debe tener 4 a 6 digitos.');
    }

    final salt = _uuid.v4();
    final hash = _hashPin(pin, salt);

    await _storage.write(key: _pinSaltKey, value: salt);
    await _storage.write(key: _pinHashKey, value: hash);
  }

  Future<bool> verifyPin(String pin) async {
    final salt = await _storage.read(key: _pinSaltKey);
    final storedHash = await _storage.read(key: _pinHashKey);

    if (salt == null || storedHash == null) return false;

    return storedHash == _hashPin(pin, salt);
  }

  Future<void> openSession() async {
    final until = DateTime.now().add(sessionDuration).toIso8601String();
    await _storage.write(key: _sessionUntilKey, value: until);
  }

  Future<bool> hasActiveSession() async {
    final untilRaw = await _storage.read(key: _sessionUntilKey);
    if (untilRaw == null) return false;

    final until = DateTime.tryParse(untilRaw);
    if (until == null) return false;

    return DateTime.now().isBefore(until);
  }

  Future<void> closeSession() async {
    await _storage.delete(key: _sessionUntilKey);
  }

  Future<String> getOrCreateDeviceId() async {
    final existing = await _storage.read(key: _deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final deviceId = _uuid.v4();
    await _storage.write(key: _deviceIdKey, value: deviceId);
    return deviceId;
  }

  Future<bool> isDeviceLinked() async {
    final token = await _storage.read(key: _deviceTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> saveDeviceLink({required String deviceToken, required String email}) async {
    await _storage.write(key: _deviceTokenKey, value: deviceToken);
    await _storage.write(key: _linkedEmailKey, value: email);
  }

  Future<String?> linkedEmail() => _storage.read(key: _linkedEmailKey);

  Future<String?> deviceToken() => _storage.read(key: _deviceTokenKey);

  Future<void> unlinkDevice() async {
    await _storage.delete(key: _deviceTokenKey);
    await _storage.delete(key: _linkedEmailKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  bool _isValidPin(String pin) {
    return RegExp(r'^\d{4,6}$').hasMatch(pin);
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }
}
