import 'dart:convert';

DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString())?.toUtc() ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

/// Decodes the subject (user id) from a JWT access token without verifying the
/// signature. Used to key locally-stored sessions per account. Returns `null`
/// when the token is malformed.
String? decodeUserIdFromJwt(String accessToken) {
  try {
    final parts = accessToken.split('.');
    if (parts.length < 2) return null;
    var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    switch (payload.length % 4) {
      case 2:
        payload += '==';
        break;
      case 3:
        payload += '=';
        break;
    }
    final decoded = jsonDecode(utf8.decode(base64.decode(payload)));
    if (decoded is! Map) return null;
    final sub = decoded['sub'] ??
        decoded['nameid'] ??
        decoded['nameidentifier'] ??
        decoded[
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
    final value = sub?.toString();
    return (value == null || value.isEmpty) ? null : value;
  } catch (_) {
    return null;
  }
}

class MobileAuthResponseDto {
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;
  final int deviceId;

  const MobileAuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.deviceId,
  });

  factory MobileAuthResponseDto.fromJson(Map<String, dynamic> json) {
    return MobileAuthResponseDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      accessTokenExpiresAt: _parseDateTime(json['accessTokenExpiresAt']),
      deviceId: (json['deviceId'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'accessTokenExpiresAt': accessTokenExpiresAt.toIso8601String(),
    'deviceId': deviceId,
  };
}

/// A locally-stored linked account: the auth [session] plus the [userId] it
/// belongs to and a cached [displayName] for the account switcher UI.
class MobileAccountSession {
  final String userId;
  final String? displayName;
  final MobileAuthResponseDto session;

  const MobileAccountSession({
    required this.userId,
    required this.displayName,
    required this.session,
  });

  MobileAccountSession copyWith({
    String? displayName,
    MobileAuthResponseDto? session,
  }) {
    return MobileAccountSession(
      userId: userId,
      displayName: displayName ?? this.displayName,
      session: session ?? this.session,
    );
  }

  factory MobileAccountSession.fromJson(Map<String, dynamic> json) {
    return MobileAccountSession(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String?,
      session: MobileAuthResponseDto.fromJson(
        Map<String, dynamic>.from(json['session'] as Map),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'displayName': displayName,
    'session': session.toJson(),
  };
}
