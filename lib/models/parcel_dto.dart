import 'town_dto.dart';

int _enumInt(dynamic value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime? _parcelDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString())?.toUtc();
}

enum ParcelRequestType { standardParcel, routeRequest }

enum ParcelSize { small, medium, large }

enum UrgencyLevel { flexible, today, urgent }

enum ParcelStatus {
  open,
  claimed,
  pickedUp,
  delivered,
  confirmed,
  cancelled,
  expired,
}

ParcelRequestType _requestTypeFromJson(dynamic value) {
  switch (_enumInt(value, 1)) {
    case 2:
      return ParcelRequestType.routeRequest;
    default:
      return ParcelRequestType.standardParcel;
  }
}

ParcelSize _parcelSizeFromJson(dynamic value) {
  switch (_enumInt(value, 1)) {
    case 2:
      return ParcelSize.medium;
    case 3:
      return ParcelSize.large;
    default:
      return ParcelSize.small;
  }
}

UrgencyLevel _urgencyFromJson(dynamic value) {
  switch (_enumInt(value, 1)) {
    case 2:
      return UrgencyLevel.today;
    case 3:
      return UrgencyLevel.urgent;
    default:
      return UrgencyLevel.flexible;
  }
}

ParcelStatus _parcelStatusFromJson(dynamic value) {
  switch (_enumInt(value, 1)) {
    case 2:
      return ParcelStatus.claimed;
    case 3:
      return ParcelStatus.pickedUp;
    case 4:
      return ParcelStatus.delivered;
    case 5:
      return ParcelStatus.confirmed;
    case 6:
      return ParcelStatus.cancelled;
    case 7:
      return ParcelStatus.expired;
    default:
      return ParcelStatus.open;
  }
}

int _requestTypeToJson(ParcelRequestType value) => switch (value) {
  ParcelRequestType.standardParcel => 1,
  ParcelRequestType.routeRequest => 2,
};

int _parcelSizeToJson(ParcelSize value) => switch (value) {
  ParcelSize.small => 1,
  ParcelSize.medium => 2,
  ParcelSize.large => 3,
};

int _urgencyToJson(UrgencyLevel value) => switch (value) {
  UrgencyLevel.flexible => 1,
  UrgencyLevel.today => 2,
  UrgencyLevel.urgent => 3,
};

class ParcelClaimTimelineDto {
  final int id;
  final String claimedByDisplayName;
  final DateTime claimedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final String? cancelReason;

  const ParcelClaimTimelineDto({
    required this.id,
    required this.claimedByDisplayName,
    required this.claimedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.confirmedAt,
    this.cancelledAt,
    this.cancelReason,
  });

  factory ParcelClaimTimelineDto.fromJson(Map<String, dynamic> json) {
    return ParcelClaimTimelineDto(
      id: (json['id'] as num).toInt(),
      claimedByDisplayName: json['claimedByDisplayName'] as String? ?? 'TownTrek member',
      claimedAt: _parcelDate(json['claimedAt']) ?? DateTime.now().toUtc(),
      pickedUpAt: _parcelDate(json['pickedUpAt']),
      deliveredAt: _parcelDate(json['deliveredAt']),
      confirmedAt: _parcelDate(json['confirmedAt']),
      cancelledAt: _parcelDate(json['cancelledAt']),
      cancelReason: json['cancelReason'] as String?,
    );
  }
}

class ParcelSummaryDto {
  final int id;
  final int townId;
  final ParcelRequestType requestType;
  final String pickupLocation;
  final String dropoffLocation;
  final ParcelSize parcelSize;
  final UrgencyLevel urgencyLevel;
  final String? note;
  final String? thankYouOffer;
  final ParcelStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String requestedByDisplayName;
  final String? routeSummary;
  final DateTime? routeTravelDate;
  final String? routeTravelNote;
  final bool requiresPassengerSeat;

  const ParcelSummaryDto({
    required this.id,
    required this.townId,
    required this.requestType,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.parcelSize,
    required this.urgencyLevel,
    required this.note,
    required this.thankYouOffer,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    required this.requestedByDisplayName,
    required this.routeSummary,
    required this.routeTravelDate,
    required this.routeTravelNote,
    required this.requiresPassengerSeat,
  });

  factory ParcelSummaryDto.fromJson(Map<String, dynamic> json) {
    return ParcelSummaryDto(
      id: (json['id'] as num).toInt(),
      townId: (json['townId'] as num).toInt(),
      requestType: _requestTypeFromJson(json['requestType']),
      pickupLocation: json['pickupLocation'] as String? ?? '',
      dropoffLocation: json['dropoffLocation'] as String? ?? '',
      parcelSize: _parcelSizeFromJson(json['parcelSize']),
      urgencyLevel: _urgencyFromJson(json['urgencyLevel']),
      note: json['note'] as String?,
      thankYouOffer: json['thankYouOffer'] as String?,
      status: _parcelStatusFromJson(json['status']),
      createdAt: _parcelDate(json['createdAt']) ?? DateTime.now().toUtc(),
      expiresAt: _parcelDate(json['expiresAt']) ?? DateTime.now().toUtc(),
      requestedByDisplayName:
          json['requestedByDisplayName'] as String? ?? 'TownTrek member',
      routeSummary: json['routeSummary'] as String?,
      routeTravelDate: _parcelDate(json['routeTravelDate']),
      routeTravelNote: json['routeTravelNote'] as String?,
      requiresPassengerSeat: (json['requiresPassengerSeat'] as bool?) ?? false,
    );
  }

