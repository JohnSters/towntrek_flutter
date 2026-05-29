import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';

class RequestDetailViewModel extends ChangeNotifier {
  RequestDetailViewModel({
    required this.requestId,
    required this.repository,
    required this.sessionManager,
  }) {
    load();
  }

  final int requestId;
  final ParcelRepository repository;
  final MobileSessionManager sessionManager;

  bool loading = true;
  bool actionLoading = false;
  String? error;
  ParcelDetailDto? detail;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      detail = await repository.getDetail(requestId);
    } catch (err) {
      error = resolveUserFacingApiError(err);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> claim() async {
    final current = detail;
    if (current == null) return false;
    return _runOptimistic(
      optimistic: current.copyWith(status: ParcelStatus.claimed, canClaim: false),
      action: () => repository.claim(requestId),
    );
  }

  Future<bool> pickedUp() async {
    final current = detail;
    if (current == null) return false;
    return _runOptimistic(
      optimistic: current.copyWith(status: ParcelStatus.pickedUp),
      action: () => repository.pickedUp(requestId),
    );
  }

  Future<bool> delivered() async {
    final current = detail;
    if (current == null) return false;
    return _runOptimistic(
      optimistic: current.copyWith(status: ParcelStatus.delivered),
      action: () => repository.delivered(requestId),
    );
  }

  Future<bool> confirm() async {
    final current = detail;
    if (current == null) return false;
    return _runOptimistic(
      optimistic: current.copyWith(status: ParcelStatus.confirmed),
      action: () => repository.confirm(requestId),
    );
  }

  Future<bool> cancel(String reason) async {
    final current = detail;
    if (current == null) return false;
    return _runOptimistic(
      optimistic: current.copyWith(
        status: ParcelStatus.cancelled,
        cancelReason: reason,
      ),
      action: () => repository.cancel(requestId, reason),
    );
  }

  Future<void> report(String reason) async {
    actionLoading = true;
    notifyListeners();
    try {
      await repository.report(requestId, reason);
    } finally {
      actionLoading = false;
      notifyListeners();
    }
  }

  Future<void> rate({
    required int score,
    required bool rateClaimer,
    String? note,
  }) async {
    actionLoading = true;
    notifyListeners();
    try {
      final updated = await repository.rate(
        id: requestId,
        score: score,
        rateClaimer: rateClaimer,
        note: note,
      );
      detail = updated;
      sessionManager.mergeFromParcelDetail(updated);
    } finally {
      actionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _runOptimistic({
    required ParcelDetailDto optimistic,
    required Future<ParcelDetailDto> Function() action,
  }) async {
    final previous = detail;
    if (previous == null) return false;
    actionLoading = true;
    detail = optimistic;
    notifyListeners();
    try {
      detail = await action();
      return true;
    } catch (_) {
      detail = previous;
      rethrow;
    } finally {
      actionLoading = false;
      notifyListeners();
    }
  }
}
