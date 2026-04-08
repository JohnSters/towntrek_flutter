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
}
