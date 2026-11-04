import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';

Reserva _reserva({
  required String fecha,
  required int hora,
  EstadoReserva estado = EstadoReserva.confirmada,
}) => Reserva(
  id: 'cancha-1_${fecha.replaceAll('-', '')}_$hora',
  canchaId: 'cancha-1',
  canchaNombre: 'Cancha Sintética 1',
  usuarioId: 'usuario-demo',
  fecha: fecha,
  hora: hora,
  estado: estado,
  total: 150,
);

void main() {
  test('una reserva confirmada futura se puede cancelar', () {
    final reserva = _reserva(fecha: '2026-11-10', hora: 18);

    expect(reserva.sePuedeCancelar(DateTime(2026, 11, 4, 12)), isTrue);
  });

  test('una reserva confirmada que ya empezó no se puede cancelar', () {
    final reserva = _reserva(fecha: '2026-11-04', hora: 18);

    expect(reserva.sePuedeCancelar(DateTime(2026, 11, 4, 18)), isFalse);
    expect(reserva.sePuedeCancelar(DateTime(2026, 11, 4, 19)), isFalse);
  });

  test('una reserva cancelada no se puede volver a cancelar', () {
    final reserva = _reserva(
      fecha: '2026-11-10',
      hora: 18,
      estado: EstadoReserva.cancelada,
    );

    expect(reserva.sePuedeCancelar(DateTime(2026, 11, 4, 12)), isFalse);
  });

  test('si la fecha no se puede interpretar no se puede cancelar', () {
    final reserva = _reserva(fecha: 'fecha-invalida', hora: 18);

    expect(reserva.sePuedeCancelar(DateTime(2026, 11, 4, 12)), isFalse);
  });
}
