import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_widget/config/api_hosts.dart';

void main() {
  test('en web no cambia localhost', () {
    expect(
      urlParaDispositivo('http://localhost:3000', esWeb: true, plataforma: TargetPlatform.android),
      'http://localhost:3000',
    );
  });

  test('en Android localhost pasa a 10.0.2.2', () {
    expect(
      urlParaDispositivo('http://localhost:3000/api', esWeb: false, plataforma: TargetPlatform.android),
      'http://10.0.2.2:3000/api',
    );
  });

  test('en Windows deja la URL igual', () {
    expect(
      urlParaDispositivo('http://localhost:3000', esWeb: false, plataforma: TargetPlatform.windows),
      'http://localhost:3000',
    );
  });

  test('una URL que no usa localhost no se toca', () {
    expect(
      urlParaDispositivo('http://10.0.2.2:3000', esWeb: false, plataforma: TargetPlatform.android),
      'http://10.0.2.2:3000',
    );
  });
}