  ParcelSummaryDto copyWith({
    int? id,
    int? townId,
    ParcelRequestType? requestType,
    String? pickupLocation,
    String? dropoffLocation,
    ParcelSize? parcelSize,
    UrgencyLevel? urgencyLevel,
    String? note,
    String? thankYouOffer,
    ParcelStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? requestedByDisplayName,
    String? routeSummary,
    DateTime? routeTravelDate,
    String? routeTravelNote,
    bool? requiresPassengerSeat,
  }) {
    return ParcelSummaryDto(
      id: id ?? this.id,
      townId: townId ?? this.townId,
      requestType: requestType ?? this.requestType,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      parcelSize: parcelSize ?? this.parcelSize,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      note: note ?? this.note,
      thankYouOffer: thankYouOffer ?? this.thankYouOffer,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      requestedByDisplayName:
          requestedByDisplayName ?? this.requestedByDisplayName,
      routeSummary: routeSummary ?? this.routeSummary,
      routeTravelDate: routeTravelDate ?? this.routeTravelDate,
      routeTravelNote: routeTravelNote ?? this.routeTravelNote,
      requiresPassengerSeat:
          requiresPassengerSeat ?? this.requiresPassengerSeat,
    );
  }
}

class ParcelDetailDto extends ParcelSummaryDto {
  final String? fullPickupAddress;
  final String? fullDropoffAddress;
  final String? cancelReason;
  final DateTime? cancelledAt;
  final ParcelClaimTimelineDto? activeClaim;
  final bool isRequester;
  final bool isClaimer;
  final bool canClaim;
  final bool canMarkPickedUp;
  final bool canMarkDelivered;
  final bool canConfirm;
  final bool canCancel;
  final bool canRate;

  const ParcelDetailDto({
    required super.id,
    required super.townId,
    required super.requestType,
    required super.pickupLocation,
    required super.dropoffLocation,
    required super.parcelSize,
    required super.urgencyLevel,
    required super.note,
    required super.thankYouOffer,
    required super.status,
    required super.createdAt,
    required super.expiresAt,
    required super.requestedByDisplayName,
    required super.routeSummary,
    required super.routeTravelDate,
    required super.routeTravelNote,
    required super.requiresPassengerSeat,
    required this.fullPickupAddress,
    required this.fullDropoffAddress,
    required this.cancelReason,
    required this.cancelledAt,
    required this.activeClaim,
    required this.isRequester,
    required this.isClaimer,
    required this.canClaim,
    required this.canMarkPickedUp,
    required this.canMarkDelivered,
    required this.canConfirm,
    required this.canCancel,
    required this.canRate,
  });

  factory ParcelDetailDto.fromJson(Map<String, dynamic> json) {
    return ParcelDetailDto(
      id: (json['id'] as num).toInt(),
      townId: (json['townId'] as num).toInt(),
      requestType: _requestTypeFromJson(json['requestType']),
      pickupLocation: json['pickupLocation'] as String? ?? '',
      dropoffLocation: json['dropoffLocation'] as String? ?? '',
      parcelSize: _parcelSizeFromJson(json['parcelSize']),
      urgencyLevel: _urgencyFromJson(json['urgencyLevel']),
      note: json['note'] as String?,
      thankYouOffer: json['thankYouOffer'] as String?,
      status: _parcelStatusFromJson(json['status']),
      createdAt: _parcelDate(json['createdAt']) ?? DateTime.now().toUtc(),
      expiresAt: _parcelDate(json['expiresAt']) ?? DateTime.now().toUtc(),
      requestedByDisplayName:
          json['requestedByDisplayName'] as String? ?? 'TownTrek member',
      routeSummary: json['routeSummary'] as String?,
      routeTravelDate: _parcelDate(json['routeTravelDate']),
      routeTravelNote: json['routeTravelNote'] as String?,
      requiresPassengerSeat: (json['requiresPassengerSeat'] as bool?) ?? false,
      fullPickupAddress: json['fullPickupAddress'] as String?,
      fullDropoffAddress: json['fullDropoffAddress'] as String?,
      cancelReason: json['cancelReason'] as String?,
      cancelledAt: _parcelDate(json['cancelledAt']),
      activeClaim: json['activeClaim'] is Map<String, dynamic>
          ? ParcelClaimTimelineDto.fromJson(
              json['activeClaim'] as Map<String, dynamic>,
            )
          : null,
      isRequester: (json['isRequester'] as bool?) ?? false,
      isClaimer: (json['isClaimer'] as bool?) ?? false,
      canClaim: (json['canClaim'] as bool?) ?? false,
      canMarkPickedUp: (json['canMarkPickedUp'] as bool?) ?? false,
      canMarkDelivered: (json['canMarkDelivered'] as bool?) ?? false,
      canConfirm: (json['canConfirm'] as bool?) ?? false,
      canCancel: (json['canCancel'] as bool?) ?? false,
      canRate: (json['canRate'] as bool?) ?? false,
    );
  }

