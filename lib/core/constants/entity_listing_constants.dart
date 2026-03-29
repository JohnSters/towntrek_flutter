import 'package:flutter/widgets.dart';

/// Shared layout and copy for entity listing screens (search bar, empty search).
class EntityListingConstants {
  EntityListingConstants._();

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
  static const String searchNoMatchesHint =
      'Try a different keyword or clear your search.';
  static const String propertySearchHint =
      'Search by address, owner, or keyword';
  static const String eventSearchHint = 'Search by name, venue, or type';
}
