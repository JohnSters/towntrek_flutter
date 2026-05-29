import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';

class ParcelProfileViewModel extends ChangeNotifier {
  ParcelProfileViewModel({required MemberRepository repository})
      : _repository = repository {
    load();
  }

  final MemberRepository _repository;

  bool loading = true;
  String? error;
  MemberProfileDto? profile;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      profile = await _repository.getMyProfile();
      await serviceLocator.mobileSessionManager.loadProgression();
    } catch (err) {
      error = resolveUserFacingApiError(err);
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
