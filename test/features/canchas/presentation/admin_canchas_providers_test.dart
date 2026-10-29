import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/core/errors/cancha_duplicada_exception.dart';
import 'package:reservacancha/core/errors/cancha_en_uso_exception.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_fake.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_provider.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/presentation/admin_canchas_providers.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_providers.dart';

/// Providers del CRUD de canchas (Lab S16, #65): los errores llegan al estado
/// y la lista se refresca invalidando, nunca agregando a mano.
void main() {
  late CanchasRepositoryFake repositorio;
  late ProviderContainer contenedor;

  setUp(() {
    repositorio = CanchasRepositoryFake(
      demora: Duration.zero,
      // La cancha-1 tiene reservas: la regla impide borrarla.
      contarReservas: (id) async => id == 'cancha-1' ? 2 : 0,
    );
    contenedor = ProviderContainer(
      overrides: [canchasRepositoryProvider.overrideWithValue(repositorio)],
    );
    addTearDown(contenedor.dispose);
    // Mantiene vivos los providers como lo haría la pantalla.
    contenedor
      ..listen(adminCanchasProvider, (_, _) {})
      ..listen(canchasProvider, (_, _) {})
      ..listen(canchaFormControllerProvider, (_, _) {});
  });

  Future<List<String>> idsAdmin() async => [
    for (final c in await contenedor.read(adminCanchasProvider.future)) c.id,
  ];

  Future<Cancha> unaCancha(String id) async =>
      (await repositorio.obtenerCancha(id))!;

  test('guardar con un nombre repetido deja el error en el estado', () async {
    final antes = await idsAdmin();
    final copia = await unaCancha('cancha-2');

    await contenedor
        .read(canchaFormControllerProvider.notifier)
        .guardar(copia.copyWith(id: ''), nueva: true);

    final estado = contenedor.read(canchaFormControllerProvider);
    expect(estado.hasError, isTrue);
    expect(estado.error, isA<CanchaDuplicadaException>());
    expect(await idsAdmin(), antes);
  });

  test('crear una cancha vuelve a consultar la lista', () async {
    final base = await unaCancha('cancha-2');
    final nueva = Cancha(
      id: '',
      nombre: 'Cancha Nueva',
      deporte: base.deporte,
      descripcion: '',
      ubicacion: 'Zona 10',
      precioPorHora: 180,
      imagenUrl: '',
      horaApertura: 7,
      horaCierre: 22,
      activa: true,
    );

    await contenedor
        .read(canchaFormControllerProvider.notifier)
        .guardar(nueva, nueva: true);

    expect(contenedor.read(canchaFormControllerProvider).hasError, isFalse);
    final nombres = [
      for (final c in await contenedor.read(adminCanchasProvider.future))
        c.nombre,
    ];
    expect(nombres, contains('Cancha Nueva'));
    final delCliente = [
      for (final c in await contenedor.read(canchasProvider.future)) c.nombre,
    ];
    expect(delCliente, contains('Cancha Nueva'));
  });

  test('editar conserva el id y la lista muestra el dato nuevo', () async {
    final original = await unaCancha('cancha-3');
    final editada = Cancha(
      id: original.id,
      nombre: 'Polideportivo',
      deporte: original.deporte,
      descripcion: original.descripcion,
      ubicacion: original.ubicacion,
      precioPorHora: original.precioPorHora,
      imagenUrl: original.imagenUrl,
      horaApertura: original.horaApertura,
      horaCierre: original.horaCierre,
      activa: original.activa,
    );

    await contenedor
        .read(canchaFormControllerProvider.notifier)
        .guardar(editada, nueva: false);

    final lista = await contenedor.read(adminCanchasProvider.future);
    expect(
      lista.singleWhere((c) => c.id == 'cancha-3').nombre,
      'Polideportivo',
    );
    expect(lista.where((c) => c.nombre == 'Polideportivo'), hasLength(1));
  });

  test(
    'borrar una cancha en uso lanza el error y no cambia la lista',
    () async {
      final antes = await idsAdmin();
      final enUso = await unaCancha('cancha-1');

      await expectLater(
        contenedor.read(adminCanchasProvider.notifier).eliminar(enUso),
        throwsA(
          isA<CanchaEnUsoException>().having((e) => e.reservas, 'reservas', 2),
        ),
      );

      expect(await idsAdmin(), antes);
    },
  );

  test('desactivar la mueve a archivadas y la quita del cliente', () async {
    final cancha = await unaCancha('cancha-1');

    await contenedor
        .read(adminCanchasProvider.notifier)
        .cambiarActiva(cancha, activa: false);

    final admin = await contenedor.read(adminCanchasProvider.future);
    expect(admin.singleWhere((c) => c.id == 'cancha-1').activa, isFalse);
    final delCliente = [
      for (final c in await contenedor.read(canchasProvider.future)) c.id,
    ];
    expect(delCliente, isNot(contains('cancha-1')));
  });
}
