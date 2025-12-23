import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/navigation_footer.dart';
import '../../core/widgets/page_header.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/error_handler.dart';
import 'widgets/event_info_card.dart';
import 'widgets/event_image_gallery.dart';
import 'widgets/event_location_section.dart';
import 'widgets/event_contact_section.dart';
import 'widgets/event_reviews_section.dart';

class EventDetailsScreen extends StatefulWidget {
  final int eventId;
  final String eventName;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  EventDetailDto? _eventDetails;
  bool _isLoading = true;
  AppError? _error;

  final EventRepository _eventRepository = serviceLocator.eventRepository;
  final ErrorHandler _errorHandler = serviceLocator.errorHandler;

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final details = await _eventRepository.getEventDetails(widget.eventId);
      if (mounted) {
        setState(() {
          _eventDetails = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      final appError = await _errorHandler.handleError(
        e,
        retryAction: _loadEventDetails,
      );
      if (mounted) {
        setState(() {
          _error = appError;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _buildContent(),
          ),
          if (_eventDetails != null)
            const BackNavigationFooter(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_error != null) {
      return _buildErrorView();
    }

    if (_eventDetails == null) {
      return _buildErrorView();
    }

    return _buildEventDetailsView();
  }

  Widget _buildLoadingView() {
    return Column(
      children: [
        PageHeader(
          title: widget.eventName,
          subtitle: 'Loading event details...',
          backgroundImage: null, // Could use a hero image if available passed from list
        ),
        const Expanded(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Column(
      children: [
        PageHeader(
          title: widget.eventName,
          subtitle: 'Unable to load event details',
        ),
        Expanded(
          child: ErrorView(error: _error!),
        ),
      ],
    );
  }

  Widget _buildEventDetailsView() {
    final event = _eventDetails!;

    return CustomScrollView(
      slivers: [
        // Event Header
        SliverToBoxAdapter(
          child: PageHeader(
            title: event.name,
            subtitle: event.eventType,
            backgroundImage: event.coverImageUrl,
            // We can add specific event header features here or customize PageHeader
          ),
        ),

        // Info Card (Date, Time, Price, Description)
        SliverToBoxAdapter(
          child: EventInfoCard(event: event),
        ),

        // Image Gallery
        if (event.images.isNotEmpty)
          SliverToBoxAdapter(
            child: EventImageGallery(images: event.images),
          ),

        // Location Section
        SliverToBoxAdapter(
          child: EventLocationSection(event: event),
        ),
        
        // Contact Section
        SliverToBoxAdapter(
          child: EventContactSection(event: event),
        ),

        // Reviews Section
        if (event.reviews.isNotEmpty)
          SliverToBoxAdapter(
             child: EventReviewsSection(
               reviews: event.reviews,
               onViewAllPressed: () {
                 // TODO: Navigate to full reviews list
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('View all reviews coming soon')),
                 );
               },
             ),
          ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }
}

