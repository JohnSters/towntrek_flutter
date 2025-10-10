import '../core/network/api_client.dart';
import '../core/config/api_config.dart';
import '../models/models.dart';

/// Service class for business-related API operations
class BusinessApiService {
  final ApiClient _apiClient;

  BusinessApiService(this._apiClient);

  /// Get businesses with optional filtering and pagination
  /// - townId: Filter by town (required if no search term)
  /// - category: Filter by business category
  /// - subCategory: Filter by business subcategory
  /// - search: Search term for business name or description
  /// - page: Page number for pagination (default: 1)
  /// - pageSize: Number of results per page (default: 20)
  Future<BusinessListResponse> getBusinesses({
    int? townId,
    String? category,
    String? subCategory,
    String? search,
    int page = 1,
    int pageSize = ApiConfig.defaultPageSize,
  }) async {
    try {
      // Validate parameters
      if (townId == null && (search == null || search.trim().isEmpty)) {
        throw ArgumentError('Either townId or search term must be provided');
      }

      // Build query parameters
      final queryParams = <String, dynamic>{
        if (townId != null) 'townId': townId,
        if (category != null) 'category': category,
        if (subCategory != null) 'subCategory': subCategory,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        'pageSize': pageSize,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.businessesUrl(),
        queryParameters: queryParams,
      );

      return BusinessListResponse.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  /// Search businesses with flexible criteria
  /// - query: Search query string
  /// - townId: Optional town filter
  /// - category: Optional category filter
  /// - subCategory: Optional subcategory filter
  /// - page: Page number for pagination (default: 1)
  /// - pageSize: Number of results per page (default: 20)
  Future<BusinessListResponse> searchBusinesses({
    required String query,
    int? townId,
    String? category,
    String? subCategory,
    int page = 1,
    int pageSize = ApiConfig.defaultPageSize,
  }) async {
    try {
      if (query.trim().isEmpty && townId == null) {
        throw ArgumentError('Search query or townId required');
      }

      final queryParams = <String, dynamic>{
        'q': query.trim(),
        if (townId != null) 'townId': townId,
        if (category != null) 'category': category,
        if (subCategory != null) 'subCategory': subCategory,
        'page': page,
        'pageSize': pageSize,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.businessSearchUrl(),
        queryParameters: queryParams,
      );

      return BusinessListResponse.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  /// Get detailed information for a specific business
  Future<BusinessDetailDto> getBusinessDetails(int businessId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.businessDetailUrl(businessId),
      );

      return BusinessDetailDto.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  /// Get available business categories with subcategories
  Future<List<CategoryDto>> getCategories() async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        ApiConfig.categoriesUrl(),
      );

      return response.data!
          .map((json) => CategoryDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get categories with business counts for a specific town
  Future<List<CategoryWithCountDto>> getCategoriesWithCounts(int townId) async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        ApiConfig.categoriesWithCountsUrl(townId),
      );

      return response.data!
          .map((json) => CategoryWithCountDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
