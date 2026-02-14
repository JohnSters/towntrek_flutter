import '../../models/models.dart';
import '../../core/errors/app_error.dart';

/// State classes for Service Category page
/// Following the established pattern with sealed classes for type-safe state management

sealed class ServiceCategoryState {}

/// Loading state when fetching service categories
class ServiceCategoryLoading extends ServiceCategoryState {}

/// Success state with loaded categories
class ServiceCategorySuccess extends ServiceCategoryState {
  final List<ServiceCategoryDto> categories;
  final bool countsAvailable;
  final int currentEventCount;

  ServiceCategorySuccess({
    required this.categories,
    required this.countsAvailable,
    this.currentEventCount = 0,
  });

  ServiceCategorySuccess copyWith({
    List<ServiceCategoryDto>? categories,
    bool? countsAvailable,
    int? currentEventCount,
  }) {
    return ServiceCategorySuccess(
      categories: categories ?? this.categories,
      countsAvailable: countsAvailable ?? this.countsAvailable,
      currentEventCount: currentEventCount ?? this.currentEventCount,
    );
  }
}

/// Error state when category loading fails
class ServiceCategoryError extends ServiceCategoryState {
  final AppError error;

  ServiceCategoryError(this.error);
}