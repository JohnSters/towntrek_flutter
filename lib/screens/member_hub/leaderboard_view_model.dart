import 'package:flutter/foundation.dart';

import '../../core/auth/mobile_session_manager.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import 'leaderboard_state.dart';

class LeaderboardViewModel extends ChangeNotifier {
  LeaderboardViewModel({
    required this.town,
    required MemberRepository memberRepository,
    required MobileSessionManager sessionManager,
  })  : _memberRepository = memberRepository,
        _sessionManager = sessionManager {
    initialize();
  }

  final TownDto town;
  final MemberRepository _memberRepository;
  final MobileSessionManager _sessionManager;

  String _season = 'alltime';
  LeaderboardState _state = LeaderboardLoading();
  bool _requiresDisclosure = false;

  String get season => _season;
  LeaderboardState get state => _state;
  bool get requiresDisclosure => _requiresDisclosure;

  Future<void> initialize() async {
    await _sessionManager.loadProgression();
    _requiresDisclosure =
        !(_sessionManager.memberProgression?.leaderboardDisclosureSeen ?? true);
    notifyListeners();
    if (!_requiresDisclosure) {
      await load();
    }
  }

  Future<void> acceptDisclosure() async {
    try {
      await _memberRepository.markLeaderboardDisclosureSeen();
      _sessionManager.setLeaderboardDisclosureSeenLocal();
    } catch (_) {
      // Non-blocking: user can still continue.
    }
    _requiresDisclosure = false;
    notifyListeners();
    await load();
  }

  Future<void> selectSeason(String value) async {
    if (_season == value) return;
    _season = value;
    notifyListeners();
    await load();
  }

  Future<void> load() async {
    _state = LeaderboardLoading();
    notifyListeners();
    try {
      final res = await _memberRepository.getLeaderboard(
        townId: town.id,
        season: _season,
      );
      _state = LeaderboardSuccess(res);
    } catch (e) {
      _state = LeaderboardError(e.toString());
    }
    notifyListeners();
  }
}
