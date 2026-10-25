import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/app.dart';

import 'package:reservacancha/features/auth/presentation/registro_screen.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_screen.dart';

import '../../../helpers/repositorios_en_memoria.dart';

void main() {
  Future<void> abrirApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(overrides: repositoriosEnMemoria(), child: const App()),
    );
    await tester.pumpAndSettle();
  }

  Future<void> irARegistro(WidgetTester tester) async {
    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();
  }

  Future<void> llenarYEnviar(
    WidgetTester tester, {
    required String correo,
  }) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre completo'),
      'Luis Pérez',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo electrónico'),
      correo,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Teléfono'),
      '55559876',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      'secreta1',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await tester.pump(const Duration(milliseconds: 900));
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

    await llenarYEnviar(tester, correo: 'luis@correo.com');

    expect(find.byType(CanchasScreen), findsOneWidget);
  });

  testWidgets('con un correo ya registrado avisa y se queda en el registro', (
    tester,
  ) async {
    await abrirApp(tester);
    await irARegistro(tester);

    await llenarYEnviar(tester, correo: 'ana@correo.com');

    expect(find.text('Ya existe una cuenta con ese correo'), findsOneWidget);
    expect(find.byType(RegistroScreen), findsOneWidget);
    expect(find.byType(CanchasScreen), findsNothing);
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
