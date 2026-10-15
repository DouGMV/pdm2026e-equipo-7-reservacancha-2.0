import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/domain/cancha_repository.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_providers.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_screen.dart';

class _MockCanchaRepository extends Mock implements CanchaRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(<Cancha>[]);
  });

  testWidgets('muestra error con mensaje para humanos y botón Reintentar', (
    tester,
  ) async {
    final repo = _MockCanchaRepository();
    when(repo.obtenerCanchas).thenThrow(Exception('Sin conexión'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [canchaRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: CanchasScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Ocurrió un error al cargar las canchas.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(ElevatedButton, 'Reintentar'), findsOneWidget);

    verify(repo.obtenerCanchas).called(greaterThanOrEqualTo(1));
  });
}
