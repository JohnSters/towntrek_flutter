import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/core.dart';
import '../models/models.dart';
import 'event_details/event_details_state.dart';
import 'event_details/event_details_view_model.dart';
import 'event_details/widgets/event_info_card.dart';
import 'event_details/widgets/event_image_gallery.dart';
import 'event_details/widgets/event_location_section.dart';
import 'event_details/widgets/event_contact_section.dart';
import 'event_details/widgets/event_reviews_section.dart';
import 'event_details/event_all_reviews_screen.dart';

/// Event Details Screen - Shows detailed information about a specific event
/// Uses Provider pattern with ViewModel and sealed classes for clean architecture
class EventDetailsScreen extends StatelessWidget {
  final int eventId;
  final String? eventName;
  final String? eventType;
  final String? initialImageUrl;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
    this.eventName,
    this.eventType,
    this.initialImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventDetailsViewModel(
        eventRepository: serviceLocator.eventRepository,
        eventId: eventId,
        eventName: eventName ?? 'Event',
        eventType: eventType,
        initialImageUrl: initialImageUrl,
      ),
      child: const _EventDetailsScreenContent(),
    );
  }
}

class _EventDetailsScreenContent extends StatelessWidget {
  const _EventDetailsScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _buildContent(),
          ),
          const BackNavigationFooter(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<EventDetailsViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;

        if (state is EventDetailsLoading) {
          return _buildLoadingView(viewModel);
        }

        if (state is EventDetailsError) {
          return _buildErrorView(state);
        }

        if (state is EventDetailsSuccess) {
          return _buildEventDetailsView(context, state);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildLoadingView(EventDetailsViewModel viewModel) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: EventDetailsConstants.appBarExpandedHeight,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: Colors.grey[300],
              child: viewModel.initialImageUrl != null
                  ? Image.network(
                      viewModel.initialImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.event, size: 64),
                      ),
                    )
                  : const Icon(Icons.event, size: 64),
            ),
          ),
        ),
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _buildErrorView(EventDetailsError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: EventDetailsConstants.errorIconSize,
            color: Colors.red,
          ),
          const SizedBox(height: EventDetailsConstants.errorSpacing),
          Text(
            state.title,
            style: const TextStyle(
              fontSize: EventDetailsConstants.errorTitleFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: EventDetailsConstants.errorSpacing * 0.5),
          Text(
            state.message,
            style: const TextStyle(
              fontSize: EventDetailsConstants.errorMessageFontSize,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: EventDetailsConstants.errorSpacing),
          ElevatedButton(
            onPressed: () {
              // Retry logic would be implemented in ViewModel
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailsView(BuildContext context, EventDetailsSuccess state) {
    final event = state.eventDetails;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: EventDetailsConstants.appBarExpandedHeight,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: EventImageGallery(images: event.images),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            EventInfoCard(event: event),
            EventLocationSection(event: event),
            EventContactSection(event: event),
            EventReviewsSection(
              reviews: event.reviews,
              onViewAllPressed: () => _navigateToAllReviews(context, event),
            ),
            const SizedBox(height: EventDetailsConstants.bottomSpacing),
          ]),
        ),
      ],
    );
  }

  void _navigateToAllReviews(BuildContext context, EventDetailDto event) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventAllReviewsScreen(
          eventName: event.name,
          reviews: event.reviews,
        ),
      ),
    );
  }
}