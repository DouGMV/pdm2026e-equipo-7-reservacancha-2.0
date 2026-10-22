import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/core/navigation/navegacion_provider.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_provider.dart';
import 'package:reservacancha/features/reservas/domain/filtro_reservas.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';
import 'package:reservacancha/features/reservas/domain/reservas_repository.dart';
import 'package:reservacancha/features/reservas/presentation/mis_reservas_screen.dart';

/// Repositorio falso que se puede hacer fallar, vaciar o volver lento.
class _ReservasRepositoryControlable implements ReservasRepository {
  List<Reserva> reservas = const [_confirmada, _cancelada];
  bool fallarAlLeer = false;
  bool fallarAlBorrar = false;
  bool fallarAlRestaurar = false;
  Duration demora = Duration.zero;
  int llamadas = 0;
  final List<FiltroReservas> filtrosPedidos = [];

  @override
  Future<List<Reserva>> obtenerMisReservas({
    FiltroReservas filtro = const FiltroReservas(),
  }) async {
    llamadas++;
    filtrosPedidos.add(filtro);
    await Future<void>.delayed(demora);
    if (fallarAlLeer) {
      throw Exception('sin conexión');
    }
    return [
      for (final reserva in reservas)
        if (filtro.incluye(reserva)) reserva,
    ]..sort(reservaMasRecientePrimero);
  }

  @override
  Future<void> eliminarReserva(String id) async {
    await Future<void>.delayed(demora);
    if (fallarAlBorrar) {
      throw Exception('sin conexión');
    }
    reservas = [
      for (final reserva in reservas)
        if (reserva.id != id) reserva,
    ];
  }

  @override
  Future<void> restaurarReserva(Reserva reserva) async {
    await Future<void>.delayed(demora);
    if (fallarAlRestaurar) {
      throw Exception('sin conexión');
    }
    if (reservas.any((actual) => actual.id == reserva.id)) {
      return;
    }
    reservas = [...reservas, reserva];
  }
}

const _confirmada = Reserva(
  id: 'cancha-1_20261020_18',
  canchaId: 'cancha-1',
  canchaNombre: 'Cancha Sintética 1',
  usuarioId: 'usuario-demo',
  fecha: '2026-10-20',
  hora: 18,
  estado: EstadoReserva.confirmada,
  total: 150,
);

const _cancelada = Reserva(
  id: 'cancha-3_20261012_19',
  canchaId: 'cancha-3',
  canchaNombre: 'Polideportivo Los Altos',
  usuarioId: 'usuario-demo',
  fecha: '2026-10-12',
  hora: 19,
  estado: EstadoReserva.cancelada,
  total: 120,
);

const _noviembre = Reserva(
  id: 'cancha-5_20261105_7',
  canchaId: 'cancha-5',
  canchaNombre: 'Pádel Club Mesoamericana',
  usuarioId: 'usuario-demo',
  fecha: '2026-11-05',
  hora: 7,
  estado: EstadoReserva.confirmada,
  total: 175,
);

/// Monta la pantalla con un repositorio simulado.
Future<void> _mostrarPantalla(
  WidgetTester tester,
  ReservasRepository repositorio,
) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [reservasRepositoryProvider.overrideWithValue(repositorio)],
      child: const MaterialApp(home: MisReservasScreen()),
    ),
  );
}

Finder _chip(String etiqueta) => find.widgetWithText(ChoiceChip, etiqueta);

/// Desliza la fila y espera a que termine el borrado. `confirmDismiss` espera
/// al repositorio sin programar cuadros, así que `pumpAndSettle` solo no
/// alcanza: hay que avanzar el reloj a mano.
Future<void> _deslizarParaBorrar(WidgetTester tester, String texto) async {
  await tester.drag(find.text(texto), const Offset(-600, 0));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}

