import 'dart:ui';

/// Constants for the Town Feature Selection Screen
class TownFeatureConstants {
  // Spacing
  static const double pagePadding = 16.0;
  static const double gridGap = 12.0;
  static const double sectionGap = 16.0;

  // Sizes
  static const double pageHeaderHeight = 100.0;
  static const double heroIconSize = 48.0;
  static const double gridIconSize = 42.0;

  // Radii
  static const double heroRadius = 20.0;
  static const double gridRadius = 18.0;
  static const double iconRadius = 14.0;
  static const double gridIconRadius = 12.0;

  // Colors (hex values)
  static const int businessesColor = 0xFF1565C0; // Blue 800
  static const int servicesColor = 0xFFEF6C00; // Orange 800
  static const int eventsColor = 0xFF6A1B9A; // Purple 800
  static const int whatToDoColor = 0xFF00897B; // Teal 600
  static const int creativeSpacesColor = 0xFFD81B60; // Rose 700
  static const int propertiesColor = 0xFF2E7D32; // Green 800
  static const int equipmentRentalsColor = 0xFFFF9800; // Amber / equipment pillar
  static const int parcelsColor = 0xFF6D4C41; // Brown 600

  /// Business category key from server seed (matches web `?category=equipment-rentals`).
  static const String equipmentRentalsCategoryKey = 'equipment-rentals';

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
  static const String whatToDoTitle = 'What to Do';
  static const String whatToDoDescription =
      'Tips, attractions & local highlights';
  static const String creativeSpacesTitle = 'Creative Spaces';
  static const String creativeSpacesDescription =
      'Local artisans, studios & cultural gems';
  static const String propertiesTitle = 'Properties';
  static const String propertiesDescription =
      'Homes and spaces for rent & sale';
  static const String equipmentRentalsTitle = 'Equipment Rentals';
  static const String equipmentRentalsDescription =
      'Tools, machinery & gear for hire';
  static const String parcelsTitle = 'Parcels & Routes';
  static const String parcelsDescription =
      'Ask for help with collections, drop-offs, and local routes';
  static const String changeTownTooltip = 'Wrong Town?';
}
