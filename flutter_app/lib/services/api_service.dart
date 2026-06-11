import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/promocion.dart';

/// Cambia esta URL según dónde ejecutes la app:
/// - Windows / web: http://localhost:3000
/// - Emulador Android: http://10.0.2.2:3000
/// - Celular físico: http://TU_IP_LOCAL:3000
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

class ApiService {
  Future<Promocion> fetchLatestPromocion() async {
    final uri = Uri.parse('$apiBaseUrl/api/promociones/latest');
    final response = await http.get(uri);

    if (response.statusCode == 404) {
      throw Exception('No hay promociones activas en el servidor.');
    }

    if (response.statusCode != 200) {
      throw Exception('Error del servidor (${response.statusCode}).');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return Promocion.fromJson(json);
  }

  Future<Promocion> createPromocion({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    final uri = Uri.parse('$apiBaseUrl/api/promociones');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'body': body,
        if (imageUrl != null) 'imageUrl': imageUrl,
      }),
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(error['error'] ?? 'No se pudo crear la promoción.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return Promocion.fromJson(json);
  }
}
