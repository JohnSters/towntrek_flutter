import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../config/api_config.dart';
import 'api_interceptors.dart';

export 'api_error_parsers.dart';
export 'api_exception.dart';

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

  /// Hook invoked by [AuthRefreshInterceptor] on a 401 to attempt a single
  /// token refresh. Returns `true` if a fresh access token was applied (the
  /// failed request is then replayed). Registered by `MobileSessionManager`.
  Future<bool> Function()? onUnauthorized;

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
        contentType: ApiConfig.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    if (ApiConfig.environment != AppEnvironment.production) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          return host == 'localhost' ||
              host == '127.0.0.1' ||
              host == '10.0.2.2' ||
              host.startsWith('192.168.');
        };
        return client;
      };
    }

    _dio.interceptors.addAll(buildApiInterceptors(this));
  }

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

  void updateHeaders(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }

  void clearHeader(String headerKey) {
    _dio.options.headers.remove(headerKey);
  }

  void clearAllHeaders() {
    _dio.options.headers.clear();
    _dio.options.headers.addAll({
      ApiConfig.contentTypeHeader: ApiConfig.jsonContentType,
      ApiConfig.acceptHeader: ApiConfig.jsonContentType,
      ApiConfig.userAgentHeader: ApiConfig.appUserAgent,
    });
  }
}
