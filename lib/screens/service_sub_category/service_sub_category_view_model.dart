import 'package:flutter/foundation.dart';
import '../../models/models.dart';
import 'service_sub_category_state.dart';

/// ViewModel for Service Sub-Category page
/// Handles sorting logic and state management for sub-categories display
class ServiceSubCategoryViewModel extends ChangeNotifier {
  ServiceSubCategoryState _state;

  ServiceSubCategoryViewModel({
    required ServiceCategoryDto category,
    required TownDto town,
    required bool countsAvailable,
  }) : _state = ServiceSubCategorySuccess(
         category: category,
         town: town,
         countsAvailable: countsAvailable,
         sortedSubCategories: _sortSubCategories(category.subCategories, countsAvailable),
       );

  /// Current state of the page
  ServiceSubCategoryState get state => _state;

  /// Sorts sub-categories with active ones (with services) first, then alphabetical
  static List<ServiceSubCategoryDto> _sortSubCategories(
    List<ServiceSubCategoryDto> subCategories,
    bool countsAvailable,
  ) {
    if (!countsAvailable) {
      // If counts are not available, just sort alphabetically
      return [...subCategories]..sort((a, b) => a.name.compareTo(b.name));
    }

    final sortedSubCategories = [...subCategories]
      ..sort((a, b) {
        // Primary sort: services with count > 0 come first
        if (a.serviceCount > 0 && b.serviceCount == 0) return -1;
        if (a.serviceCount == 0 && b.serviceCount > 0) return 1;
        // Secondary sort: alphabetical by name for same service count
        return a.name.compareTo(b.name);
      });

    return sortedSubCategories;
  }

  /// Updates the category and town data
  /// Useful for when the user changes town or category
  void updateData({
    ServiceCategoryDto? category,
    TownDto? town,
    bool? countsAvailable,
  }) {
    if (_state is! ServiceSubCategorySuccess) return;

    final currentState = _state as ServiceSubCategorySuccess;
    final newCategory = category ?? currentState.category;
    final newTown = town ?? currentState.town;
    final newCountsAvailable = countsAvailable ?? currentState.countsAvailable;

    _state = ServiceSubCategorySuccess(
      category: newCategory,
      town: newTown,
      countsAvailable: newCountsAvailable,
      sortedSubCategories: _sortSubCategories(newCategory.subCategories, newCountsAvailable),
    );
    notifyListeners();
  }

  /// Sets loading state
  void setLoading() {
    _state = ServiceSubCategoryLoading();
    notifyListeners();
  }

  /// Sets error state with message
  void setError(String message) {
    _state = ServiceSubCategoryError(message);
    notifyListeners();
  }

  /// Resets to success state (useful for retry operations)
  void resetToSuccess() {
    if (_state is ServiceSubCategorySuccess) {
      // If already in success state, just notify listeners to trigger rebuild
      notifyListeners();
    }
  }
}