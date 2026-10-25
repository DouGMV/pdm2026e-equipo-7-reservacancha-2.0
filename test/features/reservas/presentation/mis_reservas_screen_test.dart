import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/core/router/navegacion_provider.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_provider.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';
import 'package:reservacancha/features/reservas/domain/reservas_repository.dart';
import 'package:reservacancha/features/reservas/presentation/mis_reservas_screen.dart';

/// Repositorio falso que se puede hacer fallar, vaciar o volver lento.
class _ReservasRepositoryControlable extends Fake
    implements ReservasRepository {
  bool fallar = false;
  List<Reserva> reservas = const [_reserva];
  Duration demora = Duration.zero;
  int llamadas = 0;
  int cancelarLlamadas = 0;
  String? ultimoIdCancelado;

  @override
  Future<List<Reserva>> obtenerMisReservas() async {
    llamadas++;
    await Future<void>.delayed(demora);
    if (fallar) {
      throw Exception('sin conexión');
    }
    return reservas;
  }

  @override
  Future<void> cancelar(String id) async {
    cancelarLlamadas++;
    ultimoIdCancelado = id;
    await Future<void>.delayed(demora);
    if (fallar) {
      throw Exception('error');
    }
    final index = reservas.indexWhere((r) => r.id == id);
    if (index != -1) {
      final r = reservas[index];
      reservas = [
        for (final e in reservas)
          if (e.id == id)
            Reserva(
              id: e.id,
              canchaId: e.canchaId,
              canchaNombre: e.canchaNombre,
              usuarioId: e.usuarioId,
              fecha: e.fecha,
              hora: e.hora,
              estado: EstadoReserva.cancelada,
              total: e.total,
            )
          else
            e,
      ];
    }
  }

  @override
  Future<List<Reserva>> obtenerReservas({EstadoReserva? estado}) async {
    await Future<void>.delayed(demora);
    if (fallar) {
      throw Exception('sin conexión');
    }
    if (estado == null) {
      return reservas;
    }
    return reservas.where((r) => r.estado == estado).toList();
  }

  @override
  Future<void> eliminar(String id) async {
    await Future<void>.delayed(demora);
    if (fallar) {
      throw Exception('error');
    }
    reservas = reservas.where((r) => r.id != id).toList();
  }

  @override
  Future<void> restaurar(Reserva reserva) async {
    await Future<void>.delayed(demora);
    if (fallar) {
      throw Exception('error');
    }
    reservas = [...reservas.where((r) => r.id != reserva.id), reserva];
  }
}

