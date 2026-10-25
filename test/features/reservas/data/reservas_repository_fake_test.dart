import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_fake.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';

void main() {
  group('ReservasRepositoryFake - cancelar', () {
    test('cancela una reserva confirmada', () async {
      final repo = ReservasRepositoryFake(
        demora: Duration.zero,
        reservas: [
          const Reserva(
            id: 'cancha-1_20261025_18',
            canchaId: 'cancha-1',
            canchaNombre: 'Cancha 1',
            usuarioId: usuarioDemo,
            fecha: '2026-10-25',
            hora: 18,
            estado: EstadoReserva.confirmada,
            total: 150,
          ),
        ],
      );

      await repo.cancelar('cancha-1_20261025_18');

      final reservas = await repo.obtenerMisReservas();
      expect(reservas.first.estado, EstadoReserva.cancelada);
    });

    test('lanza error si la reserva no existe', () async {
      final repo = ReservasRepositoryFake(
        demora: Duration.zero,
        reservas: const [],
      );

      expect(() => repo.cancelar('no-existe'), throwsException);
    });

    test('lanza error si la reserva ya está cancelada', () async {
      final repo = ReservasRepositoryFake(
        demora: Duration.zero,
        reservas: [
          const Reserva(
            id: 'cancha-3_20261012_19',
            canchaId: 'cancha-3',
            canchaNombre: 'Polideportivo',
            usuarioId: usuarioDemo,
            fecha: '2026-10-12',
            hora: 19,
            estado: EstadoReserva.cancelada,
            total: 120,
          ),
        ],
      );

      expect(() => repo.cancelar('cancha-3_20261012_19'), throwsException);
    });
  });
}
