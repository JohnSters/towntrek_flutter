import '../core/network/api_client.dart';
import '../core/config/api_config.dart';
import '../models/models.dart';

/// Service class for event-related API operations
class EventApiService {
  final ApiClient _apiClient;

  EventApiService(this._apiClient);

  /// Get events for a specific town with optional filtering
  /// - townId: Town ID to filter events
  /// - eventType: Optional event type filter
  /// - page: Page number for pagination (default: 1)
  /// - pageSize: Number of results per page (default: 20)
  Future<EventListResponse> getEvents({
    int? townId,
    String? eventType,
    int page = 1,
    int pageSize = ApiConfig.defaultPageSize,
  }) async {
    final queryParams = <String, dynamic>{
      'townId': ?townId,
      'eventType': ?eventType,
      'page': page,
      'pageSize': pageSize,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.eventsUrl(),
      queryParameters: queryParams,
    );

    return EventListResponse.fromJson(response.data!);
  }

  /// Get detailed information for a specific event
  /// - eventId: The ID of the event to retrieve
  Future<EventDetailDto> getEventDetails(int eventId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.eventDetailUrl(eventId),
    );

    return EventDetailDto.fromJson(response.data!);
  }

  /// Search events with flexible criteria
  /// - query: Search query string
  /// - townId: Optional town filter
  /// - eventType: Optional event type filter
  /// - page: Page number for pagination (default: 1)
  /// - pageSize: Number of results per page (default: 20)
  Future<EventListResponse> searchEvents({
    required String query,
    int? townId,
    String? eventType,
    int page = 1,
    int pageSize = ApiConfig.defaultPageSize,
  }) async {
    final queryParams = <String, dynamic>{
      'q': query.trim(),
      'townId': ?townId,
      'eventType': ?eventType,
      'page': page,
      'pageSize': pageSize,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.eventSearchUrl(),
      queryParameters: queryParams,
    );

    return EventListResponse.fromJson(response.data!);
  }

  /// Get current/nearby events for mobile display
  /// Shows events that are close to starting, currently running, or close to ending
  /// - townId: Optional town filter
  /// - page: Page number for pagination (default: 1)
  /// - pageSize: Number of results per page (default: 20)
  Future<EventListResponse> getCurrentEvents({
    int? townId,
    int page = 1,
    int pageSize = ApiConfig.defaultPageSize,
  }) async {
    final queryParams = <String, dynamic>{
      'townId': ?townId,
      'page': page,
      'pageSize': pageSize,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.currentEventsUrl(),
      queryParameters: queryParams,
    );

    return EventListResponse.fromJson(response.data!);
  }

  /// Get available event types for filtering
  Future<List<EventTypeDto>> getEventTypes() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.eventTypesUrl(),
    );

    return response.data!
        .map((e) => EventTypeDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
