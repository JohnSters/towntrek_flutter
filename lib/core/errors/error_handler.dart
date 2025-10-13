import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'app_error.dart';

/// Centralized error handling service
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  final Connectivity _connectivity = Connectivity();

  /// Convert any exception to a user-friendly AppError
  Future<AppError> handleError(dynamic error, {VoidCallback? retryAction}) async {
    // Handle Dio exceptions
    if (error is DioException) {
      return await _handleDioError(error, retryAction);
    }

    // Handle location exceptions
    if (error is Exception && error.toString().contains('Location')) {
      return _handleLocationError(error, retryAction);
    }

    // Handle other exceptions
    return AppErrors.unknown(retryAction);
  }

  /// Handle Dio-specific errors
  Future<AppError> _handleDioError(DioException error, VoidCallback? retryAction) async {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppErrors.connectionTimeout(retryAction);

      case DioExceptionType.connectionError:
        return await _handleConnectionError(error, retryAction);

      case DioExceptionType.badResponse:
        return _handleBadResponse(error, retryAction);

      case DioExceptionType.cancel:
        return ValidationError(
          title: 'Request Cancelled',
          message: 'The request was cancelled. Please try again.',
          actionText: retryAction != null ? 'Retry' : null,
          action: retryAction,
        );

      default:
        return AppErrors.unknown(retryAction);
    }
  }

  /// Handle connection-related errors
  Future<AppError> _handleConnectionError(DioException error, VoidCallback? retryAction) async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();

      // Check if there's any network connectivity
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

  /// Handle HTTP error responses
  AppError _handleBadResponse(DioException error, VoidCallback? retryAction) {
    final statusCode = error.response?.statusCode;

    switch (statusCode) {
      case 400:
        return ValidationError(
          title: 'Invalid Request',
          message: 'Please check your input and try again.',
          actionText: retryAction != null ? 'Retry' : null,
          action: retryAction,
        );

      case 401:
        return ValidationError(
          title: 'Authentication Required',
          message: 'Please log in to continue.',
          actionText: 'Login',
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
        if (statusCode != null && statusCode >= 500) {
          return AppErrors.internalServerError(retryAction);
        } else if (statusCode != null && statusCode >= 400) {
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

