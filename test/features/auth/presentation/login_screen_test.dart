import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/app.dart';

import 'package:reservacancha/features/auth/presentation/login_screen.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_screen.dart';

import '../../../helpers/repositorios_en_memoria.dart';

void main() {
  Future<void> abrirApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(overrides: repositoriosEnMemoria(), child: const App()),
    );
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

  Future<void> pedirRecuperacion(WidgetTester tester, String correo) async {
    await tester.tap(
      find.widgetWithText(TextButton, '¿Olvidaste tu contraseña?'),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextFormField),
      ),
      correo,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Enviar'));
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

  testWidgets('muestra el logo de la app con etiqueta accesible', (
    tester,
  ) async {
    await abrirApp(tester);

    final logo = tester.widget<Image>(find.byType(Image));
    expect((logo.image as AssetImage).assetName, 'assets/logo/logo.png');
    expect(logo.semanticLabel, 'ReservaCancha');
  });

  testWidgets('muestra errores de validación al enviar vacío', (tester) async {
    await abrirApp(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Introduce el correo electrónico'), findsOneWidget);
    expect(find.text('Introduce la contraseña'), findsOneWidget);
  });

  testWidgets('envía el correo de recuperación y avisa', (tester) async {
    await abrirApp(tester);

    await pedirRecuperacion(tester, 'ana@correo.com');

    expect(
      find.text('Te enviamos un correo para restablecer tu contraseña.'),
      findsOneWidget,
    );
  });

  testWidgets('con una cuenta inexistente avisa en español', (tester) async {
    await abrirApp(tester);

    await pedirRecuperacion(tester, 'nadie@correo.com');

    expect(
      find.text('No encontramos una cuenta con ese correo'),
      findsOneWidget,
    );
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
