import 'dart:ui';

/// Constants for the Town Feature Selection Screen
class TownFeatureConstants {
  // Spacing constants
  static const double pagePadding = 24.0;
  static const double cardSpacing = 24.0;
  static const double cardPadding = 20.0;
  static const double iconPadding = 12.0;
  static const double titleSpacing = 4.0;
  static const double contentSpacing = 32.0;

  // Size constants
  static const double pageHeaderHeight = 120.0;
  static const double cardHeight = 120.0;
  static const double iconSize = 32.0;
  static const double borderWidth = 8.0;

  // Border radius
  static const double cardBorderRadius = 16.0;

  // Elevation
  static const double cardElevation = 4.0;

  // Alpha values
  static const double iconBackgroundAlpha = 0.1;
  static const double chevronAlpha = 0.5;

  // Colors (as hex values for consistency)
  static const int businessesColor = 0xFF1565C0; // Blue 800
  static const int servicesColor = 0xFFEF6C00; // Orange 800
  static const int eventsColor = 0xFF6A1B9A; // Purple 800
  static const int whatToDoColor = 0xFF00897B; // Teal 600

  // Import needed for FontWeight
  // Font weights
  static const FontWeight titleFontWeight = FontWeight.bold;
  static const FontWeight cardTitleFontWeight = FontWeight.bold;

  // Strings
  static const String pageTitle = 'What are you looking for?';
  static const String businessesTitle = 'Businesses';
  static const String businessesDescription =
      'Find local shops, restaurants, and more';
  static const String servicesTitle = 'Services';
  static const String servicesDescription =
      'Plumbers, electricians, and other pros';
  static const String eventsTitle = 'Events';
  static const String eventsDescription = 'Discover what\'s happening in town';
  static const String whatToDoTitle = 'What to do';
  static const String whatToDoDescription =
      'Visitor tips, attractions, and local highlights';
  static const String changeTownTooltip = 'Wrong Town?';
}
