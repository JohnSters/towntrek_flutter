import 'dart:ui';

/// Constants for the Town Feature Selection Screen
abstract final class TownFeatureConstants {
  // Spacing
  static const double pagePadding = 16.0;
  static const double gridGap = 12.0;
  static const double sectionGap = 16.0;
  static const double hubActionGap = 10.0;
  static const double hubActionHeight = 72.0;
  /// Notices / Town Admin — slightly shorter so they read as tools, not destinations.
  static const double hubActionUtilityHeight = 60.0;
  static const double hubActionPreviewWidth = 80.0;
  static const double hubActionRadius = 12.0;
  static const double hubActionIconSize = 42.0;
  static const double hubActionUtilityIconSize = 34.0;
  static const double hubActionTintStrength = 0.12;
  static const double hubActionExploreTintStrength = 0.22;
  static const double hubActionNoticeTintStrength = 0.18;
  static const double hubActionCollapsedTintStrength = 0.05;
  static const double hubActionExpandedTintBoost = 0.08;
  static const double hubActionCollapsedLeadDim = 0.34;

  /// Bottom inset for town hub / parcel board FABs above the safe area (lower = closer to the bottom edge).
  static const double floatingHubActionBottomInset = 40.0;

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
  static const int forumColor = 0xFF33658A; // TownTrek lapis
  static const int noticesAccent = 0xFF1565C0;
  static const int adminAccent = 0xFF546E7A;
  /// Warm gold — unique on the hub so Explore town is the entry point.
  static const int exploreAccent = 0xFFC67C14;
  static const int aroundTownAccent = 0xFF6A1B9A;

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
  static const String forumTitle = 'Community Forum';
  static const String forumDescription =
      'Local conversations, updates, and neighbourly help';
  static const String changeTownTooltip = 'Wrong Town?';

  static const String exploreSectionTitle = 'Explore town';
  static const String exploreSectionDescription =
      'Shops, food, services, and things to do';
  static const String aroundTownSectionTitle = 'Around town';
  static const String aroundTownSectionDescription =
      'Recordings, videos, and town adverts';
  static const String noticesTitle = 'Town Notices';

  static String noticesSubtitle(int count) =>
      count == 1 ? '1 update' : '$count updates';
}
