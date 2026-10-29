/// Ya existe otra cancha con el mismo nombre (sin importar mayúsculas,
/// espacios ni tildes). Firestore no tiene restricción UNIQUE: la revisa el
/// repositorio antes de guardar.
class CanchaDuplicadaException implements Exception {
  const CanchaDuplicadaException();

  String get mensaje => 'Ya existe una cancha con ese nombre';

  @override
  String toString() => mensaje;
}
