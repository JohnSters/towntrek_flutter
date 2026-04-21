import 'dart:async';

import 'package:flutter/foundation.dart';

import '../network/api_client.dart';
import '../progression/xp_level_math.dart';
import '../utils/mobile_session_storage.dart';
import '../../models/models.dart';
import '../../repositories/member_repository.dart';
import '../../repositories/mobile_auth_repository.dart';

class MobileSessionManager extends ChangeNotifier {
  MobileSessionManager({
    required MobileAuthRepository mobileAuthRepository,
    required MemberRepository memberRepository,
    required ApiClient apiClient,
  }) : _mobileAuthRepository = mobileAuthRepository,
       _memberRepository = memberRepository,
       _apiClient = apiClient;

  final MobileAuthRepository _mobileAuthRepository;
  final MemberRepository _memberRepository;
  final ApiClient _apiClient;

  MobileAuthResponseDto? _session;
  MemberProfileDto? _profile;
  MemberProgressionDto? _memberProgression;
  bool _initializing = false;
  bool _busy = false;
  String? _errorMessage;

  MobileAuthResponseDto? get session => _session;
  MemberProfileDto? get profile => _profile;
  MemberProgressionDto? get memberProgression => _memberProgression;
  String? get currentUserId => _profile?.userId;
  String? get currentDisplayName => _profile?.displayName;
  bool get isInitializing => _initializing;
  bool get isBusy => _busy;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _session != null;

  Future<void> initialize() async {
    if (_initializing) return;
    _initializing = true;
    notifyListeners();
    try {
      _session = await MobileSessionStorage.read();
      if (_session != null) {
        _applyAccessToken(_session!.accessToken);
        if (_session!.accessTokenExpiresAt.isBefore(
          DateTime.now().toUtc().add(const Duration(minutes: 1)),
        )) {
          await refreshSession();
        } else {
          await loadProfile();
          await loadProgression();
        }
      }
    } catch (error) {
      debugPrint('Failed to initialize mobile session: $error');
      await signOut(notify: false);
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }

  Future<void> signInWithCode({
    required String code,
    required String deviceName,
  }) async {
    if (_session != null) {
      await signOut(notify: false);
    }
    _busy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final session = await _mobileAuthRepository.redeemCode(
        code: code,
        deviceName: deviceName,
      );
      _session = session;
      _applyAccessToken(session.accessToken);
      await MobileSessionStorage.save(session);
      await loadProfile();
      await loadProgression();
    } catch (error) {
      _errorMessage = resolveUserFacingApiError(error);
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> ensureAuthenticated() async {
    if (_session == null) {
      return false;
    }

    if (_session!.accessTokenExpiresAt.isAfter(
      DateTime.now().toUtc().add(const Duration(minutes: 1)),
    )) {
      return true;
    }

    return refreshSession();
  }

  Future<bool> refreshSession() async {
    final existing = _session;
    if (existing == null) {
      return false;
    }

    try {
      final refreshed = await _mobileAuthRepository.refresh(
        refreshToken: existing.refreshToken,
      );
      _session = refreshed;
      _applyAccessToken(refreshed.accessToken);
      await MobileSessionStorage.save(refreshed);
      await loadProfile();
      await loadProgression();
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('Failed to refresh mobile session: $error');
      await signOut();
      return false;
    }
  }

  Future<void> loadProfile() async {
    if (_session == null) {
      _profile = null;
      return;
    }

    try {
      _profile = await _memberRepository.getMyProfile();
    } catch (error) {
      debugPrint('Failed to load member profile: $error');
      _profile = null;
    }
  }

  Future<void> loadProgression() async {
    if (_session == null) {
      _memberProgression = null;
      return;
    }

    try {
      _memberProgression = await _memberRepository.getMyProgression();
      notifyListeners();
    } catch (error) {
      debugPrint('Failed to load member progression: $error');
    }
  }

  /// Merges server [XpDeltaDto] into cached progression and refreshes from API in the background.
  void mergeFromParcelDetail(ParcelDetailDto? detail) {
    final delta = detail?.xpDelta;
    if (delta == null || !delta.hasAward) {
      return;
    }
    applyXpDelta(delta);
  }

  void applyXpDelta(XpDeltaDto delta) {
    if (!delta.hasAward) {
      return;
    }
    final p = _memberProgression;
    if (p == null) {
      unawaited(loadProgression());
      return;
    }
    final level = delta.currentLevel;
    final into = XpLevelMath.xpIntoCurrentLevel(delta.newTotal, level);
    final toNext = XpLevelMath.xpToNextLevel(delta.newTotal, level);
    _memberProgression = p.copyWith(
      totalXp: delta.newTotal,
      currentLevel: level,
      currentLevelTitle: delta.newLevelTitle ?? p.currentLevelTitle,
      xpIntoLevel: into,
      xpForNext: toNext,
    );
    notifyListeners();
    unawaited(loadProgression());
  }

  void setLeaderboardDisclosureSeenLocal() {
    final p = _memberProgression;
    if (p == null) {
      return;
    }
    _memberProgression = p.copyWith(leaderboardDisclosureSeen: true);
    notifyListeners();
  }

  Future<void> signOut({bool notify = true}) async {
    if (_session != null) {
      try {
        await _mobileAuthRepository.disconnect();
      } catch (_) {
        // Best-effort: still clear local session if the token is expired or offline.
      }
    }
    _session = null;
    _profile = null;
    _memberProgression = null;
    _apiClient.clearHeader('Authorization');
    await MobileSessionStorage.clear();
    if (notify) {
      notifyListeners();
    }
  }

  void _applyAccessToken(String token) {
    _apiClient.updateHeaders({'Authorization': 'Bearer $token'});
  }
}
