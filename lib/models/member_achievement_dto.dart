part of 'member_progression_dto.dart';

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
      unlockedAt: JsonHelpers.utcDate(json['unlockedAt']),
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
