import 'package:flutter/material.dart';

/// Tema de la app: verde deportivo con Material 3. Las reglas de uso
/// (colores por rol, tipografía, componentes y textos) están en
/// `docs/GUIA_VISUAL.md`.
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
