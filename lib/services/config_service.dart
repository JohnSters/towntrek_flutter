import '../core/network/api_client.dart';

/// Loads public app config (e.g. Mapbox token from `GET /api/config/public`).
class ConfigService {
  ConfigService(this._apiClient);

  final ApiClient _apiClient;

  String? _mapboxAccessToken;

  /// Cached for the session. Returns null if missing or request fails.
  Future<String?> getMapboxAccessToken({bool forceRefresh = false}) async {
    if (!forceRefresh && _mapboxAccessToken != null) {
      return _mapboxAccessToken;
    }
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/config/public',
      );
      final data = response.data;
      if (data == null) return null;
      final mapbox = data['mapbox'] as Map<String, dynamic>?;
      final token = mapbox?['accessToken'] as String?;
      if (token != null && token.isNotEmpty) {
        _mapboxAccessToken = token;
      }
      return _mapboxAccessToken;
    } catch (_) {
      return _mapboxAccessToken;
    }
  }

  void clearCache() {
    _mapboxAccessToken = null;
  }
}
