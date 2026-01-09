import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../../services/services.dart';
import '../town_selection/town_selection_screen.dart';
import '../current_events/current_events_screen.dart';
import '../business_sub_category/business_sub_category.dart';
import '../town_feature_selection/town_feature_selection_screen.dart';
import 'business_category_state.dart';

/// ViewModel for Business Category page business logic
class BusinessCategoryViewModel extends ChangeNotifier {
  final BusinessRepository _businessRepository;
  final TownRepository _townRepository;
  final EventRepository _eventRepository;
  final GeolocationService _geolocationService;
  final ErrorHandler _errorHandler;

  BusinessCategoryState _state = BusinessCategoryLocationLoading();
  BusinessCategoryState get state => _state;

  final TownDto? initialTown;

  BusinessCategoryViewModel({
    required this.initialTown,
    required BusinessRepository businessRepository,
    required TownRepository townRepository,
    required EventRepository eventRepository,
    required GeolocationService geolocationService,
    required ErrorHandler errorHandler,
  })  : _businessRepository = businessRepository,
        _townRepository = townRepository,
        _eventRepository = eventRepository,
        _geolocationService = geolocationService,
        _errorHandler = errorHandler {
    _initializePage();
  }

  Future<void> _initializePage() async {
    if (initialTown != null) {
      await loadCategoriesForTown(initialTown!);
    } else {
      await detectLocationAndLoadTown();
    }
  }

  Future<void> detectLocationAndLoadTown() async {
    _state = BusinessCategoryLocationLoading();
    notifyListeners();

    try {
      // Get all towns first
      final townsResult = await _townRepository.getTowns();

      if (townsResult.isEmpty) {
        final noDataError = AppErrors.noDataAvailable(_initializePage);
        _state = BusinessCategoryError(noDataError);
        notifyListeners();
        return;
      }

      // Try to find nearest town based on location
      final nearestTownResult = await _geolocationService.findNearestTown(townsResult);

      if (nearestTownResult.isSuccess) {
        await loadCategoriesForTown(nearestTownResult.data);
      } else {
        // Location detection failed, show town selection
        _state = BusinessCategoryTownSelection();
        notifyListeners();
      }
    } catch (e) {
      final appError = await _errorHandler.handleError(e, retryAction: _initializePage);
      _state = BusinessCategoryError(appError);
      notifyListeners();
    }
  }

  Future<void> loadCategoriesForTown(TownDto town) async {
    _state = BusinessCategoryLoading();
    notifyListeners();

    try {
      // Step 1: Load categories first
      final categories = await _businessRepository.getCategoriesWithCounts(town.id);

      // Step 2: Update state with categories (marking as loaded)
      _state = BusinessCategorySuccess(
        town: town,
        categories: categories,
        categoriesLoaded: true,
      );
      notifyListeners();

      // Step 3: Wait for UI to settle before checking events
      await Future.delayed(BusinessCategoryConstants.uiSettleDelay);

      // Step 4: Now load events sequentially after categories are done
      if (_state is BusinessCategorySuccess) {
        await _checkCurrentEvents(town.id);
      }
    } catch (e) {
      final appError = await _errorHandler.handleError(e, retryAction: () => loadCategoriesForTown(town));
      _state = BusinessCategoryError(appError);
      notifyListeners();
    }
  }

  Future<void> _checkCurrentEvents(int townId) async {
    if (_state is! BusinessCategorySuccess) return;

    try {
      final eventsResponse = await _eventRepository.getCurrentEvents(
        townId: townId,
        pageSize: BusinessCategoryConstants.eventCheckPageSize, // Just need to know if there are any events
      );

      if (_state is BusinessCategorySuccess) {
        final currentState = _state as BusinessCategorySuccess;
        _state = currentState.copyWith(currentEventCount: eventsResponse.totalCount);
        notifyListeners();
      }
    } catch (e) {
      // Silently fail for event checking - don't show error to user
      // Events are secondary feature, don't interrupt main flow
      if (_state is BusinessCategorySuccess) {
        final currentState = _state as BusinessCategorySuccess;
        _state = currentState.copyWith(currentEventCount: 0);
        notifyListeners();
      }
    }
  }

  Future<void> selectTownManually(BuildContext context) async {
    final selectedTown = await Navigator.of(context).push<TownDto>(
      MaterialPageRoute(
        builder: (context) => const TownSelectionScreen(),
      ),
    );

    // If a town was selected, load its categories
    if (selectedTown != null && context.mounted) {
      await loadCategoriesForTown(selectedTown);
    }
  }

  void changeTown(BuildContext context) {
    // Navigate to town selection screen
    Navigator.of(context).push<TownDto>(
      MaterialPageRoute(
        builder: (context) => const TownSelectionScreen(),
      ),
    ).then((selectedTown) {
      // If a town was selected, navigate to TownFeatureSelectionScreen with new town
      // This resets the flow to the "Hub" for the new town
      if (selectedTown != null && context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TownFeatureSelectionScreen(town: selectedTown),
          ),
        );
      }
    });
  }

  void navigateToEvents(BuildContext context) {
    if (_state is BusinessCategorySuccess) {
      final currentState = _state as BusinessCategorySuccess;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CurrentEventsScreen(
            townId: currentState.town.id,
            townName: currentState.town.name,
          ),
        ),
      );
    }
  }

  void navigateToCategory(BuildContext context, CategoryWithCountDto category) {
    if (_state is BusinessCategorySuccess) {
      final currentState = _state as BusinessCategorySuccess;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BusinessSubCategoryPage(
            category: category,
            town: currentState.town,
          ),
        ),
      );
    }
  }

  void skipLocationDetection() {
    _state = BusinessCategoryTownSelection();
    notifyListeners();
  }
}