import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_widget/services/local_pin_service.dart';

void main() {
  test('límites del PIN: 4 y 6 dígitos entran, 3 y 7 no', () {
    expect(pinEsValido('123'), isFalse);
    expect(pinEsValido('1234'), isTrue);
    expect(pinEsValido('12345'), isTrue);
    expect(pinEsValido('123456'), isTrue);
    expect(pinEsValido('1234567'), isFalse);
  });

  test('rechaza vacío, letras y espacios', () {
    expect(pinEsValido(''), isFalse);
    expect(pinEsValido('abcd'), isFalse);
    expect(pinEsValido('12 4'), isFalse);
    expect(pinEsValido('12a4'), isFalse);
  });
}
