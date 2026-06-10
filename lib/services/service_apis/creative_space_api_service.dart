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
    final queryParams = <String, dynamic>{
      'townId': ?townId,
      'categoryId': ?categoryId,
      'subCategoryId': ?subCategoryId,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      'page': page,
      'pageSize': pageSize,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.creativeSpacesUrl(),
      queryParameters: queryParams,
    );

    return CreativeSpaceListResponse.fromJson(response.data!);
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
    final queryParams = <String, dynamic>{
      'q': query.trim(),
      'townId': ?townId,
      'categoryId': ?categoryId,
      'subCategoryId': ?subCategoryId,
      'page': page,
      'pageSize': pageSize,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.creativeSpacesSearchUrl(),
      queryParameters: queryParams,
    );

    return CreativeSpaceListResponse.fromJson(response.data!);
  }

  /// Get detailed information for a specific creative space
  Future<CreativeSpaceDetailDto> getCreativeSpaceDetails(
    int creativeSpaceId,
  ) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.creativeSpaceDetailUrl(creativeSpaceId),
    );

    return CreativeSpaceDetailDto.fromJson(response.data!);
  }

  /// Get available creative space categories with nested subcategories
  Future<List<CreativeCategoryDto>> getCategories() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.creativeSpaceCategoriesUrl(),
    );

    return response.data!
        .map(
          (json) => CreativeCategoryDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Get creative space categories with counts for a specific town
  Future<List<CreativeCategoryDto>> getCategoriesWithCounts(int townId) async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.creativeSpaceCategoriesWithCountsUrl(townId),
    );

    return response.data!
        .map(
          (json) => CreativeCategoryDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Get subcategories for a given category
  Future<List<CreativeSubCategoryDto>> getSubCategories(int categoryId) async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.creativeSpaceSubCategoriesUrl(categoryId),
    );

    return response.data!
        .map(
          (json) =>
              CreativeSubCategoryDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }
}
