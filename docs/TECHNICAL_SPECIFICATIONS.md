# TownTrek Flutter Mobile App - Technical Specifications

## Overview

TownTrek is a cross-platform mobile application built with Flutter that provides tourists and locals with comprehensive information about businesses, events, and attractions in various towns. The app serves as a mobile companion to the TownTrek web platform, offering location-based discovery and detailed information about local businesses and events.

## Current Development Status

**Status**: Early Development / Proof of Concept
- Basic Flutter project structure created
- Cross-platform configuration established
- Backend API integration planned

## Architecture

### Technology Stack

#### Frontend (Mobile App)
- **Framework**: Flutter 3.9.2+
- **Language**: Dart
- **UI Framework**: Material Design 3
- **State Management**: [To be determined - Provider/Bloc/Redux]
- **Networking**: HTTP client (Dio/HTTP package)
- **Local Storage**: Shared Preferences / SQLite
- **Location Services**: Geolocator package
- **Maps Integration**: [Google Maps/Mapbox - TBD]

#### Backend Integration
- **API Base URL**: [TownTrek Web API]
- **Authentication**: [JWT/Token-based - TBD]
- **Data Format**: JSON
- **Real-time Updates**: [WebSocket/SSE - TBD]

### Supported Platforms
- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 11.0+
- **Web**: Progressive Web App (PWA)
- **Desktop**: Windows, macOS, Linux

## Core Features

### 1. Town Discovery
- Browse and select towns
- Location-based town suggestions
- Town information and statistics
- Offline town data caching

### 2. Business Directory
- Search businesses by name, category, or location
- Filter by business category and subcategory
- Business details with contact information
- Operating hours and services
- Photo galleries
- Reviews and ratings
- Distance calculation from user location
- Featured business highlighting

### 3. Events Calendar
- Browse current and upcoming events
- Event details with descriptions and schedules
- Event categories and filtering
- Location-based event discovery
- Event search functionality

### 4. User Experience Features
- Offline-first architecture
- Location-based recommendations
- Push notifications for nearby events
- Dark/Light theme support
- Multi-language support [planned]

## API Integration

### Backend Endpoints

#### Towns API (`/api/towns`)
- `GET /api/towns` - Retrieve all active towns
- Response: Array of town objects with basic information

#### Business API (`/api/businesses`)
- `GET /api/businesses` - Get businesses with filtering
  - Query parameters: `townId`, `category`, `subCategory`, `search`, `page`, `pageSize`
- `GET /api/businesses/{id}` - Get detailed business information
- `GET /api/businesses/search` - Search businesses
- `GET /api/businesses/categories` - Get business categories
- `GET /api/businesses/categories/town/{townId}` - Get categories with business counts

#### Services API (`/api/services`)
- `GET /api/services` - Get services with filtering (requires at least one of: `townId`, `categoryId`, `subCategoryId`, `search`)
- `GET /api/services/{id}` - Get detailed service information
- `GET /api/services/search` - Search services
- `GET /api/services/categories` - Get service categories
- `GET /api/services/categories/town/{townId}` - Get service categories with service counts (used to disable empty categories/subcategories)
- `GET /api/services/categories/{categoryId}/subcategories` - Get service subcategories for a category

#### Events API (`/api/events`)
- `GET /api/events` - Get events for a town
  - Query parameters: `townId`, `eventType`, `page`, `pageSize`
- `GET /api/events/{id}` - Get detailed event information
- `GET /api/events/search` - Search events
- `GET /api/events/current` - Get current/nearby events
- `GET /api/events/types` - Get available event types

### Data Models

#### TownDto
```dart
class TownDto {
  final int id;
  final String name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final bool isActive;
}
```

#### BusinessDto
```dart
class BusinessDto {
  final int id;
  final String name;
  final String description;
  final String? shortDescription;
  final String category;
  final String? subCategory;
  final String? phoneNumber;
  final String? emailAddress;
  final String? website;
  final String? physicalAddress;
  final double? latitude;
  final double? longitude;
  final String? logoUrl;
  final String? coverImageUrl;
  final double? rating;
  final int totalReviews;
  final int viewCount;
  final bool isFeatured;
  final bool isVerified;
  final double? distanceKm;
}
```

#### Event Models
- EventListResponse, EventDetailsViewModel, EventTypeOption

## App Structure

