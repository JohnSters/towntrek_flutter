import 'package:flutter/material.dart';

/// Premium listing-screen palette per TownTrek pillar (hero, results band, card header, accents).
/// Layout and typography tokens live in the design doc; colors are centralized here.
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

  /// Equipment rentals — deep bronze / amber (pillar: amber).
  static const EntityListingTheme equipmentRentals = EntityListingTheme(
    heroGradientStops: [
      Color(0xFF3D2914),
      Color(0xFF5C3D1A),
      Color(0xFF7A4F18),
    ],
    resultsBand: Color(0xFF4A3318),
    cardHeaderGradientStops: [Color(0xFFF3E8D8), Color(0xFFE8D4BC)],
    textTitle: Color(0xFF2A1C0C),
    textLocation: Color(0xFF6B4A28),
    accent: Color(0xFF8B5A1F),
  );

  /// Services — deep burnt copper (pillar: orange 800).
  static const EntityListingTheme services = EntityListingTheme(
    heroGradientStops: [
      Color(0xFF3D2208),
      Color(0xFF5C320C),
      Color(0xFF7A4410),
    ],
    resultsBand: Color(0xFF4A280A),
    cardHeaderGradientStops: [Color(0xFFF5E8DA), Color(0xFFEDD4C4)],
    textTitle: Color(0xFF2E1806),
    textLocation: Color(0xFF7A4A22),
    accent: Color(0xFF9A5010),
  );

  /// Events — deep plum (pillar: purple 800).
  static const EntityListingTheme events = EntityListingTheme(
    heroGradientStops: [
      Color(0xFF2A0D38),
      Color(0xFF421858),
      Color(0xFF5A2470),
    ],
    resultsBand: Color(0xFF341248),
    cardHeaderGradientStops: [Color(0xFFEDE6F5), Color(0xFFE0D4F0)],
    textTitle: Color(0xFF220830),
    textLocation: Color(0xFF5C4080),
    accent: Color(0xFF6B3D8C),
  );

  /// Creative spaces — deep wine / rose (pillar: rose 700).
  static const EntityListingTheme creativeSpaces = EntityListingTheme(
    heroGradientStops: [
      Color(0xFF3D0C20),
      Color(0xFF5C1430),
      Color(0xFF7A1F42),
    ],
    resultsBand: Color(0xFF481028),
    cardHeaderGradientStops: [Color(0xFFF5DEE8), Color(0xFFF0CEDC)],
    textTitle: Color(0xFF2E0818),
    textLocation: Color(0xFF8B4560),
    accent: Color(0xFF9E3058),
  );

  /// Properties — deep forest (pillar: green 800).
  static const EntityListingTheme properties = EntityListingTheme(
    heroGradientStops: [
      Color(0xFF0D2810),
      Color(0xFF1A4520),
      Color(0xFF245A2E),
    ],
    resultsBand: Color(0xFF143818),
    cardHeaderGradientStops: [Color(0xFFE0EFE4), Color(0xFFCFE8D6)],
    textTitle: Color(0xFF0A2210),
    textLocation: Color(0xFF2D6B3A),
    accent: Color(0xFF1F6B32),
  );
}
