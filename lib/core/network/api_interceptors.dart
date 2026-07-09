import 'dart:convert';

import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../utils/logger.dart';
import 'api_client.dart';

/// Max characters for a single HTTP log line (avoids huge allocations / log buffer truncation).
const int kMaxHttpLogChars = 12000;

String formatPayloadForLog(dynamic data) {
  if (data == null) return 'null';
  try {
    if (data is Map || data is List) {
      final encoded = const JsonEncoder.withIndent('  ').convert(data);
      if (encoded.length > kMaxHttpLogChars) {
        return '${encoded.substring(0, kMaxHttpLogChars)}… [truncated $kMaxHttpLogChars chars]';
      }
      return encoded;
    }
  } catch (_) {
    // Fall through to toString
  }
  final s = data.toString();
  if (s.length > kMaxHttpLogChars) {
    return '${s.substring(0, kMaxHttpLogChars)}… [truncated]';
  }
  return s;
}

Map<String, dynamic> redactHeadersForLog(Map<String, dynamic> headers) {
  final out = <String, dynamic>{};
  for (final e in headers.entries) {
    final k = e.key.toString().toLowerCase();
    if (k == 'authorization' || k == 'cookie' || k == 'set-cookie') {
      out[e.key] = '***';
    } else {
      out[e.key] = e.value;
    }
  }
  return out;
}

const Set<String> _sensitivePayloadKeys = {
  'code',
  'accesstoken',
  'refreshtoken',
  'token',
  'authorization',
  'password',
};

/// Deep-walks [data] and replaces sensitive auth fields with `***` for logs.
dynamic redactPayloadForLog(dynamic data) {
  if (data is Map) {
    final out = <String, dynamic>{};
    for (final e in data.entries) {
      final key = e.key.toString();
      if (_sensitivePayloadKeys.contains(key.toLowerCase())) {
        out[key] = '***';
      } else {
        out[key] = redactPayloadForLog(e.value);
      }
    }
    return out;
  }
  if (data is List) {
    return data.map(redactPayloadForLog).toList();
  }
  return data;
}

/// Builds the interceptors wired into [ApiClient].
List<Interceptor> buildApiInterceptors(ApiClient client) {
  final interceptors = <Interceptor>[
    AuthRefreshInterceptor(client),
    ErrorInterceptor(),
    RetryInterceptor(),
  ];
  if (ApiConfig.environment != AppEnvironment.production) {
    interceptors.insert(0, LoggingInterceptor());
  }
  return interceptors;
}

/// Logging interceptor for debugging API calls
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Logger.i('🌐 API Request: ${options.method} ${options.uri}');
    if (options.queryParameters.isNotEmpty) {
      Logger.d('Query Parameters: ${formatPayloadForLog(options.queryParameters)}');
    }
    if (options.data != null) {
      Logger.d(
        'Request Data: ${formatPayloadForLog(redactPayloadForLog(options.data))}',
      );
    }
    Logger.d(
      'Headers: ${formatPayloadForLog(redactHeadersForLog(Map<String, dynamic>.from(options.headers)))}',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Logger.i('✅ API Response: ${response.statusCode} ${response.requestOptions.uri}');
    Logger.d(
      'Response Data: ${formatPayloadForLog(redactPayloadForLog(response.data))}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Logger.e('❌ API Error: ${err.type} ${err.requestOptions.uri}');
    Logger.e('Error Message: ${err.message}');
    if (err.response != null) {
      Logger.e('Status Code: ${err.response?.statusCode}');
      Logger.e(
        'Error Response: ${formatPayloadForLog(redactPayloadForLog(err.response?.data))}',
      );
    }
    super.onError(err, handler);
  }
}

/// Attempts a single token refresh + request replay when the server returns 401.
class AuthRefreshInterceptor extends Interceptor {
  AuthRefreshInterceptor(this._client);

  final ApiClient _client;

  static const String triedRefreshKey = '__triedRefresh';
  static Future<bool>? inFlightRefresh;

  bool _isAuthEndpoint(String path) => path.contains('/api/mobile/');

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final requestOptions = err.requestOptions;
    final refresh = _client.onUnauthorized;

    final shouldAttempt =
        err.type == DioExceptionType.badResponse &&
        response?.statusCode == 401 &&
        refresh != null &&
        requestOptions.extra[triedRefreshKey] != true &&
        !_isAuthEndpoint(requestOptions.path) &&
        _hasAuthHeader(requestOptions);

    if (!shouldAttempt) {
      return handler.next(err);
    }

    requestOptions.extra[triedRefreshKey] = true;

    var refreshed = false;
    try {
      refreshed = await (inFlightRefresh ??= refresh());
    } catch (_) {
      refreshed = false;
    } finally {
      inFlightRefresh = null;
    }

    if (!refreshed) {
      return handler.next(err);
    }

