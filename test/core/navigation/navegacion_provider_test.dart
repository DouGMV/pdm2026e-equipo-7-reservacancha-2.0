import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/core/navigation/navegacion_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  test('la pestaña activa empieza en Inicio', () {
    expect(container.read(navegacionProvider), Pestana.inicio);
  });

  test('irA cambia la pestaña activa', () {
    container.read(navegacionProvider.notifier).irA(Pestana.canchas);

    expect(container.read(navegacionProvider), Pestana.canchas);

    container.read(navegacionProvider.notifier).irA(Pestana.reservas);

    expect(container.read(navegacionProvider), Pestana.reservas);
  });

  test('volver a la misma pestaña deja el estado igual', () {
    container.read(navegacionProvider.notifier).irA(Pestana.canchas);
    container.read(navegacionProvider.notifier).irA(Pestana.canchas);

    expect(container.read(navegacionProvider), Pestana.canchas);
  });

  test(
    'la pestaña activa se comparte entre quien la lee y quien la cambia',
    () {
      container.read(navegacionProvider.notifier).irA(Pestana.perfil);

      // Otro consumidor del provider ve el cambio sin que se le pase nada.
      expect(container.read(navegacionProvider), Pestana.perfil);
    },
  );
}
