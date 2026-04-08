import 'package:flutter/material.dart';

import 'package:towntrek_flutter/core/theme/entity_listing_theme.dart';

/// Light/dark listing surfaces and gradients (registered on [ThemeData.extensions]).
@immutable
class EntityListingThemeExtension extends ThemeExtension<EntityListingThemeExtension> {
  final Color pageBg;
  final Color cardBg;
  final Color bodyText;
  final Color footerHint;
  final Color badgeText;
  final Color chipBg;
  final Color chipIconAndLabel;
  final Color backFooterLabel;
  final List<Color> heroGradientStops;
  final Color resultsBand;
  final List<Color> cardHeaderGradientStops;
  final Color textTitle;
  final Color textLocation;
  final Color accent;

  const EntityListingThemeExtension({
    required this.pageBg,
    required this.cardBg,
    required this.bodyText,
    required this.footerHint,
    required this.badgeText,
    required this.chipBg,
    required this.chipIconAndLabel,
    required this.backFooterLabel,
    required this.heroGradientStops,
    required this.resultsBand,
    required this.cardHeaderGradientStops,
    required this.textTitle,
    required this.textLocation,
    required this.accent,
  });

  static const EntityListingThemeExtension light = EntityListingThemeExtension(
    pageBg: Color(0xFFF0F4F8),
    cardBg: Color(0xFFFFFFFF),
    bodyText: Color(0xFF3D5068),
    footerHint: Color(0xFF7A90A4),
    badgeText: Color(0xFF3D5068),
    chipBg: Color(0xFFF0F4F8),
    chipIconAndLabel: Color(0xFF3D5068),
    backFooterLabel: Color(0xFF3D5068),
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

  static const EntityListingThemeExtension dark = EntityListingThemeExtension(
    pageBg: Color(0xFF0F1419),
    cardBg: Color(0xFF1A2332),
    bodyText: Color(0xFFB8C5D6),
    footerHint: Color(0xFF8A9BAE),
    badgeText: Color(0xFFB8C5D6),
    chipBg: Color(0xFF243041),
    chipIconAndLabel: Color(0xFFB0BED0),
    backFooterLabel: Color(0xFF9AADBF),
    heroGradientStops: [
      Color(0xFF152A45),
      Color(0xFF1E3A5C),
      Color(0xFF265080),
    ],
    resultsBand: Color(0xFF122338),
    cardHeaderGradientStops: [Color(0xFF2A3F5A), Color(0xFF1F3250)],
    textTitle: Color(0xFFE8EEF4),
    textLocation: Color(0xFF9BB4D4),
    accent: Color(0xFF64B5F6),
  );

  /// Resolves [EntityListingTheme] for hero/card gradients (same palette all entities).
  EntityListingTheme toListingTheme() => EntityListingTheme(
        heroGradientStops: heroGradientStops,
        resultsBand: resultsBand,
        cardHeaderGradientStops: cardHeaderGradientStops,
        textTitle: textTitle,
        textLocation: textLocation,
        accent: accent,
      );

  @override
  EntityListingThemeExtension copyWith({
    Color? pageBg,
    Color? cardBg,
    Color? bodyText,
    Color? footerHint,
    Color? badgeText,
    Color? chipBg,
    Color? chipIconAndLabel,
    Color? backFooterLabel,
    List<Color>? heroGradientStops,
    Color? resultsBand,
    List<Color>? cardHeaderGradientStops,
    Color? textTitle,
    Color? textLocation,
    Color? accent,
  }) {
    return EntityListingThemeExtension(
      pageBg: pageBg ?? this.pageBg,
      cardBg: cardBg ?? this.cardBg,
      bodyText: bodyText ?? this.bodyText,
      footerHint: footerHint ?? this.footerHint,
      badgeText: badgeText ?? this.badgeText,
      chipBg: chipBg ?? this.chipBg,
      chipIconAndLabel: chipIconAndLabel ?? this.chipIconAndLabel,
      backFooterLabel: backFooterLabel ?? this.backFooterLabel,
      heroGradientStops: heroGradientStops ?? this.heroGradientStops,
      resultsBand: resultsBand ?? this.resultsBand,
      cardHeaderGradientStops:
          cardHeaderGradientStops ?? this.cardHeaderGradientStops,
      textTitle: textTitle ?? this.textTitle,
      textLocation: textLocation ?? this.textLocation,
      accent: accent ?? this.accent,
    );
  }

  @override
  ThemeExtension<EntityListingThemeExtension> lerp(
    ThemeExtension<EntityListingThemeExtension>? other,
    double t,
  ) {
    if (other is! EntityListingThemeExtension) return this;
    List<Color> lerpStops(List<Color> a, List<Color> b) {
      final n = a.length;
      if (b.length != n) return t < 0.5 ? a : b;
      return List.generate(
        n,
        (i) => Color.lerp(a[i], b[i], t) ?? a[i],
      );
    }

    return EntityListingThemeExtension(
      pageBg: Color.lerp(pageBg, other.pageBg, t) ?? pageBg,
      cardBg: Color.lerp(cardBg, other.cardBg, t) ?? cardBg,
      bodyText: Color.lerp(bodyText, other.bodyText, t) ?? bodyText,
      footerHint: Color.lerp(footerHint, other.footerHint, t) ?? footerHint,
      badgeText: Color.lerp(badgeText, other.badgeText, t) ?? badgeText,
      chipBg: Color.lerp(chipBg, other.chipBg, t) ?? chipBg,
      chipIconAndLabel:
          Color.lerp(chipIconAndLabel, other.chipIconAndLabel, t) ??
              chipIconAndLabel,
      backFooterLabel:
          Color.lerp(backFooterLabel, other.backFooterLabel, t) ??
              backFooterLabel,
      heroGradientStops:
          lerpStops(heroGradientStops, other.heroGradientStops),
      resultsBand: Color.lerp(resultsBand, other.resultsBand, t) ?? resultsBand,
      cardHeaderGradientStops: lerpStops(
        cardHeaderGradientStops,
        other.cardHeaderGradientStops,
      ),
      textTitle: Color.lerp(textTitle, other.textTitle, t) ?? textTitle,
      textLocation:
          Color.lerp(textLocation, other.textLocation, t) ?? textLocation,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
    );
  }
}

extension EntityListingThemeContext on BuildContext {
  EntityListingThemeExtension get entityListing =>
      Theme.of(this).extension<EntityListingThemeExtension>() ??
      EntityListingThemeExtension.light;

  /// Hero / card header gradients and listing text roles for the current brightness.
  EntityListingTheme get entityListingTheme => entityListing.toListingTheme();
}
