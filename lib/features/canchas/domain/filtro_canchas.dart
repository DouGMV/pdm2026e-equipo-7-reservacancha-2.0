/// Filtro del listado de canchas. Es inmutable: para cambiarlo se crea otro.
class FiltroCanchas {
  const FiltroCanchas({this.deporte});

  /// `null` muestra todos los deportes.
  final String? deporte;

  @override
  bool operator ==(Object other) =>
      other is FiltroCanchas && other.deporte == deporte;

  @override
  int get hashCode => deporte.hashCode;
}
