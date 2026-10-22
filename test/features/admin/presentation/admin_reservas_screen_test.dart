import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/features/admin/presentation/admin_reservas_screen.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_provider.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';
import 'package:reservacancha/features/reservas/domain/reservas_repository.dart';

/// Repositorio en memoria que registra las consultas y se puede hacer fallar.
class _ReservasEnMemoria extends Fake implements ReservasRepository {
  _ReservasEnMemoria(List<Reserva> iniciales) : reservas = [...iniciales];

  final List<Reserva> reservas;
  final List<EstadoReserva?> consultas = [];
  bool fallarConsulta = false;
  bool fallarEliminar = false;
  bool fallarRestaurar = false;

  @override
  Future<List<Reserva>> obtenerReservas({EstadoReserva? estado}) async {
    consultas.add(estado);
    if (fallarConsulta) throw Exception('sin conexión');
    return [
      for (final r in reservas)
        if (estado == null || r.estado == estado) r,
    ];
  }

  @override
  Future<void> eliminar(String id) async {
    if (fallarEliminar) throw Exception('sin permiso');
    reservas.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> restaurar(Reserva reserva) async {
    if (fallarRestaurar) throw Exception('sin conexión');
    reservas.add(reserva);
  }
}

const _sintetica = Reserva(
  id: 'cancha-1_20261020_18',
  canchaId: 'cancha-1',
  canchaNombre: 'Cancha Sintética 1',
  usuarioId: 'usuario-demo',
  fecha: '2026-10-20',
  hora: 18,
  estado: EstadoReserva.confirmada,
  total: 150,
);

const _padel = Reserva(
  id: 'cancha-5_20261022_7',
  canchaId: 'cancha-5',
  canchaNombre: 'Pádel Club Mesoamericana',
  usuarioId: 'usuario-ana',
  fecha: '2026-10-22',
  hora: 7,
  estado: EstadoReserva.confirmada,
  total: 175,
);

const _polideportivo = Reserva(
  id: 'cancha-3_20261012_19',
  canchaId: 'cancha-3',
  canchaNombre: 'Polideportivo Los Altos',
  usuarioId: 'usuario-luis',
  fecha: '2026-10-12',
  hora: 19,
  estado: EstadoReserva.cancelada,
  total: 120,
);

Future<void> _mostrarPantalla(
  WidgetTester tester,
  _ReservasEnMemoria repositorio,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [reservasRepositoryProvider.overrideWithValue(repositorio)],
      child: const MaterialApp(home: AdminReservasScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tocarChip(WidgetTester tester, String etiqueta) async {
  await tester.tap(find.widgetWithText(ChoiceChip, etiqueta));
  await tester.pumpAndSettle();
}

/// Espera la duración del SnackBar y comprueba que se cerró solo.
Future<void> _cerrarSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
  expect(find.byType(SnackBar), findsNothing);
}

Future<void> _deslizar(WidgetTester tester, String id) async {
  await tester.drag(find.byKey(ValueKey(id)), const Offset(-600, 0));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('al cambiar el filtro la lista se vuelve a consultar sola', (
    tester,
  ) async {
    final repositorio = _ReservasEnMemoria([
      _sintetica,
      _padel,
      _polideportivo,
    ]);
    await _mostrarPantalla(tester, repositorio);

    expect(find.text('Cancha Sintética 1'), findsOneWidget);
    expect(find.text('Pádel Club Mesoamericana'), findsOneWidget);
    expect(find.text('Polideportivo Los Altos'), findsOneWidget);

    await _tocarChip(tester, 'Canceladas');

    expect(find.text('Polideportivo Los Altos'), findsOneWidget);
    expect(find.text('Cancha Sintética 1'), findsNothing);
    expect(find.text('Pádel Club Mesoamericana'), findsNothing);

    await _tocarChip(tester, 'Confirmadas');

    expect(find.text('Cancha Sintética 1'), findsOneWidget);
    expect(find.text('Pádel Club Mesoamericana'), findsOneWidget);
    expect(find.text('Polideportivo Los Altos'), findsNothing);

    // Ningún botón de "recargar": cada cambio de filtro repitió la consulta.
    expect(repositorio.consultas, [
      null,
      EstadoReserva.cancelada,
      EstadoReserva.confirmada,
    ]);
  });

  testWidgets('con un filtro sin resultados muestra el estado vacío', (
    tester,
  ) async {
    final repositorio = _ReservasEnMemoria([_sintetica, _padel]);
    await _mostrarPantalla(tester, repositorio);

    await _tocarChip(tester, 'Canceladas');

    expect(find.text('No hay reservas canceladas.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Ver todas'));
    await tester.pumpAndSettle();

    expect(find.text('No hay reservas canceladas.'), findsNothing);
    expect(find.text('Cancha Sintética 1'), findsOneWidget);
  });

  testWidgets('deslizar elimina y Deshacer restaura la reserva idéntica', (
    tester,
  ) async {
    final repositorio = _ReservasEnMemoria([
      _sintetica,
      _padel,
      _polideportivo,
    ]);
    await _mostrarPantalla(tester, repositorio);

    await tester.drag(
      find.byKey(const ValueKey('cancha-5_20261022_7')),
      const Offset(-600, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pádel Club Mesoamericana'), findsNothing);
    expect(repositorio.reservas.map((r) => r.id), isNot(contains(_padel.id)));
    expect(
      find.text('Reserva de Pádel Club Mesoamericana eliminada'),
      findsOneWidget,
    );

    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();

    expect(find.text('Pádel Club Mesoamericana'), findsOneWidget);
    // Es el mismo registro: mismo id y mismos datos.
    final restaurada = repositorio.reservas.singleWhere(
      (r) => r.id == _padel.id,
    );
    expect(restaurada.usuarioId, _padel.usuarioId);
    expect(restaurada.fecha, _padel.fecha);
    expect(restaurada.hora, _padel.hora);
    expect(restaurada.total, _padel.total);
    expect(restaurada.estado, _padel.estado);

    await _cerrarSnackBar(tester);
  });

  testWidgets('si eliminar falla, la fila regresa a su lugar', (tester) async {
    final repositorio = _ReservasEnMemoria([_sintetica, _padel])
      ..fallarEliminar = true;
    await _mostrarPantalla(tester, repositorio);

    await tester.drag(
      find.byKey(const ValueKey('cancha-1_20261020_18')),
      const Offset(-600, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cancha Sintética 1'), findsOneWidget);
    expect(repositorio.reservas, hasLength(2));
    expect(find.text('No se pudo eliminar la reserva.'), findsOneWidget);

    await _cerrarSnackBar(tester);
  });

  testWidgets('el SnackBar de Deshacer se cierra solo', (tester) async {
    final repositorio = _ReservasEnMemoria([_sintetica, _padel]);
    await _mostrarPantalla(tester, repositorio);

    await _deslizar(tester, _sintetica.id);
    expect(
      find.text('Reserva de Cancha Sintética 1 eliminada'),
      findsOneWidget,
    );

    await _cerrarSnackBar(tester);
  });

  testWidgets('dos borrados seguidos: Deshacer restaura el último', (
    tester,
  ) async {
    final repositorio = _ReservasEnMemoria([
      _sintetica,
      _padel,
      _polideportivo,
    ]);
    await _mostrarPantalla(tester, repositorio);

    await _deslizar(tester, _sintetica.id);
    await _deslizar(tester, _padel.id);

    // El segundo mensaje reemplaza al primero en lugar de quedar en cola.
    expect(
      find.text('Reserva de Pádel Club Mesoamericana eliminada'),
      findsOneWidget,
    );
    expect(find.text('Reserva de Cancha Sintética 1 eliminada'), findsNothing);

    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();

    expect(find.text('Pádel Club Mesoamericana'), findsOneWidget);
    expect(find.text('Cancha Sintética 1'), findsNothing);
    expect(
      repositorio.reservas.map((r) => r.id),
      containsAll([_padel.id, _polideportivo.id]),
    );

    await _cerrarSnackBar(tester);
  });

  testWidgets('si restaurar falla, avisa y la reserva no vuelve', (
    tester,
  ) async {
    final repositorio = _ReservasEnMemoria([_sintetica, _padel])
      ..fallarRestaurar = true;
    await _mostrarPantalla(tester, repositorio);

    await _deslizar(tester, _sintetica.id);
    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo restaurar la reserva.'), findsOneWidget);
    expect(find.text('Cancha Sintética 1'), findsNothing);

    await _cerrarSnackBar(tester);
  });

  testWidgets('error al cargar → Reintentar → datos', (tester) async {
    final repositorio = _ReservasEnMemoria([_sintetica])..fallarConsulta = true;
    await _mostrarPantalla(tester, repositorio);

    expect(find.text('No pudimos cargar las reservas.'), findsOneWidget);

    repositorio.fallarConsulta = false;
    await tester.tap(find.widgetWithText(FilledButton, 'Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Cancha Sintética 1'), findsOneWidget);
  });
}
