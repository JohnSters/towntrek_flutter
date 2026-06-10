import '../core/json/json_helpers.dart';

part 'member_xp_dto.dart';
part 'member_achievement_dto.dart';
part 'member_leaderboard_dto.dart';

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
