import 'package:flutter/material.dart';

/// Constants for Event Details Screen
/// Contains all spacing, sizing, colors, strings, and styling values
class EventDetailsConstants {
  // Private constructor to prevent instantiation
  EventDetailsConstants._();

  // Layout spacing and padding
  static const double contentHorizontalPadding = 16.0;
  static const double contentVerticalPadding = 8.0;
  static const double cardPaddingAll = 20.0;
  static const double sectionSpacing = 16.0;
  static const double bottomPadding = 24.0;
  static const double bottomSpacing = 24.0;

  // AppBar configuration
  static const double appBarExpandedHeight = 250.0;

  // Card styling
  static const double cardElevation = 0.0;
  static const double cardBorderRadius = 16.0;
  static const double cardBorderOpacity = 0.1;

  // Loading view
  static const String loadingSubtitle = 'Loading event details...';
  static const String errorSubtitle = 'Unable to load event details';

  // Error view
  static const double errorIconSize = 64.0;
  static const double errorSpacing = 16.0;
  static const double errorTitleFontSize = 20.0;
  static const double errorMessageFontSize = 16.0;

  // Text spacing
  static const double titleSpacing = 8.0;
  static const double descriptionSpacing = 12.0;
  static const double sectionTitleSpacing = 16.0;
  static const double listItemSpacing = 8.0;

  // Colors and opacity
  static const double disabledTextOpacity = 0.5;
  static const double outlineOpacity = 0.1;

  // Strings
  static const String loadingMessage = 'Loading event details...';
  static const String errorTitle = 'Connection Error';
  static const String errorMessage = 'Failed to load event details. Please check your connection and try again.';
  static const String retryButtonText = 'Try Again';

  // Font weights
  static const FontWeight titleFontWeight = FontWeight.bold;
  static const FontWeight sectionTitleFontWeight = FontWeight.w600;

  // Text overflow
  static const TextOverflow textOverflow = TextOverflow.ellipsis;

  // Image gallery
  static const double imagePreviewSize = 120.0;
  static const double imagePreviewSpacing = 12.0;

  // Icon data
  static const IconData errorIcon = Icons.error_outline;
  static const IconData retryIcon = Icons.refresh;
  static const IconData starIcon = Icons.star;
}