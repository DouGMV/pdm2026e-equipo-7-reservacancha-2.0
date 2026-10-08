import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/app.dart';
import 'package:reservacancha/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('la app arranca y muestra la pantalla de inicio de sesión', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Inicio de sesión'), findsOneWidget);
  });
}
