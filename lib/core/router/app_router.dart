import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:reservacancha/core/router/inicio_shell.dart';
import 'package:reservacancha/features/admin/presentation/admin_canchas_screen.dart';
import 'package:reservacancha/features/admin/presentation/admin_reservas_screen.dart';
import 'package:reservacancha/features/auth/presentation/login_screen.dart';
import 'package:reservacancha/features/auth/presentation/registro_screen.dart';
import 'package:reservacancha/features/canchas/presentation/detalle_cancha_screen.dart';
import 'package:reservacancha/features/reservas/presentation/confirmar_reserva_screen.dart';

/// Rutas de la app (ver docs/ARQUITECTURA.md).
abstract final class AppRoutes {
  static const login = '/login';
  static const registro = '/registro';

  /// Pantalla principal con la barra inferior (Canchas, Mis reservas, Admin y
  /// Perfil son pestañas, ver `navegacion_provider.dart`).
  static const canchas = '/';
  static const detalleCancha = '/cancha/:id';
  static const confirmarReserva = '/reserva/confirmar';
  static const adminCanchas = '/admin/canchas';
  static const adminReservas = '/admin/reservas';
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
      GoRoute(
        path: AppRoutes.canchas,
        builder: (context, state) => const InicioShell(),
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
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
