import 'package:flutter/material.dart';

/// Tema provisional. Se reemplazará con la guía visual de Figma.
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
  );
}
