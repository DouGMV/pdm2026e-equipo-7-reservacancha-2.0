import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:reservacancha/core/constants/firestore_collections.dart';
import 'package:reservacancha/core/utils/normalizador.dart';

/// Migraciones del esquema de Firestore: el equivalente de `onUpgrade` de
/// SQLite (Lab S16, issue #62).
///
/// La versión de la base vive en `config/esquema` (`{version: N}`); si el
/// documento no existe, la base está en la versión 1. [migrar] aplica en orden
/// los pasos pendientes y al final guarda [versionActual].
///
/// Regla: nunca se edita un paso ya publicado. Un cambio nuevo es un paso
/// nuevo (`_pasoV2aV3`) y sube [versionActual].
///
/// Contrato definido por la prueba `test/core/data/migrador_esquema_test.dart`
/// (#67); la implementación es del #66.
class MigradorEsquema {
  MigradorEsquema(this._firestore);

  final FirebaseFirestore _firestore;

  /// Versión del esquema que espera esta versión de la app.
  static const versionActual = 2;

  DocumentReference<Map<String, dynamic>> get _esquema =>
      _firestore.collection(FirestoreCollections.config).doc('esquema');

  /// Versión guardada en `config/esquema`, o 1 si todavía no existe.
  Future<int> leerVersion() async {
    final doc = await _esquema.get();
    final version = doc.data()?['version'];
    return version is num ? version.toInt() : 1;
  }

  /// Aplica los pasos pendientes hasta [versionActual]. Si la base ya está
  /// al día no escribe nada; correrlo dos veces deja el mismo resultado.
  Future<void> migrar() async {
    var version = await leerVersion();
    if (version >= versionActual) return;

    final batch = _firestore.batch();
    if (version < 2) {
      await _pasoV1aV2(batch);
      version = 2;
    }
    batch.set(_esquema, {'version': version}, SetOptions(merge: true));
    await batch.commit();
  }

  /// Paso 1 → 2: agrega `nombreNormalizado` a las canchas que no lo tengan.
  Future<void> _pasoV1aV2(WriteBatch batch) async {
    final canchas = await _firestore
        .collection(FirestoreCollections.canchas)
        .get();
    for (final doc in canchas.docs) {
      final datos = doc.data();
      if (datos.containsKey('nombreNormalizado')) continue;
      final nombre = datos['nombre'] as String? ?? '';
      batch.update(doc.reference, {
        'nombreNormalizado': normalizarNombre(nombre),
      });
    }
  }
}
