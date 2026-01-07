import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '../core/utils/result.dart';
import '../models/models.dart';
import 'geolocation_service.dart';
import 'mapbox_service.dart';

/// Service for handling navigation operations
abstract class NavigationService {
  /// Navigate to a business location using the best available method
  Future<Result<bool>> navigateToBusiness(BusinessDetailDto business);

  /// Get directions data for offline use or custom display
  Future<Result<Map<String, dynamic>>> getDirectionsToBusiness(BusinessDetailDto business);

  /// Open navigation in external app with fallback options
  Future<Result<bool>> openExternalNavigation(
    double destinationLat,
    double destinationLng,
    [String? destinationName]
  );
}

/// Implementation of NavigationService
class NavigationServiceImpl implements NavigationService {
  final GeolocationService _geolocationService;
  final MapboxService _mapboxService;

  NavigationServiceImpl(this._geolocationService, this._mapboxService);

  @override
  Future<Result<bool>> navigateToBusiness(BusinessDetailDto business) async {
    if (business.latitude == null || business.longitude == null) {
      return Result.failure('Business location not available');
    }

    try {
      // For now: Use external navigation apps (Google Maps, Apple Maps, Waze)
      // This is the same as your current implementation but with better error handling
      return openExternalNavigation(
        business.latitude!,
        business.longitude!,
        business.name,
      );

      // FUTURE: When you want in-app Mapbox navigation with route display:
      // final directionsResult = await getDirectionsToBusiness(business);
      // if (directionsResult.isSuccess) {
      //   // Navigate to a Mapbox-powered route screen
      //   return showInAppNavigation(directionsResult.data!, business);
      // }
    } catch (e) {
      return Result.failure('Navigation failed: $e');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getDirectionsToBusiness(BusinessDetailDto business) async {
    if (business.latitude == null || business.longitude == null) {
      return Result.failure('Business location not available');
    }

    try {
      // Get current location
      final currentLocationResult = await _geolocationService.getCurrentPosition();
      if (currentLocationResult.isFailure) {
        return Result.failure(currentLocationResult.error!);
      }

      final currentLocation = currentLocationResult.data;

      // Get directions from Mapbox
      return await _mapboxService.getDirections(
        currentLocation.latitude,
        currentLocation.longitude,
        business.latitude!,
        business.longitude!,
      );
    } catch (e) {
      return Result.failure('Failed to get directions: $e');
    }
  }

  @override
  Future<Result<bool>> openExternalNavigation(
    double destinationLat,
    double destinationLng,
    [String? destinationName]
  ) async {
    try {
      // Determine platform and use appropriate URL scheme
      final isIOS = _isIOS();
      final isAndroid = _isAndroid();

      String url;

      if (isIOS) {
        // iOS - prefer Apple Maps
        url = 'maps:///?daddr=$destinationLat,$destinationLng&dirflg=d';
        if (destinationName != null) {
          url += '&q=${Uri.encodeComponent(destinationName)}';
        }
      } else if (isAndroid) {
        // Android - use geo intent
        url = 'geo:$destinationLat,$destinationLng';
        if (destinationName != null) {
          url += '?q=$destinationLat,$destinationLng(${Uri.encodeComponent(destinationName)})';
        }
      } else {
        // Desktop/web - Google Maps
        url = 'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng';
      }

      final uri = Uri.parse(url);

      // Avoid canLaunchUrl false-negatives (Android 11+ package visibility / scheme queries).
      // Try launching directly; fall back to Google Maps web if it fails.
      final primaryLaunched = await _tryLaunchExternal(uri);
      if (primaryLaunched) return Result.success(true);

      // Fallback to Google Maps web directions
      final fallbackUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng',
      );
      final fallbackLaunched = await _tryLaunchExternal(fallbackUri);
      if (fallbackLaunched) return Result.success(true);

      return Result.failure('No navigation app available');
    } catch (e) {
      return Result.failure('Failed to open navigation: $e');
    }
  }

  Future<bool> _tryLaunchExternal(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  bool _isIOS() => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  bool _isAndroid() => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}
