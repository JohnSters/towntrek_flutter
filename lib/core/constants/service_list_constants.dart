import 'package:flutter/material.dart';

/// Constants for Service List Page
/// Contains all spacing, sizing, colors, strings, and pagination settings
class ServiceListConstants {
  // Private constructor to prevent instantiation
  ServiceListConstants._();

  // Pagination settings
  static const int defaultPageSize = 20;
  static const int defaultPage = 1;

  // Layout spacing and padding
  static const double contentPadding = 24.0;
  static const double cardMarginBottom = 16.0;
  static const double cardPaddingAll = 16.0;
  static const double serviceCardPaddingHorizontal = 20.0;
  static const double serviceCardPaddingVertical = 16.0;
  static const double loadMorePaddingVertical = 16.0;
  static const double errorViewPadding = 24.0;
  static const double errorIconSize = 64.0;
  static const double errorSpacing = 16.0;
  static const double errorButtonSpacing = 24.0;

  // Page header
  static const double pageHeaderHeight = 120.0;

  // Card styling
  static const double cardElevation = 0.0;
  static const double cardBorderRadius = 16.0;
  static const double cardBorderOpacity = 0.2;

  // Icon styling
  static const double iconSize = 24.0;
  static const double defaultIconSize = 32.0;
  static const double logoSize = 80.0;
  static const double logoMarginRight = 16.0;

  // Badge styling
  static const double badgePaddingHorizontal = 8.0;
  static const double badgePaddingVertical = 4.0;
  static const double badgeBorderRadius = 12.0;

  // Spacing between elements
  static const double rowSpacing = 8.0;
  static const double titleSpacing = 2.0;
  static const double metadataSpacing = 12.0;
  static const double shortDescriptionSpacing = 8.0;

  // Colors and opacity
  static const double disabledOpacity = 0.6;
  static const double emptyStateIconOpacity = 0.4;
  static const double emptyStateTextOpacity = 0.6;
  static const double errorIconOpacity = 0.4;
  static const double errorTextOpacity = 0.6;

  // Typography
  static const int maxTitleLines = 2;
  static const int maxDescriptionLines = 2;
  static const double titleHeight = 1.2;
  static const double descriptionHeight = 1.3;

  // Font weights
  static const FontWeight titleFontWeight = FontWeight.bold;

  // Text overflow
  static const TextOverflow textOverflow = TextOverflow.ellipsis;

  // Strings
  static const String loadingMessage = 'Loading services...';
  static const String loadMoreButtonText = 'Load More Services';
  static const String tryAgainButtonText = 'Try Again';
  static const String refreshErrorTitle = 'Connection Error';
  static const String refreshErrorMessage = 'Failed to load services. Please check your connection and try again.';
  static const String emptyStateTitle = 'No services found';
  static const String emptyStateMessage = 'No services are currently available in this category.';
  static const String entryFeeLabel = 'Entry Fee:';
  static const String freePriceText = 'Free';
  static const String priceTbaText = 'Price TBA';
  static const String servicesSubtitle = 'Services';

  // Icon data
  static const IconData defaultServiceIcon = Icons.build;
  static const IconData errorIcon = Icons.error_outline;
  static const IconData emptyIcon = Icons.business_center;
  static const IconData refreshIcon = Icons.refresh;
}