import 'dart:math';

import 'package:flutter/foundation.dart';

import 'mobile_secure_storage.dart';

/// Stable per-install id used when redeeming a TREK code so the server can
/// upsert the same UserDevice for this phone.
class MobileInstallIdStorage {
  static const String _key = 'mobile_auth_install_id';
  static Future<String>? _cached;

  /// Returns the existing install id, or creates and persists a new UUID.
  static Future<String> getInstallId() {
    _cached ??= _readOrCreate();
    return _cached!;
  }

  @visibleForTesting
  static void resetForTest() {
    _cached = null;
  }

  static Future<String> _readOrCreate() async {
    final existing = (await MobileSecureStorage.instance.read(key: _key))?.trim();
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final generated = _generateInstallId();
    await MobileSecureStorage.instance.write(key: _key, value: generated);
    return generated;
  }

  static String _generateInstallId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
