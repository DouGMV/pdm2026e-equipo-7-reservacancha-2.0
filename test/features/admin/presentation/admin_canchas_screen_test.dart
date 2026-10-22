import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/features/admin/presentation/admin_canchas_screen.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_provider.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/domain/canchas_repository.dart';

/// Repositorio en memoria que se puede hacer fallar al eliminar.
class _CanchasRepositoryEnMemoria implements CanchasRepository {
  _CanchasRepositoryEnMemoria(List<Cancha> iniciales)
    : canchas = [...iniciales];

  final List<Cancha> canchas;
  bool fallarAlEliminar = false;

  @override
  Future<List<Cancha>> obtenerCanchas({String? deporte}) async => [
    for (final cancha in canchas)
      if (deporte == null || cancha.deporte == deporte) cancha,
  ];

  @override
  Future<void> eliminar(String id) async {
    if (fallarAlEliminar) throw Exception('sin conexión');
    canchas.removeWhere((cancha) => cancha.id == id);
  }

  @override
  Future<void> restaurar(Cancha cancha) async => canchas.add(cancha);
}

Cancha _cancha(String id, String nombre, String deporte) => Cancha(
  id: id,
  nombre: nombre,
  deporte: deporte,
  descripcion: '',
  ubicacion: '',
  precioPorHora: 150,
  imagenUrl: '',
  horaApertura: 7,
  horaCierre: 22,
  activa: true,
);

final _sintetica = _cancha('c1', 'Cancha Sintética 1', 'futbol');
final _polideportivo = _cancha('c2', 'Polideportivo Los Altos', 'basquetbol');
final _padel = _cancha('c3', 'Pádel Club', 'padel');

Future<void> _mostrarPantalla(
  WidgetTester tester,
  CanchasRepository repositorio,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [canchasRepositoryProvider.overrideWithValue(repositorio)],
      child: const MaterialApp(home: AdminCanchasScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late _CanchasRepositoryEnMemoria repositorio;

  setUp(
    () => repositorio = _CanchasRepositoryEnMemoria([
      _sintetica,
      _polideportivo,
      _padel,
    ]),
  );

  testWidgets('al cambiar el filtro la lista cambia sin recargar', (
    tester,
  ) async {
    await _mostrarPantalla(tester, repositorio);

    expect(find.text('Cancha Sintética 1'), findsOneWidget);
    expect(find.text('Polideportivo Los Altos'), findsOneWidget);
    expect(find.text('Pádel Club'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Pádel'));
    await tester.pumpAndSettle();

    expect(find.text('Pádel Club'), findsOneWidget);
    expect(find.text('Cancha Sintética 1'), findsNothing);
    expect(find.text('Polideportivo Los Altos'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Todos'));
    await tester.pumpAndSettle();

    expect(find.text('Cancha Sintética 1'), findsOneWidget);
    expect(find.text('Pádel Club'), findsOneWidget);
  });

  testWidgets('con un filtro sin resultados muestra el estado vacío', (
    tester,
  ) async {
    await _mostrarPantalla(tester, repositorio);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Voleibol'));
    await tester.pumpAndSettle();

    expect(find.text('No hay canchas de Voleibol.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Ver todas'));
    await tester.pumpAndSettle();

    expect(find.text('No hay canchas de Voleibol.'), findsNothing);
    expect(find.text('Cancha Sintética 1'), findsOneWidget);
  });

  testWidgets('deslizar borra la cancha y Deshacer la regresa idéntica', (
    tester,
  ) async {
    await _mostrarPantalla(tester, repositorio);

    await tester.drag(find.byKey(const ValueKey('c2')), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Polideportivo Los Altos'), findsNothing);
    expect(repositorio.canchas.map((c) => c.id), isNot(contains('c2')));
    expect(find.text('«Polideportivo Los Altos» eliminada'), findsOneWidget);

    await tester.tap(find.widgetWithText(SnackBarAction, 'Deshacer'));
    await tester.pumpAndSettle();

    expect(find.text('Polideportivo Los Altos'), findsOneWidget);
    final restaurada = repositorio.canchas.singleWhere((c) => c.id == 'c2');
    expect(identical(restaurada, _polideportivo), isTrue);
  });

  testWidgets('si eliminar falla, la fila vuelve y se avisa', (tester) async {
    repositorio.fallarAlEliminar = true;
    await _mostrarPantalla(tester, repositorio);

    await tester.drag(find.byKey(const ValueKey('c1')), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Cancha Sintética 1'), findsOneWidget);
    expect(repositorio.canchas, hasLength(3));
    expect(
      find.text('No pudimos eliminar «Cancha Sintética 1».'),
      findsOneWidget,
    );
  });
}
