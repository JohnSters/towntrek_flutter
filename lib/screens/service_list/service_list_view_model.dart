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
  String? _searchTerm;
  int? _lastTotalCount;

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

  String? get searchTerm => _searchTerm;

  /// Total count from the last successful API response, for the results band.
  int get bandCount =>
      _lastTotalCount ?? subCategory.serviceCount;

  bool get _hasSearchTerm {
    final q = _searchTerm?.trim();
    return q != null && q.isNotEmpty;
  }

  /// Load services with pagination support
  Future<void> loadServices({bool loadMore = false}) async {
    if (loadMore && !_canLoadMore()) return;

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
      final nextPage = loadMore ? _currentPage + 1 : ServiceListConstants.defaultPage;
      final response = _hasSearchTerm
          ? await _serviceRepository.searchServices(
              query: _searchTerm!,
              townId: town.id,
              categoryId: category.id,
              subCategoryId: subCategory.id,
              page: nextPage,
              pageSize: ServiceListConstants.defaultPageSize,
            )
          : await _serviceRepository.getServices(
              townId: town.id,
              categoryId: category.id,
              subCategoryId: subCategory.id,
              search: _searchTerm,
              page: nextPage,
              pageSize: ServiceListConstants.defaultPageSize,
            );

      _lastTotalCount = response.totalCount;

      if (loadMore) {
        if (_state is ServiceListLoadingMore) {
          final currentState = _state as ServiceListLoadingMore;
          final updatedServices = [
            ...currentState.services,
            ...response.services,
          ];

          _state = ServiceListSuccess(
            services: updatedServices,
            hasNextPage: response.hasNextPage,
            currentPage: nextPage,
            totalItemCount: response.totalCount,
          );
          _currentPage = nextPage;
        }
      } else {
        _state = ServiceListSuccess(
          services: response.services,
          hasNextPage: response.hasNextPage,
          currentPage: nextPage,
          totalItemCount: response.totalCount,
        );
        _currentPage = nextPage;
      }

      notifyListeners();
    } catch (e) {
      final appError = await _errorHandler.handleError(
        e,
        retryAction: () => loadServices(loadMore: loadMore),
      );
      _state = ServiceListError(appError);

      notifyListeners();
    }
  }

  bool _canLoadMore() {
    final currentState = _state;
    if (currentState is ServiceListSuccess) {
      return currentState.hasNextPage;
    }
    return false;
  }

  Future<void> search(String? term) async {
    final normalizedTerm = term?.trim();
    if ((normalizedTerm == null || normalizedTerm.isEmpty) &&
        (_searchTerm == null || _searchTerm!.trim().isEmpty)) {
      return;
    }
    _searchTerm =
        normalizedTerm == null || normalizedTerm.isEmpty ? null : normalizedTerm;
    await loadServices(loadMore: false);
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
