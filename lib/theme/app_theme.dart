import 'package:flutter/material.dart';

class AppTheme {
  // Static color definitions
  static const Color primaryLight = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF66BB6A);

  // Light theme color scheme
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: primaryLight,
    brightness: Brightness.light,
    primary: primaryLight,
    error: errorLight,
  );

  // Dark theme color scheme
  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: primaryDark,
    brightness: Brightness.dark,
    primary: primaryDark,
    error: errorDark,
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    scaffoldBackgroundColor: _lightColorScheme.background,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      scrolledUnderElevation: 0,
      backgroundColor: _lightColorScheme.surface,
      foregroundColor: _lightColorScheme.onSurface,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: _lightColorScheme.surface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: _lightColorScheme.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: _lightColorScheme.primary,
        foregroundColor: _lightColorScheme.onPrimary,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: _lightColorScheme.onBackground),
      headlineMedium: TextStyle(color: _lightColorScheme.onBackground),
      headlineSmall: TextStyle(color: _lightColorScheme.onBackground),
      titleLarge: TextStyle(color: _lightColorScheme.onBackground),
      titleMedium: TextStyle(color: _lightColorScheme.onBackground),
      titleSmall: TextStyle(color: _lightColorScheme.onBackground),
      bodyLarge: TextStyle(color: _lightColorScheme.onBackground),
      bodyMedium: TextStyle(color: _lightColorScheme.onBackground),
      bodySmall: TextStyle(color: _lightColorScheme.onBackground),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    scaffoldBackgroundColor: _darkColorScheme.background,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      scrolledUnderElevation: 0,
      backgroundColor: _darkColorScheme.surface,
      foregroundColor: _darkColorScheme.onSurface,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: _darkColorScheme.surface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: _darkColorScheme.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: _darkColorScheme.primary,
        foregroundColor: _darkColorScheme.onPrimary,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: _darkColorScheme.onBackground),
      headlineMedium: TextStyle(color: _darkColorScheme.onBackground),
      headlineSmall: TextStyle(color: _darkColorScheme.onBackground),
      titleLarge: TextStyle(color: _darkColorScheme.onBackground),
      titleMedium: TextStyle(color: _darkColorScheme.onBackground),
      titleSmall: TextStyle(color: _darkColorScheme.onBackground),
      bodyLarge: TextStyle(color: _darkColorScheme.onBackground),
      bodyMedium: TextStyle(color: _darkColorScheme.onBackground),
      bodySmall: TextStyle(color: _darkColorScheme.onBackground),
    ),
  );
}