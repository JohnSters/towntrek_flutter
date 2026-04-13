DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString())?.toUtc() ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
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
