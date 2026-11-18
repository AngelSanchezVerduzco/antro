import 'dart:convert';

import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nexus_widget/services/api_service.dart';
import 'package:nexus_widget/services/local_pin_service.dart';
import 'package:nexus_widget/services/mensaje_red.dart';

const _promo = {
  'id': 'promo-p13',
  'type': 'promocion_nueva',
  'title': 'Noche',
  'body': '2x1',
  'imageUrl': 'http://localhost:3000/uploads/promo.svg',
  'deepLink': '/inicio',
  'expiresAt': '2026-12-01T00:00:00.000Z',
  'createdAt': '2026-11-17T00:00:00.000Z',
};

void main() {
  setUp(() {
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform({});
  });

  test('AUT-04 el alta recibe 201 y arma la promoción', () async {
    final api = ApiService(
      baseUrl: 'http://localhost:3000',
      espera: (_) => Duration.zero,
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/promociones');
        expect(request.headers['Idempotency-Key'], isNotEmpty);
        return http.Response(jsonEncode(_promo), 201);
      }),
    );

    final promo = await api.createPromocion(title: 'Noche', body: '2x1');
    expect(promo.id, 'promo-p13');
    expect(promo.title, 'Noche');
    expect(promo.body, '2x1');
  });

  test('AUT-04 la consulta latest acepta el HTTP 200', () async {
    final api = ApiService(
      baseUrl: 'http://localhost:3000',
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/promociones/latest');
        return http.Response(jsonEncode(_promo), 200);
      }),
    );

    final promo = await api.fetchLatestPromocion();
    expect(promo.title, 'Noche');
  });

  test('AUT-05 si el servidor no responde, la pantalla avisa sin conexión', () async {
    final api = ApiService(
      baseUrl: 'http://localhost:3000',
      espera: (_) => Duration.zero,
      client: MockClient((_) async {
        throw http.ClientException('Connection refused');
      }),
    );

    try {
      await api.fetchLatestPromocion();
      fail('tenía que fallar');
    } catch (error) {
      expect(
        mensajeDeRed(error),
        'Sin conexión con el servidor de promociones (puerto 3000).',
      );
    }
  });

  test('AUT-06 el PIN se guarda hasheado y solo el correcto entra', () async {
    final datos = <String, String>{};
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(datos);
    final pin = LocalPinService();

    await pin.setupPin('1234');
    expect(await pin.verifyPin('1234'), isTrue);
    expect(await pin.verifyPin('9999'), isFalse);
    expect(datos.values.join(' '), isNot(contains('1234')));
  });
}
