import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nexus_widget/theme/nexus_theme.dart';

void main() {
  testWidgets('La pantalla de carga móvil muestra Nexus', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: NexusLoadingScreen()),
    );

    expect(find.text('Nexus'), findsOneWidget);
    expect(find.text('App móvil'), findsOneWidget);
  });
}
