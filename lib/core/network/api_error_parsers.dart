import 'dart:convert';

/// Parses JSON body `error` / `message` fields (shared by interceptors and UI).
///
/// Handles all server shapes:
/// - structured envelope `{ "error": { "code": "...", "message": "..." } }`
/// - flat string `{ "error": "..." }` / `{ "message": "..." }`
/// - legacy PascalCase `{ "Error": { "Message": "..." } }`
String? extractApiErrorMessageFromResponseData(dynamic responseData) {
  if (responseData == null) return null;

  if (responseData is Map) {
    final dynamic nestedError = responseData['error'] ?? responseData['Error'];
    if (nestedError is Map) {
      final dynamic nestedMessage =
          nestedError['message'] ?? nestedError['Message'];
      if (nestedMessage != null) return nestedMessage.toString();
    }

    final dynamic direct = responseData['error'] ??
        responseData['message'] ??
        responseData['Error'] ??
        responseData['Message'];
    if (direct is String) return direct;
    if (direct != null && direct is! Map) return direct.toString();

    return null;
  }

  if (responseData is String) {
    final trimmed = responseData.trim();
    if (trimmed.isEmpty) return null;

    try {
      final decoded = jsonDecode(trimmed);
      return extractApiErrorMessageFromResponseData(decoded);
    } catch (_) {
      return null;
    }
  }

  return null;
}

/// Extracts the stable machine-readable error code from the structured envelope
/// `{ "error": { "code": "...", ... } }` when present, else `null`.
String? extractApiErrorCodeFromResponseData(dynamic responseData) {
  if (responseData is Map) {
    final dynamic nestedError = responseData['error'] ?? responseData['Error'];
    if (nestedError is Map) {
      final dynamic code = nestedError['code'] ?? nestedError['Code'];
      if (code != null) return code.toString();
    }
    return null;
  }
  if (responseData is String && responseData.trim().isNotEmpty) {
    try {
      return extractApiErrorCodeFromResponseData(jsonDecode(responseData.trim()));
    } catch (_) {
      return null;
    }
  }
  return null;
}
