import 'package:flutter/material.dart';

/// Jarvis app theme.
///
/// Uses Material 3 with a purple seed color.
/// Full theming (custom colors, dark/AMOLED variants) is Phase 5 work.
class AppTheme {
  AppTheme._();

  // Seed color for Material 3 color scheme generation.
  // Will be user-customizable in Phase 5.
  static const _seedColor = Color(0xFF6750A4);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
      );
}
