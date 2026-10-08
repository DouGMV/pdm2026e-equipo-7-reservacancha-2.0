import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/core/theme/app_theme.dart';

void main() {
  group('AppTheme.light', () {
    test('usa Material 3', () {
      expect(AppTheme.light.useMaterial3, isTrue);
    });

    test('usa el color semilla verde deportivo', () {
      expect(AppTheme.semilla, const Color(0xFF2E7D32));
      expect(AppTheme.light.colorScheme.primary, isNotNull);
    });

    test('el AppBar centra el título', () {
      expect(AppTheme.light.appBarTheme.centerTitle, isTrue);
    });
  });
}
