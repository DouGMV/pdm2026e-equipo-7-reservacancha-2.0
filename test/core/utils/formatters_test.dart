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

  group('formatearHora', () {
    test('usa el formato HH:00', () {
      expect(formatearHora(18), '18:00');
    });

    test('completa con cero las horas de un dígito', () {
      expect(formatearHora(7), '07:00');
    });
  });

  group('formatearMes', () {
    test('convierte yyyy-MM en el nombre del mes y el año', () {
      expect(formatearMes('2026-10'), 'Octubre 2026');
    });

    test('usa el nombre en español de cada mes', () {
      expect(formatearMes('2026-01'), 'Enero 2026');
      expect(formatearMes('2026-12'), 'Diciembre 2026');
    });

    test('devuelve el valor tal cual si no tiene el formato esperado', () {
      expect(formatearMes('2026'), '2026');
      expect(formatearMes('2026-13'), '2026-13');
    });
  });
}
