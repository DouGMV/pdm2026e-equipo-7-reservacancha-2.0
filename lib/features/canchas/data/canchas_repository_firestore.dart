import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reservacancha/core/constants/firestore_collections.dart';
import 'package:reservacancha/core/errors/cancha_duplicada_exception.dart';
import 'package:reservacancha/core/errors/cancha_en_uso_exception.dart';
import 'package:reservacancha/core/utils/normalizador.dart';
import 'package:reservacancha/features/canchas/data/cancha_model.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/domain/canchas_repository.dart';

/// Canchas guardadas en la colección `canchas` de Cloud Firestore.
class CanchasRepositoryFirestore implements CanchasRepository {
  CanchasRepositoryFirestore(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _canchas =>
      _firestore.collection(FirestoreCollections.canchas);

  @override
  Future<List<Cancha>> obtenerCanchas({String? deporte}) async {
    Query<Map<String, dynamic>> consulta = _canchas;
    if (deporte != null) {
      consulta = consulta.where('deporte', isEqualTo: deporte);
    }
    final resultado = await consulta.get();
    // Se ordena aquí para no necesitar un índice compuesto por cada filtro.
    return [
      for (final doc in resultado.docs) CanchaModel.fromMap(doc.id, doc.data()),
    ]..sort((a, b) => a.nombre.compareTo(b.nombre));
  }

  @override
  Future<Cancha?> obtenerCancha(String id) async {
    final doc = await _canchas.doc(id).get();
    final datos = doc.data();
    return datos == null ? null : CanchaModel.fromMap(doc.id, datos);
  }

  @override
  Future<String> crear(Cancha cancha) async {
    await _validarNombre(cancha);
    final doc = await _canchas.add(CanchaModel.toMap(cancha));
    return doc.id;
  }

  @override
  Future<void> actualizar(Cancha cancha) async {
    await _validarNombre(cancha, excluirId: cancha.id);
    await _canchas.doc(cancha.id).update(CanchaModel.toMap(cancha));
  }

  Future<void> _validarNombre(Cancha cancha, {String? excluirId}) async {
    final resultado = await _canchas
        .where('nombreNormalizado', isEqualTo: normalizarNombre(cancha.nombre))
        .get();
    if (resultado.docs.any((doc) => doc.id != excluirId)) {
      throw const CanchaDuplicadaException();
    }
  }

  @override
  Future<void> cambiarActiva(String id, {required bool activa}) =>
      _canchas.doc(id).update({'activa': activa});

  @override
  Future<void> eliminar(String id) async {
    final resultado = await _firestore
        .collection(FirestoreCollections.reservas)
        .where('canchaId', isEqualTo: id)
        .count()
        .get();
    final reservas = resultado.count ?? 0;
    if (reservas > 0) throw CanchaEnUsoException(reservas);
    await _canchas.doc(id).delete();
  }

  @override
  Future<void> restaurar(Cancha cancha) =>
      _canchas.doc(cancha.id).set(CanchaModel.toMap(cancha));
}
