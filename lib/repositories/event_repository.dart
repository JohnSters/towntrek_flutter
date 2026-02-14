import '../services/event_api_service.dart';
import '../models/models.dart';

/// Abstract interface for event data operations
abstract class EventRepository {
  /// Get events for a specific town with optional filtering
  Future<EventListResponse> getEvents({
    int? townId,
    String? eventType,
    int page = 1,
    int pageSize = 20,
  });

  /// Search events with flexible criteria
  Future<EventListResponse> searchEvents({
    required String query,
    int? townId,
    String? eventType,
    int page = 1,
    int pageSize = 20,
  });

  /// Get detailed information for a specific event
  Future<EventDetailDto> getEventDetails(int eventId);

  /// Get current/nearby events for mobile display
  /// Shows events that are close to starting, currently running, or close to ending
  Future<EventListResponse> getCurrentEvents({
    int? townId,
    int page = 1,
    int pageSize = 20,
  });

  /// Get available event types for filtering
  Future<List<EventTypeDto>> getEventTypes();
}

/// Implementation of EventRepository using API service
class EventRepositoryImpl implements EventRepository {
  final EventApiService _apiService;

  EventRepositoryImpl(this._apiService);

  @override
  Future<EventListResponse> getEvents({
    int? townId,
    String? eventType,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      return await _apiService.getEvents(
        townId: townId,
        eventType: eventType,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      // Here you could add caching logic, error transformation, etc.
      rethrow;
    }
  }

  @override
  Future<EventListResponse> searchEvents({
    required String query,
    int? townId,
    String? eventType,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      return await _apiService.searchEvents(
        query: query,
        townId: townId,
        eventType: eventType,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EventDetailDto> getEventDetails(int eventId) async {
    try {
      return await _apiService.getEventDetail(eventId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EventListResponse> getCurrentEvents({
    int? townId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      return await _apiService.getCurrentEvents(
        townId: townId,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<EventTypeDto>> getEventTypes() async {
    try {
      return await _apiService.getEventTypes();
    } catch (e) {
      rethrow;
    }
  }
}
