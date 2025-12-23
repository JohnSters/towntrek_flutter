import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/models.dart';

/// Service class for public stats-related API operations
class StatsApiService {
  final ApiClient _apiClient;

  StatsApiService(this._apiClient);

  /// Get summary counts used by the landing page.
  Future<LandingStatsDto> getLandingStats({int? townId}) async {
    final queryParams = <String, dynamic>{
      if (townId != null) 'townId': townId,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConfig.statsSummaryUrl(),
      queryParameters: queryParams,
    );

    return LandingStatsDto.fromJson(response.data!);
  }
}


