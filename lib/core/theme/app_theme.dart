import 'package:flutter/material.dart';

/// Centralized Material 3 theme for the Expense Tracker app.
///
/// Uses a teal-emerald seed color to convey trust and finance.
/// All component themes are configured here so individual widgets
/// stay free of ad-hoc style overrides.
class AppTheme {
  AppTheme._();

  static const Color _seedColor = Color(0xFF0D9373);

  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.light,
  );

  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.dark,
  );

  static ThemeData get light => _buildTheme(_lightColorScheme);
  static ThemeData get dark => _buildTheme(_darkColorScheme);

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,

      // Typography
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 28,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        titleMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        bodyLarge: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
        bodyMedium: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
        bodySmall: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
        labelLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.4,
        ),
        labelMedium: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          letterSpacing: 0.3,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: colorScheme.surfaceContainerLowest,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 22,
          letterSpacing: -0.3,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colorScheme.surfaceContainer,
        margin: EdgeInsets.zero,
      ),

      // Chips
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        showCheckmark: false,
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        thickness: 1,
        space: 0,
      ),

      // Bottom sheet
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: colorScheme.surface,
        showDragHandle: true,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface.withValues(alpha: 0.65),
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}
