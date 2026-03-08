import 'package:flutter/material.dart';
import '../models/user_preferences.dart' as prefs;

class AppColors {
  final Color primary;
  final Color background;
  final Color card;
  final Color text;
  final Brightness brightness;

  const AppColors({
    required this.primary,
    required this.background,
    required this.card,
    required this.text,
    required this.brightness,
  });
}

const _themeColors = {
  prefs.ThemeMode.calm: AppColors(
    primary: Color(0xFF4A6FA5),
    background: Color(0xFFE8EDF4),
    card: Color(0xFFF0F4F8),
    text: Color(0xFF1F2933),
    brightness: Brightness.light,
  ),
  prefs.ThemeMode.highContrast: AppColors(
    primary: Color(0xFF5C9AFF),
    background: Color(0xFF000000),
    card: Color(0xFF1A1A1A),
    text: Color(0xFFFFFFFF),
    brightness: Brightness.dark,
  ),
  prefs.ThemeMode.darkFocus: AppColors(
    primary: Color(0xFF7BA4D4),
    background: Color(0xFF1A202C),
    card: Color(0xFF2D3748),
    text: Color(0xFFE2E8F0),
    brightness: Brightness.dark,
  ),
  prefs.ThemeMode.minimal: AppColors(
    primary: Color(0xFF5A6670),
    background: Color(0xFFE0E0E0),
    card: Color(0xFFEAEAEA),
    text: Color(0xFF2A2A2A),
    brightness: Brightness.light,
  ),
};

double fontScaleMultiplier(prefs.FontScale scale) {
  switch (scale) {
    case prefs.FontScale.small:
      return 0.85;
    case prefs.FontScale.medium:
      return 1.0;
    case prefs.FontScale.large:
      return 1.2;
  }
}

ThemeData buildTheme(prefs.UserPreferences preferences) {
  final colors = _themeColors[preferences.themeMode]!;
  final scale = fontScaleMultiplier(preferences.fontScale);
  final isWide = preferences.spacingLevel == prefs.SpacingLevel.wide;
  final padding = isWide ? 20.0 : 12.0;

  final colorScheme = ColorScheme.fromSeed(
    seedColor: colors.primary,
    brightness: colors.brightness,
    surface: colors.card,
    primary: colors.primary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colors.background,
    cardTheme: CardThemeData(
      color: colors.card,
      margin: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isWide ? 8 : 4,
      ),
      elevation: 1,
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28 * scale,
        fontWeight: FontWeight.bold,
        color: colors.text,
      ),
      headlineMedium: TextStyle(
        fontSize: 22 * scale,
        fontWeight: FontWeight.bold,
        color: colors.text,
      ),
      titleLarge: TextStyle(
        fontSize: 18 * scale,
        fontWeight: FontWeight.w600,
        color: colors.text,
      ),
      titleMedium: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w500,
        color: colors.text,
      ),
      bodyLarge: TextStyle(
        fontSize: 16 * scale,
        color: colors.text,
      ),
      bodyMedium: TextStyle(
        fontSize: 14 * scale,
        color: colors.text,
      ),
      bodySmall: TextStyle(
        fontSize: 12 * scale,
        color: colors.text.withValues(alpha: 0.7),
      ),
      labelLarge: TextStyle(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w500,
        color: colors.text,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colors.card,
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.text.withValues(alpha: 0.5),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.primary,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isWide ? 16 : 12,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: padding + 4,
          vertical: isWide ? 14 : 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
