/// Estado de una reserva. En Firestore se guarda como texto
/// (`confirmada` o `cancelada`); el modelo de `data/` hace la conversión.
enum EstadoReserva { confirmada, cancelada }

/// Reserva de una cancha en un bloque de una hora (ver docs/ARQUITECTURA.md).
class Reserva {
  const Reserva({
    required this.id,
    required this.canchaId,
    required this.canchaNombre,
    required this.usuarioId,
    required this.fecha,
    required this.hora,
    required this.estado,
    required this.total,
  });

  /// `{canchaId}_{yyyyMMdd}_{HH}`: evita reservas duplicadas.
  final String id;
  final String canchaId;

  /// Copiado de la cancha para mostrarlo sin otra consulta.
  final String canchaNombre;
  final String usuarioId;

  /// Fecha en formato `yyyy-MM-dd`.
  final String fecha;

  /// Hora de inicio del bloque en formato de 24 horas, por ejemplo `18`.
  final int hora;
  final EstadoReserva estado;
  final num total;
}

/// Ordena de la reserva más reciente a la más antigua, por fecha y hora.
int reservaMasRecientePrimero(Reserva a, Reserva b) {
  final porFecha = b.fecha.compareTo(a.fecha);
  return porFecha != 0 ? porFecha : b.hora.compareTo(a.hora);
}
