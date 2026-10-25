import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/features/auth/presentation/auth_providers.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_provider.dart';
import 'package:reservacancha/features/reservas/domain/solicitud_reserva.dart';
import 'package:reservacancha/features/reservas/presentation/mis_reservas_providers.dart';

/// Hora actual. Las pruebas la reemplazan para no depender del reloj.
final relojProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Cancha y fecha (`yyyy-MM-dd`) de una consulta de disponibilidad.
typedef ConsultaHorario = ({String canchaId, String fecha});

/// Horas ya reservadas de una cancha en una fecha.
final horasOcupadasProvider = FutureProvider.autoDispose
    .family<Set<int>, ConsultaHorario>(
      (ref, consulta) => ref
          .watch(reservasRepositoryProvider)
          .obtenerHorasOcupadas(
            canchaId: consulta.canchaId,
            fecha: consulta.fecha,
          ),
      retry: (_, _) => null,
    );

/// Crea la reserva. Su estado indica a la pantalla de confirmación si hay una
/// operación en curso (`isLoading`) o si falló (`hasError`).
final reservarControllerProvider =
    AsyncNotifierProvider.autoDispose<ReservarController, void>(
      ReservarController.new,
    );

class ReservarController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> reservar(SolicitudReserva solicitud) async {
    state = const AsyncLoading();
    final resultado = await AsyncValue.guard<void>(() async {
      final uid = ref.read(sesionProvider).value?.uid;
      if (uid == null) throw StateError('No hay sesión');
      await ref
          .read(reservasRepositoryProvider)
          .crearReserva(solicitud.paraUsuario(uid));
    });
    if (!ref.mounted) return;
    // Con éxito o con "Horario no disponible", la disponibilidad cambió.
    ref
      ..invalidate(horasOcupadasProvider)
      ..invalidate(misReservasProvider);
    state = resultado;
  }
}
