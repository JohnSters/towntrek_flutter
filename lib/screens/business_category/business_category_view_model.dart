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
  int _detectionRunId = 0;
  int _contentRunId = 0;
  bool _isDisposed = false;
  bool _userCancelledAutoDetect = false;
  bool _isSelectingTownManually = false;

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

  @override
  void dispose() {
    _isDisposed = true;
    _cancelPendingDetection();
    _contentRunId++;
    super.dispose();
  }

  bool _shouldAbortDetection(int runId) {
    return _isDisposed || _userCancelledAutoDetect || runId != _detectionRunId;
  }

  void _cancelPendingDetection({bool persistCancellation = false}) {
    if (persistCancellation) {
      _userCancelledAutoDetect = true;
    }
    _detectionRunId++;
  }

  bool _canUpdateContent(int runId) {
    return !_isDisposed && runId == _contentRunId;
  }

  Future<void> _initializePage() async {
    if (initialTown != null) {
      await loadCategoriesForTown(initialTown!);
    } else {
      await detectLocationAndLoadTown();
    }
  }

  Future<void> detectLocationAndLoadTown({bool userInitiatedRetry = false}) async {
    if (_isDisposed) return;
    if (_userCancelledAutoDetect && !userInitiatedRetry) return;
    if (userInitiatedRetry) {
      _userCancelledAutoDetect = false;
    }

    final runId = ++_detectionRunId;
    _state = BusinessCategoryLocationLoading();
    notifyListeners();

    try {
      // Get all towns first
      final townsResult = await _townRepository.getTowns();
      if (_shouldAbortDetection(runId)) return;

      if (townsResult.isEmpty) {
        final noDataError = AppErrors.noDataAvailable(_initializePage);
        _state = BusinessCategoryError(noDataError);
        notifyListeners();
        return;
      }

      // Try to find nearest town based on location
      final nearestTownResult = await _geolocationService.findNearestTown(townsResult);
      if (_shouldAbortDetection(runId)) return;

      if (nearestTownResult.isSuccess) {
        await loadCategoriesForTown(nearestTownResult.data, runFromDetection: runId);
      } else {
        // Location detection failed, show town selection
        _state = BusinessCategoryTownSelection();
        notifyListeners();
      }
    } catch (e) {
      if (_shouldAbortDetection(runId)) return;
      final appError = await _errorHandler.handleError(e, retryAction: _initializePage);
      if (_shouldAbortDetection(runId)) return;
      _state = BusinessCategoryError(appError);
      notifyListeners();
    }
  }

  Future<void> loadCategoriesForTown(TownDto town, {int? runFromDetection}) async {
    if (_isDisposed) return;
    if (runFromDetection != null && _shouldAbortDetection(runFromDetection)) return;

    final contentRunId = ++_contentRunId;
    _state = BusinessCategoryLoading();
    notifyListeners();

    try {
      // Step 1: Load categories first
      final categories = await _businessRepository.getCategoriesWithCounts(town.id);
      if (!_canUpdateContent(contentRunId)) return;
      if (runFromDetection != null && _shouldAbortDetection(runFromDetection)) return;

      // Step 2: Update state with categories (marking as loaded)
      _state = BusinessCategorySuccess(
        town: town,
        categories: categories,
        categoriesLoaded: true,
      );
      notifyListeners();

      // Step 3: Wait for UI to settle before checking events
      await Future.delayed(BusinessCategoryConstants.uiSettleDelay);
      if (!_canUpdateContent(contentRunId)) return;
      if (runFromDetection != null && _shouldAbortDetection(runFromDetection)) return;

      // Step 4: Now load events sequentially after categories are done
      if (_state is BusinessCategorySuccess) {
        await _checkCurrentEvents(town.id, contentRunId);
      }
    } catch (e) {
      if (!_canUpdateContent(contentRunId)) return;
      if (runFromDetection != null && _shouldAbortDetection(runFromDetection)) return;
      final appError = await _errorHandler.handleError(e, retryAction: () => loadCategoriesForTown(town));
      if (!_canUpdateContent(contentRunId)) return;
      _state = BusinessCategoryError(appError);
      notifyListeners();
    }
  }

  Future<void> _checkCurrentEvents(int townId, int contentRunId) async {
    if (!_canUpdateContent(contentRunId) || _state is! BusinessCategorySuccess) return;

    try {
      final eventsResponse = await _eventRepository.getCurrentEvents(
        townId: townId,
        pageSize: BusinessCategoryConstants.eventCheckPageSize, // Just need to know if there are any events
      );

      if (_canUpdateContent(contentRunId) && _state is BusinessCategorySuccess) {
        final currentState = _state as BusinessCategorySuccess;
        _state = currentState.copyWith(currentEventCount: eventsResponse.totalCount);
        notifyListeners();
      }
    } catch (e) {
      // Silently fail for event checking - don't show error to user
      // Events are secondary feature, don't interrupt main flow
      if (_canUpdateContent(contentRunId) && _state is BusinessCategorySuccess) {
        final currentState = _state as BusinessCategorySuccess;
        _state = currentState.copyWith(currentEventCount: 0);
        notifyListeners();
      }
    }
  }

  Future<void> selectTownManually(BuildContext context) async {
    if (_isDisposed || _isSelectingTownManually || !context.mounted) return;
    _cancelPendingDetection(persistCancellation: true);
    _isSelectingTownManually = true;

    final selectedTown = await Navigator.of(context).push<TownDto>(
      MaterialPageRoute(
        builder: (context) => const TownSelectionScreen(),
      ),
    );
    _isSelectingTownManually = false;

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
    if (_isDisposed) return;
    _cancelPendingDetection(persistCancellation: true);
    _state = BusinessCategoryTownSelection();
    notifyListeners();
  }
}