import 'package:flutter/material.dart';

/// Guía visual provisional (issue #8): verde deportivo con Material 3.
/// Se ajustará cuando el diseño de Figma esté validado.
abstract final class AppTheme {
  static const Color semilla = Color(0xFF2E7D32);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: semilla),
    appBarTheme: const AppBarTheme(centerTitle: true),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
    ),
  );
}
