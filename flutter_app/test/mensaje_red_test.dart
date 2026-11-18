import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_widget/services/mensaje_red.dart';

void main() {
  const aviso = 'Sin conexión con el servidor de promociones (puerto 3000).';

  test('cada condición de red devuelve el aviso de sin conexión', () {
    expect(mensajeDeRed(Exception('SocketException')), aviso);
    expect(mensajeDeRed('Failed host lookup'), aviso);
    expect(mensajeDeRed(Exception('Connection refused')), aviso);
    expect(mensajeDeRed('timed out'), aviso);
    expect(mensajeDeRed(Exception('Network is unreachable')), aviso);
    expect(mensajeDeRed('ClientException: Failed to fetch'), aviso);
  });

  test('un error que no es de red conserva el mensaje sin el prefijo Exception', () {
    expect(
      mensajeDeRed(Exception('Error del servidor (500).')),
      'Error del servidor (500).',
    );
  });

  test('un texto sin prefijo Exception se devuelve igual', () {
    expect(mensajeDeRed('title y body son obligatorios'), 'title y body son obligatorios');
  });
}
