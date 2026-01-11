import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../../core/errors/error_handler.dart';
import '../current_events/current_events_screen.dart';
import 'service_category_state.dart';

/// ViewModel for Service Category page
/// Handles all business logic: loading categories, error handling, and navigation
class ServiceCategoryViewModel extends ChangeNotifier {
  final ServiceRepository _serviceRepository;
  final EventRepository _eventRepository;
  final ErrorHandler _errorHandler;
  final TownDto town;

  ServiceCategoryState _state = ServiceCategoryLoading();

  ServiceCategoryViewModel({
    required this.town,
    required ServiceRepository serviceRepository,
    required EventRepository eventRepository,
    required ErrorHandler errorHandler,
  })  : _serviceRepository = serviceRepository,
        _eventRepository = eventRepository,
        _errorHandler = errorHandler {
    loadCategories();
  }

  ServiceCategoryState get state => _state;

  /// Load service categories with fallback logic
  /// First tries to load categories with counts, falls back to plain categories if counts endpoint unavailable
  Future<void> loadCategories() async {
    _state = ServiceCategoryLoading();
    notifyListeners();

    try {
      List<ServiceCategoryDto> categories;
      bool countsAvailable = true;

      // Prefer counts endpoint (enables disabling empty categories)
      // If the endpoint is not deployed/available yet, fall back to plain categories
      // so the app remains usable (no hard failure / no permanent disabling)
      try {
        categories = await _serviceRepository.getCategoriesWithCounts(town.id);
        countsAvailable = true;
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          // Counts endpoint not available, fall back to plain categories
          categories = await _serviceRepository.getCategories();
          countsAvailable = false;
        } else {
          rethrow;
        }
      }

      _state = ServiceCategorySuccess(
        categories: categories,
        countsAvailable: countsAvailable,
      );
      notifyListeners();

      // Load event count after categories are loaded
      await _loadEventCount();
    } catch (e) {
      final appError = await _errorHandler.handleError(e, retryAction: loadCategories);
      _state = ServiceCategoryError(appError);
      notifyListeners();
    }
  }

  /// Load event count for the town
  Future<void> _loadEventCount() async {
    if (_state is! ServiceCategorySuccess) return;

    try {
      final eventsResponse = await _eventRepository.getCurrentEvents(
        townId: town.id,
        page: 1,
        pageSize: 1, // Just need count
      );

      final currentState = _state as ServiceCategorySuccess;
      _state = currentState.copyWith(currentEventCount: eventsResponse.totalCount);
      notifyListeners();
    } catch (e) {
      // If event count fails, set to 0 but don't fail the whole page
      _state = (_state as ServiceCategorySuccess).copyWith(currentEventCount: 0);
      notifyListeners();
    }
  }

  /// Retry loading categories (used for error recovery)
  Future<void> retry() async {
    await loadCategories();
  }

  /// Navigate to events page
  void navigateToEvents(BuildContext context) {
    if (_state is ServiceCategorySuccess) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CurrentEventsScreen(
            townId: town.id,
            townName: town.name,
          ),
        ),
      );
    }
  }
}