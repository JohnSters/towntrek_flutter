import '../../core/auth/mobile_session_manager.dart';

class ConnectDeviceController {
  ConnectDeviceController({required MobileSessionManager sessionManager})
      : _sessionManager = sessionManager;

  final MobileSessionManager _sessionManager;

  Future<bool> ensureAuthenticated() => _sessionManager.ensureAuthenticated();

  Future<void> signInWithCode({
    required String code,
    required String deviceName,
  }) {
    return _sessionManager.signInWithCode(code: code, deviceName: deviceName);
  }
}
