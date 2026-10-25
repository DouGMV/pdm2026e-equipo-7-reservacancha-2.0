import 'package:reservacancha/features/canchas/domain/cancha.dart';

/// Id de la reserva: `{canchaId}_{yyyyMMdd}_{HH}`. Solo puede existir un
/// documento por cancha, fecha y hora (ver docs/ARQUITECTURA.md).
///
/// [fecha] va en formato `yyyy-MM-dd`.
String idReserva({
  required String canchaId,
  required String fecha,
  required int hora,
}) =>
    '${canchaId}_${fecha.replaceAll('-', '')}_${hora.toString().padLeft(2, '0')}';

/// Bloque de una hora en el detalle de una cancha.
class BloqueHorario {
  const BloqueHorario({required this.hora, required this.disponible});

  /// Hora de inicio en formato de 24 horas.
  final int hora;
  final bool disponible;
}

/// Bloques de una hora entre la apertura y el cierre de la [cancha] para el
/// [dia] indicado. No están disponibles las horas [ocupadas] ni, si [dia] es
/// hoy, las que ya empezaron.
List<BloqueHorario> bloquesDelDia({
  required Cancha cancha,
  required DateTime dia,
  required Set<int> ocupadas,
  required DateTime ahora,
}) {
  final esHoy =
      dia.year == ahora.year &&
      dia.month == ahora.month &&
      dia.day == ahora.day;
  return [
    for (var hora = cancha.horaApertura; hora < cancha.horaCierre; hora++)
      BloqueHorario(
        hora: hora,
        disponible: !ocupadas.contains(hora) && !(esHoy && hora <= ahora.hour),
      ),
  ];
}

/// Los próximos [cantidad] días a partir de hoy, sin hora.
List<DateTime> proximosDias(DateTime ahora, {int cantidad = 7}) => [
  for (var i = 0; i < cantidad; i++)
    DateTime(ahora.year, ahora.month, ahora.day + i),
];