void main() {
  late _ReservasRepositoryControlable repositorio;

  setUp(() => repositorio = _ReservasRepositoryControlable());

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
    repositorio.fallarAlLeer = true;

    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    expect(find.text('No pudimos cargar tus reservas.'), findsOneWidget);
    expect(find.text('Cancha Sintética 1'), findsNothing);

    repositorio.fallarAlLeer = false;
    await tester.tap(find.widgetWithText(FilledButton, 'Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('No pudimos cargar tus reservas.'), findsNothing);
    expect(find.text('Cancha Sintética 1'), findsOneWidget);
    expect(find.text('2026-10-20 · 18:00'), findsOneWidget);
    expect(find.text('Q150.00'), findsOneWidget);
    expect(find.text('Confirmada'), findsOneWidget);
  });

  testWidgets('sin reintento automático: el error se queda hasta tocar '
      'Reintentar', (tester) async {
    repositorio.fallarAlLeer = true;
    await _mostrarPantalla(tester, repositorio);
    // pump en lugar de pumpAndSettle: pumpAndSettle adelanta el reloj mientras
    // haya animaciones y dejaría correr todos los reintentos automáticos.
    // 100 ms es menos que el primer reintento por defecto de Riverpod (200 ms).
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('No pudimos cargar tus reservas.'), findsOneWidget);
    final llamadasAlFallar = repositorio.llamadas;

    // El repositorio ya respondería bien, pero nadie ha tocado Reintentar.
    repositorio.fallarAlLeer = false;
    await tester.pump(const Duration(seconds: 10));

    expect(find.text('No pudimos cargar tus reservas.'), findsOneWidget);
    expect(find.text('Cancha Sintética 1'), findsNothing);
    expect(repositorio.llamadas, llamadasAlFallar);
  });

  testWidgets('al reintentar muestra el indicador de carga', (tester) async {
    repositorio.fallarAlLeer = true;
    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    repositorio
      ..fallarAlLeer = false
      ..demora = const Duration(seconds: 1);
    await tester.tap(find.widgetWithText(FilledButton, 'Reintentar'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No pudimos cargar tus reservas.'), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Cancha Sintética 1'), findsOneWidget);
  });

  testWidgets('con la lista vacía muestra el estado vacío y Ver canchas', (
    tester,
  ) async {
    repositorio.reservas = const [];

    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    expect(find.text('Aún no tienes reservas.'), findsOneWidget);

    // "Ver canchas" no navega con una ruta: cambia el provider de navegación.
    await tester.tap(find.widgetWithText(FilledButton, 'Ver canchas'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MisReservasScreen)),
    );
    expect(container.read(navegacionProvider), Pestana.canchas);
  });

  testWidgets('distingue las reservas canceladas', (tester) async {
    repositorio.reservas = const [_cancelada];

    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    expect(find.text('Cancelada'), findsOneWidget);
    expect(find.text('Confirmada'), findsNothing);
  });

  testWidgets('al cambiar el filtro de estado la lista cambia', (tester) async {
    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    expect(find.text('Cancha Sintética 1'), findsOneWidget);
    expect(find.text('Polideportivo Los Altos'), findsOneWidget);

    await tester.tap(_chip('Canceladas'));
    await tester.pumpAndSettle();

    expect(find.text('Cancha Sintética 1'), findsNothing);
    expect(find.text('Polideportivo Los Altos'), findsOneWidget);
    expect(
      repositorio.filtrosPedidos.last.estado,
      EstadoFiltroReserva.canceladas,
    );

    await tester.tap(_chip('Todas'));
    await tester.pumpAndSettle();

    expect(find.text('Cancha Sintética 1'), findsOneWidget);
  });

  testWidgets('combina estado y mes y ofrece limpiar el filtro', (
    tester,
  ) async {
    repositorio.reservas = const [_confirmada, _cancelada, _noviembre];

    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    await tester.tap(_chip('Canceladas'));
    await tester.pumpAndSettle();
    await tester.tap(_chip('Noviembre 2026'));
    await tester.pumpAndSettle();

    expect(find.text('No hay reservas con este filtro.'), findsOneWidget);
    expect(repositorio.filtrosPedidos.last.mes, '2026-11');

    await tester.tap(find.widgetWithText(FilledButton, 'Limpiar filtros'));
    await tester.pumpAndSettle();

    expect(find.text('Cancha Sintética 1'), findsOneWidget);
    expect(find.text('Polideportivo Los Altos'), findsOneWidget);
    expect(find.text('Pádel Club Mesoamericana'), findsOneWidget);
  });

  testWidgets('deslizar borra y Deshacer restaura con el mismo id', (
    tester,
  ) async {
    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    await _deslizarParaBorrar(tester, 'Cancha Sintética 1');

    expect(find.text('Cancha Sintética 1'), findsNothing);
    expect(
      repositorio.reservas.map((reserva) => reserva.id),
      isNot(contains('cancha-1_20261020_18')),
    );
    expect(find.text('Deshacer'), findsOneWidget);

    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();

    expect(find.text('Cancha Sintética 1'), findsOneWidget);
    expect(
      repositorio.reservas.map((reserva) => reserva.id),
      contains('cancha-1_20261020_18'),
    );
  });

  testWidgets('si el borrado falla la fila vuelve y avisa', (tester) async {
    repositorio.fallarAlBorrar = true;

    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    await _deslizarParaBorrar(tester, 'Cancha Sintética 1');

    expect(find.text('Cancha Sintética 1'), findsOneWidget);
    expect(
      find.text('No se pudo eliminar la reserva. Intenta de nuevo.'),
      findsOneWidget,
    );
    expect(repositorio.reservas, hasLength(2));
    expect(find.text('Deshacer'), findsNothing);
  });

  testWidgets('si restaurar falla avisa que no se pudo', (tester) async {
    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    await _deslizarParaBorrar(tester, 'Cancha Sintética 1');

    repositorio.fallarAlRestaurar = true;
    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo restaurar la reserva.'), findsOneWidget);
    expect(find.text('Cancha Sintética 1'), findsNothing);
  });
}
