import 'package:intl/intl.dart';

// Guatemala usa punto decimal y coma para miles (Q1,500.00), igual que en_US.
final NumberFormat _formatoMoneda = NumberFormat.currency(
  locale: 'en_US',
  symbol: 'Q',
  decimalDigits: 2,
);

final DateFormat _formatoFecha = DateFormat('yyyy-MM-dd');

/// Formatea un monto en quetzales, por ejemplo `Q150.00`.
String formatearMoneda(num monto) => _formatoMoneda.format(monto);

/// Formatea una fecha como `yyyy-MM-dd`, el formato usado en Firestore.
String formatearFecha(DateTime fecha) => _formatoFecha.format(fecha);

/// Formatea la hora de inicio de un bloque de reserva, por ejemplo `7` → `07:00`.
String formatearHora(int hora) => '${hora.toString().padLeft(2, '0')}:00';

const _dias = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];
const _meses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// Fecha para leer en pantalla, por ejemplo `lunes 26 de octubre`.
/// Se arma a mano para no depender de cargar los datos de idioma de `intl`.
String formatearFechaLarga(DateTime fecha) =>
    '${_dias[fecha.weekday - 1]} ${fecha.day} de ${_meses[fecha.month - 1]}';

/// Día abreviado para un selector, por ejemplo `lun`.
String abreviarDia(DateTime fecha) => _dias[fecha.weekday - 1].substring(0, 3);

/// Bloque de una hora, por ejemplo `18` → `18:00 – 19:00`.
String formatearBloque(int hora) =>
    '${formatearHora(hora)} – ${formatearHora(hora + 1)}';
