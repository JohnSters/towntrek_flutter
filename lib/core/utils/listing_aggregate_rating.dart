/// Helpers for showing API aggregate ratings on listing and detail UIs.
///
/// Prefer showing `"score (count)"` when [totalReviews] &gt; 0. If the score is
/// present but the count is zero (stale API / denormalized drift), show the
/// score alone — never `"score (0)"` and never hide a real score as "no reviews".
bool shouldShowAggregateRating(double? rating, int totalReviews) =>
    rating != null;

/// Compact badge text for listing cards (e.g. `"4.2 (12)"`, `"4.2"`, or [noReviewsLabel]).
String aggregateRatingBadgeLabel({
  required double? rating,
  required int totalReviews,
  required String noReviewsLabel,
}) {
  if (rating == null) {
    return noReviewsLabel;
  }
  if (totalReviews > 0) {
    return '${rating.toStringAsFixed(1)} ($totalReviews)';
  }
  return rating.toStringAsFixed(1);
}
