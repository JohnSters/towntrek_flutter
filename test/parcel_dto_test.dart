import 'package:flutter_test/flutter_test.dart';
import 'package:towntrek_flutter/models/models.dart';

void main() {
  test('ParcelDetailDto parses server enums and booleans', () {
    final dto = ParcelDetailDto.fromJson({
      'id': 1,
      'townId': 2,
      'requestType': 2,
      'pickupLocation': 'Swellendam',
      'dropoffLocation': 'Cape Town',
      'parcelSize': 3,
      'urgencyLevel': 2,
      'status': 4,
      'createdAt': '2026-04-08T12:00:00Z',
      'expiresAt': '2026-04-09T12:00:00Z',
      'requestedByDisplayName': 'TownTrek Member',
      'requiresPassengerSeat': true,
      'canClaim': false,
      'canMarkPickedUp': false,
      'canMarkDelivered': true,
      'canConfirm': false,
      'canCancel': true,
      'canRate': false,
      'activeClaim': {
        'id': 5,
        'claimedByDisplayName': 'Helper',
        'claimedAt': '2026-04-08T13:00:00Z',
      },
    });

    expect(dto.requestType, ParcelRequestType.routeRequest);
    expect(dto.parcelSize, ParcelSize.large);
    expect(dto.urgencyLevel, UrgencyLevel.today);
    expect(dto.status, ParcelStatus.delivered);
    expect(dto.requiresPassengerSeat, isTrue);
    expect(dto.canMarkDelivered, isTrue);
    expect(dto.activeClaim?.claimedByDisplayName, 'Helper');
  });

  test('TownDto keeps parcel flag in json roundtrip', () {
    final town = TownDto.fromJson({
      'id': 1,
      'name': 'Barrydale',
      'province': 'Western Cape',
      'businessCount': 0,
      'serviceCount': 0,
      'eventCount': 0,
      'propertyListingCount': 0,
      'creativeSpaceCount': 0,
      'equipmentRentalBusinessCount': 0,
      'isParcelBoardEnabled': true,
    });

    expect(town.isParcelBoardEnabled, isTrue);
    expect(town.toJson()['isParcelBoardEnabled'], isTrue);
  });
}
