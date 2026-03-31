import '../services/service_apis/creative_space_api_service.dart';
import '../models/models.dart';

/// Abstract interface for creative space data operations
abstract class CreativeSpaceRepository {
  /// Get creative spaces with optional filtering and pagination
  Future<CreativeSpaceListResponse> getCreativeSpaces({
    int? townId,
    int? categoryId,
    int? subCategoryId,
    String? search,
    int page = 1,
    int pageSize = 20,
  });

  /// Search creative spaces with flexible criteria
  Future<CreativeSpaceListResponse> searchCreativeSpaces({
    required String query,
    int? townId,
    int? categoryId,
    int? subCategoryId,
    int page = 1,
    int pageSize = 20,
  });

  /// Get detailed information for a specific creative space
  Future<CreativeSpaceDetailDto> getCreativeSpaceDetails(int creativeSpaceId);

  /// Get available creative space categories with nested subcategories
  Future<List<CreativeCategoryDto>> getCategories();

  /// Get categories with creative space counts for a specific town
  Future<List<CreativeCategoryDto>> getCategoriesWithCounts(int townId);

  /// Get subcategories for a given category
  Future<List<CreativeSubCategoryDto>> getSubCategories(int categoryId);
}

/// Implementation of CreativeSpaceRepository using API service
class CreativeSpaceRepositoryImpl implements CreativeSpaceRepository {
  final CreativeSpaceApiService _apiService;

  CreativeSpaceRepositoryImpl(this._apiService);

  @override
  Future<CreativeSpaceListResponse> getCreativeSpaces({
    int? townId,
    int? categoryId,
    int? subCategoryId,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      return await _apiService.getCreativeSpaces(
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
  Future<CreativeSpaceListResponse> searchCreativeSpaces({
    required String query,
    int? townId,
    int? categoryId,
    int? subCategoryId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      return await _apiService.searchCreativeSpaces(
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
  Future<CreativeSpaceDetailDto> getCreativeSpaceDetails(int creativeSpaceId) async {
    try {
      return await _apiService.getCreativeSpaceDetails(creativeSpaceId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CreativeCategoryDto>> getCategories() async {
    try {
      return await _apiService.getCategories();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CreativeCategoryDto>> getCategoriesWithCounts(int townId) async {
    try {
      return await _apiService.getCategoriesWithCounts(townId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CreativeSubCategoryDto>> getSubCategories(int categoryId) async {
    try {
      return await _apiService.getSubCategories(categoryId);
    } catch (e) {
      rethrow;
    }
  }
}
