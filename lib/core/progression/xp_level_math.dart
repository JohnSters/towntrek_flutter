/// Mirrors server [XpThresholds] for client-side XP bar math after a delta merge.
class XpLevelMath {
  XpLevelMath._();

  static const List<(int minXp, int level)> _tiers = [
    (50000, 12),
    (34000, 11),
    (22000, 10),
    (14000, 9),
    (9000, 8),
    (5500, 7),
    (3200, 6),
    (1800, 5),
    (900, 4),
    (400, 3),
    (150, 2),
    (0, 1),
  ];

  static int minXpForLevel(int level) {
    for (final (minXp, l) in _tiers) {
      if (l == level) return minXp;
    }
    return 0;
  }

  static int recalculateLevel(int totalXp) {
    for (final (minXp, level) in _tiers) {
      if (totalXp >= minXp) return level;
    }
    return 1;
  }

  static int xpIntoCurrentLevel(int totalXp, int currentLevel) {
    final floor = minXpForLevel(currentLevel);
    return (totalXp - floor).clamp(0, 1 << 30);
  }

  static int xpToNextLevel(int totalXp, int currentLevel) {
    if (currentLevel >= 12) return 0;
    final nextFloor = minXpForLevel(currentLevel + 1);
    return (nextFloor - totalXp).clamp(0, 1 << 30);
  }
}
