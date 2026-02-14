import 'package:flutter/material.dart';

/// Constants for Business Sub-Category Page
/// Contains all spacing, sizing, colors, strings, and styling values
class BusinessSubCategoryConstants {
  // Private constructor to prevent instantiation
  BusinessSubCategoryConstants._();

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
  static const double titleSpacing = 2.0;
  static const double arrowIconSize = 20.0;
  static const double arrowIconSpacing = 12.0;
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
  static const double disabledTextOpacity = 0.5;
  static const double disabledArrowOpacity = 0.3;
  static const double emptyStateTextOpacity = 0.7;
  static const double emptyStateIconOpacity = 0.3;

  // Text styling
  static const int maxTitleLines = 1;
  static const int maxDescriptionLines = 1;
  static const TextOverflow textOverflow = TextOverflow.ellipsis;

  // Strings
  static const String subtitlePrefix = 'Choose a specific type in';
  static const String businessCountSeparator = '•';
  static const String businessesLabel = 'businesses';
  static const String subCategoriesLabel = 'sub-categories';
  static const String totalBusinessesLabel = 'total businesses';
  static const String noBusinessesYet = 'No businesses yet';
  static const String noSubCategoriesFound = 'No sub-categories found';
  static const String emptyStateMessage = 'No sub-categories found';
}