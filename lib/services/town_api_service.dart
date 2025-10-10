import '../core/network/api_client.dart';
import '../core/config/api_config.dart';
import '../models/town_dto.dart';

/// Service class for town-related API operations
class TownApiService {
  final ApiClient _apiClient;

  TownApiService(this._apiClient);

  /// Get all active towns
  Future<List<TownDto>> getTowns() async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        ApiConfig.townsUrl(),
      );

      return response.data!
          .map((json) => TownDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get detailed information for a specific town
  Future<TownDto> getTownDetails(int townId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.townDetailUrl(townId),
      );

      return TownDto.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }
}
