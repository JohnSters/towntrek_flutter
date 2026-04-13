import '../core/network/api_client.dart';
import '../models/models.dart';

class MobileAuthApiService {
  MobileAuthApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<MobileAuthResponseDto> redeemCode({
    required String code,
    required String deviceName,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/mobile/redeem-code',
      data: {'code': code, 'deviceName': deviceName},
    );
    return MobileAuthResponseDto.fromJson(response.data!);
  }

  Future<MobileAuthResponseDto> refresh({
    required String refreshToken,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/mobile/refresh',
      data: {'refreshToken': refreshToken},
    );
    return MobileAuthResponseDto.fromJson(response.data!);
  }
}
