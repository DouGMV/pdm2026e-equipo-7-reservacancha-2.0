import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/features/reservas/data/reserva_model.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_firestore.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';

Reserva _reserva(
  String usuarioId,
  String fecha,
  int hora, {
  EstadoReserva estado = EstadoReserva.confirmada,
}) => Reserva(
  id: 'c1_${fecha.replaceAll('-', '')}_$hora',
  canchaId: 'c1',
  canchaNombre: 'Cancha 1',
  usuarioId: usuarioId,
  fecha: fecha,
  hora: hora,
  estado: estado,
  total: 150,
);

void main() {
  late FakeFirebaseFirestore firestore;
  String? uid;
  late ReservasRepositoryFirestore repositorio;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    uid = 'ana';
    repositorio = ReservasRepositoryFirestore(
      firestore,
      usuarioActual: () => uid,
    );
    for (final reserva in [
      _reserva('ana', '2026-10-20', 18),
      _reserva('ana', '2026-10-25', 9, estado: EstadoReserva.cancelada),
      _reserva('ana', '2026-10-25', 20),
      _reserva('beto', '2026-10-22', 10),
    ]) {
      await firestore
          .collection('reservas')
          .doc(reserva.id)
          .set(ReservaModel.toMap(reserva));
    }
  });

  test('mis reservas: solo las del usuario, más recientes primero', () async {
    final reservas = await repositorio.obtenerMisReservas();

    expect(reservas.map((r) => r.id), [
      'c1_20261025_20',
      'c1_20261025_9',
      'c1_20261020_18',
    ]);
    expect(reservas[1].estado, EstadoReserva.cancelada);
  });

  test('mis reservas: sin sesión devuelve una lista vacía', () async {
    uid = null;

    expect(await repositorio.obtenerMisReservas(), isEmpty);
  });

  test('todas las reservas y filtro por estado', () async {
    expect(await repositorio.obtenerReservas(), hasLength(4));

    final canceladas = await repositorio.obtenerReservas(
      estado: EstadoReserva.cancelada,
    );
    expect(canceladas.map((r) => r.id), ['c1_20261025_9']);
  });

  test('eliminar y restaurar conservan el id y los datos', () async {
    final reserva = (await repositorio.obtenerReservas()).first;

    await repositorio.eliminar(reserva.id);
    expect(await repositorio.obtenerReservas(), hasLength(3));

    await repositorio.restaurar(reserva);
    final datos = (await firestore.collection('reservas').doc(reserva.id).get())
        .data()!;
    expect(datos['usuarioId'], reserva.usuarioId);
    expect(datos['estado'], 'confirmada');
    expect(datos['creadoEn'], isNotNull);
  });

  test('cancelar solo cambia el estado', () async {
    await repositorio.cancelar('c1_20261025_20');

    final datos =
        (await firestore.collection('reservas').doc('c1_20261025_20').get())
            .data()!;
    expect(datos['estado'], 'cancelada');
    expect(datos['hora'], 20);
  });
}
