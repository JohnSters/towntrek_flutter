import 'package:flutter/material.dart';

/// Constants for Creative Spaces screens, including layout, labels, and visuals.
class CreativeSpacesConstants {
  CreativeSpacesConstants._();

  // Page layout
  static const double pagePadding = 16.0;
  static const double pageHeaderHeight = 110.0;
  static const double sectionSpacing = 12.0;
  static const double cardSpacing = 12.0;
  static const double contentSpacing = 18.0;
  static const double searchBarRadius = 14.0;

  // Card visuals
  static const double cardImageSize = 86.0;
  static const double cardImageRadius = 12.0;
  static const double sectionRadius = 14.0;

  // Palette
  static const Color sectionAccent = Color(0xFF6D4C41); // brown

  // Labels
  static const String pageSubtitle =
      'Discover local makers, studios, tours, and creative experiences';
  static const String noSpacesTitle = 'No creative spaces found';
  static const String noSpacesSubtitle =
      'Try adjusting filters or search terms to discover more places.';
  static const String noSpacesWithFiltersTitle = 'No matching creative spaces';
  static const String noSpacesWithFiltersSubtitle =
      'Try clearing filters or changing your search to see more results.';
  static const String clearFiltersLabel = 'Clear filters';
  static const String loadingSpacesText = 'Finding creative spaces in your town...';
  static const String loadingSubtitleText = 'Please wait while we load the spaces';
  static const String filterAll = 'All';
  static const String categoryLabel = 'Categories';
  static const String subCategoryLabel = 'Sub-categories';
  static const String resultsLabel = 'results';
  static const String resultCountTemplate = '{count} spaces';
  static const String searchHint = 'Search by name, style, or service';
  static const String featuredBadge = 'Featured';
  static const String verifiedBadge = 'Verified';
  static const String openBadge = 'Open now';
  static const String closedBadge = 'Closed';
  static const String quickInfoTitle = 'Quick info';
  static const String contactTitle = 'Contact';
  static const String operatingHoursTitle = 'Operating hours';
  static const String specialHoursTitle = 'Special hours';
  static const String detailsTitle = 'Details';
  static const String galleryTitle = 'Gallery';
  static const String reviewsTitle = 'Reviews';
  static const String documentsTitle = 'Documents';
  static const String mapActionLabel = 'Take me there';
  static const String callActionLabel = 'Call';
  static const String emailActionLabel = 'Email';
  static const String websiteActionLabel = 'Website';

  // Fallback labels
  static const String noDescriptionText = 'No description available yet.';
}
