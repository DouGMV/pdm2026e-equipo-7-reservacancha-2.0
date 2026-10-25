import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/core/errors/reserva_no_disponible_exception.dart';
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

  group('ReservasRepositoryFake - crearReserva', () {
    const reserva = Reserva(
      id: 'cancha-1_20261030_18',
      canchaId: 'cancha-1',
      canchaNombre: 'Cancha 1',
      usuarioId: 'ana',
      fecha: '2026-10-30',
      hora: 18,
      estado: EstadoReserva.confirmada,
      total: 150,
    );

    test('marca la hora como ocupada y rechaza el duplicado', () async {
      final repo = ReservasRepositoryFake(
        demora: Duration.zero,
        reservas: const [],
      );

      await repo.crearReserva(reserva);

      expect(
        await repo.obtenerHorasOcupadas(
          canchaId: 'cancha-1',
          fecha: '2026-10-30',
        ),
        {18},
      );
      expect(
        () => repo.crearReserva(reserva),
        throwsA(isA<ReservaNoDisponibleException>()),
      );
    });
  });
}
