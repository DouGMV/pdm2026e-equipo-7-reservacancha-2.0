import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/core/errors/cancha_duplicada_exception.dart';
import 'package:reservacancha/core/errors/cancha_en_uso_exception.dart';
import 'package:reservacancha/features/canchas/data/canchas_de_ejemplo.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_fake.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_firestore.dart';
import 'package:reservacancha/features/canchas/domain/canchas_repository.dart';

import '../../../helpers/cancha_con_nombre.dart';

void main() {
  for (final usarFirestore in [false, true]) {
    group(usarFirestore ? 'Firestore' : 'memoria', () {
      late CanchasRepository repositorio;
      late FakeFirebaseFirestore firestore;
      var reservas = 0;
      final base = canchasDeEjemplo.first.conNombre(nombre: 'Cancha Sintética');
      late String id;

      setUp(() async {
        reservas = 0;
        firestore = FakeFirebaseFirestore();
        repositorio = usarFirestore
            ? CanchasRepositoryFirestore(firestore)
            : CanchasRepositoryFake(
                demora: Duration.zero,
                contarReservas: (canchaId) async =>
                    canchaId == id ? reservas : 0,
              );
        id = await repositorio.crear(base);
      });

      test(
        'crear rechaza nombre normalizado repetido incluso con otro id',
        () async {
          await expectLater(
            repositorio.crear(
              base.conNombre(id: 'otro', nombre: '  CANCHA   sintetica  '),
            ),
            throwsA(isA<CanchaDuplicadaException>()),
          );
        },
      );

      test(
        'editar rechaza nombre de otra cancha sin modificar datos',
        () async {
          final otroId = await repositorio.crear(
            base.conNombre(nombre: 'Otra'),
          );
          await expectLater(
            repositorio.actualizar(base.copyWith(id: otroId)),
            throwsA(isA<CanchaDuplicadaException>()),
          );
          expect((await repositorio.obtenerCancha(otroId))!.nombre, 'Otra');
        },
      );

      test('editar permite conservar su nombre normalizado', () async {
        await repositorio.actualizar(
          base.conNombre(id: id, nombre: 'CANCHA SINTETICA', activa: false),
        );
        expect((await repositorio.obtenerCancha(id))!.activa, isFalse);
      });

      test(
        'borrar cuenta reservas de cualquier estado y conserva la cancha',
        () async {
          reservas = 2;
          for (final estado in ['confirmada', 'cancelada']) {
            await firestore.collection('reservas').add({
              'canchaId': id,
              'estado': estado,
            });
          }
          await firestore.collection('reservas').add({
            'canchaId': 'otra',
            'estado': 'confirmada',
          });
          await expectLater(
            repositorio.eliminar(id),
            throwsA(
              isA<CanchaEnUsoException>().having(
                (e) => e.reservas,
                'reservas',
                2,
              ),
            ),
          );
          expect(await repositorio.obtenerCancha(id), isNotNull);
        },
      );

      test('borrar sin reservas permite deshacer aunque se haya reutilizado el nombre', () async {
        await repositorio.eliminar(id);
        expect(await repositorio.obtenerCancha(id), isNull);
        await repositorio.crear(base);
        await repositorio.restaurar(base.copyWith(id: id));
        await repositorio.restaurar(base.copyWith(id: id));
        expect((await repositorio.obtenerCancha(id))!.nombre, base.nombre);
      });
    });
  }

  test('excepciones ofrecen mensajes en español', () {
    expect(
      const CanchaDuplicadaException().toString(),
      'Ya existe una cancha con ese nombre',
    );
    expect(
      const CanchaEnUsoException(2).toString(),
      'Tiene 2 reservas. Desactívala para dejar de mostrarla.',
    );
    expect(
      const CanchaEnUsoException(1).toString(),
      'Tiene 1 reservas. Desactívala para dejar de mostrarla.',
    );
  });
}
