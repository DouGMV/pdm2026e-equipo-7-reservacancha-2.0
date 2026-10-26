import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/reservas/domain/horarios.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';

/// Lo que eligió el cliente en el detalle de la cancha: se muestra en la
/// pantalla de confirmación antes de crear la [Reserva].
class SolicitudReserva {
  const SolicitudReserva({
    required this.cancha,
    required this.fecha,
    required this.hora,
  });

  final Cancha cancha;

  /// Fecha en formato `yyyy-MM-dd`.
  final String fecha;

  /// Hora de inicio del bloque en formato de 24 horas.
  final int hora;

  num get total => cancha.precioPorHora;

  Reserva paraUsuario(String usuarioId) => Reserva(
    id: idReserva(canchaId: cancha.id, fecha: fecha, hora: hora),
    canchaId: cancha.id,
    canchaNombre: cancha.nombre,
    usuarioId: usuarioId,
    fecha: fecha,
    hora: hora,
    estado: EstadoReserva.confirmada,
    total: total,
  );
}
