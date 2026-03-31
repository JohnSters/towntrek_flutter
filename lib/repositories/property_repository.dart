import '../models/models.dart';
import '../services/property_api_service.dart';

abstract class PropertyRepository {
  Future<PropertyListingListResponse> getList({
    int? townId,
    int page = 1,
    int pageSize = 12,
  });

  Future<PropertyListingDetailDto> getDetail(int id);
}

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyApiService _apiService;

  PropertyRepositoryImpl(this._apiService);

  @override
  Future<PropertyListingListResponse> getList({
    int? townId,
    int page = 1,
    int pageSize = 12,
  }) {
    return _apiService.getList(townId: townId, page: page, pageSize: pageSize);
  }

  @override
  Future<PropertyListingDetailDto> getDetail(int id) {
    return _apiService.getDetail(id);
  }
}
