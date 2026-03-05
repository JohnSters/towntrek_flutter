import 'package:flutter/material.dart';

/// Constants for Creative Spaces screens, including layout, labels, and visuals.
class CreativeSpacesConstants {
  CreativeSpacesConstants._();

  // Page layout
  static const double pagePadding = 16.0;
  static const double pageHeaderHeight = 110.0;
  static const double sectionSpacing = 10.0;
  static const double cardSpacing = 10.0;
  static const double contentSpacing = 18.0;
  static const double searchBarRadius = 14.0;
  static const double searchBarContentPadding = 12.0;
  static const double contextStripActionSpacing = 6.0;

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
  static const String noSpacesSubCategoryLabel = 'No spaces yet';
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
  static const String resultsForLabel = '{count} spaces in {context}';
  static const String noSpacesAvailableLabel = 'No spaces available';
  static const String exploreCategoryLabel = 'Explore {name}';
  static const String exploreSubCategoryLabel = 'Explore {name} spaces';
  static const String categoryStylesTemplate = '{name} Styles';
  static const String categoryHeader = 'Creative spaces by category';
  static const String categoryHeaderHint = 'Choose your creative world and open detailed spaces';
  static const String allSpacesLabel = 'All spaces';
  static const String allInContextLabelTemplate = '{label} in {context}';
  static const String contextChipValueTemplate = '{label}: {value}';
  static const String labelValueSuffix = ': ';
  static const String numericValueTemplate = '{count} {label}';
  static const String loadMoreSpacesLabel = 'Load more spaces';
  static const String clearSearchLabel = 'Clear search';
  static const String retryLabel = 'Retry';
  static const String searchHint = 'Search by name, style, or service';
  static const String searchChipPrefix = 'Search';
  static const String viewAllLabel = 'View all';
  static const String featuredBadge = 'Featured';
  static const String verifiedBadge = 'Verified';
  static const String openBadge = 'Open now';
  static const String closedBadge = 'Closed';
  static const String closedStatusSuffixDivider = ' · ';
  static const String purchasesLabel = 'Purchases';
  static const String workshopsLabel = 'Workshops';
  static const String noReviewsLabel = 'No reviews';
  static const String viewDetailsLabel = 'View details';
  static const String quickInfoTitle = 'Quick info';
  static const String quickActionsTitle = 'Quick Actions';
  static const String contactTitle = 'Contact';
  static const String operatingHoursTitle = 'Operating hours';
  static const String specialHoursTitle = 'Special hours';
  static const String detailsTitle = 'Details';
  static const String galleryTitle = 'Gallery';
  static const String reviewsTitle = 'Reviews';
  static const String documentsTitle = 'Documents';
  static const String mapActionLabel = 'Take me there';
  static const String creativeSpaceDetailsSubtitle = 'Creative Space Details';
  static const String callActionLabel = 'Call';
  static const String emailActionLabel = 'Email';
  static const String websiteActionLabel = 'Website';
  static const String addressLabel = 'Address';
  static const String specialLabel = 'Special';
  static const String openLabel = 'Open';
  static const String noSubCategoryFallbackMessage = 'This area does not have sub-categories yet.';
  static const String mapsSearchBaseUrl = 'https://www.google.com/maps/search/?api=1&query=';
  static const String listSubtitleCategoryTemplate = 'Showing {category} spaces in {town}';
  static const String listSubtitleSubCategoryTemplate = 'Showing {subCategory} in {category}';
  static const String listHeaderTitleTemplate = '{name} spaces';
  static const String subCategoryHeaderSubtitleTemplate = 'Explore {category} by creative style in {town}';
  static const String noSubCategoriesFound = 'No sub-categories available';
  static const String categoryUnavailableTitle = 'No categories available';
  static const String categoryUnavailableSubtitle = 'Try again later or pull to refresh';
  static const String noSpacesForSelection = 'No creative spaces match this selection.';
  static const String itemInfoDivider = ' • ';
  static const String resultsForCategory = 'Category';
  static const String resultsForSubCategory = 'Sub-category';
  static const String ratingSummaryTemplate = '{rating} ({reviews})';
  static const String backToCategoriesLabel = 'Back to categories';
  static const String contextChipSeparator = '|';

  // Visual accents for list and category cards
  static const Color creativePrimary = Color(0xFF6D4C41); // Warm brown
  static const Color creativeSecondary = Color(0xFF8D6E63); // Clay
  static const Color creativeHighlight = Color(0xFFF3E5D8); // Soft glaze
  static const Color creativeTint = Color(0xFFFFF3E0); // Warm tint
  static const Color quickActionMapBackground = Color(0xFFF3F4FF);
  static const Color quickActionMapIcon = Color(0xFF3F51B5);
  static const Color quickActionCallBackground = Color(0xFFE8F5E9);
  static const Color quickActionCallIcon = Color(0xFF2E7D32);
  static const Color quickActionEmailBackground = Color(0xFFFCE4EC);
  static const Color quickActionEmailIcon = Color(0xFFC2185B);
  static const Color quickActionWebsiteBackground = Color(0xFFFFF3E0);
  static const Color quickActionWebsiteIcon = Color(0xFFE65100);
  static const Color categoryPillTextColor = Color(0xFF5D4037);
  static const Color categoryPillBackgroundColor = Color(0xFFEFEBE9);
  static const Color subCategoryPillTextColor = Color(0xFF8D6E63);
  static const Color subCategoryPillBackgroundColor = Color(0xFFECEFF1);
  static const String reviewRatingTemplate = '{rating} ★';
  static const String mapCoordinateTemplate = '{name}, {lat}, {lng}';
  static const String dateIsoTemplate = '{year}-{month}-{day}';
  static const String timeRangeTemplate = '{start} - {end}';

  // Fallback labels
  static const String noDescriptionText = 'No description available yet.';
}
