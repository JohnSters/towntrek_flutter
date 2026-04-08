import '../core/network/api_client.dart';
import '../core/config/api_config.dart';
import '../models/models.dart';

class PropertyApiService {
  final ApiClient _apiClient;

  PropertyApiService(this._apiClient);

  Future<PropertyListingListResponse> getList({
    int? townId,
    int page = 1,
    int pageSize = 12,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (townId != null) 'townId': townId,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConfig.propertiesUrl(),
      queryParameters: queryParams,
    );

    return PropertyListingListResponse.fromJson(response.data!);
  }

  Future<PropertyListingDetailDto> getDetail(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConfig.propertyDetailUrl(id),
    );
    return PropertyListingDetailDto.fromJson(response.data!);
  }
}
