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
    try {
      // Validate parameters
      if (townId == null) {
        throw ArgumentError('townId parameter is required');
      }

      // Build query parameters
      final queryParams = <String, dynamic>{
        'townId': townId,
        if (eventType != null) 'eventType': eventType,
        'page': page,
        'pageSize': pageSize,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.eventsUrl(),
        queryParameters: queryParams,
      );

      return EventListResponse.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  /// Get detailed information for a specific event
  /// - eventId: The ID of the event to retrieve
  Future<EventDetailDto> getEventDetail(int eventId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.eventDetailUrl(eventId),
      );

      return EventDetailDto.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
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
    try {
      // Validate parameters
      if (query.trim().isEmpty && townId == null) {
        throw ArgumentError('Search query or townId required');
      }

      // Build query parameters
      final queryParams = <String, dynamic>{
        'q': query.trim(),
        if (townId != null) 'townId': townId,
        if (eventType != null) 'eventType': eventType,
        'page': page,
        'pageSize': pageSize,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.eventSearchUrl(),
        queryParameters: queryParams,
      );

      return EventListResponse.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
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
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{
        if (townId != null) 'townId': townId,
        'page': page,
        'pageSize': pageSize,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.currentEventsUrl(),
        queryParameters: queryParams,
      );

      return EventListResponse.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  /// Get available event types for filtering
  Future<List<EventTypeDto>> getEventTypes() async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        ApiConfig.eventTypesUrl(),
      );

      return response.data!
          .map((e) => EventTypeDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
