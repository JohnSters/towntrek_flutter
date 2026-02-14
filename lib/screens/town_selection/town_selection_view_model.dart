import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import 'town_selection_state.dart';

// ViewModel for business logic separation
class TownSelectionViewModel extends ChangeNotifier {
  TownSelectionState _state = TownSelectionLoading();
  TownSelectionState get state => _state;

  final TownRepository _townRepository;
  final ErrorHandler _errorHandler;
  final TextEditingController searchController = TextEditingController();

  TownSelectionViewModel({
    required TownRepository townRepository,
    required ErrorHandler errorHandler,
  }) : _townRepository = townRepository,
       _errorHandler = errorHandler {
    searchController.addListener(_filterTowns);
    loadTowns();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadTowns() async {
    _state = TownSelectionLoading();
    notifyListeners();

    try {
      final towns = await _townRepository.getTowns();
      _state = TownSelectionSuccess(
        towns: towns,
        filteredTowns: towns,
      );
      notifyListeners();
    } catch (e) {
      final appError = await _errorHandler.handleError(e, retryAction: loadTowns);
      _state = TownSelectionError(appError);
      notifyListeners();
    }
  }

  void _filterTowns() {
    final query = searchController.text.toLowerCase();
    if (_state is TownSelectionSuccess) {
      final currentState = _state as TownSelectionSuccess;
      final filteredTowns = query.isEmpty
          ? currentState.towns
          : currentState.towns.where((town) {
              return town.name.toLowerCase().contains(query) ||
                     town.province.toLowerCase().contains(query) ||
                     (town.postalCode?.contains(query) == true);
            }).toList();

      _state = TownSelectionSuccess(
        towns: currentState.towns,
        filteredTowns: filteredTowns,
      );
      notifyListeners();
    }
  }

  void selectTown(TownDto town) {
    // This will be called from the widget with proper context
  }

  void clearSearch() {
    searchController.clear();
  }
}