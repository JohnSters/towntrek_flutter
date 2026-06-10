import '../core/json/json_helpers.dart';

/// Picks a value from API JSON whether the server uses camelCase or PascalCase.
class LandingStatsDto {
  final int businessCount;
  final int serviceCount;
  final int eventCount;
  final int creativeSpaceCount;
  final int propertyListingCount;
  final int equipmentRentalBusinessCount;
  final int totalListingCount;
  final String? infoBannerMessage;
  final String? issueBannerMessage;
  final DateTime? generatedAtUtc;

  const LandingStatsDto({
    required this.businessCount,
    required this.serviceCount,
    required this.eventCount,
    this.creativeSpaceCount = 0,
    this.propertyListingCount = 0,
    this.equipmentRentalBusinessCount = 0,
    this.totalListingCount = 0,
    this.infoBannerMessage,
    this.issueBannerMessage,
    this.generatedAtUtc,
  });

  factory LandingStatsDto.fromJson(Map<String, dynamic> json) {
    final business = JsonHelpers.dualInt(json, 'businessCount', 'BusinessCount');
    final services = JsonHelpers.dualInt(json, 'serviceCount', 'ServiceCount');
    final events = JsonHelpers.dualInt(json, 'eventCount', 'EventCount');
    final creative =
        JsonHelpers.dualInt(json, 'creativeSpaceCount', 'CreativeSpaceCount');
    final properties =
        JsonHelpers.dualInt(json, 'propertyListingCount', 'PropertyListingCount');
    final equipment = JsonHelpers.dualInt(
      json,
      'equipmentRentalBusinessCount',
      'EquipmentRentalBusinessCount',
    );
    final hasTotalKey = json.containsKey('totalListingCount') ||
        json.containsKey('TotalListingCount');
    final total = hasTotalKey
        ? JsonHelpers.dualInt(json, 'totalListingCount', 'TotalListingCount')
        : business + services + events + creative + properties;
    final infoBannerMessage = JsonHelpers.dualString(
      json,
      'infoBannerMessage',
      'InfoBannerMessage',
    );
    final issueBannerMessage = JsonHelpers.dualString(
      json,
      'issueBannerMessage',
      'IssueBannerMessage',
    );

    final generatedAtUtc = JsonHelpers.utcDate(
      JsonHelpers.dualKey(json, 'generatedAtUtc', 'GeneratedAtUtc'),
    );

    return LandingStatsDto(
      businessCount: business,
      serviceCount: services,
      eventCount: events,
      creativeSpaceCount: creative,
      propertyListingCount: properties,
      equipmentRentalBusinessCount: equipment,
      totalListingCount: total,
      infoBannerMessage: infoBannerMessage,
      issueBannerMessage: issueBannerMessage,
      generatedAtUtc: generatedAtUtc,
    );
  }
}
