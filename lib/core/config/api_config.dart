import 'package:flutter/foundation.dart';

import 'platform_network_probe.dart';

/// Environments available for the application.
enum AppEnvironment {
  production,
  localHost, // For Emulator (10.0.2.2) or iOS Simulator (localhost)
  localNetwork, // For Physical Devices on same network
}

/// Configuration constants for API communication.
///
/// ### Environment selection
/// - **Default**: `production` for **profile/release**, `localHost` for **debug**
/// - **Override**:
///   - `--dart-define=TT_ENV=production|localHost|localNetwork`
///   - `--dart-define=TT_API_BASE_URL=https://your-api-host` (highest priority)
class ApiConfig {
  static const String _dartDefineEnv = String.fromEnvironment('TT_ENV', defaultValue: '');
  static const String _dartDefineBaseUrl = String.fromEnvironment('TT_API_BASE_URL', defaultValue: '');

  // Runtime override (used for smart dev resolution without affecting release builds)
  static String? _runtimeBaseUrlOverride;

  // Current Environment Configuration (runtime switchable)
  static AppEnvironment _currentEnvironment = _resolveInitialEnvironment();

  // Base URLs
  static const String azureUrl = 'https://towntrek-hedwejadesagbaf6.southafricanorth-01.azurewebsites.net';

  // Local Development URLs
  // VS Studio typically runs on port 7125 for HTTPS
  static const String _localhostUrl = 'https://localhost:7125';
  // Android Emulator uses 10.0.2.2 to access host localhost
  static const String _androidEmulatorUrl = 'https://10.0.2.2:7125';
  // iOS Simulator uses localhost
  // static const String _iosSimulatorUrl = 'https://localhost:7125';
  // Physical device needs your LAN IP
  static const String _localNetworkUrl = 'https://192.168.1.104:7125';

  // Mapbox configuration
  // WARNING: This key is exposed in the client app.
  // Ensure your Mapbox token is restricted to your application bundle ID/package name in the Mapbox dashboard.
  static const String mapboxAccessToken =
      'pk.eyJ1Ijoiam9obnN0ZXJzIiwiYSI6ImNtZ2oxeXp2MzBjcTYybHNscDNrYnBuZmoifQ.sRTsjeym9YHrR1cxjHPmXw';

