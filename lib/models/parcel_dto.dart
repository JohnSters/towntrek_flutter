import '../core/json/json_helpers.dart';
import 'member_progression_dto.dart';
import 'town_dto.dart';

part 'parcel_summary_dto.dart';
part 'parcel_request_dto.dart';

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

/// Server: 1 = need a lift, 2 = offering a ride. Null/omitted = legacy or unknown (see migration runbook).
enum RouteListingPerspective { needLift, offeringLift }

RouteListingPerspective? _routeListingPerspectiveFromJson(dynamic value) {
  if (value == null) return null;
  switch (JsonHelpers.enumInt(value, -1)) {
    case 1:
      return RouteListingPerspective.needLift;
    case 2:
      return RouteListingPerspective.offeringLift;
    default:
      return null;
  }
}

int _routeListingPerspectiveToJson(RouteListingPerspective value) => switch (value) {
  RouteListingPerspective.needLift => 1,
  RouteListingPerspective.offeringLift => 2,
};

ParcelRequestType _requestTypeFromJson(dynamic value) {
  switch (JsonHelpers.enumInt(value, 1)) {
    case 2:
      return ParcelRequestType.routeRequest;
    default:
      return ParcelRequestType.standardParcel;
  }
}

ParcelSize _parcelSizeFromJson(dynamic value) {
  switch (JsonHelpers.enumInt(value, 1)) {
    case 2:
      return ParcelSize.medium;
    case 3:
      return ParcelSize.large;
    default:
      return ParcelSize.small;
  }
}

UrgencyLevel _urgencyFromJson(dynamic value) {
  switch (JsonHelpers.enumInt(value, 1)) {
    case 2:
      return UrgencyLevel.today;
    case 3:
      return UrgencyLevel.urgent;
    default:
      return UrgencyLevel.flexible;
  }
}

ParcelStatus _parcelStatusFromJson(dynamic value) {
  switch (JsonHelpers.enumInt(value, 1)) {
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
