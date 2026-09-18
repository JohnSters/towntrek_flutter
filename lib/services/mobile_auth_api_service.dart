import '../core/network/api_client.dart';
import '../models/models.dart';

class MobileAuthApiService {
  MobileAuthApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<MobileAuthResponseDto> redeemCode({
    required String code,
    required String deviceName,
    required String installId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/mobile/redeem-code',
      data: {
        'code': code,
        'deviceName': deviceName,
        'installId': installId,
      },
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

  /// Revokes this device session on the server.
  Future<void> disconnect() async {
    await _apiClient.post<Map<String, dynamic>>(
      '/api/mobile/disconnect',
      data: <String, dynamic>{},
    );
  }

  Future<MobileAuthResponseDto> registerMember({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    required bool acceptTerms,
    required String deviceName,
    required String installId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/mobile/register-member',
      data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        'acceptTerms': acceptTerms,
        'deviceName': deviceName,
        'installId': installId,
      },
    );
    return MobileAuthResponseDto.fromJson(response.data!);
  }

  Future<MobileAuthResponseDto> login({
    required String email,
    required String password,
    required String deviceName,
    required String installId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/mobile/login',
      data: {
        'email': email,
        'password': password,
        'deviceName': deviceName,
        'installId': installId,
      },
    );
    return MobileAuthResponseDto.fromJson(response.data!);
  }

  Future<MobileAuthResponseDto> upgradeFreeBasic() async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/mobile/upgrade-free-basic',
      data: <String, dynamic>{},
    );
    return MobileAuthResponseDto.fromJson(response.data!);
  }

  Future<void> deactivateAccount({required bool confirm}) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/api/mobile/deactivate-account',
      data: {'confirm': confirm},
    );
  }
}
