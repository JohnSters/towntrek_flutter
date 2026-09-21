import '../core/json/json_helpers.dart';

class TownFlyerDto {
  final int id;
  final int townId;
  final String imageUrl;
  final String? thumbnailUrl;
  final double latitude;
  final double longitude;
  final String? physicalAddress;
  final String? contactPhone;
  final String? whatsAppDigits;
  final String displayName;
  final DateTime publishedAtUtc;
  final DateTime expiresAtUtc;

  const TownFlyerDto({
    required this.id,
    required this.townId,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.latitude,
    required this.longitude,
    this.physicalAddress,
    this.contactPhone,
    this.whatsAppDigits,
    required this.displayName,
    required this.publishedAtUtc,
    required this.expiresAtUtc,
  });

  factory TownFlyerDto.fromJson(Map<String, dynamic> json) {
    return TownFlyerDto(
      id: JsonHelpers.dualInt(json, 'id', 'Id'),
      townId: JsonHelpers.dualInt(json, 'townId', 'TownId'),
      imageUrl: (json['imageUrl'] ?? json['ImageUrl'] ?? '') as String,
      thumbnailUrl: json['thumbnailUrl'] as String? ?? json['ThumbnailUrl'] as String?,
      latitude: (json['latitude'] as num? ?? json['Latitude'] as num? ?? 0).toDouble(),
      longitude: (json['longitude'] as num? ?? json['Longitude'] as num? ?? 0).toDouble(),
      physicalAddress:
          json['physicalAddress'] as String? ?? json['PhysicalAddress'] as String?,
      contactPhone: json['contactPhone'] as String? ?? json['ContactPhone'] as String?,
      whatsAppDigits:
          json['whatsAppDigits'] as String? ?? json['WhatsAppDigits'] as String?,
      displayName:
          (json['displayName'] ?? json['DisplayName'] ?? 'Neighbour') as String,
      publishedAtUtc: _utc(json['publishedAtUtc'] ?? json['PublishedAtUtc']),
      expiresAtUtc: _utc(json['expiresAtUtc'] ?? json['ExpiresAtUtc']),
    );
  }

  static DateTime _utc(dynamic value) {
    if (value is DateTime) return value.toUtc();
    return DateTime.tryParse(value?.toString() ?? '')?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
}

class TownFlyerQuotaDto {
  final bool communitySlotAvailable;
  final DateTime? communityAvailableAtUtc;
  final int liveOrPendingCount;
  final int liveOrPendingInTownCount;
  final int maxLiveOrPendingPerTown;
  final bool canPostExtra;
  final bool isClient;
  final int imagePoolUsed;
  final int imagePoolMax;
  final bool imagePoolUnlimited;

  const TownFlyerQuotaDto({
    required this.communitySlotAvailable,
    this.communityAvailableAtUtc,
    required this.liveOrPendingCount,
    required this.liveOrPendingInTownCount,
    required this.maxLiveOrPendingPerTown,
    required this.canPostExtra,
    required this.isClient,
    required this.imagePoolUsed,
    required this.imagePoolMax,
    required this.imagePoolUnlimited,
  });

  factory TownFlyerQuotaDto.fromJson(Map<String, dynamic> json) {
    return TownFlyerQuotaDto(
      communitySlotAvailable:
          json['communitySlotAvailable'] as bool? ?? false,
      communityAvailableAtUtc: _utcOrNull(
        json['communityAvailableAtUtc'] ?? json['CommunityAvailableAtUtc'],
      ),
      liveOrPendingCount: (json['liveOrPendingCount'] as num?)?.toInt() ?? 0,
      liveOrPendingInTownCount:
          (json['liveOrPendingInTownCount'] as num?)?.toInt() ?? 0,
      maxLiveOrPendingPerTown:
          (json['maxLiveOrPendingPerTown'] as num?)?.toInt() ?? 3,
      canPostExtra: json['canPostExtra'] as bool? ?? false,
      isClient: json['isClient'] as bool? ?? false,
      imagePoolUsed: (json['imagePoolUsed'] as num?)?.toInt() ?? 0,
      imagePoolMax: (json['imagePoolMax'] as num?)?.toInt() ?? 0,
      imagePoolUnlimited: json['imagePoolUnlimited'] as bool? ?? false,
    );
  }

  static DateTime? _utcOrNull(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value.toUtc();
    return DateTime.tryParse(value.toString())?.toUtc();
  }

  bool get canPostNow =>
      communitySlotAvailable ||
      (canPostExtra &&
          liveOrPendingInTownCount < maxLiveOrPendingPerTown &&
          (imagePoolUnlimited || imagePoolUsed < imagePoolMax));

  bool get needsUpgrade => !communitySlotAvailable && !canPostExtra;

  bool get poolFull =>
      !communitySlotAvailable &&
      canPostExtra &&
      !imagePoolUnlimited &&
      imagePoolUsed >= imagePoolMax;

  bool get townCapFull => liveOrPendingInTownCount >= maxLiveOrPendingPerTown;
}

class TownFlyerCreateResultDto {
  final int id;
  final String status;
  final String message;

  const TownFlyerCreateResultDto({
    required this.id,
    required this.status,
    required this.message,
  });

  factory TownFlyerCreateResultDto.fromJson(Map<String, dynamic> json) {
    return TownFlyerCreateResultDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? '') as String,
      message: (json['message'] ?? '') as String,
    );
  }
}
