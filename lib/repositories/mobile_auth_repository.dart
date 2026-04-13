import '../models/models.dart';
import '../services/mobile_auth_api_service.dart';

abstract class MobileAuthRepository {
  Future<MobileAuthResponseDto> redeemCode({
    required String code,
    required String deviceName,
  });

  Future<MobileAuthResponseDto> refresh({
    required String refreshToken,
  });
}

class MobileAuthRepositoryImpl implements MobileAuthRepository {
  MobileAuthRepositoryImpl(this._apiService);

  final MobileAuthApiService _apiService;

  @override
  Future<MobileAuthResponseDto> redeemCode({
    required String code,
    required String deviceName,
  }) async {
    return _apiService.redeemCode(code: code, deviceName: deviceName);
  }

  @override
  Future<MobileAuthResponseDto> refresh({
    required String refreshToken,
  }) async {
    return _apiService.refresh(refreshToken: refreshToken);
  }
}
