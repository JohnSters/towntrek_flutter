import '../../models/models.dart';

/// State classes for Service Sub-Category page
/// Following the established pattern with sealed classes for type-safe state management

sealed class ServiceSubCategoryState {}

/// Loading state when initializing sub-category display
class ServiceSubCategoryLoading extends ServiceSubCategoryState {}

/// Success state with loaded and sorted sub-categories
class ServiceSubCategorySuccess extends ServiceSubCategoryState {
  final ServiceCategoryDto category;
  final TownDto town;
  final bool countsAvailable;
  final List<ServiceSubCategoryDto> sortedSubCategories;

  ServiceSubCategorySuccess({
    required this.category,
    required this.town,
    required this.countsAvailable,
    required this.sortedSubCategories,
  });

  ServiceSubCategorySuccess copyWith({
    ServiceCategoryDto? category,
    TownDto? town,
    bool? countsAvailable,
    List<ServiceSubCategoryDto>? sortedSubCategories,
  }) {
    return ServiceSubCategorySuccess(
      category: category ?? this.category,
      town: town ?? this.town,
      countsAvailable: countsAvailable ?? this.countsAvailable,
      sortedSubCategories: sortedSubCategories ?? this.sortedSubCategories,
    );
  }
}

/// Error state when sub-category processing fails
class ServiceSubCategoryError extends ServiceSubCategoryState {
  final String message;

  ServiceSubCategoryError(this.message);
}