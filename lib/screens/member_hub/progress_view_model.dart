import 'package:flutter/foundation.dart';

import '../../core/auth/mobile_session_manager.dart';
import '../../repositories/repositories.dart';
import 'progress_state.dart';

class ProgressViewModel extends ChangeNotifier {
  ProgressViewModel({
    required MemberRepository memberRepository,
    required MobileSessionManager sessionManager,
  })  : _memberRepository = memberRepository,
        _sessionManager = sessionManager {
    _sessionManager.addListener(_onSessionChanged);
    initialize();
  }

  final MemberRepository _memberRepository;
  final MobileSessionManager _sessionManager;

  ProgressHistoryState _historyState = ProgressHistoryInitial();

  MobileSessionManager get sessionManager => _sessionManager;
  ProgressHistoryState get historyState => _historyState;
  bool get isHistoryLoading => _historyState is ProgressHistoryLoading;

  Future<void> initialize() async {
    await _sessionManager.loadProgression();
    await loadHistory();
  }

  Future<void> loadHistory({int page = 1}) async {
    _historyState = ProgressHistoryLoading();
    notifyListeners();
    try {
      final pageDto = await _memberRepository.getXpHistory(page: page, pageSize: 25);
      _historyState = ProgressHistorySuccess(pageDto, page);
    } catch (e) {
      _historyState = ProgressHistoryError(e.toString());
    }
    notifyListeners();
  }

  void _onSessionChanged() => notifyListeners();

  @override
  void dispose() {
    _sessionManager.removeListener(_onSessionChanged);
    super.dispose();
  }
}
