import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_movil/main.dart';

void main() {
  testWidgets('Splash, validación y acceso al dashboard', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    expect(find.text('Red Anáhuac'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    await tester.ensureVisible(find.text('Ingresar'));
    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa un ID de al menos 4 dígitos'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '9582');
    await tester.ensureVisible(find.text('Ingresar'));
    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();
    expect(find.text('Hola, María García'), findsOneWidget);
    expect(find.text('3 encuestas pendientes'), findsOneWidget);
    await tester.tap(find.text('Nueva Encuesta'));
    await tester.pumpAndSettle();
    expect(find.text('Entendido'), findsOneWidget);
  });
}
