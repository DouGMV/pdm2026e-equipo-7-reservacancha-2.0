import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/app.dart';
import 'package:reservacancha/features/auth/data/auth_repository_fake.dart';
import 'package:reservacancha/features/auth/data/auth_repository_provider.dart';
import 'package:reservacancha/features/auth/domain/usuario.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_fake.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_provider.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_fake.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_provider.dart';
import 'package:reservacancha/features/reservas/domain/horarios.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';
import 'package:reservacancha/features/reservas/presentation/confirmar_reserva_screen.dart';
import 'package:reservacancha/features/reservas/presentation/mis_reservas_screen.dart';
import 'package:reservacancha/features/reservas/presentation/reservar_providers.dart';

const _ana = Usuario(
  uid: 'ana',
  nombre: 'Ana',
  email: 'ana@correo.com',
  telefono: '12345678',
  rol: RolUsuario.cliente,
);

/// Lunes 26 de octubre de 2026, 8:30.
final _ahora = DateTime(2026, 10, 26, 8, 30);

Reserva _reservaDeOtro(int hora) => Reserva(
  id: idReserva(canchaId: 'cancha-1', fecha: '2026-10-26', hora: hora),
  canchaId: 'cancha-1',
  canchaNombre: 'Cancha Sintética 1',
  usuarioId: 'beto',
  fecha: '2026-10-26',
  hora: hora,
  estado: EstadoReserva.confirmada,
  total: 150,
);

void main() {
  late ReservasRepositoryFake reservas;

  setUp(() {
    reservas = ReservasRepositoryFake(
      demora: Duration.zero,
      reservas: [_reservaDeOtro(10)],
      usuarioActual: () => _ana.uid,
    );
  });

  Future<void> abrirDetalle(WidgetTester tester) async {
    // Pantalla de teléfono (360 × 800): la tarjeta entra completa.
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWith((ref) {
            final repositorio = AuthRepositoryFake(
              demora: Duration.zero,
              sesionInicial: _ana,
            );
            ref.onDispose(repositorio.dispose);
            return repositorio;
          }),
          canchasRepositoryProvider.overrideWith(
            (ref) => CanchasRepositoryFake(demora: Duration.zero),
          ),
          reservasRepositoryProvider.overrideWithValue(reservas),
          relojProvider.overrideWithValue(() => _ahora),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancha Sintética 1'));
    await tester.pumpAndSettle();
  }

  ChoiceChip chip(WidgetTester tester, String texto) =>
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, texto));

  testWidgets('el detalle bloquea las horas pasadas y las ocupadas', (
    tester,
  ) async {
    await abrirDetalle(tester);

    expect(find.text('Hora · lunes 26 de octubre'), findsOneWidget);
    expect(chip(tester, '07:00').onSelected, isNull);
    expect(chip(tester, '08:00').onSelected, isNull);
    expect(chip(tester, '09:00').onSelected, isNotNull);
    expect(chip(tester, '10:00').onSelected, isNull);
    expect(find.text('Elige una hora'), findsOneWidget);
  });

  testWidgets('reservar lleva a Mis reservas con la reserva nueva', (
    tester,
  ) async {
    await abrirDetalle(tester);

    await tester.ensureVisible(find.widgetWithText(ChoiceChip, '18:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '18:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar · 18:00 – 19:00'));
    await tester.pumpAndSettle();

    expect(find.byType(ConfirmarReservaScreen), findsOneWidget);
    expect(find.text('Q150.00'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Confirmar reserva'));
    await tester.pumpAndSettle();

    expect(find.byType(MisReservasScreen), findsOneWidget);
    expect(find.text('¡Reserva confirmada!'), findsOneWidget);
    // El repositorio usa Future.delayed: fuera del reloj falso de la prueba.
    final mias = await tester.runAsync(reservas.obtenerMisReservas);
    expect(mias!.single.id, 'cancha-1_20261026_18');
  });

  testWidgets('si otra persona gana el horario avisa y vuelve al detalle', (
    tester,
  ) async {
    await abrirDetalle(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, '09:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar · 09:00 – 10:00'));
    await tester.pumpAndSettle();

    // Mientras Ana confirma, otra persona reserva la misma hora.
    await tester.runAsync(() => reservas.crearReserva(_reservaDeOtro(9)));
    await tester.tap(find.widgetWithText(FilledButton, 'Confirmar reserva'));
    await tester.pumpAndSettle();

    expect(find.text('Horario no disponible'), findsOneWidget);
    await tester.tap(find.text('Elegir otra hora'));
    await tester.pumpAndSettle();

    expect(find.byType(ConfirmarReservaScreen), findsNothing);
    expect(chip(tester, '09:00').onSelected, isNull);
    expect(find.text('Elige una hora'), findsOneWidget);
  });
}
