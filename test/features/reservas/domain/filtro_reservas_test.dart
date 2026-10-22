import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/features/reservas/domain/filtro_reservas.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';

const _confirmadaOctubre = Reserva(
  id: 'cancha-1_20261020_18',
  canchaId: 'cancha-1',
  canchaNombre: 'Cancha Sintética 1',
  usuarioId: 'usuario-demo',
  fecha: '2026-10-20',
  hora: 18,
  estado: EstadoReserva.confirmada,
  total: 150,
);

const _canceladaOctubre = Reserva(
  id: 'cancha-3_20261012_19',
  canchaId: 'cancha-3',
  canchaNombre: 'Polideportivo Los Altos',
  usuarioId: 'usuario-demo',
  fecha: '2026-10-12',
  hora: 19,
  estado: EstadoReserva.cancelada,
  total: 120,
);

const _confirmadaNoviembre = Reserva(
  id: 'cancha-5_20261105_7',
  canchaId: 'cancha-5',
  canchaNombre: 'Pádel Club Mesoamericana',
  usuarioId: 'usuario-demo',
  fecha: '2026-11-05',
  hora: 7,
  estado: EstadoReserva.confirmada,
  total: 175,
);

void main() {
  test('sin filtros deja pasar todas las reservas', () {
    const filtro = FiltroReservas();

    expect(filtro.sinFiltros, isTrue);
    expect(filtro.incluye(_confirmadaOctubre), isTrue);
    expect(filtro.incluye(_canceladaOctubre), isTrue);
    expect(filtro.incluye(_confirmadaNoviembre), isTrue);
  });

  test('por estado solo deja pasar las que coinciden', () {
    const confirmadas = FiltroReservas(estado: EstadoFiltroReserva.confirmadas);
    expect(confirmadas.incluye(_confirmadaOctubre), isTrue);
    expect(confirmadas.incluye(_canceladaOctubre), isFalse);

    const canceladas = FiltroReservas(estado: EstadoFiltroReserva.canceladas);
    expect(canceladas.incluye(_canceladaOctubre), isTrue);
    expect(canceladas.incluye(_confirmadaOctubre), isFalse);
  });

  test('por mes solo deja pasar las reservas de ese mes', () {
    const octubre = FiltroReservas(mes: '2026-10');

    expect(octubre.incluye(_confirmadaOctubre), isTrue);
    expect(octubre.incluye(_confirmadaNoviembre), isFalse);
  });

  test('combina el estado con el mes', () {
    const filtro = FiltroReservas(
      estado: EstadoFiltroReserva.confirmadas,
      mes: '2026-11',
    );

    expect(filtro.incluye(_confirmadaNoviembre), isTrue);
    expect(filtro.incluye(_confirmadaOctubre), isFalse);
    expect(filtro.incluye(_canceladaOctubre), isFalse);
  });

  test('cambiar un campo crea un objeto nuevo y conserva el otro', () {
    const original = FiltroReservas(estado: EstadoFiltroReserva.confirmadas);

    final conMes = original.conMes('2026-10');
    expect(conMes.estado, EstadoFiltroReserva.confirmadas);
    expect(conMes.mes, '2026-10');
    expect(original.mes, isNull);
    expect(identical(conMes, original), isFalse);

    final conEstado = original.conEstado(EstadoFiltroReserva.canceladas);
    expect(conEstado.estado, EstadoFiltroReserva.canceladas);
    expect(conEstado.mes, isNull);
    expect(original.estado, EstadoFiltroReserva.confirmadas);
  });

  test('dos filtros con los mismos valores son iguales', () {
    const uno = FiltroReservas(
      estado: EstadoFiltroReserva.todas,
      mes: '2026-10',
    );
    const otro = FiltroReservas(
      estado: EstadoFiltroReserva.todas,
      mes: '2026-10',
    );

    expect(uno, otro);
    expect(uno.hashCode, otro.hashCode);
    expect(uno.sinFiltros, isFalse);
    expect(uno.conMes(null).sinFiltros, isTrue);
  });
}
