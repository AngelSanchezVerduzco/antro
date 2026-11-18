import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../config/api_hosts.dart';
import '../models/promocion.dart';

const String _apiBaseRaw = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

String get apiBaseUrl => urlParaDispositivo(_apiBaseRaw);

bool esFalloDeRed(Object error) {
  final texto = error.toString().toLowerCase();
  return texto.contains('socket') ||
      texto.contains('connection') ||
      texto.contains('timed out') ||
      texto.contains('network') ||
      texto.contains('failed host') ||
      texto.contains('failed to fetch') ||
      texto.contains('clientexception') ||
      texto.contains('timeout');
}

Duration esperaProgresiva(int intento) => Duration(milliseconds: 200 * (1 << intento));

Future<T> conReintento<T>(
  Future<T> Function() intento, {
  int veces = 3,
  Duration Function(int intento) espera = esperaProgresiva,
}) async {
  Object? ultimo;
  for (var i = 0; i < veces; i++) {
    try {
      return await intento();
    } catch (error) {
      ultimo = error;
      final puedeReintentar = esFalloDeRed(error) && i < veces - 1;
      if (!puedeReintentar) rethrow;
      await Future<void>.delayed(espera(i));
    }
  }
  throw ultimo ?? Exception('No se pudo completar la solicitud.');
}

class ApiService {
  ApiService({
    http.Client? client,
    String? baseUrl,
    this.espera = esperaProgresiva,
    this.tiempoLimite = const Duration(seconds: 8),
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;
  final Duration Function(int intento) espera;
  final Duration tiempoLimite;

  Future<Promocion> fetchLatestPromocion() {
    return conReintento(_consultarUltima, espera: espera);
  }

  Future<Promocion> _consultarUltima() async {
    final uri = Uri.parse('$_baseUrl/api/promociones/latest');
    final response = await _client.get(uri).timeout(tiempoLimite);

    if (response.statusCode == 404) {
      throw Exception('No hay promociones activas en el servidor.');
    }

    if (response.statusCode != 200) {
      throw Exception('Error del servidor (${response.statusCode}).');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return Promocion.fromJson(_conUrlDelEmulador(json));
  }

  Future<Promocion> createPromocion({
    required String title,
    required String body,
    String? imageUrl,
    String? idempotencyKey,
  }) {
    final clave = idempotencyKey ?? const Uuid().v4();
    return conReintento(() => _crear(title, body, imageUrl, clave), espera: espera);
  }

  Future<Promocion> _crear(String title, String body, String? imageUrl, String clave) async {
    final uri = Uri.parse('$_baseUrl/api/promociones');
    final response = await _client
        .post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Idempotency-Key': clave,
      },
      body: jsonEncode({
        'title': title,
        'body': body,
        if (imageUrl != null) 'imageUrl': imageUrl,
      }),
    )
        .timeout(tiempoLimite);

    if (response.statusCode != 201 && response.statusCode != 200) {
      var mensaje = 'No se pudo crear la promoción (${response.statusCode}).';
      try {
        final error = jsonDecode(response.body);
        if (error is Map && error['error'] != null) {
          mensaje = error['error'].toString();
        }
      } catch (_) {}
      throw Exception(mensaje);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return Promocion.fromJson(_conUrlDelEmulador(json));
  }

  Map<String, dynamic> _conUrlDelEmulador(Map<String, dynamic> json) {
    final image = json['imageUrl'] as String?;
    if (image != null) {
      json['imageUrl'] = urlParaDispositivo(image);
    }
    return json;
  }
}
