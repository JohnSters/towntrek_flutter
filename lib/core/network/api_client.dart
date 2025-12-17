import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../config/api_config.dart';
import '../utils/logger.dart';

/// Singleton Dio client for API communication
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  ApiClient._() {
    _initializeDio();
  }

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Dio get dio => _dio;

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          ApiConfig.contentTypeHeader: ApiConfig.jsonContentType,
          ApiConfig.acceptHeader: ApiConfig.jsonContentType,
          ApiConfig.userAgentHeader: ApiConfig.appUserAgent,
        },
        // Disable automatic content type detection to avoid issues with form data
        contentType: ApiConfig.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    // Configure SSL certificate handling for development
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };

    // Add interceptors
    _dio.interceptors.addAll([
      _LoggingInterceptor(),
      _ErrorInterceptor(),
      _RetryInterceptor(),
    ]);
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Update headers for authenticated requests
  void updateHeaders(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }

  /// Clear specific header
  void clearHeader(String headerKey) {
    _dio.options.headers.remove(headerKey);
  }

  /// Clear all custom headers
  void clearAllHeaders() {
    _dio.options.headers.clear();
    // Re-add default headers
    _dio.options.headers.addAll({
      ApiConfig.contentTypeHeader: ApiConfig.jsonContentType,
      ApiConfig.acceptHeader: ApiConfig.jsonContentType,
      ApiConfig.userAgentHeader: ApiConfig.appUserAgent,
    });
  }
}

/// Logging interceptor for debugging API calls
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Logger.i('🌐 API Request: ${options.method} ${options.uri}');
    if (options.queryParameters.isNotEmpty) {
      Logger.d('Query Parameters: ${options.queryParameters}');
    }
    if (options.data != null) {
      Logger.d('Request Data: ${options.data}');
    }
    Logger.d('Headers: ${options.headers}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Logger.i('✅ API Response: ${response.statusCode} ${response.requestOptions.uri}');
    Logger.d('Response Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Logger.e('❌ API Error: ${err.type} ${err.requestOptions.uri}');
    Logger.e('Error Message: ${err.message}');
    if (err.response != null) {
      Logger.e('Status Code: ${err.response?.statusCode}');
      Logger.e('Error Response: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}

/// Error interceptor for standardized error handling
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Transform DioException to our custom exceptions
    final apiException = _mapDioExceptionToApiException(err);
    // Create a new DioException with our custom error
    final dioException = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: apiException,
    );
    handler.reject(dioException);
  }

  String? _tryExtractErrorMessage(dynamic responseData) {
    if (responseData == null) return null;

    // Most common case: JSON object
    if (responseData is Map) {
      final dynamic direct =
          responseData['error'] ?? responseData['message'] ?? responseData['Error'] ?? responseData['Message'];

      if (direct != null) return direct.toString();

      // Handle GlobalExceptionMiddleware shape: { "Error": { "Message": "..." } }
      final dynamic nestedError = responseData['Error'] ?? responseData['error'];
      if (nestedError is Map) {
        final dynamic nestedMessage = nestedError['Message'] ?? nestedError['message'];
        if (nestedMessage != null) return nestedMessage.toString();
      }

      return null;
    }

    // Sometimes Dio gives us a JSON string (or an HTML error page string)
    if (responseData is String) {
      final trimmed = responseData.trim();
      if (trimmed.isEmpty) return null;

      // Try decode JSON string
      try {
        final decoded = jsonDecode(trimmed);
        return _tryExtractErrorMessage(decoded);
      } catch (_) {
        // Not JSON. Avoid surfacing raw HTML to users.
        return null;
      }
    }

    return null;
  }

  ApiException _mapDioExceptionToApiException(DioException dioException) {
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

        String message = 'An error occurred while processing your request.';
        final extracted = _tryExtractErrorMessage(responseData);

        if (statusCode != null) {
          switch (statusCode) {
            case 400:
              message = extracted ?? 'Bad request. Please check your input.';
              return ApiException(
                type: ApiExceptionType.badRequest,
                message: message,
                statusCode: statusCode,
                originalException: dioException,
              );

            case 401:
              message = 'Unauthorized access. Please log in again.';
              return ApiException(
                type: ApiExceptionType.unauthorized,
                message: message,
                statusCode: statusCode,
                originalException: dioException,
              );

            case 403:
              message = 'Access forbidden. You don\'t have permission to perform this action.';
              return ApiException(
                type: ApiExceptionType.forbidden,
                message: message,
                statusCode: statusCode,
                originalException: dioException,
              );

            case 404:
              message = extracted ?? 'The requested resource was not found.';
              return ApiException(
                type: ApiExceptionType.notFound,
                message: message,
                statusCode: statusCode,
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
                originalException: dioException,
              );

            default:
              if (statusCode >= 400 && statusCode < 500) {
                message = extracted ?? 'Client error occurred.';
                return ApiException(
                  type: ApiExceptionType.client,
                  message: message,
                  statusCode: statusCode,
                  originalException: dioException,
                );
              } else if (statusCode >= 500) {
                message = 'Server error. Please try again later.';
                return ApiException(
                  type: ApiExceptionType.server,
                  message: message,
                  statusCode: statusCode,
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
}

/// Retry interceptor for failed requests
class _RetryInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    // Don't retry for certain error types
    if (_shouldNotRetry(err)) {
      return handler.reject(err);
    }

    // Check if we haven't exceeded max retries
    final retryCount = requestOptions.extra['retryCount'] ?? 0;
    if (retryCount >= ApiConfig.maxRetries) {
      return handler.reject(err);
    }

    // Increment retry count
    requestOptions.extra['retryCount'] = retryCount + 1;

    Logger.w('Retrying request (${retryCount + 1}/${ApiConfig.maxRetries}): ${requestOptions.uri}');

    // Wait before retrying
    await Future.delayed(ApiConfig.retryDelay * (retryCount + 1));

    // Retry the request
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
    // Don't retry for client errors (4xx) except timeout
    if (err.type == DioExceptionType.badResponse) {
      final statusCode = err.response?.statusCode;
      if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        return statusCode != 408 && statusCode != 429; // Don't retry timeout or rate limit
      }
    }

    // Don't retry for cancelled requests
    if (err.type == DioExceptionType.cancel) {
      return true;
    }

    return false;
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final ApiExceptionType type;
  final String message;
  final int? statusCode;
  final DioException? originalException;

  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
    this.originalException,
  });

  @override
  String toString() {
    return 'ApiException(type: $type, message: $message, statusCode: $statusCode)';
  }
}

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
