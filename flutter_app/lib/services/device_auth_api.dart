import 'dart:convert';

import 'package:http/http.dart' as http;

const String authBaseUrl = String.fromEnvironment(
  'AUTH_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

class DeviceAuthApi {
  Future<Map<String, dynamic>> requestPairing(String deviceId) async {
    final uri = Uri.parse('$authBaseUrl/api/device/request-pairing');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'deviceId': deviceId}),
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo generar codigo: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> pollStatus(String deviceId) async {
    final uri = Uri.parse('$authBaseUrl/api/device/status').replace(
      queryParameters: {'deviceId': deviceId},
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Error consultando estado: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> validateSession({
    required String deviceId,
    required String deviceToken,
  }) async {
    final uri = Uri.parse('$authBaseUrl/api/device/validate-session');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'deviceId': deviceId, 'deviceToken': deviceToken}),
    );

    if (response.statusCode != 200) {
      throw Exception('Sesion de dispositivo invalida');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> revokeDevice(String deviceId) async {
    final uri = Uri.parse('$authBaseUrl/api/device/revoke');
    await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'deviceId': deviceId}),
    );
  }
}
