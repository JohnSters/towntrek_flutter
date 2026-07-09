import 'package:dio/dio.dart';

import 'api_error_parsers.dart';

/// Types of API exceptions
enum ApiExceptionType {
  network,
  timeout,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  client,
  server,
  cancelled,
  unknown,
}

/// Custom exception for API errors
class ApiException implements Exception {
  final ApiExceptionType type;
  final String message;
  final int? statusCode;

  /// Stable machine-readable error code from the API envelope (see backend
  /// `ApiErrorCodes`), when the server provided one. Lets the UI branch on a
  /// specific condition (e.g. claim trust too low) rather than parsing text.
  final String? code;
  final DioException? originalException;

  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
    this.code,
    this.originalException,
  });

  @override
  String toString() {
    return 'ApiException(type: $type, message: $message, statusCode: $statusCode, code: $code)';
  }
}

/// Backend [ApiErrorCodes.RefreshInvalid] — refresh token is revoked or unknown.
const String kApiErrorCodeRefreshInvalid = 'REFRESH_INVALID';

ApiException? _asApiException(Object error) {
  if (error is ApiException) return error;
  if (error is DioException) {
    final inner = error.error;
    if (inner is ApiException) return inner;
  }
  return null;
}

/// Whether [error] represents a 401 from the API (after the auth interceptor has
/// already had its single chance to refresh). Callers use this to re-prompt the
/// user to connect their device rather than showing a generic error.
bool isUnauthorizedError(Object error) {
  final api = _asApiException(error);
  if (api != null) {
    return api.type == ApiExceptionType.unauthorized;
  }
  if (error is DioException) {
    return error.response?.statusCode == 401;
  }
  return false;
}

/// Whether a token-refresh failure means the local session must be cleared
/// (invalid/revoked refresh token or unauthorized), as opposed to a transient
/// network/server error where the session should be kept.
bool isAuthDeadRefreshError(Object error) {
  final api = _asApiException(error);
  if (api == null) return false;
  if (api.type == ApiExceptionType.unauthorized) return true;
  return api.type == ApiExceptionType.badRequest &&
      api.code == kApiErrorCodeRefreshInvalid;
}

/// User-visible text for failures from [ApiClient] / Dio (e.g. redeem-code errors).
String resolveUserFacingApiError(Object error) {
  if (error is DioException) {
    final inner = error.error;
    if (inner is ApiException) return inner.message;
    final fromBody = extractApiErrorMessageFromResponseData(error.response?.data);
    if (fromBody != null && fromBody.isNotEmpty) return fromBody;
    final msg = error.message;
    if (msg != null && msg.isNotEmpty) return msg;
  }
  if (error is ApiException) return error.message;
  return error.toString();
}
