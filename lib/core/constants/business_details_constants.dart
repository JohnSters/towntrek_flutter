/// Constants for Business Details page layout, spacing, and strings
class BusinessDetailsConstants {
  // Header heights and spacing
  static const double headerHeight = 140.0;
  static const double headerHorizontalPadding = 24.0;
  static const double headerVerticalPadding = 16.0;

  // Card margins and padding
  static const double cardHorizontalMargin = 16.0;
  static const double cardVerticalMargin = 16.0;
  static const double cardPadding = 20.0;
  static const double cardBorderRadius = 16.0;

  // Card styling
  static const double cardElevation = 0.0;
  static const double cardBorderAlpha = 0.1;

  // Section spacing
  static const double sectionSpacing = 16.0;
  static const double sectionVerticalMargin = 16.0;

  // Content spacing
  static const double contentPadding = 16.0;
  static const double contentSpacing = 20.0;
  static const double smallSpacing = 12.0;
  static const double tinySpacing = 8.0;
  static const double largeSpacing = 24.0;

  // Bottom padding
  static const double bottomPadding = 24.0;

  // Icon sizes
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double starIconSize = 16.0;

  // Avatar sizes
  static const double avatarRadius = 16.0;

  // Border radius values
  static const double borderRadiusSmall = 12.0;
  static const double borderRadiusMedium = 16.0;
  static const double reviewCardBorderRadius = 12.0;

  // Button padding
  static const double buttonVerticalPadding = 12.0;

  // Text opacity values
  static const double lowOpacity = 0.3;
  static const double mediumOpacity = 0.7;
  static const double highOpacity = 0.1;

  // Border values
  static const double borderWidth = 1.0;

  // Review display limits
  static const int maxReviewsToShow = 3;

  // Height values for text
  static const double descriptionLineHeight = 1.6;
  static const double reviewLineHeight = 1.5;

  // URLs
  static const String reviewsUrl = 'https://towntrek.co.za';
  static const String publicBusinessPath = '/Public/Business/';
  static const String reviewsSectionAnchor = '#reviews';

  // Strings
  static const String loadingTagline = 'Loading business details...';
  static const String errorTagline = 'Unable to load business details';
  static const String navigationFailedMessage = 'Navigation failed';
  static const String navigationErrorMessage = 'Unable to start navigation';
  static const String reviewsSectionTitle = 'Reviews';
  static const String viewAllReviewsLabel = 'View All Reviews';
  static const String verifiedReviewLabel = 'Verified Review';
}