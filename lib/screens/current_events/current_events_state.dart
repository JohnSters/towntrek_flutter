import '../../core/errors/app_error.dart';
import '../../models/models.dart';

/// Sealed class for Current Events screen states
sealed class CurrentEventsState {}

/// Loading state for initial events load
class CurrentEventsLoading extends CurrentEventsState {}

/// Success state with loaded events and pagination info
class CurrentEventsSuccess extends CurrentEventsState {
  final List<EventDto> events;
  final bool hasNextPage;
  final bool isLoadingMore;
  final int currentPage;

  CurrentEventsSuccess({
    required this.events,
    required this.hasNextPage,
    this.isLoadingMore = false,
    this.currentPage = 1,
  });

  /// Creates a copy with updated fields
  CurrentEventsSuccess copyWith({
    List<EventDto>? events,
    bool? hasNextPage,
    bool? isLoadingMore,
    int? currentPage,
  }) {
    return CurrentEventsSuccess(
      events: events ?? this.events,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Error state for events loading failure
class CurrentEventsError extends CurrentEventsState {
  final AppError error;

  CurrentEventsError(this.error);
}

/// Loading more state for pagination
class CurrentEventsLoadingMore extends CurrentEventsState {
  final List<EventDto> events;
  final int currentPage;

  CurrentEventsLoadingMore({
    required this.events,
    required this.currentPage,
  });
}