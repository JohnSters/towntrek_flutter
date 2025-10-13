/// Configuration constants for API communication
class ApiConfig {
  // Static variable to allow dynamic switching between environments
  static String _currentBaseUrl = localNetworkUrl;
  // Base URLs - these should be configurable for different environments
  // For external devices, use your machine's IP address instead of localhost
  static const String localhostUrl = 'http://localhost:5220';
  static const String localNetworkUrl = 'http://192.168.1.103:5220'; // Your machine's local IP address

  // Mapbox configuration
  // TODO: Move to secure configuration (environment variables, secure storage)
  static const String mapboxAccessToken = 'pk.eyJ1Ijoiam9obnN0ZXJzIiwiYSI6ImNtZ2oxeXp2MzBjcTYybHNscDNrYnBuZmoifQ.sRTsjeym9YHrR1cxjHPmXw';

  // Dynamic base URL that can be switched between environments
  static String get baseUrl => _currentBaseUrl;
  static const String apiVersion = 'api';

  // Endpoints
  static const String businessesEndpoint = 'businesses';
  static const String townsEndpoint = 'towns';
  static const String eventsEndpoint = 'events';

  // Timeout configurations - reduced for development
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);

  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // Pagination defaults
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Request headers
  static const String contentTypeHeader = 'Content-Type';
  static const String jsonContentType = 'application/json';
  static const String acceptHeader = 'Accept';
  static const String userAgentHeader = 'User-Agent';
  static const String appUserAgent = 'TownTrek-Mobile/1.0';

  // API Response status codes
  static const int successStatusCode = 200;
  static const int createdStatusCode = 201;
  static const int badRequestStatusCode = 400;
  static const int unauthorizedStatusCode = 401;
  static const int forbiddenStatusCode = 403;
  static const int notFoundStatusCode = 404;
  static const int internalServerErrorStatusCode = 500;

  /// Builds the full API URL for a given endpoint
  static String buildUrl(String endpoint, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('$baseUrl/$apiVersion/$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString()))).toString();
    }
    return uri.toString();
  }

  /// Builds business endpoint URL
  static String businessesUrl([Map<String, dynamic>? queryParams]) {
    return buildUrl(businessesEndpoint, queryParams);
  }

  /// Builds business search endpoint URL
  static String businessSearchUrl([Map<String, dynamic>? queryParams]) {
    return buildUrl('$businessesEndpoint/search', queryParams);
  }

  /// Builds business categories endpoint URL
  static String categoriesUrl([Map<String, dynamic>? queryParams]) {
    return buildUrl('$businessesEndpoint/categories', queryParams);
  }

  /// Builds categories with counts for town endpoint URL
  static String categoriesWithCountsUrl(int townId, [Map<String, dynamic>? queryParams]) {
    return buildUrl('$businessesEndpoint/categories/town/$townId', queryParams);
  }

  /// Builds specific business endpoint URL
  static String businessDetailUrl(int businessId, [Map<String, dynamic>? queryParams]) {
    return buildUrl('$businessesEndpoint/$businessId', queryParams);
  }

  /// Builds towns endpoint URL
  static String townsUrl([Map<String, dynamic>? queryParams]) {
    return buildUrl(townsEndpoint, queryParams);
  }

  /// Builds specific town endpoint URL
  static String townDetailUrl(int townId, [Map<String, dynamic>? queryParams]) {
    return buildUrl('$townsEndpoint/$townId', queryParams);
  }

  /// Builds events endpoint URL
  static String eventsUrl([Map<String, dynamic>? queryParams]) {
    return buildUrl(eventsEndpoint, queryParams);
  }

  /// Builds event search endpoint URL
  static String eventSearchUrl([Map<String, dynamic>? queryParams]) {
    return buildUrl('$eventsEndpoint/search', queryParams);
  }

  /// Builds current events endpoint URL
  static String currentEventsUrl([Map<String, dynamic>? queryParams]) {
    return buildUrl('$eventsEndpoint/current', queryParams);
  }

  /// Builds event types endpoint URL
  static String eventTypesUrl([Map<String, dynamic>? queryParams]) {
    return buildUrl('$eventsEndpoint/types', queryParams);
  }

  /// Builds specific event endpoint URL
  static String eventDetailUrl(int eventId, [Map<String, dynamic>? queryParams]) {
    return buildUrl('$eventsEndpoint/$eventId', queryParams);
  }

  /// Get the appropriate base URL for the current environment
  /// This can be modified to read from environment variables or app settings
  static String getBaseUrlForEnvironment([String? environment]) {
    // You can implement logic here to detect environment
    // For now, return the configured baseUrl
    return baseUrl;
  }

  /// Switch to localhost for emulator/simulator development
  static void useLocalhost() {
    _currentBaseUrl = localhostUrl;
  }

  /// Switch to network IP for external device testing
  static void useNetworkUrl() {
    _currentBaseUrl = localNetworkUrl;
  }

  /// Set a custom base URL
  static void setCustomBaseUrl(String url) {
    _currentBaseUrl = url;
  }

  /// Get the current base URL being used
  static String getCurrentBaseUrl() => _currentBaseUrl;
}
