import '../services/business_api_service.dart';
import '../models/models.dart';

/// Abstract interface for business data operations
abstract class BusinessRepository {
  /// Get businesses with optional filtering and pagination
  Future<BusinessListResponse> getBusinesses({
    int? townId,
    String? category,
    String? subCategory,
    String? search,
    int page = 1,
    int pageSize = 20,
  });

  /// Search businesses with flexible criteria
  Future<BusinessListResponse> searchBusinesses({
    required String query,
    int? townId,
    String? category,
    String? subCategory,
    int page = 1,
    int pageSize = 20,
  });

  /// Get detailed information for a specific business
  Future<BusinessDetailDto> getBusinessDetails(int businessId);

  /// Get available business categories with subcategories
  Future<List<CategoryDto>> getCategories();

  /// Get categories with business counts for a specific town
  Future<List<CategoryWithCountDto>> getCategoriesWithCounts(int townId);
}

/// Implementation of BusinessRepository using API service
class BusinessRepositoryImpl implements BusinessRepository {
  final BusinessApiService _apiService;

  BusinessRepositoryImpl(this._apiService);

  @override
  Future<BusinessListResponse> getBusinesses({
    int? townId,
    String? category,
    String? subCategory,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      return await _apiService.getBusinesses(
        townId: townId,
        category: category,
        subCategory: subCategory,
        search: search,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      // Here you could add caching logic, error transformation, etc.
      rethrow;
    }
  }

  @override
  Future<BusinessListResponse> searchBusinesses({
    required String query,
    int? townId,
    String? category,
    String? subCategory,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      return await _apiService.searchBusinesses(
        query: query,
        townId: townId,
        category: category,
        subCategory: subCategory,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BusinessDetailDto> getBusinessDetails(int businessId) async {
    try {
      return await _apiService.getBusinessDetails(businessId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CategoryDto>> getCategories() async {
    try {
      return await _apiService.getCategories();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CategoryWithCountDto>> getCategoriesWithCounts(int townId) async {
    try {
      return await _apiService.getCategoriesWithCounts(townId);
    } catch (e) {
      rethrow;
    }
  }
}