const _reserva = Reserva(
  id: 'cancha-1_20261020_18',
  canchaId: 'cancha-1',
  canchaNombre: 'Cancha Sintética 1',
  usuarioId: 'usuario-demo',
  fecha: '2026-10-20',
  hora: 18,
  estado: EstadoReserva.confirmada,
  total: 150,
);

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
    repositorio.fallar = true;

    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    expect(find.text('No pudimos cargar tus reservas.'), findsOneWidget);
    expect(find.text('Cancha Sintética 1'), findsNothing);

    repositorio.fallar = false;
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
    repositorio.fallar = true;
    await _mostrarPantalla(tester, repositorio);
    // pump en lugar de pumpAndSettle: pumpAndSettle adelanta el reloj mientras
    // haya animaciones y dejaría correr todos los reintentos automáticos.
    // 100 ms es menos que el primer reintento por defecto de Riverpod (200 ms).
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('No pudimos cargar tus reservas.'), findsOneWidget);

    // El repositorio ya respondería bien, pero nadie ha tocado Reintentar.
    repositorio.fallar = false;
    await tester.pump(const Duration(seconds: 10));

    expect(find.text('No pudimos cargar tus reservas.'), findsOneWidget);
    expect(find.text('Cancha Sintética 1'), findsNothing);
    expect(repositorio.llamadas, 1);
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

    final contenedor = ProviderScope.containerOf(
      tester.element(find.byType(MisReservasScreen)),
    );
    contenedor.read(navegacionProvider.notifier).ir(Pestana.misReservas);

    await tester.tap(find.widgetWithText(FilledButton, 'Ver canchas'));
    await tester.pump();

    expect(contenedor.read(navegacionProvider), Pestana.canchas);
  });

  testWidgets('distingue las reservas canceladas', (tester) async {
    repositorio.reservas = const [
      Reserva(
        id: 'cancha-3_20261012_19',
        canchaId: 'cancha-3',
        canchaNombre: 'Polideportivo Los Altos',
        usuarioId: 'usuario-demo',
        fecha: '2026-10-12',
        hora: 19,
        estado: EstadoReserva.cancelada,
        total: 120,
      ),
    ];

    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    expect(find.text('Cancelada'), findsOneWidget);
    expect(find.text('Confirmada'), findsNothing);
  });

  testWidgets('muestra botón Cancelar para reservas confirmadas futuras', (
    tester,
  ) async {
    repositorio.reservas = const [
      Reserva(
        id: 'cancha-1_20991231_18',
        canchaId: 'cancha-1',
        canchaNombre: 'Cancha Sintética 1',
        usuarioId: 'usuario-demo',
        fecha: '2099-12-31',
        hora: 18,
        estado: EstadoReserva.confirmada,
        total: 150,
      ),
    ];

    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    expect(find.text('Cancelar'), findsOneWidget);
  });

  testWidgets(
    'cancelar reserva: confirma, llama repositorio y actualiza estado',
    (tester) async {
      repositorio.reservas = [
        Reserva(
          id: 'cancha-1_20991231_18',
          canchaId: 'cancha-1',
          canchaNombre: 'Cancha Sintética 1',
          usuarioId: 'usuario-demo',
          fecha: '2099-12-31',
          hora: 18,
          estado: EstadoReserva.confirmada,
          total: 150,
        ),
      ];

      await _mostrarPantalla(tester, repositorio);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(
        find.text('¿Seguro que deseas cancelar esta reserva?'),
        findsOneWidget,
      );
      await tester.tap(find.text('Sí'));
      await tester.pumpAndSettle();

      expect(repositorio.cancelarLlamadas, 1);
      expect(repositorio.ultimoIdCancelado, 'cancha-1_20991231_18');
      expect(find.text('Cancelada'), findsOneWidget);
      expect(find.text('Cancelar'), findsNothing);
    },
  );

  testWidgets('cancelar reserva: cancelar diálogo no llama repositorio', (
    tester,
  ) async {
    repositorio.reservas = [
      Reserva(
        id: 'cancha-1_20991231_18',
        canchaId: 'cancha-1',
        canchaNombre: 'Cancha Sintética 1',
        usuarioId: 'usuario-demo',
        fecha: '2099-12-31',
        hora: 18,
        estado: EstadoReserva.confirmada,
        total: 150,
      ),
    ];

    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();

    expect(repositorio.cancelarLlamadas, 0);
    expect(find.text('Confirmada'), findsOneWidget);
  });

  testWidgets('cancelar reserva: error muestra mensaje en español', (
    tester,
  ) async {
    repositorio.reservas = [
      Reserva(
        id: 'cancha-1_20991231_18',
        canchaId: 'cancha-1',
        canchaNombre: 'Cancha Sintética 1',
        usuarioId: 'usuario-demo',
        fecha: '2099-12-31',
        hora: 18,
        estado: EstadoReserva.confirmada,
        total: 150,
      ),
    ];

    await _mostrarPantalla(tester, repositorio);
    await tester.pumpAndSettle();

    repositorio.fallar = true;
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sí'));
    await tester.pumpAndSettle();

    expect(
      find.text('No pudimos cancelar la reserva. Inténtalo de nuevo.'),
      findsOneWidget,
    );
  });
}
