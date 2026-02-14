import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'event_all_reviews_state.dart';

/// ViewModel for Event All Reviews screen
class EventAllReviewsViewModel extends ChangeNotifier {
  final EventAllReviewsState _state;
  EventAllReviewsState get state => _state;

  EventAllReviewsViewModel({
    required String eventName,
    required List<EventReviewDto> reviews,
  }) : _state = EventAllReviewsLoaded(
         eventName: eventName,
         reviews: reviews,
       );
}