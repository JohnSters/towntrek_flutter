import 'package:flutter/material.dart';

/// Centralized theme configuration for TownTrek app
/// Following Material Design 3 principles with no shadows/elevations
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ===== COLOR PALETTE =====
  static const Color _primaryColor = Color(0xFF0175C2);
  static const Color _secondaryColor = Color(0xFF03A9F4);
  static const Color _tertiaryColor = Color(0xFF00BCD4);

  // Semantic colors
  static const Color _successColor = Color(0xFF4CAF50);
  static const Color _warningColor = Color(0xFFFF9800);
  static const Color _errorColor = Color(0xFFF44336);
  static const Color _infoColor = Color(0xFF2196F3);

  // Neutral colors
  static const Color _surfaceColor = Color(0xFFFFFFFF);
  static const Color _backgroundColor = Color(0xFFFAFAFA);
  static const Color _onSurfaceColor = Color(0xFF1C1B1F);
  static const Color _onSurfaceVariant = Color(0xFF49454F);
  static const Color _outlineColor = Color(0xFF79747E);
  static const Color _outlineVariantColor = Color(0xFFCAC4D0);

  // Dark theme colors
  static const Color _darkSurfaceColor = Color(0xFF0F1419);
  static const Color _darkOnSurfaceColor = Color(0xFFE6E1E5);
  static const Color _darkOnSurfaceVariant = Color(0xFFCAC4D0);
  static const Color _darkOutlineColor = Color(0xFF938F99);
  static const Color _darkOutlineVariantColor = Color(0xFF403D43);

  // ===== LIGHT THEME =====
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Roboto',

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: _primaryColor,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFD1E4FF),
        onPrimaryContainer: Color(0xFF001B3E),

        secondary: _secondaryColor,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFD1E4FF),
        onSecondaryContainer: Color(0xFF001B3E),

        tertiary: _tertiaryColor,
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFF9EEFFF),
        onTertiaryContainer: Color(0xFF001F24),

        error: _errorColor,
        onError: Colors.white,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),

        surface: _surfaceColor,
        onSurface: _onSurfaceColor,
        surfaceContainerHighest: Color(0xFFE7E0EC),
        onSurfaceVariant: _onSurfaceVariant,

        outline: _outlineColor,
        outlineVariant: _outlineVariantColor,
      ),

      // Typography
      textTheme: _textTheme(Brightness.light),
      primaryTextTheme: _primaryTextTheme,

      // Component Themes - NO SHADOWS/ELEVATIONS
      appBarTheme: appBarTheme,
      bottomNavigationBarTheme: bottomNavigationBarTheme,
      cardTheme: cardTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      filledButtonTheme: filledButtonTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      textButtonTheme: textButtonTheme,
      inputDecorationTheme: inputDecorationTheme,
      dialogTheme: dialogTheme,
      snackBarTheme: snackBarTheme,

      // Icon Theme
      iconTheme: iconTheme,
      primaryIconTheme: primaryIconTheme,

      // Other
      dividerTheme: dividerTheme,
      chipTheme: chipTheme,
      floatingActionButtonTheme: floatingActionButtonTheme,
      navigationBarTheme: navigationBarTheme,
      progressIndicatorTheme: progressIndicatorTheme,
      switchTheme: switchTheme,
    );
  }

  // ===== DARK THEME =====
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Roboto',

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: _secondaryColor,
        onPrimary: Color(0xFF0F1419),
        primaryContainer: Color(0xFF004A77),
        onPrimaryContainer: Color(0xFFD1E4FF),

        secondary: Color(0xFF8ECEFF),
        onSecondary: Color(0xFF0F1419),
        secondaryContainer: Color(0xFF004A77),
        onSecondaryContainer: Color(0xFFD1E4FF),

        tertiary: Color(0xFF4DD0E1),
        onTertiary: Color(0xFF00363D),
        tertiaryContainer: Color(0xFF004F58),
        onTertiaryContainer: Color(0xFF9EEFFF),

        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),

        surface: _darkSurfaceColor,
        onSurface: _darkOnSurfaceColor,
        surfaceContainerHighest: Color(0xFF49454F),
        onSurfaceVariant: _darkOnSurfaceVariant,

        outline: _darkOutlineColor,
        outlineVariant: _darkOutlineVariantColor,
      ),

      // Typography
      textTheme: _textTheme(Brightness.dark),
      primaryTextTheme: _primaryTextTheme,

      // Component Themes - NO SHADOWS/ELEVATIONS
      appBarTheme: appBarTheme.copyWith(
        backgroundColor: _darkSurfaceColor,
        foregroundColor: _darkOnSurfaceColor,
      ),
      bottomNavigationBarTheme: bottomNavigationBarTheme.copyWith(
        backgroundColor: _darkSurfaceColor,
      ),
      cardTheme: cardTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      filledButtonTheme: filledButtonTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      textButtonTheme: textButtonTheme,
      inputDecorationTheme: inputDecorationTheme,
      dialogTheme: dialogTheme.copyWith(
        backgroundColor: _darkSurfaceColor,
      ),
      snackBarTheme: snackBarTheme,

      // Icon Theme
      iconTheme: iconTheme.copyWith(
        color: _darkOnSurfaceColor,
      ),
      primaryIconTheme: primaryIconTheme,

      // Other
      dividerTheme: dividerTheme,
      chipTheme: chipTheme,
      floatingActionButtonTheme: floatingActionButtonTheme,
      navigationBarTheme: navigationBarTheme,
      progressIndicatorTheme: progressIndicatorTheme,
      switchTheme: switchTheme,
    );
  }

  // ===== TYPOGRAPHY =====
  static TextTheme _textTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final displayColor = isDark ? _darkOnSurfaceColor : _onSurfaceColor;
    final bodyColor = isDark ? _darkOnSurfaceColor : _onSurfaceColor;

    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        height: 1.12,
        letterSpacing: -0.25,
        color: displayColor,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        height: 1.16,
        letterSpacing: 0,
        color: displayColor,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        height: 1.22,
        letterSpacing: 0,
        color: displayColor,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        height: 1.25,
        letterSpacing: 0,
        color: displayColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        height: 1.29,
        letterSpacing: 0,
        color: displayColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0,
        color: displayColor,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.27,
        letterSpacing: 0,
        color: displayColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0.15,
        color: displayColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.1,
        color: displayColor,
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.5,
        color: bodyColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 0.25,
        color: bodyColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.4,
        color: bodyColor,
      ),

      // Label styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.1,
        color: bodyColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0.5,
        color: bodyColor,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0.5,
        color: bodyColor,
      ),
    );
  }

  static TextTheme get _primaryTextTheme => const TextTheme(
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          height: 1.27,
          letterSpacing: 0,
          color: Colors.white,
        ),
      );

  // ===== COMPONENT THEMES =====

  // App Bar - NO ELEVATION
  static AppBarTheme get appBarTheme => const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );

  // Bottom Navigation Bar - NO ELEVATION
  static BottomNavigationBarThemeData get bottomNavigationBarTheme =>
      const BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: _surfaceColor,
        selectedItemColor: _primaryColor,
        unselectedItemColor: _outlineColor,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      );

  // Card - NO ELEVATION
  static CardThemeData get cardTheme => const CardThemeData(
        elevation: 0,
        color: _surfaceColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.zero,
      );

  // Buttons - NO ELEVATION
  static ElevatedButtonThemeData get elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.43,
          ),
        ),
      );

  static FilledButtonThemeData get filledButtonTheme => FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );

  static OutlinedButtonThemeData get outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _outlineColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );

  static TextButtonThemeData get textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );

  // Input Decoration
  static InputDecorationTheme get inputDecorationTheme =>
      const InputDecorationTheme(
        filled: true,
        fillColor: _backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: _outlineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: _outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: _errorColor),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );

  // Dialog
  static DialogThemeData get dialogTheme => const DialogThemeData(
        elevation: 0,
        backgroundColor: _surfaceColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      );

  // SnackBar
  static SnackBarThemeData get snackBarTheme => const SnackBarThemeData(
        elevation: 0,
        backgroundColor: _onSurfaceColor,
        contentTextStyle: TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      );

  // ===== ICON THEMES =====
  static IconThemeData get iconTheme => const IconThemeData(
        size: 24,
        color: _onSurfaceColor,
      );

  static IconThemeData get primaryIconTheme => const IconThemeData(
        size: 24,
        color: Colors.white,
      );

  // ===== OTHER COMPONENT THEMES =====

  static DividerThemeData get dividerTheme => const DividerThemeData(
        thickness: 1,
        color: _outlineVariantColor,
        space: 0,
      );

  static ChipThemeData get chipTheme => const ChipThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: _backgroundColor,
        selectedColor: _primaryColor,
        checkmarkColor: Colors.white,
        deleteIconColor: _onSurfaceColor,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _onSurfaceColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        side: BorderSide(color: _outlineColor),
      );

  static FloatingActionButtonThemeData get floatingActionButtonTheme =>
      const FloatingActionButtonThemeData(
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        disabledElevation: 0,
        highlightElevation: 0,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      );

  static NavigationBarThemeData get navigationBarTheme =>
      const NavigationBarThemeData(
        elevation: 0,
        backgroundColor: _surfaceColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        indicatorColor: _primaryColor,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  static ProgressIndicatorThemeData get progressIndicatorTheme =>
      const ProgressIndicatorThemeData(
        linearTrackColor: _outlineVariantColor,
        circularTrackColor: _outlineVariantColor,
      );

  static SwitchThemeData get switchTheme => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryColor;
          }
          return _outlineColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryColor.withValues(alpha: 0.3);
          }
          return _outlineVariantColor;
        }),
      );

  // ===== UTILITY METHODS =====

  /// Get the appropriate theme data based on brightness
  static ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }

  /// Get primary color
  static Color get primaryColor => _primaryColor;

  /// Get secondary color
  static Color get secondaryColor => _secondaryColor;

  /// Get success color
  static Color get successColor => _successColor;

  /// Get warning color
  static Color get warningColor => _warningColor;

  /// Get error color
  static Color get errorColor => _errorColor;

  /// Get info color
  static Color get infoColor => _infoColor;
}
