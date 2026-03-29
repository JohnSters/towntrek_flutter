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

class _CurrentEventsScreenContent extends StatefulWidget {
  const _CurrentEventsScreenContent();

  @override
  State<_CurrentEventsScreenContent> createState() =>
      _CurrentEventsScreenContentState();
}

class _CurrentEventsScreenContentState extends State<_CurrentEventsScreenContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  EntityListingTheme get _theme => CurrentEventsScreen._theme;

  List<EventDto> _visibleEvents(List<EventDto> events) {
    final t = _searchController.text.trim().toLowerCase();
    if (t.isEmpty) return events;
    return events.where((e) {
      return e.name.toLowerCase().contains(t) ||
          e.eventType.toLowerCase().contains(t) ||
          (e.shortDescription?.toLowerCase().contains(t) ?? false) ||
          (e.description?.toLowerCase().contains(t) ?? false) ||
          (e.venue?.toLowerCase().contains(t) ?? false) ||
          e.physicalAddress.toLowerCase().contains(t);
    }).toList();
  }

  Widget _searchBar() {
    return EntityListingSearchBar(
      controller: _searchController,
      theme: _theme,
      hintText: EntityListingConstants.eventSearchHint,
      onSubmitted: () => setState(() {}),
      onClear: () {
        _searchController.clear();
      },
    );
  }

  Widget _searchPadding(Widget child) {
    return Padding(
      padding: EntityListingConstants.searchBarSectionPadding,
      child: child,
    );
  }

  Widget _eventsHero(CurrentEventsViewModel viewModel) {
    return EntityListingHeroHeader(
      theme: _theme,
      categoryIcon: CurrentEventsConstants.defaultEventIcon,
      subCategoryName:
          '${CurrentEventsConstants.eventsPrefix} ${viewModel.townName}',
      categoryName: CurrentEventsConstants.eventsSubtitle,
      townName: viewModel.townName,
    );
  }

  Widget _resultsBand(int count) {
    return ListingResultsBand(
      count: count,
      categoryName: 'Current events',
      bandColor: _theme.resultsBand,
    );
  }

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

  Widget _buildContent(BuildContext context, CurrentEventsViewModel viewModel) {
    return switch (viewModel.state) {
      CurrentEventsLoading() => Column(
          children: [
            _eventsHero(viewModel),
            _resultsBand(0),
            _searchPadding(_searchBar()),
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
        _buildSuccessBranch(
          context,
          viewModel,
          events,
          hasNextPage,
          isLoadingMore,
        ),
      CurrentEventsError(error: final error) =>
        _buildErrorLayout(context, error: error, viewModel: viewModel),
      CurrentEventsLoadingMore(events: final events, currentPage: _) =>
        _buildSuccessBranch(
          context,
          viewModel,
          events,
          true,
          true,
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
          _searchPadding(_searchBar()),
          Expanded(child: ErrorView(error: error)),
        ],
      );
    }

    return Column(
      children: [
        _eventsHero(viewModel),
        _resultsBand(0),
        _searchPadding(_searchBar()),
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

  Widget _buildSuccessBranch(
    BuildContext context,
    CurrentEventsViewModel viewModel,
    List<EventDto> events,
    bool hasNextPage,
    bool isLoadingMore,
  ) {
    final hasSearch = _searchController.text.trim().isNotEmpty;
    final visible = _visibleEvents(events);

    if (events.isEmpty) {
      return Column(
        children: [
          _eventsHero(viewModel),
          _resultsBand(0),
          _searchPadding(_searchBar()),
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

    if (hasSearch && visible.isEmpty) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      return Column(
        children: [
          _eventsHero(viewModel),
          _resultsBand(0),
          _searchPadding(_searchBar()),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: CurrentEventsConstants.emptyStateIconSize,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      CurrentEventsConstants.emptySearchTitle,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      EntityListingConstants.searchNoMatchesHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {
                        _searchController.clear();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text(EntityListingConstants.clearSearchLabel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    final bandCount = hasSearch ? visible.length : events.length;

    return Column(
      children: [
        _eventsHero(viewModel),
        _resultsBand(bandCount),
        _searchPadding(_searchBar()),
        Expanded(
          child: RefreshIndicator(
            onRefresh: viewModel.refreshEvents,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EntityListingConstants.cardListScrollPadding,
              itemCount: visible.length + (hasNextPage ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index == visible.length) {
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
                  event: visible[index],
                  townName: viewModel.townName,
                  listingTheme: _theme,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
