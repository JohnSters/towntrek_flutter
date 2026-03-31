import 'package:flutter/material.dart';

/// Listing-screen palette (Entity Listing Screen design system §1).
/// All entity variants share the same tokens; distinct static names remain for call-site clarity.
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

  static const Color pageBg = Color(0xFFF0F4F8);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color bodyText = Color(0xFF3D5068);
  static const Color footerHint = Color(0xFF7A90A4);
  static const Color badgeText = Color(0xFF3D5068);
  static const Color chipBg = Color(0xFFF0F4F8);
  static const Color chipIconAndLabel = Color(0xFF3D5068);
  static const Color backFooterLabel = Color(0xFF3D5068);

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

  /// Shops & retail / general businesses (design doc defaults).
  static const EntityListingTheme business = EntityListingTheme(
    heroGradientStops: [
      Color(0xFF0D2D5A),
      Color(0xFF1A4F8F),
      Color(0xFF1D6BB5),
    ],
    resultsBand: Color(0xFF1A3A62),
    cardHeaderGradientStops: [Color(0xFFDDEAF9), Color(0xFFC8DDF5)],
    textTitle: Color(0xFF0D2D5A),
    textLocation: Color(0xFF3D6A9E),
    accent: Color(0xFF1A4F8F),
  );

  /// Equipment rentals — same palette as businesses (design doc §8).
  static const EntityListingTheme equipmentRentals = business;

  /// Services — unified listing palette (design doc §1).
  static const EntityListingTheme services = business;

  /// Events — unified listing palette (design doc §1).
  static const EntityListingTheme events = business;

  /// Creative spaces — unified listing palette (design doc §1).
  static const EntityListingTheme creativeSpaces = business;

  /// Properties — unified listing palette (design doc §1).
  static const EntityListingTheme properties = business;
}
