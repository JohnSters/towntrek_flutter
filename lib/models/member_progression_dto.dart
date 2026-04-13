DateTime? _offsetDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value.toUtc();
  return DateTime.tryParse(value.toString())?.toUtc();
}

class XpDeltaDto {
  const XpDeltaDto({
    required this.awarded,
    required this.newTotal,
    required this.currentLevel,
    required this.leveledUp,
    this.newLevelTitle,
    required this.achievementsUnlocked,
  });

  final int awarded;
  final int newTotal;
  final int currentLevel;
  final bool leveledUp;
  final String? newLevelTitle;
  final List<String> achievementsUnlocked;

  factory XpDeltaDto.fromJson(Map<String, dynamic> json) {
    final ach = (json['achievementsUnlocked'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();
    return XpDeltaDto(
      awarded: (json['awarded'] as num?)?.toInt() ?? 0,
      newTotal: (json['newTotal'] as num?)?.toInt() ?? 0,
      currentLevel: (json['currentLevel'] as num?)?.toInt() ?? 1,
      leveledUp: json['leveledUp'] as bool? ?? false,
      newLevelTitle: json['newLevelTitle'] as String?,
      achievementsUnlocked: ach,
    );
  }

  bool get hasAward => awarded > 0 || achievementsUnlocked.isNotEmpty || leveledUp;
}

class XpHistoryItemDto {
  const XpHistoryItemDto({
    required this.id,
    required this.eventLabel,
    required this.amount,
    this.note,
    required this.awardedAt,
  });

  final int id;
  final String eventLabel;
  final int amount;
  final String? note;
  final DateTime awardedAt;

  factory XpHistoryItemDto.fromJson(Map<String, dynamic> json) {
    return XpHistoryItemDto(
      id: (json['id'] as num).toInt(),
      eventLabel: json['eventLabel'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      note: json['note'] as String?,
      awardedAt: _offsetDate(json['awardedAt']) ?? DateTime.now().toUtc(),
    );
  }
}

class AchievementItemDto {
  const AchievementItemDto({
    required this.key,
    required this.displayName,
    required this.xpValue,
    required this.unlocked,
    this.unlockedAt,
  });

  final String key;
  final String displayName;
  final int xpValue;
  final bool unlocked;
  final DateTime? unlockedAt;

  factory AchievementItemDto.fromJson(Map<String, dynamic> json) {
    return AchievementItemDto(
      key: json['key'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      xpValue: (json['xpValue'] as num?)?.toInt() ?? 0,
      unlocked: json['unlocked'] as bool? ?? false,
      unlockedAt: _offsetDate(json['unlockedAt']),
    );
  }
}

class AchievementSetProgressDto {
  const AchievementSetProgressDto({
    required this.setKey,
    required this.setName,
    required this.isComplete,
    required this.unlockedCount,
    required this.totalCount,
    required this.achievements,
  });

  final String setKey;
  final String setName;
  final bool isComplete;
  final int unlockedCount;
  final int totalCount;
  final List<AchievementItemDto> achievements;

  factory AchievementSetProgressDto.fromJson(Map<String, dynamic> json) {
    final raw = (json['achievements'] as List<dynamic>? ?? const []);
    return AchievementSetProgressDto(
      setKey: json['setKey'] as String? ?? '',
      setName: json['setName'] as String? ?? '',
      isComplete: json['isComplete'] as bool? ?? false,
      unlockedCount: (json['unlockedCount'] as num?)?.toInt() ?? 0,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      achievements: raw
          .map((e) => AchievementItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MemberProgressionDto {
  const MemberProgressionDto({
    required this.totalXp,
    required this.currentLevel,
    required this.currentLevelTitle,
    required this.xpIntoLevel,
    required this.xpForNext,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.showOnLeaderboard,
    required this.leaderboardDisclosureSeen,
    required this.completedSetIds,
    required this.achievementSets,
    required this.recentAwards,
  });

  final int totalXp;
  final int currentLevel;
  final String currentLevelTitle;
  final int xpIntoLevel;
  final int xpForNext;
  final int currentStreakDays;
  final int longestStreakDays;
  final bool showOnLeaderboard;
  final bool leaderboardDisclosureSeen;
  final List<String> completedSetIds;
  final List<AchievementSetProgressDto> achievementSets;
  final List<XpHistoryItemDto> recentAwards;

  factory MemberProgressionDto.fromJson(Map<String, dynamic> json) {
    final sets = (json['achievementSets'] as List<dynamic>? ?? const [])
        .map((e) => AchievementSetProgressDto.fromJson(e as Map<String, dynamic>))
        .toList();
    final recent = (json['recentAwards'] as List<dynamic>? ?? const [])
        .map((e) => XpHistoryItemDto.fromJson(e as Map<String, dynamic>))
        .toList();
    final completed = (json['completedSetIds'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();
    return MemberProgressionDto(
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      currentLevel: (json['currentLevel'] as num?)?.toInt() ?? 1,
      currentLevelTitle: json['currentLevelTitle'] as String? ?? 'Passerby',
      xpIntoLevel: (json['xpIntoLevel'] as num?)?.toInt() ?? 0,
      xpForNext: (json['xpForNext'] as num?)?.toInt() ?? 0,
      currentStreakDays: (json['currentStreakDays'] as num?)?.toInt() ?? 0,
      longestStreakDays: (json['longestStreakDays'] as num?)?.toInt() ?? 0,
      showOnLeaderboard: json['showOnLeaderboard'] as bool? ?? true,
      leaderboardDisclosureSeen:
          json['leaderboardDisclosureSeen'] as bool? ?? false,
      completedSetIds: completed,
      achievementSets: sets,
      recentAwards: recent,
    );
  }

  MemberProgressionDto copyWith({
    int? totalXp,
    int? currentLevel,
    String? currentLevelTitle,
    int? xpIntoLevel,
    int? xpForNext,
    int? currentStreakDays,
    int? longestStreakDays,
    bool? showOnLeaderboard,
    bool? leaderboardDisclosureSeen,
    List<String>? completedSetIds,
    List<AchievementSetProgressDto>? achievementSets,
    List<XpHistoryItemDto>? recentAwards,
  }) {
    return MemberProgressionDto(
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      currentLevelTitle: currentLevelTitle ?? this.currentLevelTitle,
      xpIntoLevel: xpIntoLevel ?? this.xpIntoLevel,
      xpForNext: xpForNext ?? this.xpForNext,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      longestStreakDays: longestStreakDays ?? this.longestStreakDays,
      showOnLeaderboard: showOnLeaderboard ?? this.showOnLeaderboard,
      leaderboardDisclosureSeen:
          leaderboardDisclosureSeen ?? this.leaderboardDisclosureSeen,
      completedSetIds: completedSetIds ?? this.completedSetIds,
      achievementSets: achievementSets ?? this.achievementSets,
      recentAwards: recentAwards ?? this.recentAwards,
    );
  }
}

class LeaderboardRowDto {
  const LeaderboardRowDto({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.level,
    required this.levelTitle,
    required this.xpValue,
    required this.isCurrentUser,
  });

  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int level;
  final String levelTitle;
  final int xpValue;
  final bool isCurrentUser;

  factory LeaderboardRowDto.fromJson(Map<String, dynamic> json) {
    return LeaderboardRowDto(
      userId: json['userId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      level: (json['level'] as num?)?.toInt() ?? 1,
      levelTitle: json['levelTitle'] as String? ?? '',
      xpValue: (json['xpValue'] as num?)?.toInt() ?? 0,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );
  }
}

class LeaderboardResponseDto {
  const LeaderboardResponseDto({
    required this.rows,
    required this.seasonKey,
  });

  final List<LeaderboardRowDto> rows;
  final String seasonKey;

  factory LeaderboardResponseDto.fromJson(Map<String, dynamic> json) {
    final raw = (json['rows'] as List<dynamic>? ?? const []);
    return LeaderboardResponseDto(
      rows: raw
          .map((e) => LeaderboardRowDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      seasonKey: json['seasonKey'] as String? ?? 'alltime',
    );
  }
}

class XpHistoryPageDto {
  const XpHistoryPageDto({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<XpHistoryItemDto> items;
  final int total;
  final int page;
  final int pageSize;

  factory XpHistoryPageDto.fromJson(Map<String, dynamic> json) {
    final raw = (json['items'] as List<dynamic>? ?? const []);
    return XpHistoryPageDto(
      items: raw
          .map((e) => XpHistoryItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
    );
  }
}
