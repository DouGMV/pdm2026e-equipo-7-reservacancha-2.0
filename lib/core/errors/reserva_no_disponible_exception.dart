/// Otra persona ya tiene confirmado el horario que se intentó reservar
/// (ver docs/ARQUITECTURA.md: regla anti-duplicados).
class ReservaNoDisponibleException implements Exception {
  const ReservaNoDisponibleException();

  String get mensaje => 'Horario no disponible';

  @override
  String toString() => mensaje;
}
