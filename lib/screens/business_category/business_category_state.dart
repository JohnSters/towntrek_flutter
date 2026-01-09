import '../../models/models.dart';
import '../../core/core.dart';

/// State classes for Business Category page
sealed class BusinessCategoryState {}

class BusinessCategoryLocationLoading extends BusinessCategoryState {}

class BusinessCategoryTownSelection extends BusinessCategoryState {}

class BusinessCategoryLoading extends BusinessCategoryState {}

class BusinessCategorySuccess extends BusinessCategoryState {
  final TownDto town;
  final List<CategoryWithCountDto> categories;
  final int currentEventCount;
  final bool categoriesLoaded;

  BusinessCategorySuccess({
    required this.town,
    required this.categories,
    this.currentEventCount = 0,
    this.categoriesLoaded = false,
  });

  BusinessCategorySuccess copyWith({
    TownDto? town,
    List<CategoryWithCountDto>? categories,
    int? currentEventCount,
    bool? categoriesLoaded,
  }) {
    return BusinessCategorySuccess(
      town: town ?? this.town,
      categories: categories ?? this.categories,
      currentEventCount: currentEventCount ?? this.currentEventCount,
      categoriesLoaded: categoriesLoaded ?? this.categoriesLoaded,
    );
  }
}

class BusinessCategoryError extends BusinessCategoryState {
  final AppError error;
  BusinessCategoryError(this.error);
}