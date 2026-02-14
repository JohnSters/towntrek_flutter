import '../services/service_api_service.dart';
import '../models/models.dart';

/// Abstract interface for service data operations
abstract class ServiceRepository {
  /// Get services with optional filtering and pagination
  Future<ServiceListResponse> getServices({
    int? townId,
    int? categoryId,
    int? subCategoryId,
    String? search,
    int page = 1,
    int pageSize = 20,
  });

  /// Search services with flexible criteria
  Future<ServiceListResponse> searchServices({
    required String query,
    int? townId,
    int? categoryId,
    int? subCategoryId,
    int page = 1,
    int pageSize = 20,
  });

  /// Get detailed information for a specific service
  Future<ServiceDetailDto> getServiceDetails(int serviceId);

  /// Get available service categories with subcategories
  Future<List<ServiceCategoryDto>> getCategories();

  /// Get service categories with counts for a specific town
  Future<List<ServiceCategoryDto>> getCategoriesWithCounts(int townId);

  /// Get subcategories for a given category
  Future<List<ServiceSubCategoryDto>> getSubCategories(int categoryId);
}

/// Implementation of ServiceRepository using API service
class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceApiService _apiService;

  ServiceRepositoryImpl(this._apiService);

  @override
  Future<ServiceListResponse> getServices({
    int? townId,
    int? categoryId,
    int? subCategoryId,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      return await _apiService.getServices(
        townId: townId,
        categoryId: categoryId,
        subCategoryId: subCategoryId,
        search: search,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ServiceListResponse> searchServices({
    required String query,
    int? townId,
    int? categoryId,
    int? subCategoryId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      return await _apiService.searchServices(
        query: query,
        townId: townId,
        categoryId: categoryId,
        subCategoryId: subCategoryId,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ServiceDetailDto> getServiceDetails(int serviceId) async {
    try {
      return await _apiService.getServiceDetails(serviceId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ServiceCategoryDto>> getCategories() async {
    try {
      return await _apiService.getCategories();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ServiceCategoryDto>> getCategoriesWithCounts(int townId) async {
    try {
      return await _apiService.getCategoriesWithCounts(townId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ServiceSubCategoryDto>> getSubCategories(int categoryId) async {
    try {
      return await _apiService.getSubCategories(categoryId);
    } catch (e) {
      rethrow;
    }
  }
}

