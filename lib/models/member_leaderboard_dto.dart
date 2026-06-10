part of 'member_progression_dto.dart';

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
