import 'dart:async';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import '../models/town_dto.dart';
import '../core/utils/result.dart';

/// Service for handling geolocation operations
abstract class GeolocationService {
  /// Request location permissions from the user
  Future<Result<bool>> requestLocationPermission();

  /// Get the current position of the device
  Future<Result<Position>> getCurrentPosition();

  /// Find the nearest town based on current location
  Future<Result<TownDto>> findNearestTown(List<TownDto> towns);

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled();

  /// Check location permission status
  Future<LocationPermission> checkPermission();
}

/// Implementation of GeolocationService using geolocator package
class GeolocationServiceImpl implements GeolocationService {
  @override
  Future<Result<bool>> requestLocationPermission() async {
    try {
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return Result.failure('Location permission denied');
      }

      if (permission == LocationPermission.unableToDetermine) {
        return Result.failure(
          'Unable to determine your location permission status. Please try again or select a town manually.'
        );
      }

      if (permission == LocationPermission.deniedForever) {
        return Result.failure(
          'Location permission permanently denied. Please enable it in settings.'
        );
      }

      return Result.success(true); // whileInUse / always
    } catch (e) {
      return Result.failure('Failed to request location permission: $e');
    }
  }

  @override
  Future<Result<Position>> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Result.failure(
          'Location services are disabled. Please enable them in settings.'
        );
      }

      // Check permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final permissionResult = await requestLocationPermission();
        if (permissionResult.isFailure) {
          return Result.failure(permissionResult.error!);
        }
        permission = await Geolocator.checkPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return Result.failure(
          'Location permission permanently denied. Please enable it in settings.'
        );
      }

      if (permission == LocationPermission.unableToDetermine) {
        return Result.failure(
          'Unable to determine your location permission status. Please try again or select a town manually.'
        );
      }

      if (permission == LocationPermission.denied) {
        return Result.failure('Location permission not granted');
      }

      // Get current position with high accuracy
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } on TimeoutException {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          position = lastKnown;
        } else {
          return Result.failure('Timed out while trying to get your location.');
        }
      }

      return Result.success(position);
    } catch (e) {
      return Result.failure('Failed to get current position: $e');
    }
  }

  @override
  Future<Result<TownDto>> findNearestTown(List<TownDto> towns) async {
    try {
      final positionResult = await getCurrentPosition();

      if (positionResult.isFailure) {
        return Result.failure(positionResult.error!);
      }

      final position = positionResult.data;

      // Filter towns that have coordinates
      final townsWithCoordinates = towns.where((town) =>
        town.latitude != null && town.longitude != null
      ).toList();

      if (townsWithCoordinates.isEmpty) {
        return Result.failure('No towns with location data found');
      }

      // Find the nearest town
      TownDto? nearestTown;
      double minDistance = double.infinity;

      for (final town in townsWithCoordinates) {
        final distance = _calculateDistance(
          position.latitude,
          position.longitude,
          town.latitude!,
          town.longitude!,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestTown = town;
        }
      }

      if (nearestTown == null) {
        return Result.failure('Could not determine nearest town');
      }

      return Result.success(nearestTown);
    } catch (e) {
      return Result.failure('Failed to find nearest town: $e');
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      return LocationPermission.denied;
    }
  }

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
        math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
