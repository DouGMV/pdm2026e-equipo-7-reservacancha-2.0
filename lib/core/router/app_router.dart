import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:reservacancha/core/router/inicio_shell.dart';
import 'package:reservacancha/core/router/navegacion_provider.dart';
import 'package:reservacancha/core/router/redireccion.dart';
import 'package:reservacancha/features/admin/presentation/admin_canchas_screen.dart';
import 'package:reservacancha/features/admin/presentation/admin_reservas_providers.dart';
import 'package:reservacancha/features/admin/presentation/admin_reservas_screen.dart';
import 'package:reservacancha/features/admin/presentation/cancha_form_screen.dart';
import 'package:reservacancha/features/auth/presentation/auth_providers.dart';
import 'package:reservacancha/features/auth/presentation/login_screen.dart';
import 'package:reservacancha/features/auth/presentation/registro_screen.dart';
import 'package:reservacancha/features/canchas/presentation/admin_canchas_providers.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_providers.dart';
import 'package:reservacancha/features/canchas/presentation/detalle_cancha_screen.dart';
import 'package:reservacancha/features/reservas/domain/solicitud_reserva.dart';
import 'package:reservacancha/features/reservas/presentation/confirmar_reserva_screen.dart';

/// Rutas de la app (ver docs/ARQUITECTURA.md).
abstract final class AppRoutes {
  static const login = '/login';
  static const registro = '/registro';

  /// Pantalla principal con la barra inferior (Canchas, Mis reservas, Admin y
  /// Perfil son pestañas, ver `navegacion_provider.dart`).
  static const canchas = '/';
  static const detalleCancha = '/cancha/:id';
  static String detalleDe(String canchaId) => '/cancha/$canchaId';
  static const confirmarReserva = '/reserva/confirmar';
  static const adminCanchas = '/admin/canchas';
  static const nuevaCancha = '/admin/canchas/nueva';
  static const editarCancha = '/admin/canchas/:id/editar';
  static String editarDe(String canchaId) => '/admin/canchas/$canchaId/editar';
  static const adminReservas = '/admin/reservas';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  // go_router no conoce Riverpod: este notificador le avisa que vuelva a
  // evaluar `redirect` cada vez que cambia la sesión, sin recrear el router
  // (recrearlo perdería el historial de navegación).
  final cambiosDeSesion = ValueNotifier<int>(0);
  ref.listen(sesionProvider, (anterior, siguiente) {
    cambiosDeSesion.value++;
    // Cada usuario empieza en Canchas y sin los filtros del anterior: sin
    // esto, quien inicie sesión después de un "Cerrar sesión" entraría directo
    // a la pestaña Perfil y con lo que el otro dejó filtrado.
    if (anterior?.value?.uid != siguiente.value?.uid) {
      ref.read(navegacionProvider.notifier).ir(Pestana.canchas);
      ref
        ..invalidate(filtroListadoProvider)
        ..invalidate(filtroCanchasProvider)
        ..invalidate(filtroReservasProvider);
    }
  });

  final router = GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: cambiosDeSesion,
    redirect: (context, state) => calcularRedireccion(
      sesion: ref.read(sesionProvider),
      ruta: state.matchedLocation,
    ),
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
        // La solicitud llega en `extra` desde el detalle de la cancha.
        builder: (context, state) => ConfirmarReservaScreen(
          solicitud: state.extra is SolicitudReserva
              ? state.extra! as SolicitudReserva
              : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminCanchas,
        builder: (context, state) => const AdminCanchasScreen(),
      ),
      GoRoute(
        path: AppRoutes.nuevaCancha,
        builder: (context, state) => const CanchaFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.editarCancha,
        builder: (context, state) =>
            CanchaFormScreen(canchaId: state.pathParameters['id']),
      ),
      GoRoute(
        path: AppRoutes.adminReservas,
        builder: (context, state) => const AdminReservasScreen(),
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    cambiosDeSesion.dispose();
  });
  return router;
});
