import 'package:flutter/foundation.dart';

/// En el emulador Android, localhost es el propio teléfono. La PC es 10.0.2.2.
/// [esWeb] y [plataforma] permiten probar las ramas sin cambiar el dispositivo.
String urlParaDispositivo(
  String url, {
  bool? esWeb,
  TargetPlatform? plataforma,
}) {
  if (esWeb ?? kIsWeb) return url;
  final actual = plataforma ?? defaultTargetPlatform;
  if (actual == TargetPlatform.android && url.contains('localhost')) {
    return url.replaceFirst('localhost', '10.0.2.2');
  }
  return url;
}
