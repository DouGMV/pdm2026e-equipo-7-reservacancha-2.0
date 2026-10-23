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

  Future<void> irARegistro(WidgetTester tester) async {
    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra el formulario de registro', (tester) async {
    await abrirApp(tester);
    await irARegistro(tester);

    expect(find.text('Registro'), findsOneWidget);
    expect(find.text('Nombre completo'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Teléfono'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Crear cuenta'), findsOneWidget);
  });

  testWidgets('muestra errores de validación al enviar vacío', (tester) async {
    await abrirApp(tester);
    await irARegistro(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Introduce tu nombre'), findsOneWidget);
    expect(find.text('Introduce el correo electrónico'), findsOneWidget);
    expect(find.text('Introduce tu teléfono'), findsOneWidget);
    expect(find.text('Introduce la contraseña'), findsOneWidget);
  });

  testWidgets('navega al listado de canchas tras registrarse', (tester) async {
    await abrirApp(tester);
    await irARegistro(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre completo'),
      'Ana López',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo electrónico'),
      'ana@correo.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Teléfono'),
      '55551234',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      'secreta1',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.byType(CanchasScreen), findsOneWidget);
  });

  testWidgets('el enlace de login regresa a la pantalla de inicio', (
    tester,
  ) async {
    await abrirApp(tester);
    await irARegistro(tester);

    await tester.tap(find.text('¿Ya tienes cuenta? Inicia sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsNothing);
  });
}
