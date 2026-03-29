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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: _Content(),
            ),
            Consumer<EventDetailsViewModel>(
              builder: (context, viewModel, child) {
                return viewModel.state is EventDetailsSuccess
                    ? const BackNavigationFooter()
                    : const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Consumer<EventDetailsViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;

        if (state is EventDetailsLoading) {
          return _LoadingView(
            eventName: viewModel.eventName,
            eventType: viewModel.eventType,
            initialImageUrl: viewModel.initialImageUrl,
          );
        }

        if (state is EventDetailsError) {
          return _ErrorView(
            eventName: viewModel.eventName,
            title: state.title,
            message: state.message,
            onRetry: viewModel.retryLoadEventDetails,
          );
        }

        if (state is EventDetailsSuccess) {
          return _EventDetailsView(eventDetails: state.eventDetails);
        }

        return const SizedBox();
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  final String eventName;
  final String? eventType;
  final String? initialImageUrl;

  const _LoadingView({
    required this.eventName,
    required this.eventType,
    this.initialImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: PageHeader(
            title: eventName,
            subtitle: eventType ?? EventDetailsConstants.loadingSubtitle,
            backgroundImage: initialImageUrl,
            headerType: HeaderType.event,
            height: 112.0,
          ),
        ),
        const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String eventName;
  final String title;
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.eventName,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageHeader(
          title: eventName,
          subtitle: EventDetailsConstants.errorSubtitle,
          headerType: HeaderType.event,
          height: 112.0,
        ),
        Expanded(
          child: ErrorView(
            error: ServerError(
              title: title,
              message: message,
            ),
          ),
        ),
      ],
    );
  }
}

class _EventDetailsView extends StatelessWidget {
  final EventDetailDto eventDetails;

  const _EventDetailsView({
    required this.eventDetails,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: PageHeader(
            title: eventDetails.name,
            subtitle: eventDetails.eventType,
            backgroundImage: eventDetails.coverImageUrl,
            headerType: HeaderType.event,
            height: 112.0,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
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
          ),
        ),
      ],
    );
  }
}

