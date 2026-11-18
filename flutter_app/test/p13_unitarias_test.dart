import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_widget/services/api_service.dart';
import 'package:nexus_widget/services/local_pin_service.dart';

void main() {
  setUp(() {
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform({});
  });

  test('AUT-01 un PIN de 4 dígitos es válido', () {
    expect(pinEsValido('1234'), isTrue);
    expect(pinEsValido('123456'), isTrue);
  });

  test('AUT-02 un PIN vacío no entra', () {
    expect(pinEsValido(''), isFalse);
    expect(pinEsValido('    '), isFalse);
  });

  test('AUT-02 un PIN fuera de rango no entra', () {
    expect(pinEsValido('123'), isFalse);
    expect(pinEsValido('1234567'), isFalse);
  });

  test('la espera entre reintentos es 200, 400 y 800 ms', () {
    expect(esperaProgresiva(0), const Duration(milliseconds: 200));
    expect(esperaProgresiva(1), const Duration(milliseconds: 400));
    expect(esperaProgresiva(2), const Duration(milliseconds: 800));
  });

  test('un error 500 no se toma como falla de red', () {
    expect(esFalloDeRed(Exception('Error del servidor (500).')), isFalse);
    expect(esFalloDeRed(Exception('timed out')), isTrue);
  });

  test('un error del servidor se lanza y no se reintenta', () async {
    var llamadas = 0;
    await expectLater(
      conReintento(() async {
        llamadas += 1;
        throw Exception('Error del servidor (500).');
      }),
      throwsA(isA<Exception>()),
    );
    expect(llamadas, 1);
  });

  test('guardar un PIN vacío lanza error y no deja sesión', () async {
    final pin = LocalPinService();
    expect(
      () => pin.setupPin(''),
      throwsA(predicate((Object e) => e.toString().contains('4 a 6'))),
    );
    expect(await pin.hasPinConfigured(), isFalse);
  });
}
