/// La cancha tiene reservas que apuntan a ella, así que no se puede borrar:
/// se ofrece desactivarla.
class CanchaEnUsoException implements Exception {
  const CanchaEnUsoException(this.reservas);

  /// Cuántas reservas tiene la cancha.
  final int reservas;

  String get mensaje =>
      'Tiene $reservas reservas. Desactívala para dejar de mostrarla.';

  @override
  String toString() => mensaje;
}
