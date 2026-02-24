import '../../repositories/repositories.dart';
import '../../services/services.dart';
import '../network/api_client.dart';
import '../errors/error_handler.dart';

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
  late final EventApiService _eventApiService;
  late final ServiceApiService _serviceApiService;
  late final StatsApiService _statsApiService;
  late final GeolocationService _geolocationService;
  late final NavigationService _navigationService;
  late final ErrorHandler _errorHandler;

  // Repository dependencies
  late final BusinessRepository _businessRepository;
  late final TownRepository _townRepository;
  late final EventRepository _eventRepository;
  late final ServiceRepository _serviceRepository;
  late final StatsRepository _statsRepository;

  /// Initialize all dependencies
  void initialize() {
    if (_isInitialized) return;

    // Initialize core services
    _apiClient = ApiClient.instance;
    _errorHandler = ErrorHandler();

    // Initialize API services
    _businessApiService = BusinessApiService(_apiClient);
    _townApiService = TownApiService(_apiClient);
    _eventApiService = EventApiService(_apiClient);
    _serviceApiService = ServiceApiService(_apiClient);
    _statsApiService = StatsApiService(_apiClient);
    _geolocationService = GeolocationServiceImpl();
    _navigationService = NavigationServiceImpl();

    // Initialize repositories
    _businessRepository = BusinessRepositoryImpl(_businessApiService);
    _townRepository = TownRepositoryImpl(_townApiService);
    _eventRepository = EventRepositoryImpl(_eventApiService);
    _serviceRepository = ServiceRepositoryImpl(_serviceApiService);
    _statsRepository = StatsRepositoryImpl(_statsApiService);

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

  /// Get the service API service
  ServiceApiService get serviceApiService {
    _ensureInitialized();
    return _serviceApiService;
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

  /// Get the event repository
  EventRepository get eventRepository {
    _ensureInitialized();
    return _eventRepository;
  }

  /// Get the service repository
  ServiceRepository get serviceRepository {
    _ensureInitialized();
    return _serviceRepository;
  }

  /// Get the stats repository
  StatsRepository get statsRepository {
    _ensureInitialized();
    return _statsRepository;
  }

  /// Get the geolocation service
  GeolocationService get geolocationService {
    _ensureInitialized();
    return _geolocationService;
  }

  /// Get the navigation service
  NavigationService get navigationService {
    _ensureInitialized();
    return _navigationService;
  }

  /// Get the error handler
  ErrorHandler get errorHandler {
    _ensureInitialized();
    return _errorHandler;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'ServiceLocator has not been initialized. Call initialize() in main() before accessing repositories.',
      );
    }
  }
}

/// Global instance for easy access
final serviceLocator = ServiceLocator();
