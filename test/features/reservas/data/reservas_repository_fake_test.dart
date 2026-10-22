import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_fake.dart';
import 'package:reservacancha/features/reservas/domain/filtro_reservas.dart';

void main() {
  late Directory directorio;
  late File archivo;

  setUp(() async {
    directorio = await Directory.systemTemp.createTemp('reservacancha_test_');
    archivo = File('${directorio.path}${Platform.pathSeparator}reservas.json');
  });

  tearDown(() => directorio.delete(recursive: true));

  ReservasRepositoryFake nuevoRepositorio() => ReservasRepositoryFake(
    demora: Duration.zero,
    demoraEscritura: Duration.zero,
    archivo: archivo,
  );

  test('ordena de la reserva más reciente a la más antigua', () async {
    final reservas = await nuevoRepositorio().obtenerMisReservas();

    expect(reservas.map((reserva) => reserva.fecha), [
      '2026-10-22',
      '2026-10-20',
      '2026-10-12',
    ]);
  });

  test('filtra por estado y por mes', () async {
    final repositorio = nuevoRepositorio();

    final canceladas = await repositorio.obtenerMisReservas(
      filtro: const FiltroReservas(estado: EstadoFiltroReserva.canceladas),
    );
    expect(canceladas.map((reserva) => reserva.id), ['cancha-3_20261012_19']);

    final octubre = await repositorio.obtenerMisReservas(
      filtro: const FiltroReservas(mes: '2026-10'),
    );
    expect(octubre, hasLength(3));

    final noviembre = await repositorio.obtenerMisReservas(
      filtro: const FiltroReservas(mes: '2026-11'),
    );
    expect(noviembre, isEmpty);
  });

  test('el borrado y el deshacer sobreviven a cerrar la app', () async {
    final antes = await nuevoRepositorio().obtenerMisReservas();
    final borrada = antes.first;

    await nuevoRepositorio().eliminarReserva(borrada.id);

    // Otra instancia simula volver a abrir la app: lee el mismo archivo.
    final despues = await nuevoRepositorio().obtenerMisReservas();
    expect(despues.map((reserva) => reserva.id), isNot(contains(borrada.id)));
    expect(despues, hasLength(antes.length - 1));

    await nuevoRepositorio().restaurarReserva(borrada);

    final restauradas = await nuevoRepositorio().obtenerMisReservas();
    expect(restauradas, hasLength(antes.length));

    final restaurada = restauradas.firstWhere(
      (reserva) => reserva.id == borrada.id,
    );
    expect(restaurada.canchaId, borrada.canchaId);
    expect(restaurada.canchaNombre, borrada.canchaNombre);
    expect(restaurada.usuarioId, borrada.usuarioId);
    expect(restaurada.fecha, borrada.fecha);
    expect(restaurada.hora, borrada.hora);
    expect(restaurada.estado, borrada.estado);
    expect(restaurada.total, borrada.total);
  });
}
