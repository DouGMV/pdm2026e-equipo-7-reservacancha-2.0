import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/core/utils/formatters.dart';

void main() {
  group('formatearMoneda', () {
    test('agrega el símbolo Q y dos decimales', () {
      expect(formatearMoneda(150), 'Q150.00');
    });

    test('separa los miles con coma', () {
      expect(formatearMoneda(1500.5), 'Q1,500.50');
    });

    test('formatea cero', () {
      expect(formatearMoneda(0), 'Q0.00');
    });
  });

  group('formatearFecha', () {
    test('usa el formato yyyy-MM-dd', () {
      expect(formatearFecha(DateTime(2026, 10, 15, 18, 30)), '2026-10-15');
    });

    test('completa con ceros el mes y el día', () {
      expect(formatearFecha(DateTime(2026, 1, 5)), '2026-01-05');
    });
  });
}