  @override
  ParcelDetailDto copyWith({
    int? id,
    int? townId,
    ParcelRequestType? requestType,
    String? pickupLocation,
    String? dropoffLocation,
    ParcelSize? parcelSize,
    UrgencyLevel? urgencyLevel,
    String? note,
    String? thankYouOffer,
    ParcelStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? requestedByDisplayName,
    String? routeSummary,
    DateTime? routeTravelDate,
    String? routeTravelNote,
    bool? requiresPassengerSeat,
    String? fullPickupAddress,
    String? fullDropoffAddress,
    String? cancelReason,
    DateTime? cancelledAt,
    ParcelClaimTimelineDto? activeClaim,
    bool? isRequester,
    bool? isClaimer,
    bool? canClaim,
    bool? canMarkPickedUp,
    bool? canMarkDelivered,
    bool? canConfirm,
    bool? canCancel,
    bool? canRate,
  }) {
    return ParcelDetailDto(
      id: id ?? this.id,
      townId: townId ?? this.townId,
      requestType: requestType ?? this.requestType,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      parcelSize: parcelSize ?? this.parcelSize,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      note: note ?? this.note,
      thankYouOffer: thankYouOffer ?? this.thankYouOffer,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      requestedByDisplayName:
          requestedByDisplayName ?? this.requestedByDisplayName,
      routeSummary: routeSummary ?? this.routeSummary,
      routeTravelDate: routeTravelDate ?? this.routeTravelDate,
      routeTravelNote: routeTravelNote ?? this.routeTravelNote,
      requiresPassengerSeat:
          requiresPassengerSeat ?? this.requiresPassengerSeat,
      fullPickupAddress: fullPickupAddress ?? this.fullPickupAddress,
      fullDropoffAddress: fullDropoffAddress ?? this.fullDropoffAddress,
      cancelReason: cancelReason ?? this.cancelReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      activeClaim: activeClaim ?? this.activeClaim,
      isRequester: isRequester ?? this.isRequester,
      isClaimer: isClaimer ?? this.isClaimer,
      canClaim: canClaim ?? this.canClaim,
      canMarkPickedUp: canMarkPickedUp ?? this.canMarkPickedUp,
      canMarkDelivered: canMarkDelivered ?? this.canMarkDelivered,
      canConfirm: canConfirm ?? this.canConfirm,
      canCancel: canCancel ?? this.canCancel,
      canRate: canRate ?? this.canRate,
    );
  }
}

class ParcelBoardResponse {
  final List<ParcelSummaryDto> items;

  const ParcelBoardResponse({required this.items});

  factory ParcelBoardResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? const []);
    return ParcelBoardResponse(
      items: rawItems
          .map((item) => ParcelSummaryDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CreateParcelRequestDto {
  final int townId;
  final ParcelRequestType requestType;
  final String pickupLocation;
  final String dropoffLocation;
  final String fullPickupAddress;
  final String fullDropoffAddress;
  final ParcelSize parcelSize;
  final UrgencyLevel urgencyLevel;
  final String? note;
  final String? thankYouOffer;
  final DateTime expiresAt;
  final String? routeSummary;
  final DateTime? routeTravelDate;
  final String? routeTravelNote;
  final bool requiresPassengerSeat;

  const CreateParcelRequestDto({
    required this.townId,
    required this.requestType,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.fullPickupAddress,
    required this.fullDropoffAddress,
    required this.parcelSize,
    required this.urgencyLevel,
    required this.note,
    required this.thankYouOffer,
    required this.expiresAt,
    required this.routeSummary,
    required this.routeTravelDate,
    required this.routeTravelNote,
    required this.requiresPassengerSeat,
  });

  Map<String, dynamic> toJson() => {
    'townId': townId,
    'requestType': _requestTypeToJson(requestType),
    'pickupLocation': pickupLocation,
    'dropoffLocation': dropoffLocation,
    'fullPickupAddress': fullPickupAddress,
    'fullDropoffAddress': fullDropoffAddress,
    'parcelSize': _parcelSizeToJson(parcelSize),
    'urgencyLevel': _urgencyToJson(urgencyLevel),
    'note': note,
    'thankYouOffer': thankYouOffer,
    'expiresAt': expiresAt.toUtc().toIso8601String(),
    'routeSummary': routeSummary,
    'routeTravelDate': routeTravelDate?.toUtc().toIso8601String(),
    'routeTravelNote': routeTravelNote,
    'requiresPassengerSeat': requiresPassengerSeat,
  };
}

class TownScopedParcelEntry {
  final TownDto town;
  final ParcelSummaryDto parcel;

  const TownScopedParcelEntry({required this.town, required this.parcel});
}
