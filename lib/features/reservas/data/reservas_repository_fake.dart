import 'package:reservacancha/core/errors/reserva_no_disponible_exception.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';
import 'package:reservacancha/features/reservas/domain/reservas_repository.dart';

/// Usuario de ejemplo mientras no exista el inicio de sesión real.
const usuarioDemo = 'usuario-demo';

/// Repositorio sobre una lista en memoria mientras no exista la
/// implementación con Firestore. Simula la demora de la red con
/// [Future.delayed]. Lo eliminado se pierde al cerrar la app.
class ReservasRepositoryFake implements ReservasRepository {
  ReservasRepositoryFake({
    this.demora = const Duration(seconds: 1),
    List<Reserva> reservas = reservasDeEjemplo,
    String Function()? usuarioActual,
  }) : _reservas = [...reservas],
       _usuarioActual = usuarioActual ?? (() => usuarioDemo);

  final Duration demora;
  final List<Reserva> _reservas;

  /// uid del usuario con sesión; por defecto, [usuarioDemo].
  final String Function() _usuarioActual;

  @override
  Future<List<Reserva>> obtenerMisReservas() async {
    await Future<void>.delayed(demora);
    return _ordenadas(_reservas.where((r) => r.usuarioId == _usuarioActual()));
  }

  @override
  Future<List<Reserva>> obtenerReservas({EstadoReserva? estado}) async {
    await Future<void>.delayed(demora);
    return _ordenadas(
      _reservas.where((r) => estado == null || r.estado == estado),
    );
  }

  @override
  Future<Set<int>> obtenerHorasOcupadas({
    required String canchaId,
    required String fecha,
  }) async {
    await Future<void>.delayed(demora);
    return {
      for (final r in _reservas)
        if (r.canchaId == canchaId &&
            r.fecha == fecha &&
            r.estado == EstadoReserva.confirmada)
          r.hora,
    };
  }

  @override
  Future<void> crearReserva(Reserva reserva) async {
    await Future<void>.delayed(demora);
    final indice = _reservas.indexWhere((r) => r.id == reserva.id);
    if (indice != -1 && _reservas[indice].estado == EstadoReserva.confirmada) {
      throw const ReservaNoDisponibleException();
    }
    if (indice != -1) _reservas.removeAt(indice);
    _reservas.add(reserva);
  }

  @override
  Future<void> cancelar(String id) async {
    await Future<void>.delayed(demora);
    final index = _reservas.indexWhere((r) => r.id == id);
    if (index == -1) {
      throw Exception('No se encontró la reserva');
    }
    final reserva = _reservas[index];
    if (reserva.estado != EstadoReserva.confirmada) {
      throw Exception('Solo se pueden cancelar reservas confirmadas');
    }
    _reservas[index] = Reserva(
      id: reserva.id,
      canchaId: reserva.canchaId,
      canchaNombre: reserva.canchaNombre,
      usuarioId: reserva.usuarioId,
      fecha: reserva.fecha,
      hora: reserva.hora,
      estado: EstadoReserva.cancelada,
      total: reserva.total,
    );
  }

  @override
  Future<void> eliminar(String id) async {
    await Future<void>.delayed(demora);
    _reservas.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> restaurar(Reserva reserva) async {
    await Future<void>.delayed(demora);
    _reservas
      ..removeWhere((r) => r.id == reserva.id)
      ..add(reserva);
  }

  /// Más recientes primero: el orden no depende de cuándo se restauró.
  List<Reserva> _ordenadas(Iterable<Reserva> reservas) {
    return reservas.toList()..sort((a, b) {
      final porFecha = b.fecha.compareTo(a.fecha);
      return porFecha != 0 ? porFecha : b.hora.compareTo(a.hora);
    });
  }
}

const List<Reserva> reservasDeEjemplo = [
  Reserva(
    id: 'cancha-1_20261020_18',
    canchaId: 'cancha-1',
    canchaNombre: 'Cancha Sintética 1',
    usuarioId: usuarioDemo,
    fecha: '2026-10-20',
    hora: 18,
    estado: EstadoReserva.confirmada,
    total: 150,
  ),
  Reserva(
    id: 'cancha-5_20261022_07',
    canchaId: 'cancha-5',
    canchaNombre: 'Pádel Club Mesoamericana',
    usuarioId: usuarioDemo,
    fecha: '2026-10-22',
    hora: 7,
    estado: EstadoReserva.confirmada,
    total: 175,
  ),
  Reserva(
    id: 'cancha-3_20261012_19',
    canchaId: 'cancha-3',
    canchaNombre: 'Polideportivo Los Altos',
    usuarioId: usuarioDemo,
    fecha: '2026-10-12',
    hora: 19,
    estado: EstadoReserva.cancelada,
    total: 120,
  ),
  Reserva(
    id: 'cancha-2_20261021_20',
    canchaId: 'cancha-2',
    canchaNombre: 'Cancha Sintética 2',
    usuarioId: 'usuario-ana',
    fecha: '2026-10-21',
    hora: 20,
    estado: EstadoReserva.confirmada,
    total: 200,
  ),
  Reserva(
    id: 'cancha-4_20261018_16',
    canchaId: 'cancha-4',
    canchaNombre: 'Arena Voleibol Xela',
    usuarioId: 'usuario-luis',
    fecha: '2026-10-18',
    hora: 16,
    estado: EstadoReserva.cancelada,
    total: 100,
  ),
];
