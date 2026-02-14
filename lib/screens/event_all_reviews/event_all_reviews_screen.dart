import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/event_all_reviews_constants.dart';
import '../../models/models.dart';
import 'event_all_reviews_state.dart';
import 'event_all_reviews_view_model.dart';
import 'widgets/widgets.dart';

class EventAllReviewsScreen extends StatelessWidget {
  final String eventName;
  final List<EventReviewDto> reviews;

  const EventAllReviewsScreen({
    super.key,
    required this.eventName,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventAllReviewsViewModel(
        eventName: eventName,
        reviews: reviews,
      ),
      child: const _EventAllReviewsScreenContent(),
    );
  }
}

class _EventAllReviewsScreenContent extends StatelessWidget {
  const _EventAllReviewsScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EventAllReviewsViewModel>();

    final eventName = switch (viewModel.state) {
      EventAllReviewsLoaded(eventName: final name, reviews: _) => name,
    };

    final reviews = switch (viewModel.state) {
      EventAllReviewsLoaded(eventName: _, reviews: final reviews) => reviews,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(EventAllReviewsConstants.reviewsTitlePrefix + eventName),
      ),
      body: reviews.isEmpty
          ? const Center(child: Text(EventAllReviewsConstants.noReviewsText))
          : ListView.separated(
              padding: const EdgeInsets.all(EventAllReviewsConstants.pagePadding),
              itemCount: reviews.length,
              separatorBuilder: (_, _) => const SizedBox(height: EventAllReviewsConstants.cardMargin),
              itemBuilder: (context, index) {
                final review = reviews[index];
                return EventReviewCard(review: review);
              },
            ),
    );
  }
}