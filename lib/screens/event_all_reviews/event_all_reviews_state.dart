import '../../models/models.dart';

// State classes for type-safe state management
sealed class EventAllReviewsState {}

class EventAllReviewsLoaded extends EventAllReviewsState {
  final String eventName;
  final List<EventReviewDto> reviews;

  EventAllReviewsLoaded({
    required this.eventName,
    required this.reviews,
  });
}