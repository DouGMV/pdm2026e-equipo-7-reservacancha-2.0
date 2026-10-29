import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/core/utils/normalizador.dart';

void main() {
  group('normalizarNombre', () {
    test('quita espacios sobrantes y pasa a minúsculas', () {
      expect(normalizarNombre('  Cancha  Sintética 1 '), 'cancha sintetica 1');
    });

    test('quita tildes y diéresis', () {
      expect(normalizarNombre('Pádel Club Ñandú'), 'padel club nandu');
    });

    test('trata saltos de línea y tabulaciones como un espacio', () {
      expect(normalizarNombre('Arena\tde\nVoleibol'), 'arena de voleibol');
    });

    test('deja igual un nombre que ya está normalizado', () {
      expect(normalizarNombre('cancha sintetica 1'), 'cancha sintetica 1');
    });
  });
}
