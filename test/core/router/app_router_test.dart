import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/app.dart';
import 'package:reservacancha/core/router/app_router.dart';
import 'package:reservacancha/core/router/inicio_shell.dart';
import 'package:reservacancha/features/admin/presentation/admin_canchas_screen.dart';
import 'package:reservacancha/features/auth/data/auth_repository_fake.dart';
import 'package:reservacancha/features/auth/data/auth_repository_provider.dart';
import 'package:reservacancha/features/auth/domain/usuario.dart';
import 'package:reservacancha/features/auth/presentation/login_screen.dart';

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

/// Abre la app completa con el router real y la [sesion] indicada. Devuelve el
/// repositorio para poder cambiar la sesión desde la prueba.
Future<AuthRepositoryFake> _abrirApp(
  WidgetTester tester, {
  Usuario? sesion,
}) async {
  final auth = AuthRepositoryFake(demora: Duration.zero, sesionInicial: sesion);
  addTearDown(auth.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
  return auth;
}

/// Navega a [ruta] con el mismo router que usa la app (el de
/// `appRouterProvider`), como haría un enlace directo.
Future<void> _irA(WidgetTester tester, String ruta) async {
  ProviderScope.containerOf(tester.element(find.byType(App)))
      .read(appRouterProvider)
      .go(ruta);
  await tester.pumpAndSettle();
}

void main() {
  group('sin sesión', () {
    testWidgets('la app arranca en el login', (tester) async {
      await _abrirApp(tester);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(InicioShell), findsNothing);
    });

    testWidgets('abrir una ruta privada regresa al login', (tester) async {
      await _abrirApp(tester);

      await _irA(tester, '/cancha/cancha-1');

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('con sesión', () {
    testWidgets('el login redirige solo a la pantalla principal', (
      tester,
    ) async {
      await _abrirApp(tester, sesion: _cliente);

      expect(find.byType(InicioShell), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('al cerrar sesión vuelve al login', (tester) async {
      final auth = await _abrirApp(tester, sesion: _cliente);
      expect(find.byType(InicioShell), findsOneWidget);

      await auth.cerrarSesion();
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(InicioShell), findsNothing);
    });

    testWidgets('un cliente que abre /admin/canchas vuelve al inicio', (
      tester,
    ) async {
      await _abrirApp(tester, sesion: _cliente);

      await _irA(tester, AppRoutes.adminCanchas);

      expect(find.byType(AdminCanchasScreen), findsNothing);
      expect(find.byType(InicioShell), findsOneWidget);
    });

    testWidgets('un admin sí puede abrir /admin/canchas', (tester) async {
      await _abrirApp(tester, sesion: _admin);

      await _irA(tester, AppRoutes.adminCanchas);

      expect(find.byType(AdminCanchasScreen), findsOneWidget);
    });
  });
}
