import 'package:flutter/foundation.dart';
import '../../core/core.dart';
import '../../repositories/repositories.dart';
import 'event_details_state.dart';

/// ViewModel for Event Details screen
/// Handles event detail loading and state management
class EventDetailsViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final int _eventId;
  final String _eventName;
  final String? _eventType;
  final String? _initialImageUrl;

  EventDetailsState _state;

  EventDetailsViewModel({
    required EventRepository eventRepository,
    required int eventId,
    required String eventName,
    String? eventType,
    String? initialImageUrl,
  }) : _eventRepository = eventRepository,
       _eventId = eventId,
       _eventName = eventName,
       _eventType = eventType,
       _initialImageUrl = initialImageUrl,
       _state = EventDetailsLoading() {
    loadEventDetails();
  }

  /// Current state of the screen
  EventDetailsState get state => _state;

  /// Event name for display
  String get eventName => _eventName;

  /// Event type for display
  String? get eventType => _eventType;

  /// Initial image URL for loading state
  String? get initialImageUrl => _initialImageUrl;

  /// Load event details
  Future<void> loadEventDetails() async {
    _state = EventDetailsLoading();
    notifyListeners();

    try {
      final eventDetails = await _eventRepository.getEventDetails(_eventId);
      _state = EventDetailsSuccess(eventDetails: eventDetails);
      notifyListeners();
    } catch (e) {
      // Since ErrorHandler is a singleton, access it directly
      final errorHandler = serviceLocator.errorHandler;
      await errorHandler.handleError(
        e,
        retryAction: loadEventDetails,
      );
      _state = EventDetailsError(
        title: EventDetailsConstants.errorTitle,
        message: EventDetailsConstants.errorMessage,
      );
      notifyListeners();
    }
  }

  /// Retry loading event details (used for error recovery)
  Future<void> retryLoadEventDetails() async {
    await loadEventDetails();
  }
}