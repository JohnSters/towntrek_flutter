import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class DiscoveryInstallIdStorage {
  static const String _installIdKey = 'discovery_install_id';
  static Future<String>? _cachedInstallIdFuture;

  static Future<String> getInstallId() {
    _cachedInstallIdFuture ??= _readOrCreateInstallId();
    return _cachedInstallIdFuture!;
  }

  static Future<String> _readOrCreateInstallId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_installIdKey)?.trim();
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final generated = _generateInstallId();
    await prefs.setString(_installIdKey, generated);
    return generated;
  }

  static String _generateInstallId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
