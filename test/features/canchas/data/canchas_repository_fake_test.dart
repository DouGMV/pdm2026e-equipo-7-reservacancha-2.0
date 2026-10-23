import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_fake.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_provider.dart';

void main() {
  late CanchasRepositoryFake repositorio;

  setUp(() => repositorio = CanchasRepositoryFake(demora: Duration.zero));

  group('obtenerCanchas', () {
    test('sin filtro devuelve todas las canchas de ejemplo', () async {
      final canchas = await repositorio.obtenerCanchas();

      expect(canchas.map((c) => c.id), [
        'cancha-1',
        'cancha-2',
        'cancha-3',
        'cancha-4',
        'cancha-5',
      ]);
    });

    test('filtra por deporte', () async {
      final canchas = await repositorio.obtenerCanchas(deporte: 'futbol');

      expect(canchas.map((c) => c.id), ['cancha-1', 'cancha-2']);
      expect(canchas.every((c) => c.deporte == 'futbol'), isTrue);
    });

    test('con un deporte sin canchas devuelve una lista vacía', () async {
      final canchas = await repositorio.obtenerCanchas(deporte: 'tenis');

      expect(canchas, isEmpty);
    });
  });

  group('eliminar', () {
    test('quita la cancha y deja las demás', () async {
      await repositorio.eliminar('cancha-3');

      final canchas = await repositorio.obtenerCanchas();
      expect(canchas.map((c) => c.id), [
        'cancha-1',
        'cancha-2',
        'cancha-4',
        'cancha-5',
      ]);
    });

    test('la cancha eliminada tampoco aparece al filtrar', () async {
      await repositorio.eliminar('cancha-3');

      final canchas = await repositorio.obtenerCanchas(deporte: 'basquetbol');
      expect(canchas, isEmpty);
    });

    test('con un id inexistente lanza un error', () async {
      await expectLater(
        repositorio.eliminar('no-existe'),
        throwsA(isA<StateError>()),
      );

      final canchas = await repositorio.obtenerCanchas();
      expect(canchas, hasLength(5));
    });

    test('no afecta a otro repositorio nuevo', () async {
      await repositorio.eliminar('cancha-1');

      final otro = CanchasRepositoryFake(demora: Duration.zero);
      final canchas = await otro.obtenerCanchas();
      expect(canchas, hasLength(5));
    });
  });

  group('restaurar', () {
    test('devuelve la cancha idéntica y en su posición original', () async {
      final original = (await repositorio.obtenerCanchas())[2];

      await repositorio.eliminar(original.id);
      await repositorio.restaurar(original);

      final canchas = await repositorio.obtenerCanchas();
      expect(canchas.map((c) => c.id), [
        'cancha-1',
        'cancha-2',
        'cancha-3',
        'cancha-4',
        'cancha-5',
      ]);
      expect(canchas[2], same(original));
    });

    test('restaura la primera y la última en su lugar', () async {
      final todas = await repositorio.obtenerCanchas();
      final primera = todas.first;
      final ultima = todas.last;

      await repositorio.eliminar(primera.id);
      await repositorio.eliminar(ultima.id);
      await repositorio.restaurar(ultima);
      await repositorio.restaurar(primera);

      final canchas = await repositorio.obtenerCanchas();
      expect(canchas.map((c) => c.id), todas.map((c) => c.id));
    });

    test('mantiene el orden aunque se eliminen varias', () async {
      final todas = await repositorio.obtenerCanchas();

      await repositorio.eliminar('cancha-2');
      await repositorio.eliminar('cancha-4');
      await repositorio.restaurar(todas[3]);
      await repositorio.restaurar(todas[1]);

      final canchas = await repositorio.obtenerCanchas();
      expect(canchas.map((c) => c.id), todas.map((c) => c.id));
    });

    test('no duplica una cancha que ya existe', () async {
      final existente = (await repositorio.obtenerCanchas()).first;

      await repositorio.restaurar(existente);

      final canchas = await repositorio.obtenerCanchas();
      expect(canchas, hasLength(5));
    });
  });

  test('canchasRepositoryProvider devuelve siempre la misma instancia', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final primera = container.read(canchasRepositoryProvider);
    final segunda = container.read(canchasRepositoryProvider);

    expect(segunda, same(primera));
  });
}
