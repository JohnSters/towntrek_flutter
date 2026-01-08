import '../../models/models.dart';

/// Sealed class for Business Sub-Category page states
sealed class BusinessSubCategoryState {}

/// Loading state for Business Sub-Category page
class BusinessSubCategoryLoading extends BusinessSubCategoryState {}

/// Success state for Business Sub-Category page
class BusinessSubCategorySuccess extends BusinessSubCategoryState {
  final CategoryWithCountDto category;
  final TownDto town;
  final List<SubCategoryWithCountDto> sortedSubCategories;

  BusinessSubCategorySuccess({
    required this.category,
    required this.town,
    required this.sortedSubCategories,
  });

  /// Creates a copy with updated fields
  BusinessSubCategorySuccess copyWith({
    CategoryWithCountDto? category,
    TownDto? town,
    List<SubCategoryWithCountDto>? sortedSubCategories,
  }) {
    return BusinessSubCategorySuccess(
      category: category ?? this.category,
      town: town ?? this.town,
      sortedSubCategories: sortedSubCategories ?? this.sortedSubCategories,
    );
  }
}

/// Error state for Business Sub-Category page
class BusinessSubCategoryError extends BusinessSubCategoryState {
  final String message;

  BusinessSubCategoryError(this.message);
}