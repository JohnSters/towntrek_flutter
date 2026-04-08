import 'package:flutter/material.dart';

/// Listing-screen hero/card gradients and per-card text roles (design doc §1).
/// Surfaces ([pageBg], [cardBg], etc.) live on [EntityListingThemeExtension] — use
/// `context.entityListing` / `context.entityListingTheme` from [entity_listing_theme_extension.dart].
@immutable
class EntityListingTheme {
  final List<Color> heroGradientStops;
  final Color resultsBand;
  final List<Color> cardHeaderGradientStops;
  final Color textTitle;
  final Color textLocation;
  final Color accent;

  const EntityListingTheme({
    required this.heroGradientStops,
    required this.resultsBand,
    required this.cardHeaderGradientStops,
    required this.textTitle,
    required this.textLocation,
    required this.accent,
  });

  LinearGradient get heroGradient => LinearGradient(
        begin: const Alignment(-0.6, -1.0),
        end: const Alignment(0.6, 1.0),
        colors: heroGradientStops,
      );

  LinearGradient get cardHeaderGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: cardHeaderGradientStops,
      );
}
