/// Configuration constants for API communication
class ApiConfig {
  // Base URLs - these should be configurable for different environments
  // For external devices, use your machine's IP address instead of localhost
  static const String baseUrl = 'http://192.168.1.103:5220'; // Your machine's local IP address
  static const String apiVersion = 'api';

  // Endpoints
  static const String businessesEndpoint = 'businesses';
  static const String townsEndpoint = 'towns';

  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

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
}
