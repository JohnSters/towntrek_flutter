import '../models/models.dart';
import '../services/mobile_auth_api_service.dart';

abstract class MobileAuthRepository {
  Future<MobileAuthResponseDto> redeemCode({
    required String code,
    required String deviceName,
    required String installId,
  });

  Future<MobileAuthResponseDto> refresh({
    required String refreshToken,
  });

  Future<void> disconnect();

  Future<MobileAuthResponseDto> registerMember({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    required bool acceptTerms,
    required String deviceName,
    required String installId,
  });

  Future<MobileAuthResponseDto> login({
    required String email,
    required String password,
    required String deviceName,
    required String installId,
  });

  Future<MobileAuthResponseDto> upgradeFreeBasic();

  Future<void> deactivateAccount({required bool confirm});
}

class MobileAuthRepositoryImpl implements MobileAuthRepository {
  MobileAuthRepositoryImpl(this._apiService);

  final MobileAuthApiService _apiService;

  @override
  Future<MobileAuthResponseDto> redeemCode({
    required String code,
    required String deviceName,
    required String installId,
  }) async {
    return _apiService.redeemCode(
      code: code,
      deviceName: deviceName,
      installId: installId,
    );
  }

  @override
  Future<MobileAuthResponseDto> refresh({
    required String refreshToken,
  }) async {
    return _apiService.refresh(refreshToken: refreshToken);
  }

  @override
  Future<void> disconnect() async {
    await _apiService.disconnect();
  }

  @override
  Future<MobileAuthResponseDto> registerMember({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    required bool acceptTerms,
    required String deviceName,
    required String installId,
  }) {
    return _apiService.registerMember(
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
      acceptTerms: acceptTerms,
      deviceName: deviceName,
      installId: installId,
    );
  }

  @override
  Future<MobileAuthResponseDto> login({
    required String email,
    required String password,
    required String deviceName,
    required String installId,
  }) {
    return _apiService.login(
      email: email,
      password: password,
      deviceName: deviceName,
      installId: installId,
    );
  }

  @override
  Future<MobileAuthResponseDto> upgradeFreeBasic() {
    return _apiService.upgradeFreeBasic();
  }

  @override
  Future<void> deactivateAccount({required bool confirm}) {
    return _apiService.deactivateAccount(confirm: confirm);
  }
}
