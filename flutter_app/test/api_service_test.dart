import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nexus_widget/services/api_service.dart';

const _promo = {
  'id': 'promo-test',
  'type': 'promocion_nueva',
  'title': 'Noche',
  'body': '2x1',
  'imageUrl': 'http://localhost:3000/uploads/promo-default.svg',
  'deepLink': '/inicio',
  'expiresAt': '2026-12-01T00:00:00.000Z',
  'createdAt': '2026-11-10T00:00:00.000Z',
};

void main() {
  test('consulta 200 arma la promoción', () async {
    final api = ApiService(
      baseUrl: 'http://localhost:3000',
      client: MockClient((request) async {
        expect(request.method, 'GET');
        return http.Response(jsonEncode(_promo), 200);
      }),
    );

    final promo = await api.fetchLatestPromocion();
    expect(promo.id, 'promo-test');
    expect(promo.title, 'Noche');
  });

  test('consulta 404 lanza la excepción de sin promociones', () async {
    final api = ApiService(
      baseUrl: 'http://localhost:3000',
      client: MockClient((_) async => http.Response('{}', 404)),
    );

    expect(
      api.fetchLatestPromocion,
      throwsA(predicate((Object e) => e.toString().contains('No hay promociones'))),
    );
  });

  test('consulta distinta de 200 incluye el código', () async {
    final api = ApiService(
      baseUrl: 'http://localhost:3000',
      client: MockClient((_) async => http.Response('{}', 500)),
    );

    expect(
      api.fetchLatestPromocion,
      throwsA(predicate((Object e) => e.toString().contains('500'))),
    );
  });

  test('alta 201 devuelve el registro', () async {
    final api = ApiService(
      baseUrl: 'http://localhost:3000',
      client: MockClient((request) async {
        expect(request.method, 'POST');
        final cuerpo = jsonDecode(request.body) as Map<String, dynamic>;
        expect(cuerpo['title'], 'Noche');
        return http.Response(jsonEncode(_promo), 201);
      }),
    );

    final promo = await api.createPromocion(title: 'Noche', body: '2x1');
    expect(promo.body, '2x1');
  });

  test('alta con error JSON usa el mensaje del servidor', () async {
    final api = ApiService(
      baseUrl: 'http://localhost:3000',
      client: MockClient(
        (_) async => http.Response(jsonEncode({'error': 'title y body son obligatorios'}), 400),
      ),
    );

    expect(
      () => api.createPromocion(title: '', body: ''),
      throwsA(predicate((Object e) => e.toString().contains('obligatorios'))),
    );
  });

  test('un fallo de red reintenta y conserva la misma clave', () async {
    var llamadas = 0;
    String? clave;
    final api = ApiService(
      baseUrl: 'http://localhost:3000',
      espera: (_) => Duration.zero,
      client: MockClient((request) async {
        llamadas += 1;
        clave ??= request.headers['idempotency-key'];
        expect(request.headers['idempotency-key'], clave);
        if (llamadas == 1) {
          throw http.ClientException('Connection closed');
        }
        return http.Response(jsonEncode(_promo), 201);
      }),
    );

    final promo = await api.createPromocion(title: 'Noche', body: '2x1');
    expect(promo.id, 'promo-test');
    expect(llamadas, 2);
  });

  test('un 500 no se reintenta', () async {
    var llamadas = 0;
    final api = ApiService(
      baseUrl: 'http://localhost:3000',
      espera: (_) => Duration.zero,
      client: MockClient((_) async {
        llamadas += 1;
        return http.Response('{}', 500);
      }),
    );

    await expectLater(
      api.fetchLatestPromocion(),
      throwsA(predicate((Object e) => e.toString().contains('500'))),
    );
    expect(llamadas, 1);
  });

  test('un timeout se reintenta y no se confunde con un error HTTP', () async {
    var llamadas = 0;
    final api = ApiService(
      baseUrl: 'http://localhost:3000',
      espera: (_) => Duration.zero,
      client: MockClient((_) async {
        llamadas += 1;
        throw TimeoutException('timed out');
      }),
    );

    await expectLater(api.fetchLatestPromocion(), throwsA(isA<TimeoutException>()));
    expect(llamadas, 3);
  });

  test('alta con cuerpo que no es JSON no tumba la app', () async {
    final api = ApiService(
      baseUrl: 'http://localhost:3000',
      client: MockClient((_) async => http.Response('no-json', 500)),
    );

    expect(
      () => api.createPromocion(title: 'A', body: 'B'),
      throwsA(predicate((Object e) => e.toString().contains('500'))),
    );
  });
}
