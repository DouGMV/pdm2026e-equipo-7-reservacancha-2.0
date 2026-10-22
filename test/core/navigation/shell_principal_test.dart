import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/app.dart';
import 'package:reservacancha/core/navigation/navegacion_provider.dart';
import 'package:reservacancha/core/router/app_router.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_provider.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/domain/canchas_repository.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_screen.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_provider.dart';
import 'package:reservacancha/features/reservas/domain/filtro_reservas.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';
import 'package:reservacancha/features/reservas/domain/reservas_repository.dart';

/// Repositorio de canchas sin demora, para que las pruebas no esperen.
class _CanchasRepo implements CanchasRepository {
  _CanchasRepo(this.canchas);

  final List<Cancha> canchas;

  @override
  Future<List<Cancha>> obtenerCanchas() async => canchas;
}

/// Repositorio de reservas sin demora, para que las pruebas no esperen.
class _ReservasRepo implements ReservasRepository {
  _ReservasRepo(this.reservas);

  final List<Reserva> reservas;

  @override
  Future<List<Reserva>> obtenerMisReservas({
    FiltroReservas filtro = const FiltroReservas(),
  }) async => [
    for (final reserva in reservas)
      if (filtro.incluye(reserva)) reserva,
  ];

  @override
  Future<void> eliminarReserva(String id) async {}

  @override
  Future<void> restaurarReserva(Reserva reserva) async {}
}

/// Arranca la app completa y entra a la barra principal.
Future<ProviderContainer> _arrancarApp(WidgetTester tester) async {
  final container = ProviderContainer(
    overrides: [
      canchasRepositoryProvider.overrideWithValue(_CanchasRepo(_canchas)),
      reservasRepositoryProvider.overrideWithValue(_ReservasRepo([_reserva])),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const App()),
  );
  await tester.pumpAndSettle();

  container.read(appRouterProvider).go(AppRoutes.inicio);
  await tester.pumpAndSettle();

  return container;
}

/// Botón de la barra principal con su texto.
Finder _destino(String etiqueta) => find.descendant(
  of: find.byType(NavigationBar),
  matching: find.text(etiqueta),
);

/// Posición del scroll de la lista de canchas.
double _scrollDeCanchas(WidgetTester tester) {
  final scrollable = find.descendant(
    of: find.byType(CanchasScreen),
    matching: find.byType(Scrollable),
  );
  return tester.state<ScrollableState>(scrollable).position.pixels;
}

void main() {
  testWidgets('cada botón de la barra cambia de pantalla', (tester) async {
    await _arrancarApp(tester);

    // Inicio
    expect(find.text('Te quedan este mes'), findsOneWidget);

    await tester.tap(_destino('Canchas'));
    await tester.pumpAndSettle();
    expect(find.text('Cancha Sintética 0'), findsOneWidget);
    expect(find.text('Te quedan este mes'), findsNothing);

    await tester.tap(_destino('Reservas'));
    await tester.pumpAndSettle();
    expect(find.text('Mis reservas'), findsOneWidget);
    expect(find.text('Reserva de prueba'), findsOneWidget);
    expect(find.text('Cancha Sintética 0'), findsNothing);

    await tester.tap(_destino('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Ana López'), findsOneWidget);
    expect(find.text('Mis reservas'), findsNothing);

    await tester.tap(_destino('Inicio'));
    await tester.pumpAndSettle();
    expect(find.text('Te quedan este mes'), findsOneWidget);
  });

  testWidgets('la barra marca la pestaña activa', (tester) async {
    await _arrancarApp(tester);

    NavigationBar barra() =>
        tester.widget<NavigationBar>(find.byType(NavigationBar));

    expect(barra().selectedIndex, Pestana.inicio.index);

    await tester.tap(_destino('Reservas'));
    await tester.pumpAndSettle();

    expect(barra().selectedIndex, Pestana.reservas.index);
  });

  testWidgets('«Ver todo» lleva a la pestaña del listado', (tester) async {
    final container = await _arrancarApp(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Ver todo'));
    await tester.pumpAndSettle();

    expect(container.read(navegacionProvider), Pestana.reservas);
    expect(find.text('Mis reservas'), findsOneWidget);
  });

  testWidgets('al volver a una pestaña conserva su scroll', (tester) async {
    await _arrancarApp(tester);

    await tester.tap(_destino('Canchas'));
    await tester.pumpAndSettle();

    await tester.drag(
      find.descendant(
        of: find.byType(CanchasScreen),
        matching: find.byType(Scrollable),
      ),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    final offset = _scrollDeCanchas(tester);
    expect(offset, greaterThan(0));

    await tester.tap(_destino('Inicio'));
    await tester.pumpAndSettle();

    await tester.tap(_destino('Canchas'));
    await tester.pumpAndSettle();

    expect(_scrollDeCanchas(tester), offset);
  });

  testWidgets('la sección que aún no existe muestra Próximamente', (
    tester,
  ) async {
    await _arrancarApp(tester);

    await tester.tap(_destino('Perfil'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Notificaciones'));
    await tester.pumpAndSettle();

    expect(find.text('Próximamente'), findsOneWidget);
    expect(
      find.text('Notificaciones estará disponible pronto.'),
      findsOneWidget,
    );
  });
}

const _reserva = Reserva(
  id: 'cancha-1_20261020_18',
  canchaId: 'cancha-1',
  canchaNombre: 'Reserva de prueba',
  usuarioId: 'usuario-demo',
  fecha: '2026-10-20',
  hora: 18,
  estado: EstadoReserva.confirmada,
  total: 150,
);

final List<Cancha> _canchas = List.generate(
  20,
  (indice) => Cancha(
    id: 'cancha-$indice',
    nombre: 'Cancha Sintética $indice',
    deporte: 'futbol',
    descripcion: '',
    ubicacion: '',
    precioPorHora: 150,
    imagenUrl: '',
    horaApertura: 7,
    horaCierre: 22,
    activa: true,
  ),
);
