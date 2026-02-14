import 'package:flutter/material.dart';

/// Constants for Service Sub-Category page
/// All magic numbers, spacing, colors, strings, and layout values

class ServiceSubCategoryConstants {
  // Private constructor to prevent instantiation
  ServiceSubCategoryConstants._();

  // Layout spacing
  static const double contentPadding = 24.0;
  static const double cardMarginBottom = 16.0;
  static const double infoBadgePaddingHorizontal = 16.0;
  static const double infoBadgePaddingVertical = 8.0;
  static const double infoBadgeMaxWidth = 320.0;
  static const double infoBadgeBorderRadius = 20.0;
  static const double infoBadgeIconSpacing = 6.0;
  static const double subCategoryCardPaddingHorizontal = 20.0;
  static const double subCategoryCardPaddingVertical = 16.0;
  static const double iconContainerSize = 48.0;
  static const double iconContainerBorderRadius = 10.0;
  static const double iconSize = 24.0;
  static const double iconSpacing = 16.0;
  static const double arrowIconSize = 20.0;
  static const double emptyStateIconSize = 64.0;
  static const double emptyStateIconSpacing = 16.0;

  // Page header
  static const double pageHeaderHeight = 120.0;

  // Spacing between sections
  static const double infoBadgeSpacing = 24.0;
  static const double bottomSpacing = 32.0;

  // Card styling
  static const double cardBorderRadius = 12.0;
  static const double cardBorderOpacity = 0.1;
  static const double disabledOpacity = 0.6;
  static const double disabledTextOpacity = 0.6;
  static const double emptyStateTextOpacity = 0.7;
  static const double emptyStateIconOpacity = 0.3;

  // Icon sizes
  static const double infoBadgeIconSize = 16.0;

  // Text styling
  static const int maxTitleLines = 1;
  static const int maxDescriptionLines = 1;
  static const TextOverflow textOverflow = TextOverflow.ellipsis;

  // Font weights
  static const FontWeight titleMediumWeight = FontWeight.w600;

  // Strings
  static const String subtitlePrefix = 'Choose a specific service in';
  static const String subCategoriesLabel = 'sub-categories';
  static const String noServicesAvailable = 'No services available';
  static const String servicesCount = 'services';
  static const String viewServices = 'View services';
  static const String noSubCategoriesFound = 'No sub-categories found';
}