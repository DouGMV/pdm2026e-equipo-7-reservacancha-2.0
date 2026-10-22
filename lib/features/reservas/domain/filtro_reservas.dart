import 'package:reservacancha/features/reservas/domain/reserva.dart';

/// Estados que se pueden pedir al listado de reservas.
enum EstadoFiltroReserva { todas, confirmadas, canceladas }

/// Filtro del listado de reservas. Es inmutable: cada cambio crea un objeto
/// nuevo, así el historial de estados del provider es predecible.
class FiltroReservas {
  const FiltroReservas({this.estado = EstadoFiltroReserva.todas, this.mes});

  final EstadoFiltroReserva estado;

  /// Mes en formato `yyyy-MM`; `null` muestra todos los meses.
  final String? mes;

  /// Si no hay ningún filtro activo.
  bool get sinFiltros => estado == EstadoFiltroReserva.todas && mes == null;

  /// Copia con otro estado; el mes se conserva.
  FiltroReservas conEstado(EstadoFiltroReserva estado) =>
      FiltroReservas(estado: estado, mes: mes);

  /// Copia con otro mes (`null` = todos los meses); el estado se conserva.
  FiltroReservas conMes(String? mes) =>
      FiltroReservas(estado: estado, mes: mes);

  /// Si [reserva] debe aparecer con este filtro.
  bool incluye(Reserva reserva) {
    final coincideEstado = switch (estado) {
      EstadoFiltroReserva.todas => true,
      EstadoFiltroReserva.confirmadas =>
        reserva.estado == EstadoReserva.confirmada,
      EstadoFiltroReserva.canceladas =>
        reserva.estado == EstadoReserva.cancelada,
    };
    final mesActual = mes;
    final coincideMes =
        mesActual == null || reserva.fecha.startsWith(mesActual);
    return coincideEstado && coincideMes;
  }

  @override
  bool operator ==(Object other) =>
      other is FiltroReservas && other.estado == estado && other.mes == mes;

  @override
  int get hashCode => Object.hash(estado, mes);
}
