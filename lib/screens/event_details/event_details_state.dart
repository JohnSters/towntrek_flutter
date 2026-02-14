import '../../models/models.dart';

/// Sealed class for Event Details screen states
sealed class EventDetailsState {}

/// Loading state for event details
class EventDetailsLoading extends EventDetailsState {}

/// Success state with loaded event details
class EventDetailsSuccess extends EventDetailsState {
  final EventDetailDto eventDetails;

  EventDetailsSuccess({
    required this.eventDetails,
  });

  /// Creates a copy with updated event details
  EventDetailsSuccess copyWith({
    EventDetailDto? eventDetails,
  }) {
    return EventDetailsSuccess(
      eventDetails: eventDetails ?? this.eventDetails,
    );
  }
}

/// Error state for event details loading failure
class EventDetailsError extends EventDetailsState {
  final String title;
  final String message;

  EventDetailsError({
    required this.title,
    required this.message,
  });
}