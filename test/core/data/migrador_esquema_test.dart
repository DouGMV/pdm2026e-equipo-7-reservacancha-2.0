import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/core/data/migrador_esquema.dart';

/// Canchas tal como las guardaba la versión 1: sin `nombreNormalizado`.
const _canchasV1 = {
  'c1': {
    'nombre': 'Cancha Sintética 1',
    'deporte': 'futbol',
    'descripcion': 'Fútbol 5 con grama sintética.',
    'ubicacion': 'Zona 3, Quetzaltenango',
    'precioPorHora': 150,
    'imagenUrl': '',
    'horaApertura': 7,
    'horaCierre': 22,
    'activa': true,
  },
  'c2': {
    'nombre': '  Pádel   Club  Mesoamericana ',
    'deporte': 'padel',
    'descripcion': '',
    'ubicacion': 'Zona 9, Quetzaltenango',
    'precioPorHora': 175.5,
    'imagenUrl': 'https://ejemplo.com/padel.jpg',
    'horaApertura': 6,
    'horaCierre': 23,
    'activa': false,
  },
};

const _normalizados = {
  'c1': 'cancha sintetica 1',
  'c2': 'padel club mesoamericana',
};

/// Prueba de migración (Lab S16, #67): el equivalente de `app_database_test`.
void main() {
  late FakeFirebaseFirestore firestore;
  late MigradorEsquema migrador;

  /// Todos los documentos de `canchas/` por id.
  Future<Map<String, Map<String, dynamic>>> leerCanchas() async {
    final resultado = await firestore.collection('canchas').get();
    return {for (final doc in resultado.docs) doc.id: doc.data()};
  }

  Future<Object?> versionGuardada() async =>
      (await firestore.collection('config').doc('esquema').get())
          .data()?['version'];

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    migrador = MigradorEsquema(firestore);
    for (final MapEntry(:key, :value) in _canchasV1.entries) {
      await firestore.collection('canchas').doc(key).set(value);
    }
  });

  test('sin config/esquema la base está en la versión 1', () async {
    expect(await migrador.leerVersion(), 1);
    expect(MigradorEsquema.versionActual, 2);
  });

  test('v1 → v2 conserva los datos y agrega nombreNormalizado', () async {
    await migrador.migrar();

    final canchas = await leerCanchas();
    expect(canchas.keys, unorderedEquals(_canchasV1.keys));
    for (final MapEntry(key: id, value: antes) in _canchasV1.entries) {
      final despues = Map.of(canchas[id]!);
      expect(despues.remove('nombreNormalizado'), _normalizados[id]);
      expect(despues, antes, reason: 'la cancha $id cambió otros campos');
    }
    expect(await versionGuardada(), 2);
    expect(await migrador.leerVersion(), 2);
  });

  test('migrar otra vez no cambia nada', () async {
    await migrador.migrar();
    final primera = await leerCanchas();

    await migrador.migrar();

    expect(await leerCanchas(), primera);
    expect(await versionGuardada(), 2);
  });

  test('una base que ya está en la versión 2 no se toca', () async {
    // Si el migrador ignorara la versión, agregaría nombreNormalizado aquí.
    await firestore.collection('config').doc('esquema').set({'version': 2});

    await migrador.migrar();

    final canchas = await leerCanchas();
    expect(canchas['c1'], _canchasV1['c1']);
    expect(canchas['c2'], _canchasV1['c2']);
  });

  test('una cancha que ya tiene nombreNormalizado lo conserva', () async {
    // Por ejemplo, creada con la app nueva antes de que corriera la migración.
    await firestore.collection('canchas').doc('c3').set({
      ..._canchasV1['c1']!,
      'nombre': 'Arena Voleibol',
      'nombreNormalizado': 'arena voleibol',
    });

    await migrador.migrar();

    final canchas = await leerCanchas();
    expect(canchas['c3']!['nombreNormalizado'], 'arena voleibol');
    expect(canchas, hasLength(3));
  });
}
