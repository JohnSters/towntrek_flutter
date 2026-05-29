import 'package:flutter/foundation.dart';

import '../../core/auth/mobile_session_manager.dart';

class AccessCodeEntryViewModel extends ChangeNotifier {
  AccessCodeEntryViewModel({required MobileSessionManager sessionManager})
      : _sessionManager = sessionManager;

  final MobileSessionManager _sessionManager;

  bool _submitting = false;
  String? _submitError;

  bool get submitting => _submitting;
  String? get submitError => _submitError;

  Future<bool> submit({
    required String code,
    required String deviceName,
    required String Function(Object error) mapError,
  }) async {
    _submitting = true;
    _submitError = null;
    notifyListeners();

    try {
      await _sessionManager.signInWithCode(code: code, deviceName: deviceName);
      _submitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _submitError = mapError(e);
      _submitting = false;
      notifyListeners();
      return false;
    }
  }
}
