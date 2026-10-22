import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/features/reservas/data/reservas_repository_provider.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';

/// Qué reservas quiere ver el administrador. Inmutable: cambiar el filtro es
/// crear uno nuevo.
@immutable
class FiltroReservas {
  const FiltroReservas({this.estado});

  /// `null` = todas.
  final EstadoReserva? estado;

  @override
  bool operator ==(Object other) =>
      other is FiltroReservas && other.estado == estado;

  @override
  int get hashCode => estado.hashCode;
}

final filtroReservasProvider =
    NotifierProvider<FiltroReservasController, FiltroReservas>(
      FiltroReservasController.new,
    );

class FiltroReservasController extends Notifier<FiltroReservas> {
  @override
  FiltroReservas build() => const FiltroReservas();

  void estado(EstadoReserva? estado) => state = FiltroReservas(estado: estado);
}

/// Reservas según el filtro. `build` hace `ref.watch` del filtro: al
/// cambiarlo, Riverpod repite la consulta solo. El reintento automático se
/// desactiva para que el error llegue a la pantalla.
final reservasAdminProvider =
    AsyncNotifierProvider<ReservasAdminController, List<Reserva>>(
      ReservasAdminController.new,
      retry: (_, _) => null,
    );

class ReservasAdminController extends AsyncNotifier<List<Reserva>> {
  @override
  Future<List<Reserva>> build() {
    final filtro = ref.watch(filtroReservasProvider);
    return ref
        .watch(reservasRepositoryProvider)
        .obtenerReservas(estado: filtro.estado);
  }

  /// Elimina primero en el repositorio. Si falla, la excepción llega a la
  /// pantalla y la lista no cambia.
  Future<void> eliminar(Reserva reserva) async {
    await ref.read(reservasRepositoryProvider).eliminar(reserva.id);
    final actuales = state.value;
    if (actuales != null) {
      state = AsyncData([
        for (final r in actuales)
          if (r.id != reserva.id) r,
      ]);
    }
  }

  /// Restaura la reserva idéntica (mismo id) y vuelve a consultar con el
  /// filtro actual.
  Future<void> restaurar(Reserva reserva) async {
    await ref.read(reservasRepositoryProvider).restaurar(reserva);
    ref.invalidateSelf();
    await future;
  }
}
