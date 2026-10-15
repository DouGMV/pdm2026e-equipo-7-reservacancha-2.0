import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_provider.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/domain/canchas_repository.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_screen.dart';

/// Repositorio falso que se puede hacer fallar, vaciar o volver lento.
class _CanchasRepositoryControlable implements CanchasRepository {
  bool fallar = false;
  List<Cancha> canchas = const [_cancha];
  Duration demora = Duration.zero;

  @override
  Future<List<Cancha>> obtenerCanchas() async {
    await Future<void>.delayed(demora);
    if (fallar) {
      throw Exception('sin conexión');
    }
    return canchas;
  }
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
    expect(find.text('Fútbol'), findsOneWidget);
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
}
