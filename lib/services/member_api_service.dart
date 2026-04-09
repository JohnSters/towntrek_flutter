import '../core/network/api_client.dart';
import '../models/models.dart';

class MemberApiService {
  MemberApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<MemberProfileDto> getMyProfile() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/api/members/me');
    return MemberProfileDto.fromJson(response.data!);
  }

  Future<MemberActivityDto> getMyActivity() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/members/me/activity',
    );
    return MemberActivityDto.fromJson(response.data!);
  }

  Future<MemberProgressionDto> getMyProgression() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/members/me/progression',
    );
    return MemberProgressionDto.fromJson(response.data!);
  }

  Future<void> markLeaderboardDisclosureSeen() async {
    await _apiClient.post<Map<String, dynamic>>(
      '/api/members/me/progression/leaderboard-disclosure',
    );
  }

  Future<XpHistoryPageDto> getXpHistory({int page = 1, int pageSize = 20}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/members/me/xp-history',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return XpHistoryPageDto.fromJson(response.data!);
  }

  Future<LeaderboardResponseDto> getLeaderboard({
    required int townId,
    String season = 'alltime',
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/leaderboard',
      queryParameters: {'townId': townId, 'season': season},
    );
    return LeaderboardResponseDto.fromJson(response.data!);
  }
}
