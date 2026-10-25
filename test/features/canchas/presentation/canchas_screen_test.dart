import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_provider.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/domain/canchas_repository.dart';
import 'package:reservacancha/features/canchas/presentation/cancha_card.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_screen.dart';

/// Repositorio falso que se puede hacer fallar, vaciar o volver lento.
class _CanchasRepositoryControlable implements CanchasRepository {
  bool fallar = false;
  List<Cancha> canchas = const [_cancha];
  Duration demora = Duration.zero;
  final List<String?> consultas = [];

  @override
  Future<List<Cancha>> obtenerCanchas({String? deporte}) async {
    consultas.add(deporte);
    await Future<void>.delayed(demora);
    if (fallar) {
      throw Exception('sin conexión');
    }
    return [
      for (final cancha in canchas)
        if (deporte == null || cancha.deporte == deporte) cancha,
    ];
  }

  @override
  Future<void> eliminar(String id) async {}

  @override
  Future<void> restaurar(Cancha cancha) async {}
}

const _cancha = Cancha(
  id: 'cancha-1',
  nombre: 'Cancha Sintética 1',
  deporte: 'futbol',
  descripcion: '',
  ubicacion: '',
  precioPorHora: 150,
  imagenUrl: '',
  horaApertura: 7,
  horaCierre: 22,
  activa: true,
);

const _polideportivo = Cancha(
  id: 'cancha-3',
  nombre: 'Polideportivo Los Altos',
  deporte: 'basquetbol',
  descripcion: '',
  ubicacion: '',
  precioPorHora: 120,
  imagenUrl: '',
  horaApertura: 8,
  horaCierre: 21,
  activa: true,
);

const _padel = Cancha(
  id: 'cancha-5',
  nombre: 'Pádel Club Mesoamericana',
  deporte: 'padel',
  descripcion: '',
  ubicacion: '',
  precioPorHora: 175,
  imagenUrl: '',
  horaApertura: 6,
  horaCierre: 22,
  activa: true,
);

/// Pantalla alta para que todas las tarjetas se construyan sin hacer scroll.
void _pantallaAlta(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(400, 1600)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Finder _enTarjeta(String texto) =>
    find.descendant(of: find.byType(CanchaCard), matching: find.text(texto));

Future<void> _tocarChip(WidgetTester tester, String deporte) async {
  // En un teléfono angosto los últimos chips quedan fuera de la pantalla.
  final chip = find.widgetWithText(ChoiceChip, deporte);
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

Future<void> _mostrarPantalla(
  WidgetTester tester,
  CanchasRepository repositorio,
) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [canchasRepositoryProvider.overrideWithValue(repositorio)],
      child: const MaterialApp(home: CanchasScreen()),
    ),
  );
}

void main() {
  late _CanchasRepositoryControlable repositorio;

  setUp(() => repositorio = _CanchasRepositoryControlable());

  testWidgets('con el repositorio lento muestra el indicador de carga', (
    tester,
  ) async {
    repositorio.demora = const Duration(seconds: 2);

    await _mostrarPantalla(tester, repositorio);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Cancha Sintética 1'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Cancha Sintética 1'), findsOneWidget);
  });

  testWidgets('error → Reintentar → datos', (tester) async {
    repositorio.fallar = true;

    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    expect(find.text('No pudimos cargar las canchas.'), findsOneWidget);
    expect(find.text('Cancha Sintética 1'), findsNothing);

    repositorio.fallar = false;
    await tester.tap(find.widgetWithText(FilledButton, 'Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('No pudimos cargar las canchas.'), findsNothing);
    expect(find.text('Cancha Sintética 1'), findsOneWidget);
    expect(_enTarjeta('Fútbol'), findsOneWidget);
    expect(find.text('Q150.00/h'), findsOneWidget);
  });

  testWidgets('al reintentar muestra el indicador de carga', (tester) async {
    repositorio.fallar = true;
    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    repositorio
      ..fallar = false
      ..demora = const Duration(seconds: 1);
    await tester.tap(find.widgetWithText(FilledButton, 'Reintentar'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No pudimos cargar las canchas.'), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Cancha Sintética 1'), findsOneWidget);
  });

  testWidgets('con la lista vacía muestra el estado vacío y Actualizar', (
    tester,
  ) async {
    repositorio.canchas = const [];

    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    expect(find.text('Aún no hay canchas disponibles.'), findsOneWidget);

    repositorio.canchas = const [_cancha];
    await tester.tap(find.widgetWithText(FilledButton, 'Actualizar'));
    await tester.pumpAndSettle();

    expect(find.text('Aún no hay canchas disponibles.'), findsNothing);
    expect(find.text('Cancha Sintética 1'), findsOneWidget);
  });

  testWidgets('la tarjeta muestra el icono del deporte si no hay foto', (
    tester,
  ) async {
    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    final tarjeta = find.byType(CanchaCard);
    expect(tarjeta, findsOneWidget);
    expect(
      find.descendant(of: tarjeta, matching: find.byIcon(Icons.sports_soccer)),
      findsOneWidget,
    );
    expect(_enTarjeta('Cancha Sintética 1'), findsOneWidget);
    expect(_enTarjeta('Fútbol'), findsOneWidget);
    expect(_enTarjeta('Q150.00/h'), findsOneWidget);
  });

  testWidgets('al cambiar el filtro la lista cambia sin recargar', (
    tester,
  ) async {
    _pantallaAlta(tester);
    repositorio.canchas = const [_cancha, _polideportivo, _padel];
    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    expect(find.byType(CanchaCard), findsNWidgets(3));

    await _tocarChip(tester, 'Pádel');

    expect(find.byType(CanchaCard), findsOneWidget);
    expect(find.text('Pádel Club Mesoamericana'), findsOneWidget);
    expect(find.text('Cancha Sintética 1'), findsNothing);

    await _tocarChip(tester, 'Todos');

    expect(find.byType(CanchaCard), findsNWidgets(3));
    // Cada cambio de filtro repitió la consulta, sin ningún botón.
    expect(repositorio.consultas, [null, 'padel', null]);
  });

  testWidgets('con un filtro sin resultados muestra el estado vacío', (
    tester,
  ) async {
    _pantallaAlta(tester);
    repositorio.canchas = const [_cancha, _polideportivo, _padel];
    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    await _tocarChip(tester, 'Voleibol');

    expect(find.text('No hay canchas de Voleibol.'), findsOneWidget);
    expect(find.byType(CanchaCard), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Ver todas'));
    await tester.pumpAndSettle();

    expect(find.text('No hay canchas de Voleibol.'), findsNothing);
    expect(find.byType(CanchaCard), findsNWidgets(3));
  });
}
