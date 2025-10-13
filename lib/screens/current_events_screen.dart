import 'package:flutter/material.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../core/errors/app_error.dart';

/// Screen displaying current/nearby events for a town
class CurrentEventsScreen extends StatefulWidget {
  final int townId;
  final String townName;

  const CurrentEventsScreen({
    super.key,
    required this.townId,
    required this.townName,
  });

  @override
  State<CurrentEventsScreen> createState() => _CurrentEventsScreenState();
}

class _CurrentEventsScreenState extends State<CurrentEventsScreen> {
  final EventRepository _eventRepository = serviceLocator.eventRepository;

  List<EventDto> _events = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  AppError? _error;
  int _currentPage = 1;
  bool _hasNextPage = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents({bool loadMore = false}) async {
    if (loadMore && !_hasNextPage) return;

    setState(() {
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
      }
    });

    try {
      final response = await _eventRepository.getCurrentEvents(
        townId: widget.townId,
        page: loadMore ? _currentPage + 1 : 1,
        pageSize: 20,
      );

      setState(() {
        if (loadMore) {
          _events.addAll(response.events.where((event) => !event.shouldHide));
          _currentPage++;
        } else {
          _events = response.events.where((event) => !event.shouldHide).toList();
        }
        _hasNextPage = response.hasNextPage;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ServerError(
            title: 'Connection Error',
            message: 'Failed to load events. Please check your connection and try again.',
          );
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Events in ${widget.townName}',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.05),
              colorScheme.surface,
            ],
          ),
        ),
        child: _buildContent(),
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

    if (_events.isEmpty) {
      return _buildEmptyView();
    }

    return _buildEventsList();
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.0,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load events',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error?.message ?? 'An unexpected error occurred',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadEvents(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No events happening right now',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for upcoming events in ${widget.townName}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    return RefreshIndicator(
      onRefresh: () => _loadEvents(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length + (_hasNextPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _events.length) {
            // Load more indicator
            if (_isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            } else {
              // Load more button
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () => _loadEvents(loadMore: true),
                    child: const Text('Load More Events'),
                  ),
                ),
              );
            }
          }

          return _buildEventCard(_events[index]);
        },
      ),
    );
  }

  Widget _buildEventCard(EventDto event) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: event.shouldGreyOut ? null : () => _showEventDetails(event),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event name and status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: event.shouldGreyOut
                                ? colorScheme.onSurface.withValues(alpha: 0.5)
                                : colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (event.isPriorityListing)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: event.shouldGreyOut
                                ? colorScheme.primary.withValues(alpha: 0.05)
                                : colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Featured',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: event.shouldGreyOut
                                  ? colorScheme.primary.withValues(alpha: 0.5)
                                  : colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Event type and date
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 16,
                        color: event.shouldGreyOut
                            ? colorScheme.onSurface.withValues(alpha: 0.3)
                            : colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.eventType,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: event.shouldGreyOut
                              ? colorScheme.onSurface.withValues(alpha: 0.3)
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: event.shouldGreyOut
                            ? colorScheme.onSurface.withValues(alpha: 0.3)
                            : colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.displayDate,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: event.shouldGreyOut
                              ? colorScheme.onSurface.withValues(alpha: 0.3)
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description
                  if (event.description != null && event.description!.isNotEmpty)
                    Text(
                      event.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: event.shouldGreyOut
                            ? colorScheme.onSurface.withValues(alpha: 0.4)
                            : colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Price and reviews
                  Row(
                    children: [
                      // Price
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: event.shouldGreyOut
                              ? (event.isFreeEvent
                                  ? Colors.green.withValues(alpha: 0.05)
                                  : colorScheme.primary.withValues(alpha: 0.05))
                              : (event.isFreeEvent
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : colorScheme.primary.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.displayPrice,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: event.shouldGreyOut
                                ? (event.isFreeEvent
                                    ? Colors.green.withValues(alpha: 0.5)
                                    : colorScheme.primary.withValues(alpha: 0.5))
                                : (event.isFreeEvent
                                    ? Colors.green
                                    : colorScheme.primary),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Reviews
                      if (event.totalReviews > 0) ...[
                        Icon(
                          Icons.star,
                          size: 16,
                          color: event.shouldGreyOut
                              ? Colors.amber.withValues(alpha: 0.5)
                              : Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.rating?.toStringAsFixed(1) ?? '0.0'} (${event.totalReviews})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: event.shouldGreyOut
                                ? colorScheme.onSurface.withValues(alpha: 0.3)
                                : colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Overlay for finished events
          if (event.shouldGreyOut)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Event Finished',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showEventDetails(EventDto event) {
    // TODO: Navigate to event details screen
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event details for "${event.name}" coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
