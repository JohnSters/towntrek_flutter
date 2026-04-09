import 'package:flutter/material.dart';

/// Visual tokens per member level (1–12). Matches server [XpThresholds] titles.
/// [perkTagline] is client-only marketing copy; product may revise wording.
class TierStyle {
  const TierStyle({
    required this.accentColor,
    required this.ringColor,
    required this.title,
    required this.labelColorLight,
    required this.labelColorDark,
    required this.perkTagline,
  });

  final Color accentColor;
  final Color ringColor;
  final String title;
  final Color labelColorLight;
  final Color labelColorDark;
  final String perkTagline;
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
    perkTagline: 'Browse the board and learn how parcels work',
  ),
  2: TierStyle(
    accentColor: _c('0D9488'),
    ringColor: _c('5EEAD4'),
    title: 'Newcomer',
    labelColorLight: _c('115E59'),
    labelColorDark: _c('99F6E4'),
    perkTagline: 'Post parcel and route requests for your town',
  ),
  3: TierStyle(
    accentColor: _c('2563EB'),
    ringColor: _c('93C5FD'),
    title: 'Resident',
    labelColorLight: _c('1E3A8A'),
    labelColorDark: _c('BFDBFE'),
    perkTagline: 'Claim deliveries and grow your reputation',
  ),
  4: TierStyle(
    accentColor: _c('7C3AED'),
    ringColor: _c('C4B5FD'),
    title: 'Neighbour',
    labelColorLight: _c('4C1D95'),
    labelColorDark: _c('DDD6FE'),
    perkTagline: 'Stronger trust signals across the community',
  ),
  5: TierStyle(
    accentColor: _c('059669'),
    ringColor: _c('6EE7B7'),
    title: 'Local',
    labelColorLight: _c('064E3B'),
    labelColorDark: _c('A7F3D0'),
    perkTagline: 'Stand out as an active local helper',
  ),
  6: TierStyle(
    accentColor: _c('D97706'),
    ringColor: _c('FCD34D'),
    title: 'Regular',
    labelColorLight: _c('78350F'),
    labelColorDark: _c('FDE68A'),
    perkTagline: 'Route requests and steady participation',
  ),
  7: TierStyle(
    accentColor: _c('DC2626'),
    ringColor: _c('FCA5A5'),
    title: 'Town Voice',
    labelColorLight: _c('7F1D1D'),
    labelColorDark: _c('FECACA'),
    perkTagline: 'Recognised contributor around town',
  ),
  8: TierStyle(
    accentColor: _c('B45309'),
    ringColor: _c('FDBA74'),
    title: 'Town Pillar',
    labelColorLight: _c('7C2D12'),
    labelColorDark: _c('FED7AA'),
    perkTagline: 'Profile flair and community visibility',
  ),
  9: TierStyle(
    accentColor: _c('BE185D'),
    ringColor: _c('F9A8D4'),
    title: 'Town Champion',
    labelColorLight: _c('831843'),
    labelColorDark: _c('FBCFE8'),
    perkTagline: 'Early looks at new TownTrek experiments',
  ),
  10: TierStyle(
    accentColor: _c('0369A1'),
    ringColor: _c('7DD3FC'),
    title: 'TownTrek Legend',
    labelColorLight: _c('0C4A6E'),
    labelColorDark: _c('E0F2FE'),
    perkTagline: 'Legend badge and top-tier profile polish',
  ),
  11: TierStyle(
    accentColor: _c('A16207'),
    ringColor: _c('FDE047'),
    title: 'TownTrek Hero',
    labelColorLight: _c('713F12'),
    labelColorDark: _c('FEF08A'),
    perkTagline: 'Hero tier recognition on leaderboards',
  ),
  12: TierStyle(
    accentColor: _c('4F46E5'),
    ringColor: _c('C7D2FE'),
    title: 'TownTrek Elite',
    labelColorLight: _c('312E81'),
    labelColorDark: _c('E0E7FF'),
    perkTagline: 'Elite standing and seasonal prestige',
  ),
};

TierStyle tierStyleForLevel(int level) =>
    memberLevelTierStyle[level.clamp(1, 12)] ?? memberLevelTierStyle[1]!;

/// Accent colors for achievement-set card gradients (rotates by index).
final List<Color> achievementSetCardAccents = [
  memberLevelTierStyle[3]!.accentColor,
  memberLevelTierStyle[5]!.accentColor,
  memberLevelTierStyle[7]!.accentColor,
  memberLevelTierStyle[4]!.accentColor,
  memberLevelTierStyle[6]!.accentColor,
  memberLevelTierStyle[9]!.accentColor,
  memberLevelTierStyle[10]!.accentColor,
];
