import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/reservas/domain/horarios.dart';
import 'package:reservacancha/features/reservas/domain/solicitud_reserva.dart';

const _cancha = Cancha(
  id: 'c1',
  nombre: 'Cancha 1',
  deporte: 'futbol',
  descripcion: '',
  ubicacion: '',
  precioPorHora: 150,
  imagenUrl: '',
  horaApertura: 7,
  horaCierre: 12,
  activa: true,
);

void main() {
  group('idReserva', () {
    test('sigue el formato {canchaId}_{yyyyMMdd}_{HH}', () {
      expect(
        idReserva(canchaId: 'abc123', fecha: '2026-10-15', hora: 18),
        'abc123_20261015_18',
      );
    });

    test('rellena con cero las horas de un dígito', () {
      expect(
        idReserva(canchaId: 'c1', fecha: '2026-10-15', hora: 7),
        'c1_20261015_07',
      );
    });
  });

  group('bloquesDelDia', () {
    final ahora = DateTime(2026, 10, 26, 9, 15);

    test('un bloque por hora entre la apertura y el cierre', () {
      final bloques = bloquesDelDia(
        cancha: _cancha,
        dia: DateTime(2026, 10, 27),
        ocupadas: const {},
        ahora: ahora,
      );

      expect(bloques.map((b) => b.hora), [7, 8, 9, 10, 11]);
      expect(bloques.every((b) => b.disponible), isTrue);
    });

    test('las horas ocupadas no están disponibles', () {
      final bloques = bloquesDelDia(
        cancha: _cancha,
        dia: DateTime(2026, 10, 27),
        ocupadas: const {8, 10},
        ahora: ahora,
      );

      expect(
        [
          for (final b in bloques)
            if (!b.disponible) b.hora,
        ],
        [8, 10],
      );
    });

    test('hoy no se puede reservar una hora que ya empezó', () {
      final bloques = bloquesDelDia(
        cancha: _cancha,
        dia: DateTime(2026, 10, 26),
        ocupadas: const {},
        ahora: ahora,
      );

      expect(
        [
          for (final b in bloques)
            if (b.disponible) b.hora,
        ],
        [10, 11],
      );
    });
  });

  test('proximosDias devuelve 7 días sin hora desde hoy', () {
    final dias = proximosDias(DateTime(2026, 10, 30, 21, 5));

    expect(dias, hasLength(7));
    expect(dias.first, DateTime(2026, 10, 30));
    expect(dias.last, DateTime(2026, 11, 5));
  });

  test('SolicitudReserva arma la reserva confirmada del usuario', () {
    const solicitud = SolicitudReserva(
      cancha: _cancha,
      fecha: '2026-10-27',
      hora: 8,
    );

    final reserva = solicitud.paraUsuario('ana');

    expect(reserva.id, 'c1_20261027_08');
    expect(reserva.usuarioId, 'ana');
    expect(reserva.canchaNombre, 'Cancha 1');
    expect(reserva.total, 150);
  });
}
