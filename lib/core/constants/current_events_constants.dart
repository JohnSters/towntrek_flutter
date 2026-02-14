import 'package:flutter/material.dart';

/// Constants for Current Events Screen
/// Contains all spacing, sizing, colors, strings, and styling values
class CurrentEventsConstants {
  // Private constructor to prevent instantiation
  CurrentEventsConstants._();

  // Layout spacing and padding
  static const double cardSpacing = 16.0; // Space between cards
  static const double logoSize = 64.0; // Consistent with other Material 3 cards
  static const double loadMorePaddingVertical = 16.0;

  // Card styling
  static const double cardElevation = 0.0; // Using 0 for modern flat look
  static const double cardBorderRadius = 16.0;
  static const double cardBorderOpacity = 0.2;

  // Logo/Image styling
  static const double logoBorderRadius = 12.0;
  static const double defaultIconSize = 32.0;

  // Badge styling
  static const double featuredBadgePaddingHorizontal = 12.0;
  static const double featuredBadgePaddingVertical = 4.0;
  static const double featuredBadgeBorderRadius = 16.0;
  static const double finishedOverlayBorderRadius = 8.0;
  static const double finishedOverlayPaddingHorizontal = 16.0;
  static const double finishedOverlayPaddingVertical = 8.0;

  // Pill styling
  static const double pillPaddingHorizontal = 8.0;
  static const double pillPaddingVertical = 4.0;
  static const double pillBorderRadius = 12.0;
  static const double pillBorderOpacity = 0.2;
  static const double pillFontSize = 10.0;

  // Colors and opacity
  static const double freePillBackgroundOpacity = 0.1;
  static const double primaryPillBackgroundOpacity = 0.1;
  static const double disabledTextOpacity = 0.5;
  static const double disabledArrowOpacity = 0.3;
  static const double emptyStateIconOpacity = 0.4;
  static const double emptyStateTextOpacity = 0.6;
  static const double errorIconOpacity = 0.4;
  static const double errorTextOpacity = 0.6;
  static const double finishedOverlayOpacity = 0.6;
  static const double finishedTextBackgroundOpacity = 0.87;

  // Spacing between elements
  static const double rowSpacing = 8.0;
  static const double titleSpacing = 2.0;
  static const double wrapSpacing = 8.0;
  static const double wrapRunSpacing = 4.0;
  static const double headerRowSpacing = 8.0;
  static const double shortDescriptionSpacing = 8.0;
  static const double metadataSpacing = 12.0;

  // Typography
  static const int maxTitleLines = 2;
  static const int maxDescriptionLines = 2;
  static const double titleHeight = 1.2;
  static const double descriptionHeight = 1.3;

  // Gradient colors (alpha values)
  static const double gradientStartAlpha = 0.05;

  // Error view
  static const double errorViewPadding = 24.0;
  static const double errorIconSize = 64.0;
  static const double errorSpacing = 16.0;
  static const double errorButtonSpacing = 24.0;

  // Empty view
  static const double emptyViewPadding = 24.0;
  static const double emptyIconSize = 64.0;
  static const double emptySpacing = 16.0;
  static const double emptyTextSpacing = 8.0;
  static const double emptyStateIconSize = 64.0;
  static const double emptyStateIconSpacing = 16.0;

  // Pagination
  static const int defaultPageSize = 20;
  static const int defaultPage = 1;

  // Strings
  static const String eventsPrefix = 'Events in';
  static const String eventsSubtitle = 'Events';
  static const String loadingMessage = 'Loading events...';
  static const String loadMoreButtonText = 'Load More Events';
  static const String tryAgainButtonText = 'Try Again';
  static const String refreshErrorTitle = 'Connection Error';
  static const String refreshErrorMessage = 'Failed to load events. Please check your connection and try again.';
  static const String emptyStateTitle = 'No events happening right now';
  static const String emptyStateMessage = 'Check back later for upcoming events in';
  static const String featuredBadgeText = 'Featured';
  static const String finishedBadgeText = 'Finished';
  static const String entryFeeLabel = 'Entry Fee:';
  static const String freePriceText = 'Free';
  static const String priceTbaText = 'Price TBA';

  // Page layout
  static const double pageHeaderHeight = 120.0;

  // Font weights
  static const FontWeight titleFontWeight = FontWeight.bold;
  static const FontWeight featuredBadgeFontWeight = FontWeight.bold;
  static const FontWeight finishedBadgeFontWeight = FontWeight.bold;
  static const FontWeight pillFontWeight = FontWeight.bold;
  static const FontWeight infoPillFontWeight = FontWeight.w500;
  static const FontWeight appBarTitleFontWeight = FontWeight.bold;

  // Text overflow
  static const TextOverflow textOverflow = TextOverflow.ellipsis;

  // Icon data
  static const IconData defaultEventIcon = Icons.event;
  static const IconData errorIcon = Icons.error_outline;
  static const IconData emptyIcon = Icons.event_busy;
  static const IconData refreshIcon = Icons.refresh;
}