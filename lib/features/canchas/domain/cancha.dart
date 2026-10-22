/// Cancha deportiva que se puede reservar (ver docs/ARQUITECTURA.md).
class Cancha {
  const Cancha({
    required this.id,
    required this.nombre,
    required this.deporte,
    required this.descripcion,
    required this.ubicacion,
    required this.precioPorHora,
    required this.imagenUrl,
    required this.horaApertura,
    required this.horaCierre,
    required this.activa,
  });

  final String id;
  final String nombre;

  /// `futbol`, `basquetbol`, `voleibol` o `padel`.
  final String deporte;
  final String descripcion;
  final String ubicacion;
  final num precioPorHora;
  final String imagenUrl;

  /// Hora de apertura en formato de 24 horas, por ejemplo `7`.
  final int horaApertura;

  /// Hora de cierre en formato de 24 horas, por ejemplo `22`.
  final int horaCierre;
  final bool activa;
}
