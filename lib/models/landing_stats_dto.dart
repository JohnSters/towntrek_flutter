/// Picks a value from API JSON whether the server uses camelCase or PascalCase.
int _landingStatInt(Map<String, dynamic> json, String camel, String pascal) {
  final v = json[camel] ?? json[pascal];
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim()) ?? 0;
  return 0;
}

class LandingStatsDto {
  final int businessCount;
  final int serviceCount;
  final int eventCount;
  final int creativeSpaceCount;
  final int propertyListingCount;
  final int equipmentRentalBusinessCount;
  final int totalListingCount;
  final DateTime? generatedAtUtc;

  const LandingStatsDto({
    required this.businessCount,
    required this.serviceCount,
    required this.eventCount,
    this.creativeSpaceCount = 0,
    this.propertyListingCount = 0,
    this.equipmentRentalBusinessCount = 0,
    this.totalListingCount = 0,
    this.generatedAtUtc,
  });

  factory LandingStatsDto.fromJson(Map<String, dynamic> json) {
    final business = _landingStatInt(json, 'businessCount', 'BusinessCount');
    final services = _landingStatInt(json, 'serviceCount', 'ServiceCount');
    final events = _landingStatInt(json, 'eventCount', 'EventCount');
    final creative =
        _landingStatInt(json, 'creativeSpaceCount', 'CreativeSpaceCount');
    final properties =
        _landingStatInt(json, 'propertyListingCount', 'PropertyListingCount');
    final equipment = _landingStatInt(
      json,
      'equipmentRentalBusinessCount',
      'EquipmentRentalBusinessCount',
    );
    final hasTotalKey = json.containsKey('totalListingCount') ||
        json.containsKey('TotalListingCount');
    final total = hasTotalKey
        ? _landingStatInt(json, 'totalListingCount', 'TotalListingCount')
        : business + services + events + creative + properties;

    final genRaw = json['generatedAtUtc'] ?? json['GeneratedAtUtc'];
    DateTime? generatedAtUtc;
    if (genRaw is String && genRaw.isNotEmpty) {
      generatedAtUtc = DateTime.tryParse(genRaw);
    }

    return LandingStatsDto(
      businessCount: business,
      serviceCount: services,
      eventCount: events,
      creativeSpaceCount: creative,
      propertyListingCount: properties,
      equipmentRentalBusinessCount: equipment,
      totalListingCount: total,
      generatedAtUtc: generatedAtUtc,
    );
  }
}
