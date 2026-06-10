import 'dart:convert';

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
