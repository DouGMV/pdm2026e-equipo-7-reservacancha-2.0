import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/app.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_screen.dart';

void main() {
  Future<void> abrirApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra el formulario de correo y contraseña', (tester) async {
    await abrirApp(tester);

    expect(find.text('Iniciar sesión'), findsWidgets);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('¿No tienes cuenta? Regístrate'), findsOneWidget);
  });

  testWidgets('muestra errores de validación al enviar vacío', (tester) async {
    await abrirApp(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Introduce el correo electrónico'), findsOneWidget);
    expect(find.text('Introduce la contraseña'), findsOneWidget);
  });

  testWidgets('navega al listado de canchas tras iniciar sesión', (
    tester,
  ) async {
    await abrirApp(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo electrónico'),
      'ana@correo.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      'secreta1',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.byType(CanchasScreen), findsOneWidget);
  });
}
