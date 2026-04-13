import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/mobile_auth_dto.dart';

class MobileSessionStorage {
  static const String _sessionKey = 'mobile_auth_session';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> save(MobileAuthResponseDto session) async {
    await _storage.write(
      key: _sessionKey,
      value: jsonEncode(session.toJson()),
    );
  }

  static Future<MobileAuthResponseDto?> read() async {
    final raw = await _storage.read(key: _sessionKey);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    return MobileAuthResponseDto.fromJson(decoded);
  }

  static Future<void> clear() async {
    await _storage.delete(key: _sessionKey);
  }
}
