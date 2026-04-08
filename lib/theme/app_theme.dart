import 'package:flutter/material.dart';

import 'detail_quick_action_theme_extension.dart';
import 'entity_listing_theme_extension.dart';

/// Centralized theme configuration for TownTrek app
/// Following Material Design 3 principles with no shadows/elevations
class AppTheme {
  AppTheme._();

  static const Color _primaryColor = Color(0xFF0175C2);
  static const Color _secondaryColor = Color(0xFF03A9F4);
  static const Color _tertiaryColor = Color(0xFF00BCD4);

  static const Color _successColor = Color(0xFF4CAF50);
  static const Color _errorColor = Color(0xFFF44336);

  static const Color _surfaceColor = Color(0xFFFFFFFF);
  static const Color _backgroundColor = Color(0xFFFAFAFA);
  static const Color _onSurfaceColor = Color(0xFF1C1B1F);
  static const Color _onSurfaceVariant = Color(0xFF49454F);
  static const Color _outlineColor = Color(0xFF79747E);
  static const Color _outlineVariantColor = Color(0xFFCAC4D0);

  static const Color _darkSurfaceColor = Color(0xFF0F1419);
  static const Color _darkOnSurfaceColor = Color(0xFFE6E1E5);
  static const Color _darkOnSurfaceVariant = Color(0xFFCAC4D0);
  static const Color _darkOutlineColor = Color(0xFF938F99);
  static const Color _darkOutlineVariantColor = Color(0xFF403D43);

  static const ColorScheme _lightScheme = ColorScheme.light(
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
  );

  static const ColorScheme _darkScheme = ColorScheme.dark(
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
    surfaceContainerHighest: Color(0xFF3B3840),
    onSurfaceVariant: _darkOnSurfaceVariant,
    outline: _darkOutlineColor,
    outlineVariant: _darkOutlineVariantColor,
  );

  static ThemeData get lightTheme => _themeData(
        colorScheme: _lightScheme,
        brightness: Brightness.light,
        listing: EntityListingThemeExtension.light,
        detail: DetailQuickActionThemeExtension.light,
      );

  static ThemeData get darkTheme => _themeData(
        colorScheme: _darkScheme,
        brightness: Brightness.dark,
        listing: EntityListingThemeExtension.dark,
        detail: DetailQuickActionThemeExtension.dark,
      );

  static ThemeData _themeData({
    required ColorScheme colorScheme,
    required Brightness brightness,
    required EntityListingThemeExtension listing,
    required DetailQuickActionThemeExtension detail,
  }) {
    final isDark = brightness == Brightness.dark;

    final cardColor = listing.cardBg;
    final inputFill = isDark
        ? const Color(0xFF243041)
        : _backgroundColor;
    final snackBarBg =
        isDark ? const Color(0xFFE2E8F0) : _onSurfaceColor;
    final snackBarFg =
        isDark ? const Color(0xFF0F1419) : Colors.white;

    final dividerColor = colorScheme.outlineVariant;
    final chipBg = isDark ? const Color(0xFF243041) : _backgroundColor;
    final navBarBg = isDark ? _darkSurfaceColor : _surfaceColor;
    final bottomNavBg = isDark ? _darkSurfaceColor : _surfaceColor;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Roboto',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: _textTheme(brightness),
      primaryTextTheme: _primaryTextTheme,
      extensions: <ThemeExtension<dynamic>>[
        listing,
        detail,
      ],

      appBarTheme: const AppBarTheme(
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
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: bottomNavBg,
        selectedItemColor: _primaryColor,
        unselectedItemColor: isDark ? _darkOnSurfaceVariant : _outlineColor,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
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
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: const BorderSide(color: _errorColor),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        elevation: 0,
        backgroundColor: snackBarBg,
        contentTextStyle: TextStyle(color: snackBarFg),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),

      iconTheme: IconThemeData(
        size: 24,
        color: colorScheme.onSurface,
      ),

      primaryIconTheme: const IconThemeData(
        size: 24,
        color: Colors.white,
      ),

      dividerTheme: DividerThemeData(
        thickness: 1,
        color: dividerColor,
        space: 0,
      ),

      chipTheme: ChipThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: chipBg,
        selectedColor: _primaryColor,
        checkmarkColor: Colors.white,
        deleteIconColor: colorScheme.onSurface,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        side: BorderSide(color: colorScheme.outline),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        disabledElevation: 0,
        highlightElevation: 0,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),

      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: navBarBg,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        indicatorColor: _primaryColor.withValues(alpha: isDark ? 0.35 : 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? _darkOnSurfaceVariant : _outlineColor,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.white, size: 24);
          }
          return IconThemeData(
            color: isDark ? _darkOnSurfaceVariant : _outlineColor,
            size: 24,
          );
        }),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _primaryColor,
        linearTrackColor: dividerColor,
        circularTrackColor: dividerColor,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryColor;
          }
          return isDark ? _darkOutlineColor : _outlineColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryColor.withValues(alpha: 0.35);
          }
          return dividerColor;
        }),
      ),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final displayColor = isDark ? _darkOnSurfaceColor : _onSurfaceColor;
    final bodyColor = isDark ? _darkOnSurfaceColor : _onSurfaceColor;

    return TextTheme(
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

  static const TextTheme _primaryTextTheme = TextTheme(
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      height: 1.27,
      letterSpacing: 0,
      color: Colors.white,
    ),
  );

  static ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }

  static Color get primaryColor => _primaryColor;
  static Color get secondaryColor => _secondaryColor;
  static Color get successColor => _successColor;
  static Color get warningColor => const Color(0xFFFF9800);
  static Color get errorColor => _errorColor;
  static Color get infoColor => const Color(0xFF2196F3);
}
