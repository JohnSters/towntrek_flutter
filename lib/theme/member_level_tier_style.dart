import 'package:flutter/material.dart';

/// Visual tokens per member level (1–12). Matches parcel board polish style.
class TierStyle {
  const TierStyle({
    required this.accentColor,
    required this.ringColor,
    required this.title,
    required this.labelColorLight,
    required this.labelColorDark,
  });

  final Color accentColor;
  final Color ringColor;
  final String title;
  final Color labelColorLight;
  final Color labelColorDark;
}

Color _c(String hex) => Color(int.parse('FF$hex', radix: 16));

/// Level → style (titles align with server [XpThresholds]).
final Map<int, TierStyle> memberLevelTierStyle = {
  1: TierStyle(
    accentColor: _c('6B7280'),
    ringColor: _c('9CA3AF'),
    title: 'Passerby',
    labelColorLight: _c('374151'),
    labelColorDark: _c('E5E7EB'),
  ),
  2: TierStyle(
    accentColor: _c('0D9488'),
    ringColor: _c('5EEAD4'),
    title: 'Newcomer',
    labelColorLight: _c('115E59'),
    labelColorDark: _c('99F6E4'),
  ),
  3: TierStyle(
    accentColor: _c('2563EB'),
    ringColor: _c('93C5FD'),
    title: 'Resident',
    labelColorLight: _c('1E3A8A'),
    labelColorDark: _c('BFDBFE'),
  ),
  4: TierStyle(
    accentColor: _c('7C3AED'),
    ringColor: _c('C4B5FD'),
    title: 'Neighbour',
    labelColorLight: _c('4C1D95'),
    labelColorDark: _c('DDD6FE'),
  ),
  5: TierStyle(
    accentColor: _c('059669'),
    ringColor: _c('6EE7B7'),
    title: 'Local',
    labelColorLight: _c('064E3B'),
    labelColorDark: _c('A7F3D0'),
  ),
  6: TierStyle(
    accentColor: _c('D97706'),
    ringColor: _c('FCD34D'),
    title: 'Regular',
    labelColorLight: _c('78350F'),
    labelColorDark: _c('FDE68A'),
  ),
  7: TierStyle(
    accentColor: _c('DC2626'),
    ringColor: _c('FCA5A5'),
    title: 'Town Voice',
    labelColorLight: _c('7F1D1D'),
    labelColorDark: _c('FECACA'),
  ),
  8: TierStyle(
    accentColor: _c('B45309'),
    ringColor: _c('FDBA74'),
    title: 'Town Pillar',
    labelColorLight: _c('7C2D12'),
    labelColorDark: _c('FED7AA'),
  ),
  9: TierStyle(
    accentColor: _c('BE185D'),
    ringColor: _c('F9A8D4'),
    title: 'Town Champion',
    labelColorLight: _c('831843'),
    labelColorDark: _c('FBCFE8'),
  ),
  10: TierStyle(
    accentColor: _c('0369A1'),
    ringColor: _c('7DD3FC'),
    title: 'TownTrek Legend',
    labelColorLight: _c('0C4A6E'),
    labelColorDark: _c('E0F2FE'),
  ),
  11: TierStyle(
    accentColor: _c('A16207'),
    ringColor: _c('FDE047'),
    title: 'TownTrek Hero',
    labelColorLight: _c('713F12'),
    labelColorDark: _c('FEF08A'),
  ),
  12: TierStyle(
    accentColor: _c('4F46E5'),
    ringColor: _c('C7D2FE'),
    title: 'TownTrek Elite',
    labelColorLight: _c('312E81'),
    labelColorDark: _c('E0E7FF'),
  ),
};

TierStyle tierStyleForLevel(int level) =>
    memberLevelTierStyle[level.clamp(1, 12)] ?? memberLevelTierStyle[1]!;
