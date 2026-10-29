import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/core/errors/cancha_duplicada_exception.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_fake.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_provider.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/presentation/admin_canchas_providers.dart';

/// Repositorio en memoria que cuenta cuántas veces se consulta la lista: así
/// se comprueba que solo se refresca (invalidando) cuando algo cambió.
class _RepositorioQueCuenta extends CanchasRepositoryFake {
  _RepositorioQueCuenta() : super(demora: Duration.zero);

  var consultas = 0;

  @override
  Future<List<Cancha>> obtenerCanchas({String? deporte}) {
    consultas++;
    return super.obtenerCanchas(deporte: deporte);
  }
}

/// Complementa `admin_canchas_providers_test.dart` (#65): cuándo se refresca
/// la lista y la separación en Activas y Archivadas.
void main() {
  late _RepositorioQueCuenta repositorio;
  late ProviderContainer contenedor;

  setUp(() {
    repositorio = _RepositorioQueCuenta();
    contenedor = ProviderContainer(
      overrides: [canchasRepositoryProvider.overrideWithValue(repositorio)],
    );
    addTearDown(contenedor.dispose);
    contenedor.listen(canchaFormControllerProvider, (_, _) {});
  });

  Future<List<Cancha>> lista() => contenedor.read(adminCanchasProvider.future);

  test('un nombre repetido no vuelve a consultar la lista', () async {
    final existente = (await lista()).first;
    final antes = repositorio.consultas;

    await contenedor
        .read(canchaFormControllerProvider.notifier)
        .guardar(existente.copyWith(id: ''), nueva: true);

    expect(
      contenedor.read(canchaFormControllerProvider).error,
      isA<CanchaDuplicadaException>(),
    );
    await lista();
    expect(repositorio.consultas, antes);
  });

  test('guardar bien vuelve a consultar la lista una vez', () async {
    final original = (await lista()).first;
    final antes = repositorio.consultas;

    await contenedor
        .read(canchaFormControllerProvider.notifier)
        .guardar(original, nueva: false);
    await lista();

    expect(repositorio.consultas, antes + 1);
  });

  test('desactivar mueve la cancha de Activas a Archivadas', () async {
    final cancha = (await lista()).first;

    await contenedor
        .read(adminCanchasProvider.notifier)
        .cambiarActiva(cancha, activa: false);
    await lista();

    final agrupadas = contenedor.read(canchasAgrupadasProvider).requireValue;
    expect(agrupadas.archivadas.map((c) => c.id), contains(cancha.id));
    expect(agrupadas.activas.map((c) => c.id), isNot(contains(cancha.id)));
  });

  test('entre Activas y Archivadas están todas las canchas', () async {
    final todas = await lista();

    final agrupadas = contenedor.read(canchasAgrupadasProvider).requireValue;

    expect(
      agrupadas.activas.length + agrupadas.archivadas.length,
      todas.length,
    );
    expect(agrupadas.activas.every((c) => c.activa), isTrue);
    expect(agrupadas.archivadas.every((c) => !c.activa), isTrue);
  });
}
