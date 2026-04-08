import 'package:flutter/widgets.dart';

/// Shared layout and copy for entity listing screens (search bar, empty search).
class EntityListingConstants {
  EntityListingConstants._();

  /// Space below [ListingResultsBand] before the next row (search, first card,
  /// loading area). Matches typical vertical gaps between listing cards on browse
  /// screens (e.g. creative spaces card spacing). Scroll views that sit directly
  /// under the band should use top padding 0 so this is the only gap.
  static const double contentBelowResultsBand = 10.0;

  /// Padding around the search row (below results band). Bottom is 0 so the gap
  /// to cards is controlled only by [cardListScrollPadding.top].
  static const EdgeInsets searchBarSectionPadding =
      EdgeInsets.fromLTRB(16, 12, 16, 0);

  /// Scroll padding for card lists directly under the search bar. Top is the
  /// vertical gap between search field and first card (keep in sync everywhere).
  static const EdgeInsets cardListScrollPadding =
      EdgeInsets.fromLTRB(16, 16, 16, 20);

  static const double searchBarRadius = 14.0;
  static const double searchBarContentPadding = 12.0;
  static const String clearSearchLabel = 'Clear search';
  /// Listing cards (business, service, creative space, etc.): hours-style pill.
  static const String listingCardOpenNow = 'Open now';
  static const String listingCardClosed = 'Closed';
  /// Closed due to date override (or server closed while weekly template still says open).
  static const String listingCardClosedSpecialHours = 'Closed · Special hours';
  static const String searchNoMatchesHint =
      'Try a different keyword or clear your search.';
  static const String propertySearchHint =
      'Search by address, owner, or keyword';
  static const String eventSearchHint = 'Search by name, venue, or type';
}
