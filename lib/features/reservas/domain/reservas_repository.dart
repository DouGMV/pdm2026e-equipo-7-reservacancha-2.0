import 'package:reservacancha/features/reservas/domain/reserva.dart';

/// Contrato para consultar reservas. La implementación vive en `data/`.
abstract interface class ReservasRepository {
  /// Reservas del usuario con sesión iniciada, próximas e historial.
  Future<List<Reserva>> obtenerMisReservas();

  /// Todas las reservas (vista del administrador). Con [estado], solo las
  /// que tienen ese estado.
  Future<List<Reserva>> obtenerReservas({EstadoReserva? estado});

  /// Horas con reserva `confirmada` de la cancha en la [fecha]
  /// (`yyyy-MM-dd`), para marcarlas como ocupadas.
  Future<Set<int>> obtenerHorasOcupadas({
    required String canchaId,
    required String fecha,
  });

  /// Guarda la [reserva] como `confirmada`. Si el horario ya está confirmado
  /// lanza `ReservaNoDisponibleException`; si estaba cancelado, lo reemplaza.
  Future<void> crearReserva(Reserva reserva);

  /// Cancela una reserva confirmada. Solo el dueño puede hacerlo.
  Future<void> cancelar(String id);

  /// Elimina la reserva. Solo el administrador puede hacerlo
  /// (ver `firestore.rules`).
  Future<void> eliminar(String id);

  /// Vuelve a guardar una reserva eliminada tal como estaba (mismo id), para
  /// "Deshacer".
  Future<void> restaurar(Reserva reserva);
}
