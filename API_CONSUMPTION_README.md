# TownTrek Flutter API Consumption Layer

This document provides a comprehensive guide to the centralized API consumption layer built for the TownTrek Flutter application.

## Overview

The API consumption layer provides a clean, maintainable, and testable way to interact with the TownTrek ASP.NET backend. It follows best practices for Flutter development including:

- **Separation of Concerns**: Clear separation between data models, API services, repositories, and UI
- **Dependency Injection**: Centralized service locator for easy testing and maintenance
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Result Pattern**: Type-safe handling of success/failure operations
- **Retry Logic**: Automatic retry for failed requests
- **Logging**: Detailed logging for debugging and monitoring

## Architecture

```
lib/
├── models/                 # Data transfer objects (DTOs)
├── services/              # API service classes
├── repositories/          # Repository layer for data access abstraction
├── core/
│   ├── config/           # API configuration
│   ├── network/          # Dio client and interceptors
│   ├── utils/            # Utilities (logger, result pattern)
│   └── di/               # Dependency injection
└── screens/               # UI screens (with API demo)
```

## Quick Start

### 1. Initialize Dependencies

```dart
import 'core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator and all dependencies
  serviceLocator.initialize();

  runApp(const TownTrekApp());
}
```

### 2. Use Repositories

```dart
import 'core/core.dart';

// Get towns
final towns = await serviceLocator.townRepository.getTowns();

// Search businesses
final businesses = await serviceLocator.businessRepository.searchBusinesses(
  query: "restaurant",
  townId: 1,
);

// Get business details
final businessDetails = await serviceLocator.businessRepository.getBusinessDetails(123);
```

## Core Components

### ApiClient

Singleton Dio client with built-in interceptors for logging, error handling, and retry logic.

**Features:**
- Automatic retry on failure
- Request/response logging
- Standardized error handling
- Timeout configuration

### Result Pattern

Type-safe handling of API operations:

```dart
// Using Result for better error handling
Result<List<TownDto>> result = await _fetchTowns();

result.fold(
  onSuccess: (towns) {
    // Handle success
    setState(() => _towns = towns);
  },
  onFailure: (error, originalError) {
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  },
);
```

## API Endpoints

### Business Endpoints

```dart
// Get businesses with filtering
BusinessListResponse businesses = await serviceLocator.businessRepository.getBusinesses(
  townId: 1,
  category: "restaurant",
  page: 1,
  pageSize: 20,
);

// Search businesses
BusinessListResponse searchResults = await serviceLocator.businessRepository.searchBusinesses(
  query: "pizza",
  townId: 1,
);

// Get business details
BusinessDetailDto details = await serviceLocator.businessRepository.getBusinessDetails(123);

// Get categories
List<CategoryDto> categories = await serviceLocator.businessRepository.getCategories();

// Get categories with business counts for a town
List<CategoryWithCountDto> categoriesWithCounts =
    await serviceLocator.businessRepository.getCategoriesWithCounts(1);
```

### Town Endpoints

```dart
// Get all towns
List<TownDto> towns = await serviceLocator.townRepository.getTowns();

// Get town details
TownDto town = await serviceLocator.townRepository.getTownDetails(1);
```

## Data Models

All data models are immutable and include:
- JSON serialization/deserialization
- `copyWith` methods for updates
- Proper `toString`, `==`, and `hashCode` implementations

### Business Models

- `BusinessDto`: Basic business information for listings
- `BusinessDetailDto`: Detailed business information with reviews, hours, services
- `BusinessListResponse`: Paginated business listings

### Category Models

- `CategoryDto`: Categories with subcategories
- `CategoryWithCountDto`: Categories with business counts per town
- `SubCategoryDto`: Subcategory information

### Other Models

- `TownDto`: Town information
- `OperatingHourDto`: Business operating hours
- `BusinessServiceDto`: Business services
- `BusinessImageDto`: Business images
- `ReviewDto`: Customer reviews

## Error Handling

The layer provides comprehensive error handling:

### ApiException Types

- `network`: Network connectivity issues
- `timeout`: Request timeout
- `badRequest`: Invalid request (400)
- `unauthorized`: Authentication required (401)
- `forbidden`: Access denied (403)
- `notFound`: Resource not found (404)
- `server`: Server errors (5xx)
- `cancelled`: Request cancelled
- `unknown`: Unexpected errors

### Error Handling Example

```dart
try {
  final businesses = await serviceLocator.businessRepository.getBusinesses(townId: 1);
  // Handle success
} on ApiException catch (e) {
  switch (e.type) {
    case ApiExceptionType.network:
      // Show offline message
      break;
    case ApiExceptionType.notFound:
      // Show not found message
      break;
    default:
      // Show generic error
      break;
  }
} catch (e) {
  // Handle unexpected errors
}
```

