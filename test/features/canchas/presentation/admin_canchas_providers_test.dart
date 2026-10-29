import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/core/errors/cancha_duplicada_exception.dart';
import 'package:reservacancha/core/errors/cancha_en_uso_exception.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_fake.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_provider.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/presentation/admin_canchas_providers.dart';

/// Repositorio en memoria que cuenta las consultas de la lista y puede
/// simular las reglas del Lab S16 (nombre repetido y cancha en uso).
class _RepositorioDePrueba extends CanchasRepositoryFake {
  _RepositorioDePrueba() : super(demora: Duration.zero);

  var consultas = 0;
  Exception? errorAlGuardar;
  Exception? errorAlEliminar;

  @override
  Future<List<Cancha>> obtenerCanchas({String? deporte}) {
    consultas++;
    return super.obtenerCanchas(deporte: deporte);
  }

  @override
  Future<String> crear(Cancha cancha) async {
    final error = errorAlGuardar;
    if (error != null) throw error;
    return super.crear(cancha);
  }

  @override
  Future<void> actualizar(Cancha cancha) async {
    final error = errorAlGuardar;
    if (error != null) throw error;
    return super.actualizar(cancha);
  }

  @override
  Future<void> eliminar(String id) async {
    final error = errorAlEliminar;
    if (error != null) throw error;
    return super.eliminar(id);
  }
}

Cancha _conNombre(Cancha cancha, String nombre) => Cancha(
  id: cancha.id,
  nombre: nombre,
  deporte: cancha.deporte,
  descripcion: cancha.descripcion,
  ubicacion: cancha.ubicacion,
  precioPorHora: cancha.precioPorHora,
  imagenUrl: cancha.imagenUrl,
  horaApertura: cancha.horaApertura,
  horaCierre: cancha.horaCierre,
  activa: cancha.activa,
);

void main() {
  late _RepositorioDePrueba repositorio;
  late ProviderContainer contenedor;

  setUp(() {
    repositorio = _RepositorioDePrueba();
    contenedor = ProviderContainer(
      overrides: [canchasRepositoryProvider.overrideWithValue(repositorio)],
    );
    addTearDown(contenedor.dispose);
    // El controlador del formulario es autoDispose: se mantiene vivo durante
    // la prueba, como lo haría la pantalla abierta.
    contenedor.listen(canchaFormControllerProvider, (_, _) {});
  });

  Future<List<Cancha>> lista() => contenedor.read(adminCanchasProvider.future);

  CanchaFormController formulario() =>
      contenedor.read(canchaFormControllerProvider.notifier);

  AdminCanchasNotifier admin() =>
      contenedor.read(adminCanchasProvider.notifier);

  group('guardar', () {
    test('editar vuelve a consultar la lista y conserva el id', () async {
      final original = (await lista()).first;
      final antes = repositorio.consultas;

      await formulario().guardar(
        _conNombre(original, 'Cancha Renovada'),
        nueva: false,
      );

      final despues = await lista();
      expect(repositorio.consultas, antes + 1);
      final editada = despues.singleWhere((c) => c.id == original.id);
      expect(editada.nombre, 'Cancha Renovada');
      expect(contenedor.read(canchaFormControllerProvider).hasError, isFalse);
    });

    test('crear vuelve a consultar y la cancha nueva aparece', () async {
      final base = (await lista()).first;
      final total = (await lista()).length;
      final antes = repositorio.consultas;

      await formulario().guardar(
        _conNombre(base.copyWith(id: ''), 'Cancha Nueva'),
        nueva: true,
      );

      final despues = await lista();
      expect(repositorio.consultas, antes + 1);
      expect(despues, hasLength(total + 1));
      expect(despues.map((c) => c.nombre), contains('Cancha Nueva'));
    });

    test(
      'un nombre repetido deja el error en el estado y no refresca',
      () async {
        final base = (await lista()).first;
        final antes = repositorio.consultas;
        repositorio.errorAlGuardar = const CanchaDuplicadaException();

        await formulario().guardar(base.copyWith(id: ''), nueva: true);

        final estado = contenedor.read(canchaFormControllerProvider);
        expect(estado.hasError, isTrue);
        expect(estado.error, isA<CanchaDuplicadaException>());
        await lista();
        expect(repositorio.consultas, antes);
      },
    );
  });

  group('eliminar', () {
    test('una cancha en uso devuelve el error y la lista no cambia', () async {
      final antes = await lista();
      final consultas = repositorio.consultas;
      repositorio.errorAlEliminar = const CanchaEnUsoException(3);

      await expectLater(
        admin().eliminar(antes.first),
        throwsA(
          isA<CanchaEnUsoException>().having(
            (error) => error.mensaje,
            'mensaje',
            contains('3 reservas'),
          ),
        ),
      );

      expect(contenedor.read(adminCanchasProvider).value, antes);
      expect(repositorio.consultas, consultas);
      expect(await repositorio.obtenerCancha(antes.first.id), isNotNull);
    });

    test('una cancha libre se borra del repositorio', () async {
      final cancha = (await lista()).first;

      await admin().eliminar(cancha);

      expect(await repositorio.obtenerCancha(cancha.id), isNull);
    });
  });

  group('activas y archivadas', () {
    test(
      'desactivar vuelve a consultar y mueve la cancha a Archivadas',
      () async {
        final cancha = (await lista()).first;
        final antes = repositorio.consultas;

        await admin().cambiarActiva(cancha, activa: false);
        await lista();

        expect(repositorio.consultas, antes + 1);
        final agrupadas = contenedor
            .read(canchasAgrupadasProvider)
            .requireValue;
        expect(agrupadas.archivadas.map((c) => c.id), contains(cancha.id));
        expect(agrupadas.activas.map((c) => c.id), isNot(contains(cancha.id)));
      },
    );

    test('entre activas y archivadas están todas las canchas', () async {
      final todas = await lista();

      final agrupadas = contenedor.read(canchasAgrupadasProvider).requireValue;

      expect(
        agrupadas.activas.length + agrupadas.archivadas.length,
        todas.length,
      );
      expect(agrupadas.activas.every((c) => c.activa), isTrue);
      expect(agrupadas.archivadas.every((c) => !c.activa), isTrue);
    });
  });
}
