import 'package:flutter/material.dart';

/// Constants for Business Category page layout, spacing, and strings
class BusinessCategoryConstants {
  // Header heights
  static const double headerHeight = 120.0;

  // Container sizes
  static const double locationContainerSize = 80.0;
  static const double townContainerSize = 80.0;
  static const double categoryIconContainerSize = 48.0;

  // Spacing and padding
  static const double horizontalPadding = 24.0;
  static const double verticalPadding = 12.0;
  static const double contentPadding = 20.0;
  static const double smallSpacing = 16.0;
  static const double tinySpacing = 12.0;
  static const double largeSpacing = 32.0;
  static const double extraLargeSpacing = 24.0;

  // Border radius values
  static const double borderRadiusSmall = 10.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double pillBorderRadius = 25.0;

  // Action button dimensions
  static const double actionButtonHeight = 100.0;
  static const double actionButtonPadding = 12.0;
  static const double actionButtonIconSize = 40.0;
  /// Strip under category headers (Wrong Town / Events).
  static const double connectedButtonHeight = 46.0;
  static const double connectedButtonHorizontalPadding = 10.0;
  static const double connectedButtonVerticalPadding = 7.0;
  static const double connectedButtonIconSize = 19.0;

  /// Shared compact [FilledButton] style for the Wrong Town / Events row.
  static ButtonStyle connectedHeaderButtonStyle(
    ThemeData theme, {
    Color? backgroundColor,
    Color? foregroundColor,
    double elevation = 0,
    Color? shadowColor,
    OutlinedBorder? shape,
  }) {
    return FilledButton.styleFrom(
      minimumSize: Size(0, connectedButtonHeight),
      maximumSize: Size(double.infinity, connectedButtonHeight),
      padding: EdgeInsets.symmetric(
        horizontal: connectedButtonHorizontalPadding,
        vertical: connectedButtonVerticalPadding,
      ),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      iconSize: connectedButtonIconSize,
      textStyle: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      shadowColor: shadowColor,
      shape: shape ?? const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    );
  }

  // Card styling
  static const double cardElevation = 0.0;
  static const double cardBorderAlpha = 0.1;
  static const double cardMarginBottom = 16.0;
  static const double cardHorizontalPadding = 20.0;
  static const double cardVerticalPadding = 16.0;

  // Icon sizes
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 40.0;
  static const double iconSizeExtraLarge = 64.0;

  // Animation durations
  static const Duration uiSettleDelay = Duration(milliseconds: 100);

  // Animation values
  static const double disabledOpacity = 0.6;
  static const double disabledAlpha = 0.5;
  static const double lowAlpha = 0.3;
  static const double mediumAlpha = 0.7;
  static const double mediumOpacity = 0.5;
  static const double highAlpha = 0.15;

  // Border and shadow values
  static const double borderWidth = 1.5;
  static const double shadowBlurRadius = 8.0;
  static const double shadowSpreadRadius = 1.0;

  // Event checking
  static const int eventCheckPageSize = 1;

  // Colors
  static const int activeButtonBgColor = 0xFF00E676;
  static const int activeIconColor = 0xFF00C853;

  // Strings
  static const String locationLoadingText = 'Finding your location...';
  static const String locationLoadingSubtitle = 'We\'re detecting your town to show relevant businesses';
  static const String skipLocationText = 'Skip Location Detection';
  static const String townSelectionTitle = 'Select Your Town';
  static const String townSelectionSubtitle = 'Choose your town to explore local businesses';
  static const String useMyLocationText = 'Use My Location';
  static const String selectManuallyText = 'Select Manually';
  static const String noCategoriesText = 'No business categories found';
  static const String noBusinessesText = 'No businesses yet';
  static const String changeTownText = 'Wrong Town?';
  static const String eventsText = 'Events';
  static const String noEventsText = 'No Events';
}