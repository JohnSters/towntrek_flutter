import 'package:flutter/material.dart';

/// Constants for Service Category page
/// All magic numbers, spacing, colors, strings, and layout values

class ServiceCategoryConstants {
  // Spacing and sizing
  static const double pagePadding = 24.0;
  static const double cardSpacing = 16.0;
  static const double actionButtonSpacing = 16.0;
  static const double contentBottomSpacing = 32.0;
  static const double iconSize = 24.0;
  static const double actionIconSize = 40.0;
  static const double emptyIconSize = 64.0;
  static const double actionButtonHeight = 100.0;
  static const double actionButtonPadding = 12.0;
  static const double actionButtonTextSpacing = 8.0;
  static const double categoryCardPaddingHorizontal = 20.0;
  static const double categoryCardPaddingVertical = 16.0;
  static const double categoryIconSize = 48.0;
  static const double categoryIconSpacing = 16.0;
  static const double categoryCardBorderRadius = 12.0;
  static const double categoryIconBorderRadius = 10.0;
  static const double emptyStateTextSpacing = 16.0;

  // Opacity values
  static const double disabledOpacity = 0.6;
  static const double surfaceOpacity = 0.5;
  static const double outlineOpacity = 0.1;
  static const double chevronOpacity = 0.5;
  static const double emptyIconOpacity = 0.3;
  static const double emptyTextOpacity = 0.7;
  static const double disabledTextOpacity = 0.6;

  // Page header
  static const double pageHeaderHeight = 120.0;

  // Card styling
  static const double cardElevation = 0.0;

  // Border radius values
  static const double actionButtonBorderRadius = 16.0;

  // Strings
  static const String servicesSubtitle = 'Services';
  static const String changeTownLabel = 'Change Town';
  static const String emptyStateTitle = 'No service categories found';
  static const String noServicesAvailable = 'No services available';
  static const String servicesCount = 'services';
  static const String viewServices = 'View services';

  // Icons
  static const IconData changeTownIcon = Icons.location_on;
  static const IconData categoryIcon = Icons.build;
  static const IconData emptyStateIcon = Icons.handyman;
  static const IconData chevronRightIcon = Icons.chevron_right;

  // Colors (relative opacity values, actual colors resolved at runtime)
  static const double surfaceContainerHighestOpacity = 0.5;

  // Text styles (weights and sizes are applied via theme)
  static const FontWeight titleMediumWeight = FontWeight.w600;
  static const FontWeight actionButtonWeight = FontWeight.w700;
}