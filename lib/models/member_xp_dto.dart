part of 'member_progression_dto.dart';

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
      awardedAt: JsonHelpers.utcDate(json['awardedAt']) ?? DateTime.now().toUtc(),
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
