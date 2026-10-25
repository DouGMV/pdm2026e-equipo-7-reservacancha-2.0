import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:reservacancha/core/router/app_router.dart';
import 'package:reservacancha/core/router/inicio_shell.dart';
import 'package:reservacancha/features/admin/presentation/admin_canchas_screen.dart';
import 'package:reservacancha/features/admin/presentation/admin_reservas_screen.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_provider.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/domain/canchas_repository.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_screen.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_provider.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';
import 'package:reservacancha/features/reservas/domain/reservas_repository.dart';

class _CanchasFalsas extends Fake implements CanchasRepository {
  @override
  Future<List<Cancha>> obtenerCanchas({String? deporte}) async => [
    for (var i = 1; i <= 20; i++)
      Cancha(
        id: 'cancha-$i',
        nombre: 'Cancha $i',
        deporte: 'futbol',
        descripcion: '',
        ubicacion: '',
        precioPorHora: 100,
        imagenUrl: '',
        horaApertura: 7,
        horaCierre: 22,
        activa: true,
      ),
  ];
}

/// Sin reservas: así Mis reservas muestra el estado vacío con "Ver canchas".
class _ReservasFalsas extends Fake implements ReservasRepository {
  @override
  Future<List<Reserva>> obtenerMisReservas() async => const [];
}

Future<void> _mostrarApp(WidgetTester tester) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.canchas,
        builder: (context, state) => const InicioShell(),
      ),
      GoRoute(
        path: AppRoutes.adminCanchas,
        builder: (context, state) => const AdminCanchasScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminReservas,
        builder: (context, state) => const AdminReservasScreen(),
      ),
    ],
  );
  addTearDown(router.dispose);

  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        canchasRepositoryProvider.overrideWithValue(_CanchasFalsas()),
        reservasRepositoryProvider.overrideWithValue(_ReservasFalsas()),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

Future<void> _tocarPestana(WidgetTester tester, String etiqueta) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(etiqueta),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _titulo(String texto) =>
    find.descendant(of: find.byType(AppBar), matching: find.text(texto));

void main() {
  testWidgets('cada botón de la barra cambia de pantalla', (tester) async {
    await _mostrarApp(tester);
    await tester.pumpAndSettle();

    expect(_titulo('Canchas'), findsOneWidget);

    await _tocarPestana(tester, 'Mis reservas');
    expect(_titulo('Mis reservas'), findsOneWidget);
    expect(_titulo('Canchas'), findsNothing);

    await _tocarPestana(tester, 'Admin');
    expect(_titulo('Administración'), findsOneWidget);

    await _tocarPestana(tester, 'Perfil');
    expect(_titulo('Perfil'), findsOneWidget);
    expect(find.text('Próximamente'), findsOneWidget);

    await _tocarPestana(tester, 'Canchas');
    expect(_titulo('Canchas'), findsOneWidget);
  });

  testWidgets('al volver a una pestaña conserva su scroll', (tester) async {
    tester.view
      ..physicalSize = const Size(400, 600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _mostrarApp(tester);
    await tester.pumpAndSettle();

    // La lista vertical; los chips de filtro tienen su propio scroll horizontal.
    final listaCanchas = find.descendant(
      of: find.byType(CanchasScreen),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    await tester.drag(listaCanchas, const Offset(0, -300));
    await tester.pumpAndSettle();
    final antes = tester.state<ScrollableState>(listaCanchas).position.pixels;
    expect(antes, greaterThan(0));

    await _tocarPestana(tester, 'Mis reservas');
    await _tocarPestana(tester, 'Canchas');

    expect(tester.state<ScrollableState>(listaCanchas).position.pixels, antes);
  });

  testWidgets('"Ver canchas" en Mis reservas lleva a la pestaña Canchas', (
    tester,
  ) async {
    await _mostrarApp(tester);
    await tester.pumpAndSettle();

    await _tocarPestana(tester, 'Mis reservas');
    expect(find.text('Aún no tienes reservas.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Ver canchas'));
    await tester.pumpAndSettle();

    expect(_titulo('Canchas'), findsOneWidget);
    expect(_titulo('Mis reservas'), findsNothing);
  });

  testWidgets('la pestaña Admin abre Gestión de canchas y Reservas', (
    tester,
  ) async {
    await _mostrarApp(tester);
    await tester.pumpAndSettle();
    await _tocarPestana(tester, 'Admin');

    await tester.tap(find.text('Gestión de canchas'));
    await tester.pumpAndSettle();
    expect(find.byType(AdminCanchasScreen), findsOneWidget);

    GoRouter.of(tester.element(find.byType(AdminCanchasScreen))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reservas'));
    await tester.pumpAndSettle();
    expect(find.byType(AdminReservasScreen), findsOneWidget);
  });
}
