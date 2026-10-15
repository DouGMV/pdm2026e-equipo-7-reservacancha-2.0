/// Entidad Cancha (dominio puro, sin Flutter ni Firebase).
class Cancha {
  const Cancha({
    required this.id,
    required this.nombre,
    required this.deporte,
    required this.precioPorHora,
    this.descripcion = '',
    this.ubicacion = '',
    this.imagenUrl = '',
    this.activa = true,
  });

  final String id;
  final String nombre;

  /// Uno de: futbol, basquetbol, voleibol, padel.
  final String deporte;
  final num precioPorHora;
  final String descripcion;
  final String ubicacion;
  final String imagenUrl;
  final bool activa;
}
