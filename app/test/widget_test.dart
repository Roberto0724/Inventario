
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_erp/main.dart';

void main() {
  testWidgets('El dashboard principal se carga correctamente',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(const InventarioApp());
    await tester.pumpAndSettle();

    // Verificar que se muestra el panel principal.
    expect(find.text('Panel principal'), findsOneWidget);

    // Verificar que la aplicación tiene una estructura visual.
    expect(find.byType(Scaffold), findsWidgets);

    // Verificar que no se produjeron excepciones.
    expect(tester.takeException(), isNull);
  });
}
