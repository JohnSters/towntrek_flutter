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
    final queryParams = <String, dynamic>{
      'townId': ?townId,
      'categoryId': ?categoryId,
      'subCategoryId': ?subCategoryId,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      'page': page,
      'pageSize': pageSize,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.servicesUrl(),
      queryParameters: queryParams,
    );

    return ServiceListResponse.fromJson(response.data!);
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
    final queryParams = <String, dynamic>{
      'q': query.trim(),
      'townId': ?townId,
      'categoryId': ?categoryId,
      'subCategoryId': ?subCategoryId,
      'page': page,
      'pageSize': pageSize,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.serviceSearchUrl(),
      queryParameters: queryParams,
    );

    return ServiceListResponse.fromJson(response.data!);
  }

  /// Get detailed information for a specific service
  Future<ServiceDetailDto> getServiceDetails(int serviceId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.serviceDetailUrl(serviceId),
    );

    return ServiceDetailDto.fromJson(response.data!);
  }

  /// Get available service categories with subcategories
  Future<List<ServiceCategoryDto>> getCategories() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.serviceCategoriesUrl(),
    );

    return response.data!
        .map((json) => ServiceCategoryDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get service categories with counts for a specific town
  Future<List<ServiceCategoryDto>> getCategoriesWithCounts(int townId) async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.serviceCategoriesWithCountsUrl(townId),
    );

    return response.data!
        .map((json) => ServiceCategoryDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get subcategories for a given category
  Future<List<ServiceSubCategoryDto>> getSubCategories(int categoryId) async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.serviceSubCategoriesUrl(categoryId),
    );

    return response.data!
        .map(
          (json) => ServiceSubCategoryDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }
}
