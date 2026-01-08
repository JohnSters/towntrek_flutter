import 'package:flutter/foundation.dart';
import '../../core/core.dart';
import '../../repositories/repositories.dart';
import '../../core/constants/current_events_constants.dart';
import 'current_events_state.dart';

/// ViewModel for Current Events screen
/// Handles pagination, loading states, and event filtering
class CurrentEventsViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final int _townId;
  final String _townName;

  CurrentEventsState _state;
  int _currentPage = CurrentEventsConstants.defaultPage;

  CurrentEventsViewModel({
    required EventRepository eventRepository,
    required int townId,
    required String townName,
  }) : _eventRepository = eventRepository,
       _townId = townId,
       _townName = townName,
       _state = CurrentEventsLoading() {
    loadEvents();
  }

  /// Current state of the screen
  CurrentEventsState get state => _state;

  /// Town name for display
  String get townName => _townName;

  /// Load initial events
  Future<void> loadEvents() async {
    _state = CurrentEventsLoading();
    _currentPage = CurrentEventsConstants.defaultPage;
    notifyListeners();

    try {
      final response = await _eventRepository.getCurrentEvents(
        townId: _townId,
        page: _currentPage,
        pageSize: CurrentEventsConstants.defaultPageSize,
      );

      // Filter out hidden events
      final filteredEvents = response.events.where((event) => !event.shouldHide).toList();

      _state = CurrentEventsSuccess(
        events: filteredEvents,
        hasNextPage: response.hasNextPage,
        currentPage: _currentPage,
      );
      notifyListeners();
    } catch (e) {
      _state = CurrentEventsError(
        title: CurrentEventsConstants.refreshErrorTitle,
        message: CurrentEventsConstants.refreshErrorMessage,
      );
      notifyListeners();
    }
  }

  /// Load more events for pagination
  Future<void> loadMoreEvents() async {
    if (_state is! CurrentEventsSuccess) return;

    final currentState = _state as CurrentEventsSuccess;
    if (!currentState.hasNextPage || currentState.isLoadingMore) return;

    // Set loading more state
    _state = currentState.copyWith(isLoadingMore: true);
    notifyListeners();

    try {
      final response = await _eventRepository.getCurrentEvents(
        townId: _townId,
        page: _currentPage + 1,
        pageSize: CurrentEventsConstants.defaultPageSize,
      );

      // Filter out hidden events
      final newEvents = response.events.where((event) => !event.shouldHide).toList();

      _currentPage++;
      _state = CurrentEventsSuccess(
        events: [...currentState.events, ...newEvents],
        hasNextPage: response.hasNextPage,
        currentPage: _currentPage,
      );
      notifyListeners();
    } catch (e) {
      // Revert loading state on error
      _state = currentState.copyWith(isLoadingMore: false);
      notifyListeners();
    }
  }

  /// Retry loading events (used for error recovery)
  Future<void> retryLoadEvents() async {
    await loadEvents();
  }

  /// Refresh events (pull-to-refresh)
  Future<void> refreshEvents() async {
    await loadEvents();
  }
}