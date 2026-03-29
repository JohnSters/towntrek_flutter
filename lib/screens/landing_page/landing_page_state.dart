// State classes for type-safe state management
sealed class LandingPageState {}

class LandingPageLoading extends LandingPageState {}

class LandingPageSuccess extends LandingPageState {
  final int businessCount;
  final int serviceCount;
  final int eventCount;
  final int creativeSpaceCount;
  final int propertyListingCount;
  final int equipmentRentalBusinessCount;

  LandingPageSuccess({
    required this.businessCount,
    required this.serviceCount,
    required this.eventCount,
    required this.creativeSpaceCount,
    required this.propertyListingCount,
    required this.equipmentRentalBusinessCount,
  });
}

class LandingPageError extends LandingPageState {
  final String message;

  LandingPageError(this.message);
}
