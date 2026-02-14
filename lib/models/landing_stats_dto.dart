class LandingStatsDto {
  final int businessCount;
  final int serviceCount;
  final int eventCount;
  final DateTime? generatedAtUtc;

  const LandingStatsDto({
    required this.businessCount,
    required this.serviceCount,
    required this.eventCount,
    required this.generatedAtUtc,
  });

  factory LandingStatsDto.fromJson(Map<String, dynamic> json) {
    return LandingStatsDto(
      businessCount: (json['businessCount'] as num?)?.toInt() ?? 0,
      serviceCount: (json['serviceCount'] as num?)?.toInt() ?? 0,
      eventCount: (json['eventCount'] as num?)?.toInt() ?? 0,
      generatedAtUtc: DateTime.tryParse((json['generatedAtUtc'] as String?) ?? ''),
    );
  }
}


