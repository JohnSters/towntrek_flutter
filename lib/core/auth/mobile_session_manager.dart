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
       _apiClient = apiClient {
    // Let the network layer transparently refresh + replay on a 401.
    _apiClient.onUnauthorized = _handleUnauthorizedRefresh;
  }

  final MobileAuthRepository _mobileAuthRepository;
  final MemberRepository _memberRepository;
  final ApiClient _apiClient;

  MobileAuthResponseDto? _session;
  MemberProfileDto? _profile;
  MemberProgressionDto? _memberProgression;
  bool _initializing = false;
  bool _busy = false;
  String? _errorMessage;
  int _lastDisplayAwardedXp = 0;

  List<MobileAccountSession> _accounts = const [];
  String? _activeUserId;

  MobileAuthResponseDto? get session => _session;
  MemberProfileDto? get profile => _profile;
  MemberProgressionDto? get memberProgression => _memberProgression;
  String? get currentUserId => _profile?.userId ?? _activeUserId;
  String? get currentDisplayName => _profile?.displayName;
  bool get isInitializing => _initializing;
  bool get isBusy => _busy;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _session != null;

  /// All accounts currently linked on this device, for the account switcher.
  List<MobileAccountSession> get accounts => List.unmodifiable(_accounts);
  String? get activeUserId => _activeUserId;
  bool get hasMultipleAccounts => _accounts.length > 1;

  /// XP amount to display for the most recent [applyXpDelta]. Reflects the full
  /// jump in total XP (e.g. a parcel-post award plus the daily-streak award that
  /// the server granted on the same request), not just the parcel event amount.
  int get lastDisplayAwardedXp => _lastDisplayAwardedXp;

  Future<void> initialize() async {
    if (_initializing) return;
    _initializing = true;
    notifyListeners();
    try {
      final store = await MobileSessionStorage.readStore();
      _accounts = store.accounts;
      _activeUserId = store.activeUserId;
      final active = store.active;
      if (active != null) {
        _session = active.session;
        _applyAccessToken(active.session.accessToken);
        if (_isNearExpiry(active.session)) {
          await refreshSession();
        } else {
          await loadProfile();
          await loadProgression();
          await _syncActiveDisplayName();
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

  /// Redeems a TREK code and links the account, keeping any previously linked
  /// accounts (multi-account). The newly linked account becomes active.
  Future<void> signInWithCode({
    required String code,
    required String deviceName,
  }) async {
    _busy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final session = await _mobileAuthRepository.redeemCode(
        code: code,
        deviceName: deviceName,
      );
      final userId = decodeUserIdFromJwt(session.accessToken) ??
          'device:${session.deviceId}';
      _session = session;
      _activeUserId = userId;
      _applyAccessToken(session.accessToken);
      final store = await MobileSessionStorage.upsertAndActivate(
        MobileAccountSession(
          userId: userId,
          displayName: _displayNameForUser(userId),
          session: session,
        ),
      );
      _accounts = store.accounts;
      _profile = null;
      _memberProgression = null;
      await loadProfile();
      await loadProgression();
      await _syncActiveDisplayName();
    } catch (error) {
      _errorMessage = resolveUserFacingApiError(error);
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Switches the active account to a previously-linked [userId]. Returns false
  /// if no such account is linked on this device.
  Future<bool> switchAccount(String userId) async {
    if (userId == _activeUserId) return true;
    MobileAccountSession? target;
    for (final account in _accounts) {
      if (account.userId == userId) {
        target = account;
        break;
      }
    }
    if (target == null) return false;

    _busy = true;
    notifyListeners();
    try {
      _session = target.session;
      _activeUserId = userId;
      _applyAccessToken(target.session.accessToken);
      _profile = null;
      _memberProgression = null;
      final store = await MobileSessionStorage.setActive(userId);
      _accounts = store.accounts;
      if (_isNearExpiry(target.session)) {
        await refreshSession();
      } else {
        await loadProfile();
        await loadProgression();
        await _syncActiveDisplayName();
      }
      return true;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> ensureAuthenticated() async {
    if (_session == null) {
      return false;
    }

    if (!_isNearExpiry(_session!)) {
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
      await _persistRefreshedSession(refreshed);
      await loadProfile();
      await loadProgression();
      await _syncActiveDisplayName();
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('Failed to refresh mobile session: $error');
      await signOut();
      return false;
    }
  }

  /// Refresh used by the 401 interceptor. Swaps the access token and reloads
  /// profile/progression in the background so those requests never await this
  /// in-flight refresh (which would deadlock the interceptor).
  Future<bool> _handleUnauthorizedRefresh() async {
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
      await _persistRefreshedSession(refreshed);
      unawaited(loadProfile());
      unawaited(loadProgression());
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('Failed to refresh mobile session (interceptor): $error');
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
      _lastDisplayAwardedXp = delta.awarded;
      unawaited(loadProgression());
      return;
    }
    // The parcel response only reports its own event amount in [delta.awarded],
    // but [delta.newTotal] also includes any same-request streak award. Show the
    // larger of the two so the user sees their true XP gain.
    final totalJump = delta.newTotal - p.totalXp;
    _lastDisplayAwardedXp = totalJump > delta.awarded ? totalJump : delta.awarded;
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

  /// Disconnects the active account (revokes its device server-side) and removes
  /// it locally. If other accounts remain, the most recent becomes active.
  Future<void> signOut({bool notify = true}) async {
    final removingUserId = _activeUserId;
    if (_session != null) {
      try {
        await _mobileAuthRepository.disconnect();
      } catch (_) {
        // Best-effort: still clear local session if the token is expired or offline.
      }
    }

    final store = removingUserId != null
        ? await MobileSessionStorage.remove(removingUserId)
        : await MobileSessionStorage.readStore();
    _accounts = store.accounts;
    _activeUserId = store.activeUserId;

    final active = store.active;
    if (active != null) {
      _session = active.session;
      _applyAccessToken(active.session.accessToken);
      _profile = null;
      _memberProgression = null;
      await loadProfile();
      await loadProgression();
      await _syncActiveDisplayName();
    } else {
      _session = null;
      _profile = null;
      _memberProgression = null;
      _apiClient.clearHeader('Authorization');
    }

    if (notify) {
      notifyListeners();
    }
  }

  bool _isNearExpiry(MobileAuthResponseDto session) {
    return session.accessTokenExpiresAt.isBefore(
      DateTime.now().toUtc().add(const Duration(minutes: 1)),
    );
  }

  String? _displayNameForUser(String userId) {
    for (final account in _accounts) {
      if (account.userId == userId) return account.displayName;
    }
    return null;
  }

  Future<void> _persistRefreshedSession(MobileAuthResponseDto refreshed) async {
    final userId =
        _activeUserId ?? decodeUserIdFromJwt(refreshed.accessToken);
    if (userId == null) return;
    _activeUserId = userId;
    final store = await MobileSessionStorage.upsertAndActivate(
      MobileAccountSession(
        userId: userId,
        displayName: _displayNameForUser(userId),
        session: refreshed,
      ),
    );
    _accounts = store.accounts;
  }

  /// Persists the loaded profile's display name onto the active account so the
  /// account switcher can label it.
  Future<void> _syncActiveDisplayName() async {
    final userId = _activeUserId;
    final session = _session;
    final name = _profile?.displayName;
    if (userId == null || session == null || name == null || name.isEmpty) {
      return;
    }
    if (_displayNameForUser(userId) == name) return;
    final store = await MobileSessionStorage.upsertAndActivate(
      MobileAccountSession(
        userId: userId,
        displayName: name,
        session: session,
      ),
    );
    _accounts = store.accounts;
  }

  void _applyAccessToken(String token) {
    _apiClient.updateHeaders({'Authorization': 'Bearer $token'});
  }
}
