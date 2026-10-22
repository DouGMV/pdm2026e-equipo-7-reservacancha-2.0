import 'package:reservacancha/features/reservas/domain/filtro_reservas.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';

/// Contrato para consultar y administrar reservas. La implementación vive en
/// `data/`.
abstract interface class ReservasRepository {
  /// Reservas del usuario con sesión iniciada que cumplen [filtro], de la más
  /// reciente a la más antigua.
  Future<List<Reserva>> obtenerMisReservas({
    FiltroReservas filtro = const FiltroReservas(),
  });

  /// Borra la reserva [id]. Debe fallar si el borrado no se pudo hacer para
  /// que la pantalla devuelva la fila a su lugar.
  Future<void> eliminarReserva(String id);

  /// Vuelve a guardar [reserva] con el mismo id (acción «Deshacer»).
  Future<void> restaurarReserva(Reserva reserva);
}