### Directory Organization
```
lib/
├── main.dart                 # App entry point
├── core/                     # Core functionality
│   ├── config/              # Configuration and constants
│   ├── network/             # API client and network utilities
│   ├── storage/             # Local storage management
│   └── utils/               # Utility functions
├── models/                   # Data models
├── services/                 # Business logic and API calls
├── providers/                # State management
├── screens/                  # UI screens/pages
│   ├── home/                # Home screen
│   ├── towns/               # Town selection and info
│   ├── businesses/          # Business listing and details
│   ├── events/              # Event listing and details
│   └── search/              # Search functionality
├── widgets/                  # Reusable UI components
└── theme/                    # App theming and styling
```

### Key Components

#### Navigation
- Bottom navigation bar with main sections
- Tab-based navigation for different views
- Deep linking support

#### State Management
- Provider pattern for app-wide state
- Individual providers for features (businesses, events, location)
- Offline state synchronization

#### Caching Strategy
- SQLite for structured data (businesses, events, towns)
- Shared Preferences for user settings
- Image caching with flutter_cache_manager
- API response caching with expiration

## Dependencies

### Core Dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.0.5

  # Networking
  dio: ^5.3.2
  connectivity_plus: ^5.0.2

  # Storage
  shared_preferences: ^2.2.2
  sqflite: ^2.3.0
  path_provider: ^2.1.2

  # Location & Maps
  geolocator: ^10.1.0
  geocoding: ^2.1.1

  # UI & UX
  flutter_rating_bar: ^4.0.1
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.9
  intl: ^0.19.0

  # Utilities
  uuid: ^4.2.1
  url_launcher: ^6.2.2
  share_plus: ^7.2.2
```

## Platform-Specific Configurations

### Android Configuration
- **Minimum SDK**: API 21 (Android 5.0)
- **Target SDK**: API 34 (Android 14)
- **Java Version**: 11
- **Application ID**: com.example.towntrek_flutter
- **Permissions**:
  - INTERNET
  - ACCESS_FINE_LOCATION
  - ACCESS_COARSE_LOCATION
  - ACCESS_NETWORK_STATE

### iOS Configuration
- **Minimum iOS Version**: 11.0
- **Device Orientation**: Portrait, Landscape Left, Landscape Right
- **Bundle Identifier**: [To be configured]
- **Capabilities**: Location Services, Push Notifications

### Web Configuration
- **PWA Support**: Enabled
- **Service Worker**: For offline caching
- **Web App Manifest**: Configured for mobile installation
- **Theme Color**: #0175C2

## Security Considerations

### Data Protection
- HTTPS-only API communication
- No sensitive data storage on device
- Secure token storage with flutter_secure_storage
- Input validation and sanitization

### Privacy
- Location permissions requested only when needed
- Clear privacy policy integration
- GDPR compliance considerations

## Performance Requirements

### App Performance
- **Cold Start Time**: < 3 seconds
- **Hot Restart Time**: < 1 second
- **Memory Usage**: < 150MB average
- **Battery Impact**: Minimal location-based features

### Network Performance
- **Offline Functionality**: Core features work offline
- **Sync Strategy**: Background sync with conflict resolution
- **Image Optimization**: Progressive loading and caching
- **API Response Caching**: 24-hour cache for static data

## Testing Strategy

### Unit Tests
- Model classes and utility functions
- API service methods
- Business logic validation

### Integration Tests
- API integration
- Database operations
- State management

### UI Tests
- Screen navigation
- User interactions
- Responsive design

### Platform Tests
- Android device testing (various screen sizes)
- iOS device testing
- Web browser compatibility

## Deployment & Distribution

### Android
- Google Play Store
- APK and AAB distribution
- Beta testing via Google Play Beta
- Crash reporting with Firebase Crashlytics

### iOS
- Apple App Store
- TestFlight for beta testing
- App Store Connect configuration

### Web
- PWA deployment
- Service worker caching
- Web app manifest optimization

## Development Workflow

### Code Quality
- Flutter lints enabled
- Code formatting with dartfmt
- Static analysis with dart analyze
- Pre-commit hooks for code quality

### Version Control
- Git-based workflow
- Feature branches
- Pull request reviews
- CI/CD pipeline integration

### Documentation
- Code documentation with dartdoc
- API documentation
- User-facing documentation

## Future Enhancements

### Phase 2 Features
- User authentication and profiles
- Business bookmarks/favorites
- Event calendar integration
- Social sharing features
- In-app messaging
- Analytics integration

### Advanced Features
- Augmented Reality (AR) business previews
- AI-powered recommendations
- Real-time event updates
- Offline map support
- Multi-language support
- Accessibility improvements

---

**Document Version**: 1.0
**Last Updated**: October 10, 2025
**Current Status**: Planning Phase
