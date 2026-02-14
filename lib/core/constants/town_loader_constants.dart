import 'dart:ui';

/// Constants for the Town Loader Screen
class TownLoaderConstants {
  // Spacing constants
  static const double horizontalPadding = 20.0;
  static const double verticalPadding = 12.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;

  // Container sizes
  static const double logoContainerSize = 120.0;
  static const double maxWidthConstraint = 320.0;
  static const double infoPillMaxWidth = 280.0;

  // Border radius constants
  static const double borderRadiusSmall = 16.0;
  static const double borderRadiusMedium = 25.0;

  // Button padding
  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 12.0;
  static const double textButtonPaddingHorizontal = 16.0;
  static const double textButtonPaddingVertical = 8.0;

  // Icon sizes
  static const double infoIconSize = 18.0;

  // Import needed for FontWeight
  // Font weights
  static const FontWeight titleFontWeight = FontWeight.w600;
  static const FontWeight subtitleFontWeight = FontWeight.w500;
  static const FontWeight buttonFontWeight = FontWeight.w500;

  // Alpha values
  static const double surfaceContainerAlpha = 0.8;
  static const double infoContainerAlpha = 0.6;
  static const double outlineAlpha = 0.15;
  static const double onSurfaceVariantAlpha = 0.7;

  // Strings
  static const String loadingTitle = 'Finding your location...';
  static const String loadingDescription = 'We\'re detecting your town to show relevant content';
  static const String skipLocationButtonText = 'Skip Location Detection';
  static const String selectTownTitle = 'Select Your Town';
  static const String selectTownDescription = 'Choose your town to explore';
  static const String useLocationButtonText = 'Use My Location';
  static const String selectManuallyButtonText = 'Select Manually';
  static const String openLocationSettingsText = 'Open Location Settings';
  static const String openAppSettingsText = 'Open App Settings';
}