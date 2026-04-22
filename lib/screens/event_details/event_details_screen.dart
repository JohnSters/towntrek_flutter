import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/event_detail_dto.dart';
import 'widgets/event_info_card.dart';
import 'widgets/event_image_gallery.dart';
import 'widgets/event_location_section.dart';
import 'widgets/event_contact_section.dart';
import 'widgets/event_reviews_section.dart';
import 'event_details_state.dart';
import 'event_details_view_model.dart';
import '../event_all_reviews/event_all_reviews_screen.dart';

/// Screen displaying detailed information for a specific event
/// Uses Provider pattern with EventDetailsViewModel for state management
class EventDetailsScreen extends StatelessWidget {
  final int eventId;
  final String eventName;
  final String? eventType;
  final String? initialImageUrl;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
    required this.eventName,
    this.eventType,
    this.initialImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventDetailsViewModel(
        eventRepository: serviceLocator.eventRepository,
        eventId: eventId,
        eventName: eventName,
        eventType: eventType,
        initialImageUrl: initialImageUrl,
      ),
      child: const _EventDetailsScreenContent(),
    );
  }
}

class _EventDetailsScreenContent extends StatelessWidget {
  const _EventDetailsScreenContent();

  Widget _eventHero(
    BuildContext context,
    EventDetailsState state,
    EventDetailsViewModel viewModel,
  ) {
    final title = switch (state) {
      EventDetailsSuccess(:final eventDetails) => eventDetails.name,
      _ => viewModel.eventName,
    };
    final typeLine = switch (state) {
      EventDetailsSuccess(:final eventDetails) => eventDetails.eventType,
      _ => viewModel.eventType ?? 'Event',
    };
    final placeLine = switch (state) {
      EventDetailsSuccess(:final eventDetails) => _placeLine(eventDetails),
      _ => 'Details',
    };
    return EntityListingHeroHeader(
      theme: context.entityListingTheme,
      categoryIcon: Icons.event_rounded,
      subCategoryName: title,
      categoryName: typeLine,
      townName: placeLine,
    );
  }

  String _placeLine(EventDetailDto event) {
    if (event.venue != null && event.venue!.trim().isNotEmpty) {
      return event.venue!.trim();
    }
    if (event.physicalAddress.trim().isNotEmpty) {
      return event.physicalAddress.trim();
    }
    return 'Details';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventDetailsViewModel>(
      builder: (context, viewModel, _) {
        final state = viewModel.state;
        return Scaffold(
          backgroundColor: context.entityListing.pageBg,
          body: SafeArea(
            child: Column(
              children: [
                _eventHero(context, state, viewModel),
                if (state is EventDetailsSuccess)
                  EntityOpenClosedBanner(
                    isOpen: null,
                    viewCount: state.eventDetails.viewCount,
                  ),
                Expanded(
                  child: _buildBody(context, state, viewModel),
                ),
                const ListingBackFooter(label: 'Back'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    EventDetailsState state,
    EventDetailsViewModel viewModel,
  ) {
    if (state is EventDetailsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is EventDetailsError) {
      return _ErrorBody(
        title: state.title,
        message: state.message,
      );
    }

    if (state is EventDetailsSuccess) {
      return _EventDetailsScrollContent(eventDetails: state.eventDetails);
    }

    return const SizedBox.shrink();
  }
}

class _ErrorBody extends StatelessWidget {
  final String title;
  final String message;

  const _ErrorBody({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorView(
      error: ServerError(
        title: title,
        message: message,
      ),
    );
  }
}

class _EventDetailsScrollContent extends StatelessWidget {
  final EventDetailDto eventDetails;

  const _EventDetailsScrollContent({
    required this.eventDetails,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EventInfoCard(event: eventDetails),
          if (eventDetails.images.isNotEmpty)
            EventImageGallery(images: eventDetails.images),
          EventLocationSection(event: eventDetails),
          EventContactSection(event: eventDetails),
          if (eventDetails.reviews.isNotEmpty)
            EventReviewsSection(
              reviews: eventDetails.reviews,
              onViewAllPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EventAllReviewsScreen(
                      eventName: eventDetails.name,
                      reviews: eventDetails.reviews,
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: EventDetailsConstants.bottomPadding),
        ],
      ),
    );
  }
}
