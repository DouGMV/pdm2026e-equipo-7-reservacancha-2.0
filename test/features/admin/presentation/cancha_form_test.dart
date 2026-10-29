import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/core/errors/cancha_duplicada_exception.dart';
import 'package:reservacancha/features/admin/presentation/cancha_form.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';

const _polideportivo = Cancha(
  id: 'cancha-3',
  nombre: 'Polideportivo Los Altos',
  deporte: 'basquetbol',
  descripcion: 'Cancha techada de duela.',
  ubicacion: 'Zona 1, Quetzaltenango',
  precioPorHora: 120,
  imagenUrl: '',
  horaApertura: 8,
  horaCierre: 21,
  activa: true,
);

/// Sin providers: el formulario solo recibe la cancha y la función guardar.
Future<void> _mostrar(
  WidgetTester tester, {
  Cancha? inicial,
  required Future<void> Function(Cancha) alGuardar,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CanchaForm(inicial: inicial, alGuardar: alGuardar),
      ),
    ),
  );
}

Finder _campo(String texto) => find.widgetWithText(TextFormField, texto);

void main() {
  testWidgets('sin cancha inicial está vacío y el botón dice Crear', (
    tester,
  ) async {
    await _mostrar(tester, alGuardar: (_) async {});

    expect(find.widgetWithText(FilledButton, 'Crear'), findsOneWidget);
    expect(find.text('Guardar cambios'), findsNothing);
    expect(find.text('Polideportivo Los Altos'), findsNothing);
  });

  testWidgets('con una cancha muestra sus datos y guarda con el mismo id', (
    tester,
  ) async {
    Cancha? guardada;
    await _mostrar(
      tester,
      inicial: _polideportivo,
      alGuardar: (cancha) async => guardada = cancha,
    );

    expect(_campo('Polideportivo Los Altos'), findsOneWidget);
    expect(_campo('Zona 1, Quetzaltenango'), findsOneWidget);
    expect(_campo('120'), findsOneWidget);
    expect(find.text('Básquetbol'), findsOneWidget);

    await tester.enterText(_campo('Polideportivo Los Altos'), 'Polideportivo');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar cambios'));
    await tester.pumpAndSettle();

    expect(guardada, isNotNull);
    expect(guardada!.id, 'cancha-3');
    expect(guardada!.nombre, 'Polideportivo');
    expect(guardada!.ubicacion, 'Zona 1, Quetzaltenango');
    expect(guardada!.horaApertura, 8);
  });

  testWidgets('un nombre repetido se muestra bajo el campo Nombre', (
    tester,
  ) async {
    await _mostrar(
      tester,
      inicial: _polideportivo,
      alGuardar: (_) async => throw const CanchaDuplicadaException(),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Guardar cambios'));
    await tester.pumpAndSettle();

    expect(find.text('Ya existe una cancha con ese nombre.'), findsOneWidget);

    // Al escribir otro nombre, el mensaje desaparece.
    await tester.enterText(_campo('Polideportivo Los Altos'), 'Otro nombre');
    await tester.pump();
    expect(find.text('Ya existe una cancha con ese nombre.'), findsNothing);
  });

  testWidgets('cualquier otro error avisa sin salir del formulario', (
    tester,
  ) async {
    await _mostrar(
      tester,
      inicial: _polideportivo,
      alGuardar: (_) async => throw Exception('sin conexión'),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Guardar cambios'));
    await tester.pumpAndSettle();

    expect(
      find.text('No pudimos guardar la cancha. Intenta de nuevo.'),
      findsOneWidget,
    );
    expect(_campo('Polideportivo Los Altos'), findsOneWidget);
  });
}
