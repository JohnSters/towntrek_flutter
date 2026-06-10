import 'package:flutter/foundation.dart';

import 'platform_network_probe.dart';

export 'api_endpoints.dart';

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
  static const String _dartDefineEnv = String.fromEnvironment(
    'TT_ENV',
    defaultValue: '',
  );
  static const String _dartDefineBaseUrl = String.fromEnvironment(
    'TT_API_BASE_URL',
    defaultValue: '',
  );

  static String? _runtimeBaseUrlOverride;
  static AppEnvironment _currentEnvironment = _resolveInitialEnvironment();

  static const String azureUrl =
      'https://towntrek-hedwejadesagbaf6.southafricanorth-01.azurewebsites.net';

  static const String _localhostUrl = 'https://localhost:7125';
  static const String _androidEmulatorUrl = 'https://10.0.2.2:7125';
  static const String _localNetworkUrl = 'https://192.168.1.1:7125';

  static String get baseUrl {
    final runtime = _runtimeBaseUrlOverride?.trim();
    if (runtime != null && runtime.isNotEmpty) return runtime;

    final override = _dartDefineBaseUrl.trim();
    if (override.isNotEmpty) return override;

    switch (_currentEnvironment) {
      case AppEnvironment.production:
        return azureUrl;
      case AppEnvironment.localHost:
        return _localhostUrl;
      case AppEnvironment.localNetwork:
        return _localNetworkUrl;
    }
  }

  static Future<void> initialize() async {
    if (_currentEnvironment == AppEnvironment.production) return;
    if (_dartDefineBaseUrl.trim().isNotEmpty) return;

    final candidates = <String>[ _localhostUrl ];

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      candidates.add(_androidEmulatorUrl);
    }

    candidates.add(_localNetworkUrl);

    final resolved = await _pickFirstReachableBaseUrl(candidates);
    if (resolved != null) {
      _runtimeBaseUrlOverride = resolved;
    }
  }

  static Future<String?> _pickFirstReachableBaseUrl(
    List<String> baseUrls,
  ) async {
    for (final raw in baseUrls) {
      final candidate = raw.trim();
      if (candidate.isEmpty) continue;

      final uri = Uri.tryParse(candidate);
      if (uri == null || uri.host.isEmpty || uri.port == 0) continue;

      final ok = await canConnect(
        uri.host,
        uri.port,
        timeout: const Duration(milliseconds: 750),
      );
      if (ok) return candidate;
    }
    return null;
  }

  static AppEnvironment _resolveInitialEnvironment() {
    final parsed = _tryParseEnvironment(_dartDefineEnv);
    if (parsed != null) return parsed;

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

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);

  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  static const String contentTypeHeader = 'Content-Type';
  static const String jsonContentType = 'application/json';
  static const String acceptHeader = 'Accept';
  static const String userAgentHeader = 'User-Agent';
  static const String appUserAgent = 'TownTrek-Mobile/1.0';

  static const int successStatusCode = 200;
  static const int createdStatusCode = 201;
  static const int badRequestStatusCode = 400;
  static const int unauthorizedStatusCode = 401;
  static const int forbiddenStatusCode = 403;
  static const int notFoundStatusCode = 404;
  static const int internalServerErrorStatusCode = 500;

  static String getBaseUrlForEnvironment([AppEnvironment? environment]) {
    if (environment != null) {
      _currentEnvironment = environment;
    }
    return baseUrl;
  }

  static void setEnvironment(AppEnvironment environment) {
    _currentEnvironment = environment;
  }

  static AppEnvironment get environment => _currentEnvironment;
}
