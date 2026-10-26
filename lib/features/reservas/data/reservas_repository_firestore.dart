import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:reservacancha/core/constants/firestore_collections.dart';
import 'package:reservacancha/core/errors/reserva_no_disponible_exception.dart';
import 'package:reservacancha/features/reservas/data/reserva_model.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';
import 'package:reservacancha/features/reservas/domain/reservas_repository.dart';

/// Reservas guardadas en la colección `reservas` de Cloud Firestore.
class ReservasRepositoryFirestore implements ReservasRepository {
  ReservasRepositoryFirestore(this._firestore, {required this.usuarioActual});

  final FirebaseFirestore _firestore;

  /// uid del usuario con sesión, o `null` si no hay sesión.
  final String? Function() usuarioActual;

  CollectionReference<Map<String, dynamic>> get _reservas =>
      _firestore.collection(FirestoreCollections.reservas);

  @override
  Future<List<Reserva>> obtenerMisReservas() async {
    final uid = usuarioActual();
    if (uid == null) return const [];
    return _leer(_reservas.where('usuarioId', isEqualTo: uid));
  }

  @override
  Future<List<Reserva>> obtenerReservas({EstadoReserva? estado}) {
    Query<Map<String, dynamic>> consulta = _reservas;
    if (estado != null) {
      consulta = consulta.where('estado', isEqualTo: estado.name);
    }
    return _leer(consulta);
  }

  @override
  Future<Set<int>> obtenerHorasOcupadas({
    required String canchaId,
    required String fecha,
  }) async {
    final resultado = await _reservas
        .where('canchaId', isEqualTo: canchaId)
        .where('fecha', isEqualTo: fecha)
        .where('estado', isEqualTo: EstadoReserva.confirmada.name)
        .get();
    return {
      for (final doc in resultado.docs)
        ReservaModel.fromMap(doc.id, doc.data()).hora,
    };
  }

  /// Transacción de la regla anti-duplicados (docs/ARQUITECTURA.md): si dos
  /// personas reservan la misma hora a la vez, Firestore repite la
  /// transacción de la segunda y esta encuentra el horario ya confirmado.
  @override
  Future<void> crearReserva(Reserva reserva) async {
    final referencia = _reservas.doc(reserva.id);
    await _firestore.runTransaction((transaccion) async {
      final actual = await transaccion.get(referencia);
      if (actual.data()?['estado'] == EstadoReserva.confirmada.name) {
        throw const ReservaNoDisponibleException();
      }
      transaccion.set(referencia, {
        ...ReservaModel.toMap(reserva),
        'estado': EstadoReserva.confirmada.name,
        'creadoEn': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Solo cambia `estado`: `firestore.rules` no deja que el dueño toque
  /// ningún otro campo al cancelar.
  @override
  Future<void> cancelar(String id) =>
      _reservas.doc(id).update({'estado': EstadoReserva.cancelada.name});

  @override
  Future<void> eliminar(String id) => _reservas.doc(id).delete();

  @override
  Future<void> restaurar(Reserva reserva) => _reservas.doc(reserva.id).set({
    ...ReservaModel.toMap(reserva),
    'creadoEn': FieldValue.serverTimestamp(),
  });

  /// Más recientes primero (los índices de `firestore.indexes.json` cubren
  /// estas consultas ordenadas por fecha y hora).
  Future<List<Reserva>> _leer(Query<Map<String, dynamic>> consulta) async {
    final resultado = await consulta
        .orderBy('fecha', descending: true)
        .orderBy('hora', descending: true)
        .get();
    return [
      for (final doc in resultado.docs)
        ReservaModel.fromMap(doc.id, doc.data()),
    ];
  }
}
