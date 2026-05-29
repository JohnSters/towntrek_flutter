import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';

class PostRequestViewModel extends ChangeNotifier {
  PostRequestViewModel({
    required this.town,
    required ParcelRepository repository,
  }) : _repository = repository;

  final TownDto town;
  final ParcelRepository _repository;

  final formKey = GlobalKey<FormState>();
  final pickupController = TextEditingController();
  final dropoffController = TextEditingController();
  final fullPickupController = TextEditingController();
  final fullDropoffController = TextEditingController();
  final noteController = TextEditingController();
  final thankYouController = TextEditingController();
  final routeSummaryController = TextEditingController();
  final routeTravelNoteController = TextEditingController();

  ParcelRequestType requestType = ParcelRequestType.standardParcel;
  RouteListingPerspective routeListingPerspective =
      RouteListingPerspective.needLift;
  ParcelSize parcelSize = ParcelSize.small;
  UrgencyLevel urgencyLevel = UrgencyLevel.flexible;
  DateTime expiresAt = DateTime.now().toUtc().add(const Duration(days: 2));
  DateTime? routeTravelDate;
  /// For NeedLift: true = traveller needs a seat; false = sending goods only with someone's trip.
  bool requiresPassengerSeat = false;
  bool submitting = false;

  void setRequestType(ParcelRequestType value) {
    requestType = value;
    if (value == ParcelRequestType.standardParcel) {
      requiresPassengerSeat = false;
      routeListingPerspective = RouteListingPerspective.needLift;
    } else {
      if (!kEnableOfferingLiftRoutePost) {
        routeListingPerspective = RouteListingPerspective.needLift;
      }
      requiresPassengerSeat = true;
    }
    notifyListeners();
  }

  void setRouteListingPerspective(RouteListingPerspective value) {
    if (!kEnableOfferingLiftRoutePost &&
        value == RouteListingPerspective.offeringLift) {
      return;
    }
    routeListingPerspective = value;
    notifyListeners();
  }

  void setParcelSize(ParcelSize value) {
    parcelSize = value;
    notifyListeners();
  }

  void setUrgency(UrgencyLevel value) {
    urgencyLevel = value;
    notifyListeners();
  }

  void setRequiresPassengerSeat(bool value) {
    requiresPassengerSeat = value;
    notifyListeners();
  }

  void setRouteTravelDate(DateTime? value) {
    routeTravelDate = value;
    notifyListeners();
  }

  Future<ParcelDetailDto?> submit() async {
    if (!formKey.currentState!.validate()) return null;
    submitting = true;
    notifyListeners();
    try {
      final isRoute = requestType == ParcelRequestType.routeRequest;
      final perspective = isRoute
          ? (kEnableOfferingLiftRoutePost
                ? routeListingPerspective
                : RouteListingPerspective.needLift)
          : null;
      final effectiveUrgency =
          isRoute && routeTravelDate != null ? UrgencyLevel.flexible : urgencyLevel;
      final detail = await _repository.create(
        CreateParcelRequestDto(
          townId: town.id,
          requestType: requestType,
          pickupLocation: pickupController.text.trim(),
          dropoffLocation: dropoffController.text.trim(),
          fullPickupAddress: fullPickupController.text.trim(),
          fullDropoffAddress: fullDropoffController.text.trim(),
          parcelSize: parcelSize,
          urgencyLevel: effectiveUrgency,
          note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
          thankYouOffer: thankYouController.text.trim().isEmpty
              ? null
              : thankYouController.text.trim(),
          expiresAt: expiresAt,
          routeSummary: routeSummaryController.text.trim().isEmpty
              ? null
              : routeSummaryController.text.trim(),
          routeTravelDate: routeTravelDate,
          routeTravelNote: routeTravelNoteController.text.trim().isEmpty
              ? null
              : routeTravelNoteController.text.trim(),
          requiresPassengerSeat: requiresPassengerSeat,
          routeListingPerspective: perspective,
        ),
      );
      return detail;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    pickupController.dispose();
    dropoffController.dispose();
    fullPickupController.dispose();
    fullDropoffController.dispose();
    noteController.dispose();
    thankYouController.dispose();
    routeSummaryController.dispose();
    routeTravelNoteController.dispose();
    super.dispose();
  }
}
