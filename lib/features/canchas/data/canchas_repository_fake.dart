import 'package:reservacancha/core/errors/cancha_duplicada_exception.dart';
import 'package:reservacancha/core/errors/cancha_en_uso_exception.dart';
import 'package:reservacancha/core/utils/normalizador.dart';
import 'package:reservacancha/features/canchas/data/canchas_de_ejemplo.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/domain/canchas_repository.dart';

/// Repositorio con datos de ejemplo mientras no exista la implementación con
/// Firestore. Trabaja sobre una lista en memoria y simula la demora de la red
/// con [Future.delayed].
///
/// Cada instancia parte de una copia de las canchas de ejemplo. Para que lo
/// eliminado siga eliminado mientras la app esté abierta, la app debe usar
/// siempre la misma instancia (ver `canchasRepositoryProvider`).
class CanchasRepositoryFake implements CanchasRepository {
  CanchasRepositoryFake({
    this.demora = const Duration(seconds: 1),
    Future<int> Function(String canchaId)? contarReservas,
  }) : contarReservas = contarReservas ?? _sinReservas;

  final Future<int> Function(String canchaId) contarReservas;

  static Future<int> _sinReservas(String canchaId) async => 0;

  void _validarNombre(Cancha cancha, {String? excluirId}) {
    final nombre = normalizarNombre(cancha.nombre);
    if (_canchas.any(
      (otra) => otra.id != excluirId && normalizarNombre(otra.nombre) == nombre,
    )) {
      throw const CanchaDuplicadaException();
    }
  }

  final Duration demora;

  final List<Cancha> _canchas = List<Cancha>.of(canchasDeEjemplo);

  @override
  Future<List<Cancha>> obtenerCanchas({String? deporte}) async {
    await Future<void>.delayed(demora);
    return [
      for (final cancha in _canchas)
        if (deporte == null || cancha.deporte == deporte) cancha,
    ];
  }

  @override
  Future<Cancha?> obtenerCancha(String id) async {
    await Future<void>.delayed(demora);
    for (final cancha in _canchas) {
      if (cancha.id == id) return cancha;
    }
    return null;
  }

  var _siguienteId = 1;

  @override
  Future<String> crear(Cancha cancha) async {
    await Future<void>.delayed(demora);
    _validarNombre(cancha);
    final id = 'cancha-nueva-${_siguienteId++}';
    _canchas.add(cancha.copyWith(id: id));
    return id;
  }

  @override
  Future<void> actualizar(Cancha cancha) async {
    await Future<void>.delayed(demora);
    final indice = _indice(cancha.id);
    _validarNombre(cancha, excluirId: cancha.id);
    _canchas[indice] = cancha;
  }

  @override
  Future<void> cambiarActiva(String id, {required bool activa}) async {
    await Future<void>.delayed(demora);
    final indice = _indice(id);
    _canchas[indice] = _canchas[indice].copyWith(activa: activa);
  }

  int _indice(String id) {
    final indice = _canchas.indexWhere((cancha) => cancha.id == id);
    if (indice == -1) throw StateError('No existe una cancha con id $id');
    return indice;
  }

  @override
  Future<void> eliminar(String id) async {
    await Future<void>.delayed(demora);
    final indice = _canchas.indexWhere((cancha) => cancha.id == id);
    if (indice == -1) {
      throw StateError('No existe una cancha con id $id');
    }
    final reservas = await contarReservas(id);
    if (reservas > 0) throw CanchaEnUsoException(reservas);
    _canchas.removeAt(_indice(id));
  }

  @override
  Future<void> restaurar(Cancha cancha) async {
    await Future<void>.delayed(demora);
    if (_canchas.any((existente) => existente.id == cancha.id)) {
      return;
    }

    // Vuelve a su posición original: antes de la primera cancha que, en la
    // lista de ejemplo, venía después de ella. Si no es una cancha de ejemplo,
    // va al final.
    final orden = _ordenOriginal(cancha.id);
    var posicion = _canchas.length;
    if (orden != -1) {
      final siguiente = _canchas.indexWhere(
        (existente) => _ordenOriginal(existente.id) > orden,
      );
      if (siguiente != -1) {
        posicion = siguiente;
      }
    }
    _canchas.insert(posicion, cancha);
  }

  int _ordenOriginal(String id) =>
      canchasDeEjemplo.indexWhere((cancha) => cancha.id == id);
}
