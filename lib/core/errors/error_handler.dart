import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'app_error.dart';
import '../network/api_client.dart';

/// Centralized error handling service for general browse screens (businesses,
/// properties, events, creative spaces, etc.), producing [AppError]s with a
/// title + retry action for full-screen error states.
///
/// This adapts the transport-level [ApiException] (already produced by the
/// interceptors in `lib/core/network/api_client.dart`) into a presentation
/// [AppError]. It does NOT re-map raw [DioException]s from scratch - the HTTP
/// status -> message classification lives in one place (the interceptor).
///
/// NOTE: Parcel / member-hub and connect-device flows do NOT use this. They
/// standardize on [ApiException] + [resolveUserFacingApiError] (see
/// `lib/core/network/api_client.dart`) and surface errors via `showErrorSnack`
/// / `ErrorStateView` (`lib/core/widgets/error_feedback.dart`). Prefer that path
/// for any new parcel/member code so we keep a single error vocabulary there.
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  final Connectivity _connectivity = Connectivity();

  /// Convert any exception to a user-friendly AppError
  Future<AppError> handleError(dynamic error, {VoidCallback? retryAction}) async {
    // Transport failures arrive as an [ApiException] (wrapped in a
    // [DioException] by the error interceptor). Unwrap and adapt it rather than
    // re-deriving the status mapping here.
    final apiException = _asApiException(error);
    if (apiException != null) {
      return _fromApiException(apiException, retryAction);
    }

    // Handle location exceptions
    if (error is Exception && error.toString().contains('Location')) {
      return _handleLocationError(error, retryAction);
    }

    // Handle JSON parsing errors (TypeError, CastError, etc.)
    if (error is TypeError ||
        error.toString().contains('type') ||
        error.toString().contains('cast')) {
      return AppErrors.invalidData(retryAction);
    }

    // Handle other exceptions
    return AppErrors.unknown(retryAction);
  }

  /// Extracts the canonical [ApiException] from [error] when present.
  ApiException? _asApiException(Object? error) {
    if (error is ApiException) return error;
    if (error is DioException) {
      final inner = error.error;
      if (inner is ApiException) return inner;
    }
    return null;
  }

  /// Adapts a transport [ApiException] into a presentation [AppError].
  Future<AppError> _fromApiException(
    ApiException error,
    VoidCallback? retryAction,
  ) async {
    // HTTP responses carry a status code: branch on it (keeps 408/429 nuances).
    final statusCode = error.statusCode;
    if (statusCode != null) {
      return _fromHttpStatus(statusCode, error, retryAction);
    }

    // No status code: classify by transport type.
    switch (error.type) {
      case ApiExceptionType.timeout:
        return AppErrors.connectionTimeout(retryAction);

      case ApiExceptionType.network:
        return _handleNoConnection(retryAction);

      case ApiExceptionType.cancelled:
        return ValidationError(
          title: 'Request Cancelled',
          message: 'The request was cancelled. Please try again.',
          actionText: retryAction != null ? 'Retry' : null,
          action: retryAction,
        );

      case ApiExceptionType.badRequest:
      case ApiExceptionType.unauthorized:
      case ApiExceptionType.forbidden:
      case ApiExceptionType.notFound:
      case ApiExceptionType.server:
      case ApiExceptionType.client:
      case ApiExceptionType.unknown:
        return AppErrors.unknown(retryAction);
    }
  }

  /// Decides between "no internet" and "server unreachable" for connection
  /// failures that have no HTTP status code.
  Future<AppError> _handleNoConnection(VoidCallback? retryAction) async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();

      if (connectivityResults.contains(ConnectivityResult.none) ||
          connectivityResults.every((result) => result == ConnectivityResult.none)) {
        return AppErrors.noInternet(retryAction);
      }

      // Network is available but connection failed - likely server unreachable
      return AppErrors.serverUnreachable(retryAction);
    } catch (e) {
      // If we can't check connectivity, assume network issue
      return AppErrors.serverUnreachable(retryAction);
    }
  }

  /// Maps an HTTP status code (with the server-provided [ApiException.message])
  /// to a presentation [AppError].
  AppError _fromHttpStatus(
    int statusCode,
    ApiException error,
    VoidCallback? retryAction,
  ) {
    switch (statusCode) {
      case 400:
        return ValidationError(
          title: 'Invalid Request',
          message: error.message,
          actionText: retryAction != null ? 'Retry' : null,
          action: retryAction,
        );

      case 401:
        return ValidationError(
          title: 'Authentication Required',
          message: 'Connect your device to continue.',
          actionText: 'Connect device',
          action: retryAction,
        );

      case 403:
        return ValidationError(
          title: 'Access Denied',
          message: 'You don\'t have permission to access this resource.',
          actionText: 'OK',
        );

      case 404:
        return ValidationError(
          title: 'Not Found',
          message: 'The requested resource was not found.',
          actionText: retryAction != null ? 'Retry' : null,
          action: retryAction,
        );

      case 408:
        return AppErrors.connectionTimeout(retryAction);

      case 429:
        return ServerError(
          title: 'Too Many Requests',
          message: 'Please wait a moment before trying again.',
          actionText: 'Retry Later',
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return AppErrors.internalServerError(retryAction);

      default:
        if (statusCode >= 500) {
          return AppErrors.internalServerError(retryAction);
        } else if (statusCode >= 400) {
          return ValidationError(
            title: 'Request Error',
            message: 'There was an issue with your request. Please try again.',
            actionText: retryAction != null ? 'Retry' : null,
            action: retryAction,
          );
        } else {
          return AppErrors.unknown(retryAction);
        }
    }
  }

  /// Handle location-related errors
  AppError _handleLocationError(Exception error, VoidCallback? retryAction) {
    final errorMessage = error.toString().toLowerCase();

    if (errorMessage.contains('disabled') || errorMessage.contains('service')) {
      return AppErrors.locationDisabled(retryAction);
    } else if (errorMessage.contains('permission') || errorMessage.contains('denied')) {
      return AppErrors.locationPermissionDenied(retryAction);
    } else {
      return AppErrors.locationUnavailable(retryAction);
    }
  }
}
