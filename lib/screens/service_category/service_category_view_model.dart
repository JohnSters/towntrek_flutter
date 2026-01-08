import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../../core/errors/error_handler.dart';
import 'service_category_state.dart';

/// ViewModel for Service Category page
/// Handles all business logic: loading categories, error handling, and navigation
class ServiceCategoryViewModel extends ChangeNotifier {
  final ServiceRepository _serviceRepository;
  final ErrorHandler _errorHandler;
  final TownDto town;

  ServiceCategoryState _state = ServiceCategoryLoading();

  ServiceCategoryViewModel({
    required this.town,
    required ServiceRepository serviceRepository,
    required ErrorHandler errorHandler,
  })  : _serviceRepository = serviceRepository,
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
    } catch (e) {
      final appError = await _errorHandler.handleError(e, retryAction: loadCategories);
      _state = ServiceCategoryError(appError);
      notifyListeners();
    }
  }

  /// Retry loading categories (used for error recovery)
  Future<void> retry() async {
    await loadCategories();
  }
}