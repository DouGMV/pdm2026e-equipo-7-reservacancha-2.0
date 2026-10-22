import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:reservacancha/core/navigation/shell_principal.dart';
import 'package:reservacancha/core/widgets/proximamente_screen.dart';
import 'package:reservacancha/features/admin/presentation/admin_canchas_screen.dart';
import 'package:reservacancha/features/admin/presentation/admin_reservas_screen.dart';
import 'package:reservacancha/features/auth/presentation/login_screen.dart';
import 'package:reservacancha/features/auth/presentation/registro_screen.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_screen.dart';
import 'package:reservacancha/features/canchas/presentation/detalle_cancha_screen.dart';
import 'package:reservacancha/features/inicio/presentation/inicio_screen.dart';
import 'package:reservacancha/features/perfil/presentation/perfil_screen.dart';
import 'package:reservacancha/features/reservas/presentation/confirmar_reserva_screen.dart';
import 'package:reservacancha/features/reservas/presentation/mis_reservas_screen.dart';

/// Rutas de la app (ver docs/ARQUITECTURA.md).
abstract final class AppRoutes {
  static const login = '/login';
  static const registro = '/registro';
  static const inicio = '/';
  static const canchas = '/canchas';
  static const detalleCancha = '/cancha/:id';
  static const confirmarReserva = '/reserva/confirmar';
  static const misReservas = '/mis-reservas';
  static const perfil = '/perfil';
  static const adminCanchas = '/admin/canchas';
  static const adminReservas = '/admin/reservas';
  static const proximamente = '/proximamente';

  /// Ruta del detalle de una cancha concreta.
  static String detalleDeCancha(String id) => '/cancha/$id';

  /// Ruta de una sección que todavía no existe.
  static String proximamenteDe(String seccion) =>
      '/proximamente?titulo=$seccion';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.registro,
        builder: (context, state) => const RegistroScreen(),
      ),
      // Las pestañas de la barra. El IndexedStack de go_router mantiene cada
      // pantalla viva, así conserva su scroll al cambiar de pestaña.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellPrincipal(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.inicio,
                builder: (context, state) => const InicioScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.canchas,
                builder: (context, state) => const CanchasScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.misReservas,
                builder: (context, state) => const MisReservasScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.perfil,
                builder: (context, state) => const PerfilScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.detalleCancha,
        builder: (context, state) =>
            DetalleCanchaScreen(canchaId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.confirmarReserva,
        builder: (context, state) => const ConfirmarReservaScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminCanchas,
        builder: (context, state) => const AdminCanchasScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminReservas,
        builder: (context, state) => const AdminReservasScreen(),
      ),
      GoRoute(
        path: AppRoutes.proximamente,
        builder: (context, state) => ProximamenteScreen(
          titulo: state.uri.queryParameters['titulo'] ?? 'Esta sección',
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
