import '../../core/network/api_client.dart';
import '../../core/config/api_config.dart';
import '../../models/models.dart';

/// Service class for creative space-related API operations
class CreativeSpaceApiService {
  final ApiClient _apiClient;

  CreativeSpaceApiService(this._apiClient);

  /// Get creative spaces with optional filtering and pagination
  Future<CreativeSpaceListResponse> getCreativeSpaces({
    int? townId,
    int? categoryId,
    int? subCategoryId,
    String? search,
    int page = 1,
    int pageSize = ApiConfig.defaultPageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (townId != null) 'townId': townId,
        if (categoryId != null) 'categoryId': categoryId,
        if (subCategoryId != null) 'subCategoryId': subCategoryId,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        'pageSize': pageSize,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.creativeSpacesUrl(),
        queryParameters: queryParams,
      );

      return CreativeSpaceListResponse.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  /// Search creative spaces with flexible criteria
  Future<CreativeSpaceListResponse> searchCreativeSpaces({
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
        ApiConfig.creativeSpacesSearchUrl(),
        queryParameters: queryParams,
      );

      return CreativeSpaceListResponse.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  /// Get detailed information for a specific creative space
  Future<CreativeSpaceDetailDto> getCreativeSpaceDetails(int creativeSpaceId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.creativeSpaceDetailUrl(creativeSpaceId),
      );

      return CreativeSpaceDetailDto.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  /// Get available creative space categories with nested subcategories
  Future<List<CreativeCategoryDto>> getCategories() async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        ApiConfig.creativeSpaceCategoriesUrl(),
      );

      return response.data!
          .map((json) => CreativeCategoryDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get creative space categories with counts for a specific town
  Future<List<CreativeCategoryDto>> getCategoriesWithCounts(int townId) async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        ApiConfig.creativeSpaceCategoriesWithCountsUrl(townId),
      );

      return response.data!
          .map((json) => CreativeCategoryDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get subcategories for a given category
  Future<List<CreativeSubCategoryDto>> getSubCategories(int categoryId) async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        ApiConfig.creativeSpaceSubCategoriesUrl(categoryId),
      );

      return response.data!
          .map((json) => CreativeSubCategoryDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
