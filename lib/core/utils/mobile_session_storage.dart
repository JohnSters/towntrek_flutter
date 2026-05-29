import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/mobile_auth_dto.dart';

/// Snapshot of all locally-linked accounts and which one is active.
class MobileAccountStore {
  const MobileAccountStore({required this.accounts, required this.activeUserId});

  final List<MobileAccountSession> accounts;
  final String? activeUserId;

  MobileAccountSession? get active {
    if (activeUserId == null) return null;
    for (final account in accounts) {
      if (account.userId == activeUserId) return account;
    }
    return null;
  }

  static const MobileAccountStore empty =
      MobileAccountStore(accounts: [], activeUserId: null);
}

/// Persists linked mobile sessions in secure storage.
///
/// Supports multiple accounts per device (keyed by userId) with a single active
/// account. Transparently migrates the legacy single-session key on first read
/// so already-connected devices stay signed in.
class MobileSessionStorage {
  static const String _legacySessionKey = 'mobile_auth_session';
  static const String _storeKey = 'mobile_auth_sessions';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Reads all linked accounts, migrating the legacy single-session key if found.
  static Future<MobileAccountStore> readStore() async {
    final raw = await _storage.read(key: _storeKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          final accountsRaw = decoded['accounts'];
          final accounts = <MobileAccountSession>[];
          if (accountsRaw is List) {
            for (final item in accountsRaw) {
              if (item is Map) {
                accounts.add(MobileAccountSession.fromJson(
                  Map<String, dynamic>.from(item),
                ));
              }
            }
          }
          return MobileAccountStore(
            accounts: accounts,
            activeUserId: decoded['activeUserId'] as String?,
          );
        }
      } catch (_) {
        // Corrupt store; fall through to legacy/empty.
      }
    }

    return _migrateLegacy();
  }

  static Future<MobileAccountStore> _migrateLegacy() async {
    final legacy = await _storage.read(key: _legacySessionKey);
    if (legacy == null || legacy.isEmpty) {
      return MobileAccountStore.empty;
    }

    try {
      final decoded = jsonDecode(legacy);
      if (decoded is Map<String, dynamic>) {
        final session = MobileAuthResponseDto.fromJson(decoded);
        final userId = decodeUserIdFromJwt(session.accessToken) ?? 'legacy';
        final store = MobileAccountStore(
          accounts: [
            MobileAccountSession(
              userId: userId,
              displayName: null,
              session: session,
            ),
          ],
          activeUserId: userId,
        );
        await writeStore(store);
        await _storage.delete(key: _legacySessionKey);
        return store;
      }
    } catch (_) {
      // Ignore corrupt legacy value.
    }

    await _storage.delete(key: _legacySessionKey);
    return MobileAccountStore.empty;
  }

  static Future<void> writeStore(MobileAccountStore store) async {
    final payload = jsonEncode({
      'activeUserId': store.activeUserId,
      'accounts': store.accounts.map((a) => a.toJson()).toList(),
    });
    await _storage.write(key: _storeKey, value: payload);
  }

  /// Adds or updates [account] and marks it active.
  static Future<MobileAccountStore> upsertAndActivate(
    MobileAccountSession account,
  ) async {
    final store = await readStore();
    final accounts = List<MobileAccountSession>.from(store.accounts)
      ..removeWhere((a) => a.userId == account.userId)
      ..add(account);
    final next =
        MobileAccountStore(accounts: accounts, activeUserId: account.userId);
    await writeStore(next);
    return next;
  }

  /// Removes the account for [userId]; if it was active, promotes the most
  /// recently added remaining account (or clears the active account).
  static Future<MobileAccountStore> remove(String userId) async {
    final store = await readStore();
    final accounts = List<MobileAccountSession>.from(store.accounts)
      ..removeWhere((a) => a.userId == userId);
    final activeUserId = store.activeUserId == userId
        ? (accounts.isNotEmpty ? accounts.last.userId : null)
        : store.activeUserId;
    final next =
        MobileAccountStore(accounts: accounts, activeUserId: activeUserId);
    await writeStore(next);
    return next;
  }

  /// Sets the active account without changing the stored list.
  static Future<MobileAccountStore> setActive(String userId) async {
    final store = await readStore();
    final exists = store.accounts.any((a) => a.userId == userId);
    final next = MobileAccountStore(
      accounts: store.accounts,
      activeUserId: exists ? userId : store.activeUserId,
    );
    await writeStore(next);
    return next;
  }

  static Future<void> clearAll() async {
    await _storage.delete(key: _storeKey);
    await _storage.delete(key: _legacySessionKey);
  }
}