  // Dynamic base URL getter
  static String get baseUrl {
    // Highest priority (runtime): resolved/forced value (debug helper).
    final runtime = _runtimeBaseUrlOverride?.trim();
    if (runtime != null && runtime.isNotEmpty) return runtime;

    // Highest priority: explicit base URL override at build/run time.
    final override = _dartDefineBaseUrl.trim();
    if (override.isNotEmpty) return override;

    switch (_currentEnvironment) {
      case AppEnvironment.production:
        return azureUrl;
      case AppEnvironment.localHost:
        // NOTE:
        // - Android Emulator: use 10.0.2.2
        // - Physical device (USB): prefer adb reverse + localhost (resolved at runtime in initialize())
        // - iOS Simulator: localhost
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          return _androidEmulatorUrl;
        }
        return _localhostUrl;
      case AppEnvironment.localNetwork:
        return _localNetworkUrl;
    }
  }

  /// Initializes runtime configuration for non-production builds.
  ///
  /// This is intentionally conservative:
  /// - **Production** is never changed.
  /// - If `TT_API_BASE_URL` is provided, we respect it and do nothing.
  /// - Otherwise, we try a small set of common dev URLs and pick the first reachable one.
  ///
  /// Call this **before** creating the `ApiClient` (i.e., before DI init in `main()`).
  static Future<void> initialize() async {
    if (_currentEnvironment == AppEnvironment.production) return;

    // Build/run-time override wins.
    if (_dartDefineBaseUrl.trim().isNotEmpty) return;

    final candidates = <String>[];

    // For Android physical devices, `adb reverse tcp:7125 tcp:7125` allows localhost to work.
    // For iOS Simulator, localhost works directly.
    candidates.add(_localhostUrl);

    // Android emulator host mapping.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      candidates.add(_androidEmulatorUrl);
    }

    // LAN fallback (requires API to bind to LAN interface and firewall to allow 7125).
    candidates.add(_localNetworkUrl);

    final resolved = await _pickFirstReachableBaseUrl(candidates);
    if (resolved != null) {
      _runtimeBaseUrlOverride = resolved;
    }
  }

  static Future<String?> _pickFirstReachableBaseUrl(List<String> baseUrls) async {
    for (final raw in baseUrls) {
      final candidate = raw.trim();
      if (candidate.isEmpty) continue;

      final uri = Uri.tryParse(candidate);
      if (uri == null || uri.host.isEmpty || uri.port == 0) continue;

      final ok = await canConnect(uri.host, uri.port, timeout: const Duration(milliseconds: 750));
      if (ok) return candidate;
    }
    return null;
  }

  static AppEnvironment _resolveInitialEnvironment() {
    final parsed = _tryParseEnvironment(_dartDefineEnv);
    if (parsed != null) return parsed;

    // Default behavior: ship builds use Azure unless explicitly overridden.
    if (kReleaseMode || kProfileMode) return AppEnvironment.production;
    return AppEnvironment.localHost;
  }

  static AppEnvironment? _tryParseEnvironment(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.isEmpty) return null;

    switch (value) {
      case 'prod':
      case 'production':
        return AppEnvironment.production;
      case 'localhost':
      case 'local_host':
      case 'local':
      case 'dev':
      case 'debug':
        return AppEnvironment.localHost;
      case 'localnetwork':
      case 'local_network':
      case 'lan':
      case 'network':
        return AppEnvironment.localNetwork;
      default:
        return null;
    }
  }

  static const String apiVersion = 'api';

  // Endpoints
  static const String businessesEndpoint = 'businesses';
  static const String servicesEndpoint = 'services';
  static const String townsEndpoint = 'towns';
  static const String eventsEndpoint = 'events';
  static const String statsEndpoint = 'stats';

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
      return uri
          .replace(queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())))
          .toString();
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

  /// Builds services endpoint URL
  static String servicesUrl([Map<String, dynamic>? queryParams]) {
    return buildUrl(servicesEndpoint, queryParams);
  }

  /// Builds services search endpoint URL
  static String serviceSearchUrl([Map<String, dynamic>? queryParams]) {
    return buildUrl('$servicesEndpoint/search', queryParams);
  }

  /// Builds services categories endpoint URL
  static String serviceCategoriesUrl([Map<String, dynamic>? queryParams]) {
    return buildUrl('$servicesEndpoint/categories', queryParams);
  }

  /// Builds specific service endpoint URL
  static String serviceDetailUrl(int serviceId, [Map<String, dynamic>? queryParams]) {
    return buildUrl('$servicesEndpoint/$serviceId', queryParams);
  }

  /// Builds service subcategories endpoint URL
  static String serviceSubCategoriesUrl(int categoryId, [Map<String, dynamic>? queryParams]) {
    return buildUrl('$servicesEndpoint/categories/$categoryId/subcategories', queryParams);
  }

  /// Builds services categories with counts for town endpoint URL
  static String serviceCategoriesWithCountsUrl(int townId, [Map<String, dynamic>? queryParams]) {
    return buildUrl('$servicesEndpoint/categories/town/$townId', queryParams);
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

  /// Builds stats summary endpoint URL (used by the mobile landing page)
  static String statsSummaryUrl([Map<String, dynamic>? queryParams]) {
    return buildUrl('$statsEndpoint/summary', queryParams);
  }

  /// Get the appropriate base URL for the current environment
  static String getBaseUrlForEnvironment([AppEnvironment? environment]) {
    if (environment != null) {
      _currentEnvironment = environment;
    }
    return baseUrl;
  }

  /// Switch environment
  static void setEnvironment(AppEnvironment environment) {
    _currentEnvironment = environment;
  }

  /// Get current environment
  static AppEnvironment get environment => _currentEnvironment;
}


