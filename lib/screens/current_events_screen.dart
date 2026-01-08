import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/core.dart';
import 'current_events/current_events_state.dart';
import 'current_events/current_events_view_model.dart';
import 'current_events/widgets/widgets.dart';

/// Current Events Screen - Shows paginated list of current events for a town
/// Uses Provider pattern with ViewModel and sealed classes for clean architecture
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
    return Consumer<CurrentEventsViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;

        if (state is CurrentEventsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CurrentEventsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: CurrentEventsConstants.emptyStateIconSize,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: CurrentEventsConstants.emptyStateIconSpacing),
                Text(
                  state.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: CurrentEventsConstants.emptyStateIconSpacing * 0.5),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: CurrentEventsConstants.emptyStateIconSpacing),
                ElevatedButton(
                  onPressed: viewModel.retryLoadEvents,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is CurrentEventsSuccess) {
          return _buildEventsView(context, state, viewModel);
        }

        if (state is CurrentEventsLoadingMore) {
          return _buildEventsView(context, state, viewModel);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildEventsView(
    BuildContext context,
    dynamic state,
    CurrentEventsViewModel viewModel,
  ) {
    final events = state.events;
    final hasNextPage = state is CurrentEventsSuccess ? state.hasNextPage : false;
    final isLoadingMore = state is CurrentEventsLoadingMore;

    return Column(
      children: [
        PageHeader(
          title: viewModel.townName,
          subtitle: CurrentEventsConstants.eventsSubtitle,
          height: CurrentEventsConstants.pageHeaderHeight,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: viewModel.refreshEvents,
            child: ListView.builder(
              padding: const EdgeInsets.all(CurrentEventsConstants.contentPadding),
              itemCount: events.length + (hasNextPage ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == events.length) {
                  // Load more indicator
                  if (!isLoadingMore) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      viewModel.loadMoreEvents();
                    });
                  }
                  return const Padding(
                    padding: EdgeInsets.all(CurrentEventsConstants.contentPadding),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final event = events[index];
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: CurrentEventsConstants.cardSpacing,
                  ),
                  child: EventCard(event: event),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}