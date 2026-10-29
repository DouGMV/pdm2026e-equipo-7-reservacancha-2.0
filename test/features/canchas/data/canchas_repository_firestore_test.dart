import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/core/utils/normalizador.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_firestore.dart';

import '../../../helpers/cancha_con_nombre.dart';

Map<String, Object?> _cancha(String nombre, String deporte) => {
  'nombre': nombre,
  'nombreNormalizado': normalizarNombre(nombre),
  'deporte': deporte,
  'descripcion': 'Descripción',
  'ubicacion': 'Zona 1',
  'precioPorHora': 150,
  'imagenUrl': '',
  'horaApertura': 7,
  'horaCierre': 22,
  'activa': true,
};

void main() {
  late FakeFirebaseFirestore firestore;
  late CanchasRepositoryFirestore repositorio;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    repositorio = CanchasRepositoryFirestore(firestore);
    final canchas = firestore.collection('canchas');
    await canchas.doc('c2').set(_cancha('Zeta', 'futbol'));
    await canchas.doc('c1').set(_cancha('Alfa', 'padel'));
    await canchas.doc('c3').set(_cancha('Beta', 'futbol'));
  });

  test('devuelve todas las canchas ordenadas por nombre', () async {
    final canchas = await repositorio.obtenerCanchas();

    expect(canchas.map((c) => c.nombre), ['Alfa', 'Beta', 'Zeta']);
    expect(canchas.first.id, 'c1');
    expect(canchas.first.precioPorHora, 150);
  });

  test('filtra por deporte', () async {
    final canchas = await repositorio.obtenerCanchas(deporte: 'futbol');

    expect(canchas.map((c) => c.id), ['c3', 'c2']);
  });

  test('eliminar y restaurar dejan la cancha igual que antes', () async {
    final antes = (await repositorio.obtenerCanchas()).first;

    await repositorio.eliminar(antes.id);
    expect(await repositorio.obtenerCanchas(), hasLength(2));

    await repositorio.restaurar(antes);
    final despues = (await repositorio.obtenerCanchas()).first;
    expect(despues.id, antes.id);
    expect(despues.nombre, antes.nombre);
    expect(despues.horaCierre, antes.horaCierre);
  });

  test('un documento incompleto usa valores por defecto', () async {
    await firestore.collection('canchas').doc('c4').set({
      'nombre': 'Incompleta',
    });

    final cancha = (await repositorio.obtenerCanchas()).firstWhere(
      (c) => c.id == 'c4',
    );
    expect(cancha.deporte, '');
    expect(cancha.activa, isTrue);
  });

  test('obtenerCancha devuelve la cancha o null si no existe', () async {
    expect((await repositorio.obtenerCancha('c3'))?.nombre, 'Beta');
    expect(await repositorio.obtenerCancha('no-existe'), isNull);
  });

  test('crear asigna un id nuevo y guarda los datos', () async {
    final base = (await repositorio.obtenerCancha('c1'))!;

    final id = await repositorio.crear(
      base.conNombre(id: 'ignorado', nombre: 'Nueva cancha'),
    );

    expect(id, isNot('ignorado'));
    expect((await repositorio.obtenerCancha(id))?.nombre, 'Nueva cancha');
    expect(await repositorio.obtenerCanchas(), hasLength(4));
  });

  test('crear guarda el nombre normalizado', () async {
    final base = (await repositorio.obtenerCancha('c1'))!;

    final id = await repositorio.crear(
      base.conNombre(id: 'ignorado', nombre: 'Nueva cancha'),
    );

    final doc = await firestore.collection('canchas').doc(id).get();
    expect(doc.data()?['nombreNormalizado'], 'nueva cancha');
  });

  test('actualizar y cambiarActiva modifican la cancha', () async {
    final cancha = (await repositorio.obtenerCancha('c1'))!;

    await repositorio.actualizar(cancha.copyWith(activa: false));
    expect((await repositorio.obtenerCancha('c1'))!.activa, isFalse);

    await repositorio.cambiarActiva('c1', activa: true);
    expect((await repositorio.obtenerCancha('c1'))!.activa, isTrue);
  });
}
