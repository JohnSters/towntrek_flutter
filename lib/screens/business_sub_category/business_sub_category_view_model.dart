import 'package:flutter/foundation.dart';
import '../../models/models.dart';
import '../../core/core.dart';
import 'business_sub_category_state.dart';

/// ViewModel for Business Sub-Category page
/// Handles sorting logic and state management for sub-categories display
class BusinessSubCategoryViewModel extends ChangeNotifier {
  BusinessSubCategoryState _state;
  CategoryWithCountDto _category;
  TownDto _town;

  BusinessSubCategoryViewModel({
    required CategoryWithCountDto category,
    required TownDto town,
  })  : _category = category,
       _town = town,
       _state = BusinessSubCategorySuccess(
         category: category,
         town: town,
         sortedSubCategories: _sortSubCategories(category.subCategories),
       );

  /// Current state of the page
  BusinessSubCategoryState get state => _state;

  /// Sorts sub-categories with active ones (with businesses) first, then alphabetical
  static List<SubCategoryWithCountDto> _sortSubCategories(
    List<SubCategoryWithCountDto> subCategories,
  ) {
    final sortedSubCategories = [...subCategories]
      ..sort((a, b) {
        // Primary sort: businesses with count > 0 come first
        if (a.businessCount > 0 && b.businessCount == 0) return -1;
        if (a.businessCount == 0 && b.businessCount > 0) return 1;
        // Secondary sort: alphabetical by name for same business count
        return a.name.compareTo(b.name);
      });

    return sortedSubCategories;
  }

  /// Updates the category and town data
  /// Useful for when the user changes town or category
  void updateData({
    CategoryWithCountDto? category,
    TownDto? town,
  }) {
    final currentState = _state is BusinessSubCategorySuccess
        ? _state as BusinessSubCategorySuccess
        : BusinessSubCategorySuccess(
            category: _category,
            town: _town,
            sortedSubCategories: _sortSubCategories(_category.subCategories),
          );
    final newCategory = category ?? currentState.category;
    final newTown = town ?? currentState.town;
    _category = newCategory;
    _town = newTown;

    _state = BusinessSubCategorySuccess(
      category: newCategory,
      town: newTown,
      sortedSubCategories: _sortSubCategories(newCategory.subCategories),
    );
    notifyListeners();
  }

  /// Sets loading state
  void setLoading() {
    _state = BusinessSubCategoryLoading();
    notifyListeners();
  }

  /// Sets error state with message
  void setError(AppError error) {
    _state = BusinessSubCategoryError(error);
    notifyListeners();
  }

  /// Resets to success state (useful for retry operations)
  void resetToSuccess() {
    _state = BusinessSubCategorySuccess(
      category: _category,
      town: _town,
      sortedSubCategories: _sortSubCategories(_category.subCategories),
    );
    notifyListeners();
  }

  /// Retry by restoring current category payload.
  void retry() {
    resetToSuccess();
  }
}