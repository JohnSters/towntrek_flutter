// State classes for type-safe state management
sealed class LandingScreenState {}

class LandingScreenLoading extends LandingScreenState {}

class LandingScreenSuccess extends LandingScreenState {
  final int businessCount;
  final int serviceCount;
  final int eventCount;
  final int creativeSpaceCount;
  final int propertyListingCount;
  final int equipmentRentalBusinessCount;
  final String? infoBannerMessage;
  final String? issueBannerMessage;

  LandingScreenSuccess({
    required this.businessCount,
    required this.serviceCount,
    required this.eventCount,
    required this.creativeSpaceCount,
    required this.propertyListingCount,
    required this.equipmentRentalBusinessCount,
    this.infoBannerMessage,
    this.issueBannerMessage,
  });
}

class LandingScreenError extends LandingScreenState {
  final String message;

  LandingScreenError(this.message);
}
