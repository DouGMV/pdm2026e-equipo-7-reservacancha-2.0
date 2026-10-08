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