## Configuration

### API Configuration

Update `lib/core/config/api_config.dart` with your API details:

```dart
class ApiConfig {
  static const String baseUrl = 'https://your-api-domain.com';
  // ... other configurations
}
```

### Timeouts and Retries

Configure timeouts and retry behavior in `ApiConfig`:

```dart
static const Duration connectTimeout = Duration(seconds: 30);
static const Duration receiveTimeout = Duration(seconds: 30);
static const int maxRetries = 3;
```

## Testing

### Unit Testing

```dart
// Example test for repository
void main() {
  late BusinessRepository repository;
  late BusinessApiService mockApiService;

  setUp(() {
    mockApiService = MockBusinessApiService();
    repository = BusinessRepositoryImpl(mockApiService);
  });

  test('getBusinesses returns BusinessListResponse', () async {
    // Arrange
    when(mockApiService.getBusinesses(townId: 1))
        .thenAnswer((_) async => mockBusinessListResponse);

    // Act
    final result = await repository.getBusinesses(townId: 1);

    // Assert
    expect(result, isA<BusinessListResponse>());
  });
}
```

### Integration Testing

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('API integration test', (tester) async {
    await tester.pumpWidget(const TownTrekApp());

    // Test actual API calls
    final towns = await serviceLocator.townRepository.getTowns();
    expect(towns, isNotEmpty);
  });
}
```

## Best Practices

### 1. Use Repositories, Not Services Directly

```dart
// ✅ Good
final businesses = await serviceLocator.businessRepository.getBusinesses();

// ❌ Avoid
final businesses = await serviceLocator.businessApiService.getBusinesses();
```

### 2. Handle Errors Appropriately

```dart
// ✅ Good - Use Result pattern
Result<BusinessListResponse> result = await _fetchBusinesses();
result.fold(
  onSuccess: (data) => setState(() => _businesses = data),
  onFailure: (error, _) => _showError(error),
);

// ❌ Avoid - Bare try/catch
try {
  final businesses = await serviceLocator.businessRepository.getBusinesses();
  setState(() => _businesses = businesses);
} catch (e) {
  _showError(e.toString());
}
```

### 3. Use Proper Loading States

```dart
// ✅ Good
setState(() => _isLoading = true);
try {
  final data = await serviceLocator.businessRepository.getBusinesses();
  setState(() {
    _data = data;
    _isLoading = false;
  });
} catch (e) {
  setState(() {
    _error = e.toString();
    _isLoading = false;
  });
}
```

### 4. Cancel Requests When Appropriate

```dart
// ✅ Good - Cancel on widget dispose
class _MyWidgetState extends State<MyWidget> {
  CancelToken? _cancelToken;

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    _cancelToken = CancelToken();
    try {
      final data = await serviceLocator.businessRepository.getBusinesses(
        cancelToken: _cancelToken,
      );
      // Handle data
    } catch (e) {
      if (!CancelToken.isCancel(e)) {
        // Handle error
      }
    }
  }
}
```

## Demo Screen

The app includes an `ApiDemoScreen` that demonstrates all API endpoints. Access it from the landing page to see the API consumption layer in action.

## Migration Guide

When migrating from direct API calls:

1. **Replace direct Dio calls** with repository methods
2. **Update error handling** to use `Result` pattern or try/catch with `ApiException`
3. **Add loading states** for better UX
4. **Use dependency injection** instead of singleton instances

## Troubleshooting

### Common Issues

1. **"DioException: Connection failed"**
   - Check internet connection
   - Verify API URL in `ApiConfig`
   - Check CORS settings on backend

2. **"ApiException: unauthorized"**
   - Implement authentication if required
   - Check API key/token configuration

3. **Timeout errors**
   - Increase timeout values in `ApiConfig`
   - Check network speed

### Debug Logging

Enable detailed logging by checking the console output. All API requests and responses are logged automatically.

## Contributing

When adding new API endpoints:

1. Add DTOs to `lib/models/`
2. Create/update API service methods
3. Add repository methods
4. Update service locator
5. Add to demo screen for testing

## Dependencies

Required packages added to `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.3.2                    # HTTP client
  connectivity_plus: ^5.0.2      # Network connectivity
  provider: ^6.0.5               # State management
  logger: ^2.0.2                 # Logging
  shared_preferences: ^2.2.2     # Local storage
```

---

**Note**: This API consumption layer is designed to be production-ready and follows Flutter best practices. Update the API URL in `ApiConfig` before deploying to production.
