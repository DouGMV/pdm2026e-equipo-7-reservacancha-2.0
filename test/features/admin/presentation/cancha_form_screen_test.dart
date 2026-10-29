import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/app.dart';
import 'package:reservacancha/core/errors/cancha_duplicada_exception.dart';
import 'package:reservacancha/core/router/app_router.dart';
import 'package:reservacancha/features/admin/presentation/admin_canchas_screen.dart';
import 'package:reservacancha/features/auth/data/auth_repository_fake.dart';
import 'package:reservacancha/features/auth/data/auth_repository_provider.dart';
import 'package:reservacancha/features/auth/domain/usuario.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_fake.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_provider.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_providers.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_fake.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_provider.dart';

const _admin = Usuario(
  uid: 'admin',
  nombre: 'Admin',
  email: 'admin@correo.com',
  telefono: '55550000',
  rol: RolUsuario.admin,
);

void main() {
  late CanchasRepositoryFake canchas;
  late ProviderContainer contenedor;

  setUp(() => canchas = CanchasRepositoryFake(demora: Duration.zero));

  /// Abre la app con sesión de admin directamente en [ruta].
  Future<void> abrir(WidgetTester tester, String ruta) async {
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
              sesionInicial: _admin,
            );
            ref.onDispose(repositorio.dispose);
            return repositorio;
          }),
          canchasRepositoryProvider.overrideWithValue(canchas),
          reservasRepositoryProvider.overrideWith(
            (ref) => ReservasRepositoryFake(demora: Duration.zero),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
    contenedor = ProviderScope.containerOf(tester.element(find.byType(App)));
    unawaited(contenedor.read(appRouterProvider).push(AppRoutes.adminCanchas));
    await tester.pumpAndSettle();
    if (ruta != AppRoutes.adminCanchas) {
      unawaited(contenedor.read(appRouterProvider).push(ruta));
      await tester.pumpAndSettle();
    }
  }

  Finder campo(String etiqueta) => find.widgetWithText(TextFormField, etiqueta);

  Future<List<String>> nombresEnRepositorio(WidgetTester tester) async {
    final lista = await tester.runAsync(canchas.obtenerCanchas);
    return [for (final c in lista!) c.nombre];
  }

  testWidgets('agregar valida los campos obligatorios', (tester) async {
    await abrir(tester, AppRoutes.nuevaCancha);

    await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
    await tester.pumpAndSettle();

    expect(find.text('Introduce el nombre'), findsOneWidget);
    expect(find.text('Elige el deporte'), findsOneWidget);
    expect(find.text('Introduce la ubicación'), findsOneWidget);
    expect(find.text('Introduce el precio por hora'), findsOneWidget);
  });

  testWidgets('agregar una cancha la guarda y vuelve al listado', (
    tester,
  ) async {
    await abrir(tester, AppRoutes.nuevaCancha);

    await tester.enterText(campo('Nombre'), 'Cancha Nueva');
    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Deporte'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pádel').last);
    await tester.pumpAndSettle();
    await tester.enterText(campo('Ubicación'), 'Zona 10');
    await tester.enterText(campo('Precio por hora'), '180');
    await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
    await tester.pumpAndSettle();

    expect(find.byType(AdminCanchasScreen), findsOneWidget);
    expect(find.text('«Cancha Nueva» creada'), findsOneWidget);
    // Aparece en la lista sin recargar a mano: el provider se invalidó.
    expect(find.text('Cancha Nueva'), findsOneWidget);
    expect(await nombresEnRepositorio(tester), contains('Cancha Nueva'));
  });

  testWidgets('editar carga los datos y guarda los cambios', (tester) async {
    await abrir(tester, AppRoutes.editarDe('cancha-3'));

    expect(find.text('Editar cancha'), findsOneWidget);
    expect(find.text('Polideportivo Los Altos'), findsOneWidget);

    await tester.enterText(campo('Polideportivo Los Altos'), 'Polideportivo');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar cambios'));
    await tester.pumpAndSettle();

    expect(find.text('«Polideportivo» actualizada'), findsOneWidget);
    final nombres = await nombresEnRepositorio(tester);
    expect(nombres, contains('Polideportivo'));
    expect(nombres, isNot(contains('Polideportivo Los Altos')));
  });

  testWidgets('desactivar una cancha la oculta del listado del cliente', (
    tester,
  ) async {
    await abrir(tester, AppRoutes.adminCanchas);

    final fila = find.widgetWithText(ListTile, 'Cancha Sintética 1');
    await tester.tap(find.descendant(of: fila, matching: find.byType(Switch)));
    await tester.pumpAndSettle();

    expect(find.text('Fútbol · Inactiva'), findsOneWidget);
    final delCliente = await tester.runAsync(
      () => contenedor.read(canchasProvider.future),
    );
    expect(
      delCliente!.map((c) => c.nombre),
      isNot(contains('Cancha Sintética 1')),
    );
  });

  testWidgets('sin canchas se pueden cargar las de ejemplo', (tester) async {
    final todas = await tester.runAsync(canchas.obtenerCanchas);
    for (final cancha in todas!) {
      await tester.runAsync(() => canchas.eliminar(cancha.id));
    }
    await abrir(tester, AppRoutes.adminCanchas);

    await tester.tap(find.text('Cargar canchas de ejemplo'));
    await tester.pumpAndSettle();

    expect(find.text('Canchas de ejemplo cargadas'), findsOneWidget);
    expect(find.text('Cancha Sintética 1'), findsOneWidget);
  });

  testWidgets('tocar una cancha abre el formulario lleno y Guardar cambios la '
      'actualiza con el mismo id', (tester) async {
    await abrir(tester, AppRoutes.adminCanchas);

    await tester.tap(find.widgetWithText(ListTile, 'Polideportivo Los Altos'));
    await tester.pumpAndSettle();

    // El formulario abre lleno con los datos de la cancha.
    expect(find.text('Editar cancha'), findsOneWidget);
    expect(campo('Polideportivo Los Altos'), findsOneWidget);
    expect(campo('Zona 1, Quetzaltenango'), findsOneWidget);
    expect(campo('120'), findsOneWidget);

    await tester.enterText(campo('Polideportivo Los Altos'), 'Polideportivo');
    await tester.enterText(campo('120'), '135');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar cambios'));
    await tester.pumpAndSettle();

    // De vuelta en la lista, con el dato nuevo y sin recargar a mano.
    expect(find.byType(AdminCanchasScreen), findsOneWidget);
    expect(find.text('Polideportivo'), findsOneWidget);
    expect(find.text('Polideportivo Los Altos'), findsNothing);

    // Es el mismo documento: el id no cambió.
    final editada = await tester.runAsync(
      () => canchas.obtenerCancha('cancha-3'),
    );
    expect(editada!.nombre, 'Polideportivo');
    expect(editada.precioPorHora, 135);
    final todas = await tester.runAsync(canchas.obtenerCanchas);
    expect(todas!.where((c) => c.nombre == 'Polideportivo'), hasLength(1));
  });

  testWidgets('crear con un nombre repetido muestra un mensaje humano', (
    tester,
  ) async {
    canchas = _CanchasConNombreUnico();
    await abrir(tester, AppRoutes.nuevaCancha);

    await tester.enterText(campo('Nombre'), '  cancha SINTETICA 1 ');
    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Deporte'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fútbol').last);
    await tester.pumpAndSettle();
    await tester.enterText(campo('Ubicación'), 'Zona 3');
    await tester.enterText(campo('Precio por hora'), '150');
    await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
    await tester.pumpAndSettle();

    // Sigue en el formulario, con el mensaje bajo el nombre.
    expect(find.text('Nueva cancha'), findsOneWidget);
    expect(find.text('Ya existe una cancha con ese nombre'), findsOneWidget);
    final todas = await tester.runAsync(canchas.obtenerCanchas);
    expect(todas, hasLength(5));
  });
}

/// Hasta que el repositorio tenga la regla del nombre único (#64), esta
/// prueba la simula comparando sin mayúsculas, espacios ni tildes.
class _CanchasConNombreUnico extends CanchasRepositoryFake {
  _CanchasConNombreUnico() : super(demora: Duration.zero);

  static String _normalizar(String nombre) => nombre
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');

  @override
  Future<String> crear(Cancha cancha) async {
    final existentes = await obtenerCanchas();
    if (existentes.any(
      (c) => _normalizar(c.nombre) == _normalizar(cancha.nombre),
    )) {
      throw const CanchaDuplicadaException();
    }
    return super.crear(cancha);
  }
}
