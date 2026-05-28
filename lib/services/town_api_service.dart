import '../core/network/api_client.dart';
import '../core/config/api_config.dart';
import '../models/town_admin_public_dto.dart';
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

  /// Active Town Admin public profile, or `null` if none (404 / error).
  Future<PublicTownAdminProfileDto?> getTownAdminProfile(int townId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.townAdminProfileUrl(townId),
      );
      final data = response.data;
      if (data == null) return null;
      return PublicTownAdminProfileDto.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Published, non-expired notices for mobile town hub (empty on failure).
  Future<List<PublicTownNoticeDto>> getPublishedTownNotices(
    int townId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.townNoticesUrl(townId, page: page, pageSize: pageSize),
      );
      final data = response.data;
      if (data == null) return [];
      return PublicTownNoticeListDto.fromJson(data).items;
    } catch (_) {
      return [];
    }
  }
}
