import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/core/utils/validators.dart';

void main() {
  group('validarRequerido', () {
    test('devuelve el mensaje por defecto con valor vacío', () {
      expect(validarRequerido(''), 'Este campo es obligatorio');
      expect(validarRequerido(null), 'Este campo es obligatorio');
      expect(validarRequerido('   '), 'Este campo es obligatorio');
    });

    test('devuelve el mensaje personalizado', () {
      expect(
        validarRequerido(null, mensaje: 'Introduce tu nombre'),
        'Introduce tu nombre',
      );
    });

    test('devuelve null con valor no vacío', () {
      expect(validarRequerido('Ana'), isNull);
    });
  });

  group('validarCorreo', () {
    test('exige el correo', () {
      expect(validarCorreo(''), 'Introduce el correo electrónico');
      expect(validarCorreo(null), 'Introduce el correo electrónico');
    });

    test('exige arroba', () {
      expect(
        validarCorreo('ana.correo.com'),
        'Introduce un correo electrónico válido',
      );
    });

    test('acepta un correo válido', () {
      expect(validarCorreo('ana@correo.com'), isNull);
    });
  });

  group('validarContrasena', () {
    test('exige la contraseña', () {
      expect(validarContrasena(''), 'Introduce la contraseña');
      expect(validarContrasena(null), 'Introduce la contraseña');
    });

    test('exige al menos 6 caracteres', () {
      expect(
        validarContrasena('12345'),
        'La contraseña debe tener al menos 6 caracteres',
      );
    });

    test('acepta una contraseña de 6 o más caracteres', () {
      expect(validarContrasena('123456'), isNull);
    });
  });

  group('validarTelefono', () {
    test('exige el teléfono', () {
      expect(validarTelefono(''), 'Introduce tu teléfono');
      expect(validarTelefono(null), 'Introduce tu teléfono');
    });

    test('rechaza letras', () {
      expect(
        validarTelefono('abcdefgh'),
        'Introduce un teléfono válido (8 dígitos)',
      );
    });

    test('rechaza menos de 8 dígitos', () {
      expect(
        validarTelefono('5555123'),
        'Introduce un teléfono válido (8 dígitos)',
      );
    });

    test('rechaza más de 8 dígitos', () {
      expect(
        validarTelefono('555512345'),
        'Introduce un teléfono válido (8 dígitos)',
      );
    });

    test('acepta exactamente 8 dígitos', () {
      expect(validarTelefono('55551234'), isNull);
    });
  });
}
