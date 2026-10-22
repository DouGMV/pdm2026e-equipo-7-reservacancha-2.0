import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/features/reservas/data/reservas_repository_provider.dart';
import 'package:reservacancha/features/reservas/domain/filtro_reservas.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';

/// Filtro activo del listado. El objeto es inmutable: cada cambio publica un
/// objeto nuevo y el listado se vuelve a pedir con `ref.watch`.
class FiltroReservasNotifier extends Notifier<FiltroReservas> {
  @override
  FiltroReservas build() => const FiltroReservas();

  void cambiarEstado(EstadoFiltroReserva estado) =>
      state = state.conEstado(estado);

  void cambiarMes(String? mes) => state = state.conMes(mes);

  void limpiar() => state = const FiltroReservas();
}

final filtroReservasProvider =
    NotifierProvider<FiltroReservasNotifier, FiltroReservas>(
      FiltroReservasNotifier.new,
    );

/// Reservas del usuario sin filtro, para el resumen de Inicio. El reintento
/// automático de Riverpod 3 se desactiva para que el error llegue a la
/// pantalla y el usuario decida cuándo reintentar.
final misReservasProvider = FutureProvider<List<Reserva>>(
  (ref) => ref.watch(reservasRepositoryProvider).obtenerMisReservas(),
  retry: (_, _) => null,
);

/// Meses (`yyyy-MM`) que tienen reservas, del más reciente al más antiguo.
final mesesDisponiblesProvider = Provider<List<String>>((ref) {
  final reservas = ref.watch(misReservasProvider).value ?? const <Reserva>[];
  final meses = {
    for (final reserva in reservas)
      if (reserva.fecha.length >= 7) reserva.fecha.substring(0, 7),
  };
  return meses.toList()..sort((a, b) => b.compareTo(a));
});

/// Listado con el filtro aplicado. Es un `AsyncNotifier` para poder actualizar
/// la lista visible (borrar y deshacer) sin volver a pedirla al repositorio.
class MisReservasController extends AsyncNotifier<List<Reserva>> {
  @override
  Future<List<Reserva>> build() {
    final filtro = ref.watch(filtroReservasProvider);
    return ref
        .watch(reservasRepositoryProvider)
        .obtenerMisReservas(filtro: filtro);
  }

  /// Borra la reserva en la base. Devuelve `false` si falló, para que
  /// `Dismissible` devuelva la fila a su lugar.
  Future<bool> eliminar(Reserva reserva) async {
    try {
      await ref.read(reservasRepositoryProvider).eliminarReserva(reserva.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Quita de la lista visible la reserva que ya se borró en la base.
  void quitar(Reserva reserva) {
    final actuales = state.value;
    if (actuales == null) {
      return;
    }
    state = AsyncData([
      for (final actual in actuales)
        if (actual.id != reserva.id) actual,
    ]);
    ref.invalidate(misReservasProvider);
  }

  /// Vuelve a guardar la reserva con el mismo id (acción «Deshacer») y la
  /// devuelve a la lista si todavía cumple el filtro activo.
  Future<bool> restaurar(Reserva reserva) async {
    try {
      await ref.read(reservasRepositoryProvider).restaurarReserva(reserva);
    } catch (_) {
      return false;
    }
    final actuales = state.value ?? const <Reserva>[];
    final filtro = ref.read(filtroReservasProvider);
    if (filtro.incluye(reserva) &&
        !actuales.any((actual) => actual.id == reserva.id)) {
      state = AsyncData(
        [...actuales, reserva]..sort(reservaMasRecientePrimero),
      );
    }
    ref.invalidate(misReservasProvider);
    return true;
  }
}

final misReservasFiltradasProvider =
    AsyncNotifierProvider<MisReservasController, List<Reserva>>(
      MisReservasController.new,
      retry: (_, _) => null,
    );
