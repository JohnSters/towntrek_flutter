import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';

class MyActivityViewModel extends ChangeNotifier {
  MyActivityViewModel({required MemberRepository repository})
      : _repository = repository {
    load();
  }

  final MemberRepository _repository;

  bool loading = true;
  String? error;
  MemberActivityDto? activity;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      activity = await _repository.getMyActivity();
    } catch (err) {
      error = resolveUserFacingApiError(err);
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
