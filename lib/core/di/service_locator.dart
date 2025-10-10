import '../../repositories/repositories.dart';
import '../../services/services.dart';
import '../network/api_client.dart';

/// Service Locator for dependency injection
/// This provides a centralized way to access all services and repositories
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() => _instance;

  ServiceLocator._internal();

  // Core dependencies
  late final ApiClient _apiClient;
  late final BusinessApiService _businessApiService;
  late final TownApiService _townApiService;

  // Repository dependencies
  late final BusinessRepository _businessRepository;
  late final TownRepository _townRepository;

  /// Initialize all dependencies
  void initialize() {
    if (_isInitialized) return;

    // Initialize core services
    _apiClient = ApiClient.instance;

    // Initialize API services
    _businessApiService = BusinessApiService(_apiClient);
    _townApiService = TownApiService(_apiClient);

    // Initialize repositories
    _businessRepository = BusinessRepositoryImpl(_businessApiService);
    _townRepository = TownRepositoryImpl(_townApiService);

    _isInitialized = true;
  }

  bool get isInitialized => _isInitialized;
  bool _isInitialized = false;

  // Getters for accessing dependencies

  /// Get the API client instance
  ApiClient get apiClient {
    _ensureInitialized();
    return _apiClient;
  }

  /// Get the business API service
  BusinessApiService get businessApiService {
    _ensureInitialized();
    return _businessApiService;
  }

  /// Get the town API service
  TownApiService get townApiService {
    _ensureInitialized();
    return _townApiService;
  }

  /// Get the business repository
  BusinessRepository get businessRepository {
    _ensureInitialized();
    return _businessRepository;
  }

  /// Get the town repository
  TownRepository get townRepository {
    _ensureInitialized();
    return _townRepository;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'ServiceLocator has not been initialized. Call initialize() in main() before accessing repositories.'
      );
    }
  }
}

/// Global instance for easy access
final serviceLocator = ServiceLocator();
