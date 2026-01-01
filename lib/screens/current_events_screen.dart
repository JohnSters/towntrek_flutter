import 'package:flutter/material.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../core/errors/app_error.dart';
import 'event_details/event_details_screen.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    
    // Construct image URL if available
    ImageProvider? logoImage;
    if (event.logoUrl != null && event.logoUrl!.isNotEmpty) {
      if (event.logoUrl!.startsWith('http')) {
        logoImage = NetworkImage(event.logoUrl!);
      } else {
        logoImage = NetworkImage('${ApiConfig.baseUrl}${event.logoUrl}');
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0, // Using 0 for modern flat look with border
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        clipBehavior: Clip.antiAlias,
          child: InkWell(
          onTap: event.shouldGreyOut ? null : () => _showEventDetails(event),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo/Image (Left Side)
                    if (logoImage != null)
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: logoImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.event,
                          size: 32,
                          color: colorScheme.primary,
                        ),
                      ),
                      
                    // Content (Right Side)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row: Title and Price
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  event.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                    color: event.shouldGreyOut
                                        ? colorScheme.onSurface.withValues(alpha: 0.5)
                                        : colorScheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildPricePill(context, event),
                            ],
                          ),
                          
                          // Short Description
                          if (event.shortDescription != null && event.shortDescription!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              event.shortDescription!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: event.shouldGreyOut
                                    ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                                    : colorScheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          
                          const SizedBox(height: 12),
                          
                          // Metadata Row (Type | Date)
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _buildInfoPill(
                                context, 
                                event.eventType,
                                colorScheme.secondaryContainer,
                                colorScheme.onSecondaryContainer,
                              ),
                              _buildInfoPill(
                                context, 
                                event.displayDate,
                                colorScheme.tertiaryContainer,
                                colorScheme.onTertiaryContainer,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Priority/Featured Badge (Top Left)
              if (event.isPriorityListing && !event.shouldGreyOut)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Featured',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onTertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
              // Finished Overlay
              if (event.shouldGreyOut)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Finished',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPricePill(BuildContext context, EventDto event) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isFree = event.isFreeEvent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFree
            ? Colors.green.withValues(alpha: 0.1)
            : colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFree
              ? Colors.green.withValues(alpha: 0.2)
              : colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        'Entry Fee: ${event.displayPrice}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: isFree ? Colors.green : colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildInfoPill(BuildContext context, String text, Color bgColor, Color textColor) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showEventDetails(EventDto event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(
          eventId: event.id,
          eventName: event.name,
          eventType: event.eventType,
          initialImageUrl: event.logoUrl,
        ),
      ),
    );
  }
}
