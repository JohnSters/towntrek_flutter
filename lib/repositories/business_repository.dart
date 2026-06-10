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
  }) {
    return _apiService.getBusinesses(
      townId: townId,
      category: category,
      subCategory: subCategory,
      search: search,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<BusinessListResponse> searchBusinesses({
    required String query,
    int? townId,
    String? category,
    String? subCategory,
    int page = 1,
    int pageSize = 20,
  }) {
    return _apiService.searchBusinesses(
      query: query,
      townId: townId,
      category: category,
      subCategory: subCategory,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<BusinessDetailDto> getBusinessDetails(int businessId) {
    return _apiService.getBusinessDetails(businessId);
  }

  @override
  Future<List<CategoryDto>> getCategories() {
    return _apiService.getCategories();
  }

  @override
  Future<List<CategoryWithCountDto>> getCategoriesWithCounts(int townId) {
    return _apiService.getCategoriesWithCounts(townId);
  }
}
