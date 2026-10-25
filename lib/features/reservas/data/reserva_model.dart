import 'package:reservacancha/features/reservas/domain/reserva.dart';

/// Conversión entre [Reserva] y el documento `reservas/{reservaId}` de
/// Firestore.
abstract final class ReservaModel {
  static Reserva fromMap(String id, Map<String, dynamic> datos) {
    return Reserva(
      id: id,
      canchaId: datos['canchaId'] as String? ?? '',
      canchaNombre: datos['canchaNombre'] as String? ?? '',
      usuarioId: datos['usuarioId'] as String? ?? '',
      fecha: datos['fecha'] as String? ?? '',
      hora: (datos['hora'] as num?)?.toInt() ?? 0,
      estado: datos['estado'] == 'cancelada'
          ? EstadoReserva.cancelada
          : EstadoReserva.confirmada,
      total: datos['total'] as num? ?? 0,
    );
  }

  /// Sin `creadoEn`: lo agrega el repositorio con la hora del servidor.
  static Map<String, Object?> toMap(Reserva reserva) {
    return {
      'canchaId': reserva.canchaId,
      'canchaNombre': reserva.canchaNombre,
      'usuarioId': reserva.usuarioId,
      'fecha': reserva.fecha,
      'hora': reserva.hora,
      'estado': reserva.estado.name,
      'total': reserva.total,
    };
  }
}
