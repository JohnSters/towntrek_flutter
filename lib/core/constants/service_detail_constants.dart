import 'package:flutter/material.dart';

/// Constants for Service Detail Page
/// Contains all spacing, sizing, colors, strings, and styling values
class ServiceDetailConstants {
  // Private constructor to prevent instantiation
  ServiceDetailConstants._();

  // Layout spacing and padding
  static const double contentPadding = 24.0;
  static const double sectionSpacing = 16.0; // Tighter spacing between cards
  static const double bottomSpacing = 24.0;
  static const double headerPaddingVertical = 12.0;
  static const double headerPaddingHorizontal = 24.0;
  static const double cardPadding = 20.0; // Reduced back for better balance
  static const double infoCardPadding = 16.0;
  static const double iconSpacing = 8.0;
  static const double statusIndicatorPaddingVertical = 12.0;
  static const double statusIndicatorPaddingHorizontal = 24.0;
  static const double statusDotSize = 4.0;

  // Page header
  static const double pageHeaderHeight = 120.0;

  // Material 3 Card styling (matching design system)
  static const double cardBorderRadius = 16.0;
  static const double cardBorderWidth = 1.5;
  static const double cardBorderOpacity = 0.1; // Much lighter borders
  static const double cardBackgroundOpacity = 0.02;
  static const double cardElevation = 0.0; // OutlinedButton doesn't use elevation
  static const double shadowOpacity = 0.1;

  // Status indicator colors
  static const Color openBackgroundColor = Color(0xFFE8F5E9);
  static const Color closedBackgroundColor = Color(0xFFFFEBEE);
  static const Color openTextColor = Color(0xFF1B5E20);
  static const Color openIconColor = Color(0xFF2E7D32);
  static const Color closedTextColor = Color(0xFFB71C1C);
  static const Color closedIconColor = Color(0xFFC62828);
  static const Color dotColor = Color(0xFF1B5E20);

  // Icon sizes
  static const double statusIconSize = 18.0;
  static const double logoSize = 80.0;
  static const double logoMarginRight = 16.0;
  static const double actionIconSize = 20.0;
  static const double contactIconSize = 24.0;
  static const double attributeIconSize = 20.0;

  // Typography
  static const int maxDescriptionLines = 5;
  static const int maxAddressLines = 2;
  static const double letterSpacing = 0.5;
  static const double descriptionHeight = 1.5;
  static const double titleHeight = 1.2;

  // Font weights
  static const FontWeight statusFontWeight = FontWeight.bold;
  static const FontWeight closingTimeFontWeight = FontWeight.w600;
  static const FontWeight titleFontWeight = FontWeight.bold;
  static const FontWeight subtitleFontWeight = FontWeight.w500;
  static const FontWeight actionFontWeight = FontWeight.w600;

  // Button styling
  static const double actionButtonPaddingVertical = 14.0;
  static const double actionButtonPaddingHorizontal = 20.0;
  static const double actionButtonBorderRadius = 12.0;

  // Operating hours
  static const double hoursRowSpacing = 12.0;
  static const double hoursPadding = 16.0;
  static const double hoursBorderRadius = 8.0;

  // Image gallery
  static const double gallerySpacing = 8.0;
  static const double galleryBorderRadius = 12.0;

  // Documents
  static const double documentSpacing = 12.0;
  static const double documentPadding = 12.0;
  static const double documentBorderRadius = 8.0;

  // Attributes
  static const double attributeSpacing = 8.0;
  static const double attributePadding = 16.0;
  static const double attributeBorderRadius = 8.0;
  static const double attributeChipPaddingHorizontal = 12.0;
  static const double attributeChipPaddingVertical = 6.0;
  static const double attributeChipBorderRadius = 16.0;

  // Contact actions
  static const double contactButtonSpacing = 12.0;
  static const double contactButtonHeight = 50.0;
  static const double contactButtonBorderRadius = 12.0;

  // Strings
  static const String loadingSubtitle = 'Loading details...';
  static const String errorSubtitle = 'Unable to load details';
  static const String openNowText = 'Open Now';
  static const String closedText = 'Closed';
  static const String callAction = 'Call';
  static const String directionsAction = 'Directions';
  static const String websiteAction = 'Website';
  static const String shareAction = 'Share';
  static const String operatingHoursTitle = 'Operating Hours';
  static const String attributesTitle = 'Services & Features';
  static const String contactInfoTitle = 'Contact & Actions';
  static const String documentsTitle = 'Documents';
  static const String todayText = 'Today';
  static const String closedTodayText = 'Closed';
  static const String open24HoursText = 'Open 24 hours';
  static const String refreshErrorTitle = 'Connection Error';
  static const String refreshErrorMessage = 'Failed to load service details. Please check your connection and try again.';
  static const String retryButtonText = 'Try Again';

  // Time formats
  static const String timeFormat = 'HH:mm';
  static const String closingTimePrefix = 'Closes at';

  // Error view
  static const double errorViewPadding = 24.0;
  static const double errorIconSize = 64.0;
  static const double errorSpacing = 16.0;
  static const double errorButtonSpacing = 24.0;
  static const double errorIconOpacity = 0.4;
  static const double errorTextOpacity = 0.6;

  // Icon data
  static const IconData errorIcon = Icons.error_outline;
  static const IconData statusIcon = Icons.access_time_filled;
  static const IconData callIcon = Icons.phone;
  static const IconData directionsIcon = Icons.directions;
  static const IconData websiteIcon = Icons.language;
  static const IconData shareIcon = Icons.share;
  static const IconData locationIcon = Icons.location_on;
  static const IconData clockIcon = Icons.schedule;
  static const IconData documentIcon = Icons.description;
  static const IconData attributeIcon = Icons.check_circle;
}