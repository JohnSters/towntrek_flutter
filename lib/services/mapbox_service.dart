import 'dart:convert';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../core/utils/result.dart';
import '../core/config/api_config.dart';

/// Service for handling Mapbox Maps operations
abstract class MapboxService {
  /// Initialize Mapbox with access token
  Future<Result<bool>> initialize();

  /// Get directions from current location to destination
  Future<Result<Map<String, dynamic>>> getDirections(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  );

  /// Search for places using Mapbox Geocoding API
  Future<Result<List<Map<String, dynamic>>>> searchPlaces(String query);

  /// Reverse geocode coordinates to address
  Future<Result<Map<String, dynamic>>> reverseGeocode(double lat, double lng);
}

/// Implementation of MapboxService
class MapboxServiceImpl implements MapboxService {
  static const String _baseUrl = 'https://api.mapbox.com';
  late final String _accessToken;

  MapboxServiceImpl() {
    _accessToken = ApiConfig.mapboxAccessToken;
  }

  @override
  Future<Result<bool>> initialize() async {
    try {
      if (_accessToken.isEmpty) {
        return Result.failure('Mapbox access token not configured');
      }

      // Set the access token globally for the Mapbox SDK
      MapboxOptions.setAccessToken(_accessToken);

      return Result.success(true);
    } catch (e) {
      return Result.failure('Failed to initialize Mapbox: $e');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getDirections(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/directions/v5/mapbox/driving/$startLng,$startLat;$endLng,$endLat'
        '?geometries=geojson&overview=full&steps=true&access_token=$_accessToken',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          return Result.success(data['routes'][0]);
        } else {
          return Result.failure('No routes found');
        }
      } else {
        return Result.failure('Directions API error: ${response.statusCode}');
      }
    } catch (e) {
      return Result.failure('Failed to get directions: $e');
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> searchPlaces(String query) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/geocoding/v5/mapbox.places/$query.json'
        '?access_token=$_accessToken&limit=5',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List<dynamic>;

        return Result.success(
          features.map((feature) => feature as Map<String, dynamic>).toList(),
        );
      } else {
        return Result.failure('Geocoding API error: ${response.statusCode}');
      }
    } catch (e) {
      return Result.failure('Failed to search places: $e');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/geocoding/v5/mapbox.places/$lng,$lat.json'
        '?access_token=$_accessToken',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List<dynamic>;

        if (features.isNotEmpty) {
          return Result.success(features[0] as Map<String, dynamic>);
        } else {
          return Result.failure('No address found for coordinates');
        }
      } else {
        return Result.failure('Reverse geocoding API error: ${response.statusCode}');
      }
    } catch (e) {
      return Result.failure('Failed to reverse geocode: $e');
    }
  }
}
