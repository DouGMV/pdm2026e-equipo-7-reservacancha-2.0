import 'package:cloud_firestore/cloud_firestore.dart';

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

  // ignore: unused_field, se usa en la implementación del #66.
  final FirebaseFirestore _firestore;

  /// Versión del esquema que espera esta versión de la app.
  static const versionActual = 2;

  /// Versión guardada en `config/esquema`, o 1 si todavía no existe.
  Future<int> leerVersion() {
    // TODO(julianeduardo512-del): #66.
    throw UnimplementedError('leerVersion (#66)');
  }

  /// Aplica los pasos pendientes hasta [versionActual]. Si la base ya está
  /// al día no escribe nada; correrlo dos veces deja el mismo resultado.
  Future<void> migrar() {
    // TODO(julianeduardo512-del): #66. Paso 1 → 2: agregar
    // `nombreNormalizado` a cada documento de `canchas/` que no lo tenga, en
    // un WriteBatch, y guardar `{version: 2}` en `config/esquema`.
    throw UnimplementedError('migrar (#66)');
  }
}
