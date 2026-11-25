import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_movil/screens/login_screen.dart';

void main() {
  testWidgets('Login valida campos y permite mostrar contraseña', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('Iniciar Sesión'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Mostrar contraseña'));
    await tester.pump();
    expect(find.byTooltip('Ocultar contraseña'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar Sesión'));
    await tester.pumpAndSettle();

    expect(
      find.text('Ingresa tu usuario o correo institucional'),
      findsOneWidget,
    );
    expect(
      find.text('Ingresa tu contraseña (mínimo 6 caracteres)'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
