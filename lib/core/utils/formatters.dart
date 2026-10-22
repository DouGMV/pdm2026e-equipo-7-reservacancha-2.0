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

const List<String> _nombresDeMes = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

/// Formatea un mes en formato `yyyy-MM` como `Octubre 2026`. Si el valor no
/// tiene ese formato se devuelve tal cual para no romper la pantalla.
String formatearMes(String anioMes) {
  final partes = anioMes.split('-');
  if (partes.length < 2) {
    return anioMes;
  }
  final mes = int.tryParse(partes[1]);
  if (mes == null || mes < 1 || mes > 12) {
    return anioMes;
  }
  return '${_nombresDeMes[mes - 1]} ${partes[0]}';
}
