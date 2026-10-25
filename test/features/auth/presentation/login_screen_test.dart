import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/app.dart';
import 'package:reservacancha/features/auth/presentation/login_screen.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_screen.dart';

void main() {
  Future<void> abrirApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();
  }

  Future<void> enviarCredenciales(
    WidgetTester tester, {
    required String correo,
    required String contrasena,
  }) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo electrónico'),
      correo,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      contrasena,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pump(const Duration(milliseconds: 900));
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

    await enviarCredenciales(
      tester,
      correo: 'ana@correo.com',
      contrasena: 'secreta1',
    );

    expect(find.byType(CanchasScreen), findsOneWidget);
  });

  testWidgets('con credenciales incorrectas avisa y se queda en el login', (
    tester,
  ) async {
    await abrirApp(tester);

    await enviarCredenciales(
      tester,
      correo: 'ana@correo.com',
      contrasena: 'equivocada',
    );

    expect(find.text('Correo o contraseña incorrectos'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(CanchasScreen), findsNothing);
  });
}
