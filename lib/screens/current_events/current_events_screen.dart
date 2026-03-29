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

  static final EntityListingTheme _theme = EntityListingTheme.events;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CurrentEventsViewModel(
        eventRepository: serviceLocator.eventRepository,
        errorHandler: serviceLocator.errorHandler,
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
      backgroundColor: EntityListingTheme.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildContent(context, viewModel),
            ),
            const ListingBackFooter(label: 'Back to events'),
          ],
        ),
      ),
    );
  }

  Widget _eventsHero(CurrentEventsViewModel viewModel) {
    return EntityListingHeroHeader(
      theme: CurrentEventsScreen._theme,
      categoryIcon: CurrentEventsConstants.defaultEventIcon,
      subCategoryName: '${CurrentEventsConstants.eventsPrefix} ${viewModel.townName}',
      categoryName: CurrentEventsConstants.eventsSubtitle,
      townName: viewModel.townName,
    );
  }

  Widget _resultsBand(int count) {
    return ListingResultsBand(
      count: count,
      categoryName: 'Current events',
      bandColor: CurrentEventsScreen._theme.resultsBand,
    );
  }

  Widget _buildContent(BuildContext context, CurrentEventsViewModel viewModel) {
    return switch (viewModel.state) {
      CurrentEventsLoading() => Column(
          children: [
            _eventsHero(viewModel),
            _resultsBand(0),
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      CurrentEventsSuccess(
        events: final events,
        hasNextPage: final hasNextPage,
        isLoadingMore: final isLoadingMore,
      ) =>
        _buildEventsListLayout(
          context,
          viewModel,
          events,
          hasNextPage,
          isLoadingMore,
        ),
      CurrentEventsError(error: final error) =>
        _buildErrorLayout(context, error: error, viewModel: viewModel),
      CurrentEventsLoadingMore() => Column(
          children: [
            _eventsHero(viewModel),
            _resultsBand(0),
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
    };
  }

  Widget _buildErrorLayout(
    BuildContext context, {
    required AppError error,
    required CurrentEventsViewModel viewModel,
  }) {
    if (error.actionText != null && error.action != null) {
      return Column(
        children: [
          _eventsHero(viewModel),
          _resultsBand(0),
          Expanded(child: ErrorView(error: error)),
        ],
      );
    }

    return Column(
      children: [
        _eventsHero(viewModel),
        _resultsBand(0),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              ErrorView(error: error),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: viewModel.retryLoadEvents,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventsListLayout(
    BuildContext context,
    CurrentEventsViewModel viewModel,
    List<EventDto> events,
    bool hasNextPage,
    bool isLoadingMore,
  ) {
    if (events.isEmpty) {
      return Column(
        children: [
          _eventsHero(viewModel),
          _resultsBand(0),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CurrentEventsConstants.emptyIcon,
                    size: CurrentEventsConstants.emptyStateIconSize,
                    color: Theme.of(context).colorScheme.onSurface.withValues(
                          alpha: CurrentEventsConstants.emptyStateIconOpacity,
                        ),
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
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _eventsHero(viewModel),
        _resultsBand(events.length),
        Expanded(
          child: RefreshIndicator(
            onRefresh: viewModel.refreshEvents,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: events.length + (hasNextPage ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index == events.length) {
                  if (!isLoadingMore) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      viewModel.loadMoreEvents();
                    });
                  }
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: CurrentEventsConstants.loadMorePaddingVertical,
                      ),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return EventCard(
                  event: events[index],
                  townName: viewModel.townName,
                  listingTheme: CurrentEventsScreen._theme,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
