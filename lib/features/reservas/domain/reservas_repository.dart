import 'package:reservacancha/features/reservas/domain/reserva.dart';

/// Contrato para consultar reservas. La implementación vive en `data/`.
abstract interface class ReservasRepository {
  /// Reservas del usuario con sesión iniciada, próximas e historial.
  Future<List<Reserva>> obtenerMisReservas();
}
