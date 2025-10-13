import 'package:flutter/material.dart';

/// Base class for all application errors
abstract class AppError implements Exception {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? action;

  const AppError({
    required this.title,
    required this.message,
    this.actionText,
    this.action,
  });

  @override
  String toString() => '$title: $message';
}

/// Network-related errors
class NetworkError extends AppError {
  const NetworkError({
    required super.title,
    required super.message,
    super.actionText,
    super.action,
  });
}

/// Server-related errors
class ServerError extends AppError {
  const ServerError({
    required super.title,
    required super.message,
    super.actionText,
    super.action,
  });
}

/// Location/GPS related errors
class LocationError extends AppError {
  const LocationError({
    required super.title,
    required super.message,
    super.actionText,
    super.action,
  });
}

/// Validation errors
class ValidationError extends AppError {
  const ValidationError({
    required super.title,
    required super.message,
    super.actionText,
    super.action,
  });
}

/// Generic unknown errors
class UnknownError extends AppError {
  const UnknownError({
    required super.title,
    required super.message,
    super.actionText,
    super.action,
  });
}

/// Common predefined errors for reuse
class AppErrors {
  // Network errors
  static NetworkError connectionTimeout([VoidCallback? action]) => NetworkError(
    title: 'Connection Timeout',
    message: 'The request took too long to complete. Please check your internet connection and try again.',
    actionText: 'Retry',
    action: action,
  );

  static NetworkError noInternet([VoidCallback? action]) => NetworkError(
    title: 'No Internet Connection',
    message: 'Please check your internet connection and try again.',
    actionText: 'Retry',
    action: action,
  );

  static NetworkError serverUnreachable([VoidCallback? action]) => NetworkError(
    title: 'Server Unreachable',
    message: 'We\'re having trouble connecting to our servers. Please try again in a moment.',
    actionText: 'Retry',
    action: action,
  );

  // Server errors
  static ServerError internalServerError([VoidCallback? action]) => ServerError(
    title: 'Server Error',
    message: 'Something went wrong on our end. Please try again later.',
    actionText: 'Retry',
    action: action,
  );

  static ServerError serviceUnavailable([VoidCallback? action]) => ServerError(
    title: 'Service Unavailable',
    message: 'The service is temporarily unavailable. Please try again later.',
    actionText: 'Retry',
    action: action,
  );

  // Location errors
  static LocationError locationDisabled([VoidCallback? action]) => LocationError(
    title: 'Location Services Disabled',
    message: 'Please enable location services in your device settings to find nearby businesses.',
    actionText: 'Open Settings',
    action: action,
  );

  static LocationError locationPermissionDenied([VoidCallback? action]) => LocationError(
    title: 'Location Permission Required',
    message: 'We need location permission to find businesses near you. Please grant permission in your device settings.',
    actionText: 'Open Settings',
    action: action,
  );

  static LocationError locationUnavailable([VoidCallback? action]) => LocationError(
    title: 'Location Unavailable',
    message: 'We couldn\'t determine your location. You can still browse businesses by selecting your town manually.',
    actionText: 'Select Manually',
    action: action,
  );

  // Data errors
  static ValidationError noDataAvailable([VoidCallback? action]) => ValidationError(
    title: 'No Data Available',
    message: 'No information is currently available. Please try again later.',
    actionText: 'Retry',
    action: action,
  );

  static ValidationError invalidData([VoidCallback? action]) => ValidationError(
    title: 'Invalid Data',
    message: 'The received data appears to be invalid. Please try again.',
    actionText: 'Retry',
    action: action,
  );

  // Generic errors
  static UnknownError unknown([VoidCallback? action]) => UnknownError(
    title: 'Something Went Wrong',
    message: 'An unexpected error occurred. Please try again.',
    actionText: 'Retry',
    action: action,
  );

  static UnknownError featureUnavailable([VoidCallback? action]) => UnknownError(
    title: 'Feature Unavailable',
    message: 'This feature is currently unavailable. Please try again later.',
    actionText: 'OK',
    action: action,
  );
}
