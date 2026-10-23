import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/core/theme/app_theme.dart';

void main() {
  group('AppTheme.light', () {
    test('usa Material 3', () {
      expect(AppTheme.light.useMaterial3, isTrue);
    });

    test('usa el color semilla verde deportivo', () {
      expect(
        AppTheme.light.colorScheme.primary,
        ColorScheme.fromSeed(seedColor: AppTheme.semilla).primary,
      );
    });

    test('el AppBar centra el título', () {
      expect(AppTheme.light.appBarTheme.centerTitle, isTrue);
    });
  });

  testWidgets('dos FilledButton en un Row no fuerzan ancho infinito', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Row(
            children: [
              FilledButton(onPressed: null, child: Text('Primario')),
              FilledButton(onPressed: null, child: Text('Secundario')),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final sizePrimario = tester.getSize(
      find.widgetWithText(FilledButton, 'Primario'),
    );
    expect(sizePrimario.isFinite, isTrue);
  });
}
