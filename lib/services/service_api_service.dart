import '../core/network/api_client.dart';
import '../core/config/api_config.dart';
import '../models/models.dart';

/// Service class for service-provider-related API operations
class ServiceApiService {
  final ApiClient _apiClient;

  ServiceApiService(this._apiClient);

  /// Get services with optional filtering and pagination
  Future<ServiceListResponse> getServices({
    int? townId,
    int? categoryId,
    int? subCategoryId,
    String? search,
    int page = 1,
    int pageSize = ApiConfig.defaultPageSize,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{
        if (townId != null) 'townId': townId,
        if (categoryId != null) 'categoryId': categoryId,
        if (subCategoryId != null) 'subCategoryId': subCategoryId,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        'pageSize': pageSize,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.servicesUrl(),
        queryParameters: queryParams,
      );

      return ServiceListResponse.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  /// Search services with flexible criteria
  Future<ServiceListResponse> searchServices({
    required String query,
    int? townId,
    int? categoryId,
    int? subCategoryId,
    int page = 1,
    int pageSize = ApiConfig.defaultPageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query.trim(),
        if (townId != null) 'townId': townId,
        if (categoryId != null) 'categoryId': categoryId,
        if (subCategoryId != null) 'subCategoryId': subCategoryId,
        'page': page,
        'pageSize': pageSize,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.serviceSearchUrl(),
        queryParameters: queryParams,
      );

      return ServiceListResponse.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  /// Get detailed information for a specific service
  Future<ServiceDetailDto> getServiceDetails(int serviceId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.serviceDetailUrl(serviceId),
      );

      return ServiceDetailDto.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  /// Get available service categories with subcategories
  Future<List<ServiceCategoryDto>> getCategories() async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        ApiConfig.serviceCategoriesUrl(),
      );

      return response.data!
          .map((json) => ServiceCategoryDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get service categories with counts for a specific town
  Future<List<ServiceCategoryDto>> getCategoriesWithCounts(int townId) async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        ApiConfig.serviceCategoriesWithCountsUrl(townId),
      );

      return response.data!
          .map((json) => ServiceCategoryDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get subcategories for a given category
  Future<List<ServiceSubCategoryDto>> getSubCategories(int categoryId) async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        ApiConfig.serviceSubCategoriesUrl(categoryId),
      );

      return response.data!
          .map((json) => ServiceSubCategoryDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}

