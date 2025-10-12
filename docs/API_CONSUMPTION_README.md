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

## ⚠️ Critical Lessons Learned

**Always test API responses BEFORE creating models!** We encountered several critical issues that could have been prevented:

1. **Test endpoints first**: `curl http://localhost:5220/api/towns`
2. **Match models to reality**: Don't assume fields exist - verify with actual API responses
3. **Use null-safe boolean parsing**: `json['field'] as bool? ?? false`
4. **Configure servers properly**: Use `0.0.0.0` for external device testing
5. **Avoid URL construction issues**: No trailing slashes in baseUrl

See the [Troubleshooting](#troubleshooting) section for detailed solutions to these issues.

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

## Migration Guide

When migrating from direct API calls:

1. **Replace direct Dio calls** with repository methods
2. **Update error handling** to use `Result` pattern or try/catch with `ApiException`
3. **Add loading states** for better UX
4. **Use dependency injection** instead of singleton instances

## Troubleshooting

### 🚨 Critical Issues We Encountered & Fixed

During development, we encountered several critical issues that could have been prevented with proper API testing and model validation. Here's what we learned:

#### **Issue #1: "Type 'Null' is not a subtype of 'bool' in type cast"**
- **Problem**: Flutter `TownDto` expected `isActive` field, but ASP.NET API didn't return it
- **Root Cause**: Created model fields based on assumptions, not actual API responses
- **Fix**: Test API with `curl` first, then create models to match reality exactly

#### **Issue #2: Double Slashes in URLs**
- **Problem**: `http://192.168.1.103:5220//api/towns` (notice `//api`)
- **Root Cause**: `baseUrl` had trailing slash: `'http://192.168.1.103:5220/'`
- **Fix**: Remove trailing slashes from base URLs in `ApiConfig`

#### **Issue #3: External Device Connection Issues**
- **Problem**: Samsung device couldn't connect despite correct IP address
- **Root Cause**: ASP.NET server only listened on `localhost`, not network interfaces
- **Fix**: Configure `launchSettings.json` with `"applicationUrl": "http://0.0.0.0:5220"`

#### **Issue #4: LateInitializationError**
- **Problem**: Repository accessed before service locator initialization
- **Root Cause**: Race condition between widget initialization and dependency injection
- **Fix**: Add safety checks and proper initialization order

### Common Issues & Solutions

#### 1. **"Type 'Null' is not a subtype of 'bool' in type cast"**
   **Cause**: Boolean fields in Flutter models don't match API response structure
   **Symptoms**: App crashes when parsing JSON responses
   **Solutions**:
   - **Always use null-safe boolean parsing**: `json['field'] as bool? ?? false`
   - **Verify API responses match model expectations**: Test endpoints with curl/Postman
   - **Update models to match actual API responses**: Don't assume fields exist

   **Example Fix**:
   ```dart
   // ❌ Dangerous - will crash if null
   isActive: json['isActive'] as bool,

   // ✅ Safe - provides default value
   isActive: json['isActive'] as bool? ?? false,
   ```

#### 2. **"LateInitializationError: Field has not been initialized"**
   **Cause**: Accessing repository before service locator initialization
   **Symptoms**: Crashes on first repository access
   **Solutions**:
   - **Initialize service locator in main()**: Call `serviceLocator.initialize()` early
   - **Add safety checks**: Verify initialization before use
   - **Use dependency injection**: Avoid manual instantiation

#### 3. **"DioException: Connection failed" / "XMLHttpRequest onError"**
   **Cause**: Network connectivity or server configuration issues
   **Symptoms**: Timeout or connection refused errors
   **Solutions**:
   - **Check server status**: Verify ASP.NET server is running
   - **Verify network interfaces**: Ensure server listens on `0.0.0.0` not just `localhost`
   - **Use correct IP addresses**: Don't use `localhost` for external devices
   - **Test with curl**: `curl http://YOUR_IP:PORT/api/endpoint`

#### 4. **Double Slashes in URLs (`//api/endpoint`)**
   **Cause**: Incorrect URL construction with trailing slashes
   **Symptoms**: `http://192.168.1.103:5220//api/towns`
   **Solutions**:
   - **Remove trailing slashes from baseUrl**: `'http://192.168.1.103:5220'` not `'http://192.168.1.103:5220/'`
   - **Verify URL construction**: Check `ApiConfig.buildUrl()` method

#### 5. **Model-Response Mismatches**
   **Cause**: Flutter models don't match actual API response structure
   **Symptoms**: Missing fields or unexpected null values
   **Solutions**:
   - **Always test API responses first**: Use curl/Postman to inspect actual responses
   - **Update models to match reality**: Don't create fields that don't exist in API
   - **Document API contracts**: Keep models synchronized with backend

### ASP.NET Server Configuration

#### For External Device Testing:
1. **Update launchSettings.json**:
   ```json
   "applicationUrl": "http://0.0.0.0:5220"
   ```
2. **Use HTTP profile**: Run with `dotnet run --launch-profile http`
3. **Verify listening**: `netstat -ano | findstr :5220` should show `0.0.0.0:5220`

#### Network Debugging:
- **Test locally**: `curl http://localhost:5220/api/towns`
- **Test from network**: `curl http://192.168.1.103:5220/api/towns`
- **Check firewall**: Ensure port is not blocked
- **Same WiFi**: External devices must be on same network

### Flutter-Specific Issues

#### Boolean Field Handling:
```dart
// Always use null-safe parsing for booleans
isFeatured: json['isFeatured'] as bool? ?? false,
isVerified: json['isVerified'] as bool? ?? false,
hasNextPage: json['hasNextPage'] as bool? ?? false,
```

#### Model Synchronization:
```dart
// Before adding fields, verify they exist in API response
// Test with: curl http://YOUR_API_URL/api/endpoint | jq .
```

### Debug Logging

Enable detailed logging by checking the console output. All API requests and responses are logged automatically with emojis for easy identification:

- 🌐 **API Request**: Outgoing HTTP requests
- ✅ **API Response**: Successful responses
- ❌ **API Error**: Failed requests with error details
- 🐛 **Debug Info**: Request headers and response data

## Contributing

When adding new API endpoints:

1. Add DTOs to `lib/models/`
2. Create/update API service methods
3. Add repository methods
4. Update service locator
5. Add to demo screen for testing

## Dependencies & Architecture Decisions

### Core Dependencies

```yaml
dependencies:
  dio: ^5.3.2                    # HTTP client with interceptors
  connectivity_plus: ^5.0.2      # Network connectivity detection
  provider: ^6.0.5               # State management (planned for future use)
  logger: ^2.0.2                 # Structured logging with emojis
  shared_preferences: ^2.2.2     # Local storage (planned for caching)
```

### Architecture Decisions

#### **Why Dio over HTTP package?**
- **Interceptors**: Automatic retry logic, logging, error transformation
- **Better error handling**: Detailed DioException types vs generic exceptions
- **Request/Response logging**: Built-in debugging capabilities
- **Timeout management**: Granular control over connect/receive/send timeouts

#### **Why Repository Pattern?**
- **Testability**: Easy to mock repositories for unit testing
- **Separation of concerns**: Business logic separated from API implementation
- **Caching potential**: Easy to add caching layer between service and repository
- **Error transformation**: Centralized error handling and transformation

#### **Why Service Locator over GetIt/Provider?**
- **Simplicity**: Single point of dependency management
- **Transparency**: Clear initialization and access patterns
- **No external dependencies**: Built with core Dart/Flutter features
- **Easy debugging**: Direct access to all services for troubleshooting

### Development Workflow

#### **Always test API responses first**:
```bash
# Test endpoint before creating models
curl http://localhost:5220/api/towns
curl http://localhost:5220/api/businesses/categories
```

#### **Update models to match reality, not assumptions**:
```dart
// ❌ Don't assume fields exist
final bool isActive;  // Crashes if field doesn't exist

// ✅ Check API response first, then create matching model
// API returns: {"id":1,"name":"Town","businessCount":5}
// Model should match exactly what API provides
```

#### **Use null-safe boolean parsing**:
```dart
// Always protect against null boolean values
isFeatured: json['isFeatured'] as bool? ?? false,
isVerified: json['isVerified'] as bool? ?? false,
```

---

## Version History

- **v1.0**: Initial implementation with repository pattern, Dio client, and error handling
- **v1.1**: Added null-safe boolean parsing, fixed model-response mismatches, improved troubleshooting documentation

**Last Updated**: October 10, 2025
**Note**: This API consumption layer is designed to be production-ready and follows Flutter best practices. Update the API URL in `ApiConfig` before deploying to production.
