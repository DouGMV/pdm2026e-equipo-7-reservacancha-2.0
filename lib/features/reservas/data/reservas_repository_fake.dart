import 'package:reservacancha/features/reservas/domain/reserva.dart';
import 'package:reservacancha/features/reservas/domain/reservas_repository.dart';

/// Repositorio con datos de ejemplo mientras no exista la implementación con
/// Firestore. Simula la demora de la red con [Future.delayed].
class ReservasRepositoryFake implements ReservasRepository {
  const ReservasRepositoryFake({this.demora = const Duration(seconds: 1)});

  final Duration demora;

  @override
  Future<List<Reserva>> obtenerMisReservas() async {
    await Future<void>.delayed(demora);
    return _reservasDeEjemplo;
  }
}

const List<Reserva> _reservasDeEjemplo = [
  Reserva(
    id: 'cancha-1_20261020_18',
    canchaId: 'cancha-1',
    canchaNombre: 'Cancha Sintética 1',
    usuarioId: 'usuario-demo',
    fecha: '2026-10-20',
    hora: 18,
    estado: EstadoReserva.confirmada,
    total: 150,
  ),
  Reserva(
    id: 'cancha-5_20261022_7',
    canchaId: 'cancha-5',
    canchaNombre: 'Pádel Club Mesoamericana',
    usuarioId: 'usuario-demo',
    fecha: '2026-10-22',
    hora: 7,
    estado: EstadoReserva.confirmada,
    total: 175,
  ),
  Reserva(
    id: 'cancha-3_20261012_19',
    canchaId: 'cancha-3',
    canchaNombre: 'Polideportivo Los Altos',
    usuarioId: 'usuario-demo',
    fecha: '2026-10-12',
    hora: 19,
    estado: EstadoReserva.cancelada,
    total: 120,
  ),
];
