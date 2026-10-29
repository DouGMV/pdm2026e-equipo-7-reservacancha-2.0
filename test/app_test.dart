import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/app.dart';
import 'package:reservacancha/core/data/migracion_provider.dart';
import 'package:reservacancha/core/router/inicio_shell.dart';
import 'package:reservacancha/features/auth/domain/usuario.dart';
import 'package:reservacancha/features/auth/presentation/login_screen.dart';

import 'helpers/repositorios_en_memoria.dart';

const _cliente = Usuario(
  uid: 'uid-ana',
  nombre: 'Ana López',
  email: 'ana@correo.com',
  telefono: '55551234',
  rol: RolUsuario.cliente,
);

const _admin = Usuario(
  uid: 'uid-admin',
  nombre: 'Administrador',
  email: 'admin@correo.com',
  telefono: '55550000',
  rol: RolUsuario.admin,
);

Future<void> _abrirApp(
  WidgetTester tester, {
  Usuario? sesion,
  Future<void> Function()? migrar,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...repositoriosEnMemoria(sesionInicial: sesion),
        if (migrar != null) migrarEsquemaProvider.overrideWithValue(migrar),
      ],
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la app arranca y muestra la pantalla de inicio de sesión', (
    tester,
  ) async {
    await _abrirApp(tester);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
  });

  testWidgets('la migración corre al entrar un admin', (tester) async {
    var llamadas = 0;

    await _abrirApp(tester, sesion: _admin, migrar: () async => llamadas++);

    expect(find.byType(InicioShell), findsOneWidget);
    expect(llamadas, 1);
  });

  testWidgets('la migración no corre para un cliente', (tester) async {
    var llamadas = 0;

    await _abrirApp(tester, sesion: _cliente, migrar: () async => llamadas++);

    expect(find.byType(InicioShell), findsOneWidget);
    expect(llamadas, 0);
  });

  testWidgets('si la migración falla, la app sigue funcionando', (
    tester,
  ) async {
    await _abrirApp(
      tester,
      sesion: _admin,
      migrar: () async => throw Exception('sin conexión'),
    );

    expect(find.byType(InicioShell), findsOneWidget);
  });
}
