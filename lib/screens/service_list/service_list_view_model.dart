import 'package:flutter/foundation.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../../core/errors/error_handler.dart';
import '../../core/constants/service_list_constants.dart';
import 'service_list_state.dart';

/// ViewModel for Service List page
/// Handles pagination, loading states, and service fetching with proper error handling
class ServiceListViewModel extends ChangeNotifier {
  final ServiceRepository _serviceRepository;
  final ErrorHandler _errorHandler;
  final ServiceCategoryDto category;
  final ServiceSubCategoryDto subCategory;
  final TownDto town;

  ServiceListState _state;
  int _currentPage = ServiceListConstants.defaultPage;
  bool _hasMorePages = true;

  ServiceListViewModel({
    required ServiceRepository serviceRepository,
    required ErrorHandler errorHandler,
    required this.category,
    required this.subCategory,
    required this.town,
  })  : _serviceRepository = serviceRepository,
        _errorHandler = errorHandler,
        _state = ServiceListLoading() {
    loadServices();
  }

  /// Current state of the service list
  ServiceListState get state => _state;

  /// Load services with pagination support
  Future<void> loadServices({bool loadMore = false}) async {
    if (loadMore && !_hasMorePages) return;

    if (loadMore) {
      if (_state is ServiceListSuccess) {
        final currentState = _state as ServiceListSuccess;
        _state = ServiceListLoadingMore(
          services: currentState.services,
          currentPage: _currentPage,
        );
        notifyListeners();
      }
    } else {
      _state = ServiceListLoading();
      _currentPage = ServiceListConstants.defaultPage;
      notifyListeners();
    }

    try {
      final response = await _serviceRepository.getServices(
        townId: town.id,
        categoryId: category.id,
        subCategoryId: subCategory.id,
        page: loadMore ? _currentPage + 1 : ServiceListConstants.defaultPage,
        pageSize: ServiceListConstants.defaultPageSize,
      );

      if (loadMore) {
        if (_state is ServiceListLoadingMore) {
          final currentState = _state as ServiceListLoadingMore;
          final updatedServices = [...currentState.services, ...response.services];

          _state = ServiceListSuccess(
            services: updatedServices,
            hasNextPage: response.services.length == ServiceListConstants.defaultPageSize,
            currentPage: _currentPage + 1,
          );
          _currentPage++;
        }
      } else {
        _state = ServiceListSuccess(
          services: response.services,
          hasNextPage: response.services.length == ServiceListConstants.defaultPageSize,
        );
        _hasMorePages = response.services.length == ServiceListConstants.defaultPageSize;
      }

      notifyListeners();
    } catch (e) {
      await _errorHandler.handleError(
        e,
        retryAction: () => loadServices(loadMore: loadMore),
      );

      _state = ServiceListError(
        title: ServiceListConstants.refreshErrorTitle,
        message: ServiceListConstants.refreshErrorMessage,
      );

      notifyListeners();
    }
  }

  /// Refresh services (reload from first page)
  Future<void> refresh() async {
    await loadServices(loadMore: false);
  }

  /// Load more services (pagination)
  Future<void> loadMore() async {
    await loadServices(loadMore: true);
  }

  /// Retry loading services
  Future<void> retry() async {
    await loadServices(loadMore: false);
  }
}