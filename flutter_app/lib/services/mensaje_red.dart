/// Traduce un fallo de red a un texto que la pantalla puede mostrar.
/// Si el error no parece de red, devuelve el mensaje original sin el prefijo Exception.
String mensajeDeRed(Object err) {
  final texto = err.toString();
  final bajo = texto.toLowerCase();
  if (bajo.contains('socket') ||
      bajo.contains('failed host') ||
      bajo.contains('connection') ||
      bajo.contains('timed out') ||
      bajo.contains('network') ||
      bajo.contains('failed to fetch')) {
    return 'Sin conexión con el servidor de promociones (puerto 3000).';
  }
  return texto.replaceFirst('Exception: ', '');
}