    final freshAuth = _client.dio.options.headers['Authorization'];
    if (freshAuth != null) {
      requestOptions.headers['Authorization'] = freshAuth;
    }

    try {
      final replay = await _client.dio.fetch<dynamic>(requestOptions);
      return handler.resolve(replay);
    } on DioException catch (replayError) {
      return handler.next(replayError);
    } catch (_) {
      return handler.next(err);
    }
  }

  bool _hasAuthHeader(RequestOptions options) {
    final value = options.headers['Authorization'];
    return value is String && value.isNotEmpty;
  }
}

/// Error interceptor for standardized error handling
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = mapDioExceptionToApiException(err);
    final dioException = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: apiException,
    );
    handler.reject(dioException);
  }
}

ApiException mapDioExceptionToApiException(DioException dioException) {
  switch (dioException.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return ApiException(
        type: ApiExceptionType.timeout,
        message: 'Request timeout. Please check your connection and try again.',
        originalException: dioException,
      );

    case DioExceptionType.connectionError:
      return ApiException(
        type: ApiExceptionType.network,
        message: 'Network error. Please check your internet connection.',
        originalException: dioException,
      );

    case DioExceptionType.badResponse:
      final statusCode = dioException.response?.statusCode;
      final responseData = dioException.response?.data;

      var message = 'An error occurred while processing your request.';
      final extracted = extractApiErrorMessageFromResponseData(responseData);
      final code = extractApiErrorCodeFromResponseData(responseData);

      if (statusCode != null) {
        switch (statusCode) {
          case 400:
            message = extracted ?? 'Bad request. Please check your input.';
            return ApiException(
              type: ApiExceptionType.badRequest,
              message: message,
              statusCode: statusCode,
              code: code,
              originalException: dioException,
            );

          case 401:
            message = 'Unauthorized access. Connect your device to continue.';
            return ApiException(
              type: ApiExceptionType.unauthorized,
              message: message,
              statusCode: statusCode,
              code: code,
              originalException: dioException,
            );

          case 403:
            message =
                'Access forbidden. You don\'t have permission to perform this action.';
            return ApiException(
              type: ApiExceptionType.forbidden,
              message: message,
              statusCode: statusCode,
              code: code,
              originalException: dioException,
            );

          case 404:
            message = extracted ?? 'The requested resource was not found.';
            return ApiException(
              type: ApiExceptionType.notFound,
              message: message,
              statusCode: statusCode,
              code: code,
              originalException: dioException,
            );

          case 500:
          case 502:
          case 503:
          case 504:
            message = 'Server error. Please try again later.';
            return ApiException(
              type: ApiExceptionType.server,
              message: message,
              statusCode: statusCode,
              code: code,
              originalException: dioException,
            );

          default:
            if (statusCode >= 400 && statusCode < 500) {
              message = extracted ?? 'Client error occurred.';
              return ApiException(
                type: ApiExceptionType.client,
                message: message,
                statusCode: statusCode,
                code: code,
                originalException: dioException,
              );
            } else if (statusCode >= 500) {
              message = 'Server error. Please try again later.';
              return ApiException(
                type: ApiExceptionType.server,
                message: message,
                statusCode: statusCode,
                code: code,
                originalException: dioException,
              );
            }
        }
      }
      break;

    case DioExceptionType.cancel:
      return ApiException(
        type: ApiExceptionType.cancelled,
        message: 'Request was cancelled.',
        originalException: dioException,
      );

    default:
      return ApiException(
        type: ApiExceptionType.unknown,
        message: 'An unexpected error occurred.',
        originalException: dioException,
      );
  }

  return ApiException(
    type: ApiExceptionType.unknown,
    message: 'An unexpected error occurred.',
    originalException: dioException,
  );
}

/// Retry interceptor for failed requests
class RetryInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    if (_shouldNotRetry(err)) {
      return handler.reject(err);
    }

    final retryCount = requestOptions.extra['retryCount'] ?? 0;
    if (retryCount >= ApiConfig.maxRetries) {
      return handler.reject(err);
    }

    requestOptions.extra['retryCount'] = retryCount + 1;

    Logger.w(
      'Retrying request (${retryCount + 1}/${ApiConfig.maxRetries}): ${requestOptions.uri}',
    );

    await Future.delayed(ApiConfig.retryDelay * (retryCount + 1));

    try {
      final response = await ApiClient.instance.dio.request(
        requestOptions.path,
        options: Options(
          method: requestOptions.method,
          headers: requestOptions.headers,
          extra: requestOptions.extra,
        ),
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
      );
      return handler.resolve(response);
    } catch (e) {
      return handler.reject(err);
    }
  }

  bool _shouldNotRetry(DioException err) {
    if (err.type == DioExceptionType.badResponse) {
      final statusCode = err.response?.statusCode;
      if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        return statusCode != 408 && statusCode != 429;
      }
    }

    if (err.type == DioExceptionType.cancel) {
      return true;
    }

    return false;
  }
}
