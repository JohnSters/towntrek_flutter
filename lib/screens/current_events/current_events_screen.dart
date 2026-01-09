import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import 'current_events_state.dart';
import 'current_events_view_model.dart';
import 'widgets/widgets.dart';

class CurrentEventsScreen extends StatelessWidget {
  final int townId;
  final String townName;

  const CurrentEventsScreen({
    super.key,
    required this.townId,
    required this.townName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CurrentEventsViewModel(
        eventRepository: serviceLocator.eventRepository,
        townId: townId,
        townName: townName,
      ),
      child: const _CurrentEventsScreenContent(),
    );
  }
}

class _CurrentEventsScreenContent extends StatelessWidget {
  const _CurrentEventsScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CurrentEventsViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Page Header
            PageHeader(
              title: viewModel.townName,
              subtitle: CurrentEventsConstants.eventsPrefix,
              height: 80, // Consistent header height
              headerType: HeaderType.event,
            ),

            // Main content area
            Expanded(
              child: _buildContent(context, viewModel),
            ),

            // Navigation footer
            const BackNavigationFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CurrentEventsViewModel viewModel) {
    return switch (viewModel.state) {
      CurrentEventsLoading() => const Center(child: CircularProgressIndicator()),
      CurrentEventsSuccess(events: final events, hasNextPage: final hasNextPage, isLoadingMore: final isLoadingMore) =>
        _buildEventsList(context, events, hasNextPage, isLoadingMore, viewModel),
      CurrentEventsError(title: final title, message: final message) =>
        _buildErrorView(title, message, viewModel),
      CurrentEventsLoadingMore() => const Center(child: CircularProgressIndicator()),
    };
  }

  Widget _buildErrorView(String title, String message, CurrentEventsViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: viewModel.retryLoadEvents,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(
    BuildContext context,
    List<EventDto> events,
    bool hasNextPage,
    bool isLoadingMore,
    CurrentEventsViewModel viewModel,
  ) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CurrentEventsConstants.emptyIcon,
              size: CurrentEventsConstants.emptyStateIconSize,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: CurrentEventsConstants.emptyStateIconOpacity),
            ),
            const SizedBox(height: 16),
            Text(
              CurrentEventsConstants.emptyStateTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${CurrentEventsConstants.emptyStateMessage} ${viewModel.townName}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refreshEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: events.length + (hasNextPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == events.length) {
            // Load more indicator
            if (!isLoadingMore) {
              // Trigger load more when reaching the end
              WidgetsBinding.instance.addPostFrameCallback((_) {
                viewModel.loadMoreEvents();
              });
            }
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: CurrentEventsConstants.loadMorePaddingVertical),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final event = events[index];
          return Column(
            children: [
              EventCard(event: event),
              if (index < events.length - 1) const SizedBox(height: CurrentEventsConstants.cardSpacing),
            ],
          );
        },
      ),
    );
  }
}