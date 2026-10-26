import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/app.dart';
import 'package:reservacancha/core/router/inicio_shell.dart';
import 'package:reservacancha/core/router/navegacion_provider.dart';
import 'package:reservacancha/features/auth/data/auth_repository_provider.dart';
import 'package:reservacancha/features/auth/domain/auth_repository.dart';
import 'package:reservacancha/features/auth/domain/usuario.dart';
import 'package:reservacancha/features/auth/presentation/login_screen.dart';
import 'package:reservacancha/features/perfil/presentation/perfil_screen.dart';

import '../../../helpers/repositorios_en_memoria.dart';

/// Repositorio de auth falso: la sesión la decide la prueba y cerrar sesión
/// se puede hacer fallar.
class _AuthControlable extends Fake implements AuthRepository {
  _AuthControlable(this.sesion);

  Stream<Usuario?> Function() sesion;
  bool fallarAlCerrar = false;
  int cierres = 0;

  @override
  Stream<Usuario?> cambiosDeSesion() => sesion();

  @override
  Future<void> cerrarSesion() async {
    cierres++;
    if (fallarAlCerrar) throw Exception('sin conexión');
  }
}

const _ana = Usuario(
  uid: 'uid-ana',
  nombre: 'Ana López',
  email: 'ana@correo.com',
  telefono: '55551234',
  rol: RolUsuario.cliente,
);

Future<void> _mostrarPerfil(WidgetTester tester, AuthRepository auth) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
      child: const MaterialApp(home: PerfilScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tocarCerrarSesion(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(OutlinedButton, 'Cerrar sesión'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra nombre, correo, teléfono y rol', (tester) async {
    await _mostrarPerfil(tester, _AuthControlable(() => Stream.value(_ana)));

    expect(find.text('Ana López'), findsOneWidget);
    expect(find.text('AL'), findsOneWidget);
    expect(find.text('ana@correo.com'), findsOneWidget);
    expect(find.text('55551234'), findsOneWidget);
    expect(find.text('Cliente'), findsOneWidget);
  });

  testWidgets('muestra el rol de administrador', (tester) async {
    const admin = Usuario(
      uid: 'uid-admin',
      nombre: 'Administrador',
      email: 'admin@correo.com',
      telefono: '55550000',
      rol: RolUsuario.admin,
    );
    await _mostrarPerfil(tester, _AuthControlable(() => Stream.value(admin)));

    expect(find.text('Administrador'), findsNWidgets(2));
  });

  testWidgets('mientras carga la sesión muestra el indicador', (tester) async {
    final sinRespuesta = StreamController<Usuario?>();
    addTearDown(sinRespuesta.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            _AuthControlable(() => sinRespuesta.stream),
          ),
        ],
        child: const MaterialApp(home: PerfilScreen()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Ana López'), findsNothing);
  });

  testWidgets('error al cargar → Reintentar → datos', (tester) async {
    // Falla hasta que la prueba lo cambie: así el reintento automático de
    // Riverpod no lo resuelve solo antes de ver el error.
    var fallar = true;
    final auth = _AuthControlable(
      () =>
          fallar ? Stream.error(Exception('sin conexión')) : Stream.value(_ana),
    );
    await _mostrarPerfil(tester, auth);

    expect(find.text('No pudimos cargar tu perfil.'), findsOneWidget);

    fallar = false;
    await tester.tap(find.widgetWithText(FilledButton, 'Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('No pudimos cargar tu perfil.'), findsNothing);
    expect(find.text('Ana López'), findsOneWidget);
  });

  testWidgets('Cancelar en la confirmación no cierra la sesión', (
    tester,
  ) async {
    final auth = _AuthControlable(() => Stream.value(_ana));
    await _mostrarPerfil(tester, auth);

    await _tocarCerrarSesion(tester);
    expect(find.text('¿Cerrar sesión?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('¿Cerrar sesión?'), findsNothing);
    expect(auth.cierres, 0);
  });

  testWidgets('al confirmar llama al cierre de sesión', (tester) async {
    final auth = _AuthControlable(() => Stream.value(_ana));
    await _mostrarPerfil(tester, auth);

    await _tocarCerrarSesion(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(auth.cierres, 1);
  });

  testWidgets('si cerrar sesión falla, avisa', (tester) async {
    final auth = _AuthControlable(() => Stream.value(_ana))
      ..fallarAlCerrar = true;
    await _mostrarPerfil(tester, auth);

    await _tocarCerrarSesion(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(
      find.text('No se pudo cerrar sesión. Intenta de nuevo.'),
      findsOneWidget,
    );
    expect(find.text('Ana López'), findsOneWidget);
  });

  group('en la app completa', () {
    Future<void> iniciarSesion(
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

    Pestana pestanaActiva(WidgetTester tester) =>
        ProviderScope.containerOf(tester.element(find.byType(InicioShell)))
            .read(navegacionProvider);

    testWidgets(
      'cerrar sesión vuelve al login y el siguiente usuario entra a Canchas',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(overrides: repositoriosEnMemoria(), child: const App()),
        );
        await tester.pumpAndSettle();

        await iniciarSesion(
          tester,
          correo: 'admin@correo.com',
          contrasena: 'admin123',
        );
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Perfil'),
          ),
        );
        await tester.pumpAndSettle();
        expect(pestanaActiva(tester), Pestana.perfil);

        await _tocarCerrarSesion(tester);
        await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
        await tester.pump(const Duration(milliseconds: 900));
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);

        await iniciarSesion(
          tester,
          correo: 'ana@correo.com',
          contrasena: 'secreta1',
        );

        expect(find.byType(InicioShell), findsOneWidget);
        expect(pestanaActiva(tester), Pestana.canchas);
        final barra = tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(barra.selectedIndex, 0);
      },
    );
  });
}
