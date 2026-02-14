import '../../models/models.dart';

/// State classes for Service Detail page
/// Following the established pattern with sealed classes for type-safe state management

sealed class ServiceDetailState {}

/// Loading state for service detail loading
class ServiceDetailLoading extends ServiceDetailState {}

/// Success state with loaded service details
class ServiceDetailSuccess extends ServiceDetailState {
  final ServiceDetailDto serviceDetails;

  ServiceDetailSuccess({
    required this.serviceDetails,
  });

  /// Creates a copy with updated service details
  ServiceDetailSuccess copyWith({
    ServiceDetailDto? serviceDetails,
  }) {
    return ServiceDetailSuccess(
      serviceDetails: serviceDetails ?? this.serviceDetails,
    );
  }
}

/// Error state for service detail loading failure
class ServiceDetailError extends ServiceDetailState {
  final String title;
  final String message;

  ServiceDetailError({
    required this.title,
    required this.message,
  });
}