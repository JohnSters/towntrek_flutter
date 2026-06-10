part of 'parcel_dto.dart';

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
  final RouteListingPerspective? routeListingPerspective;

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
    this.routeListingPerspective,
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
    if (routeListingPerspective != null)
      'routeListingPerspective':
          _routeListingPerspectiveToJson(routeListingPerspective!),
  };
}

class TownScopedParcelEntry {
  final TownDto town;
  final ParcelSummaryDto parcel;

  const TownScopedParcelEntry({required this.town, required this.parcel});
}
