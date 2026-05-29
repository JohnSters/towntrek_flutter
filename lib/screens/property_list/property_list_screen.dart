import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../property_details/property_details.dart';
import 'property_list_state.dart';
import 'property_list_view_model.dart';
import 'widgets/widgets.dart';

class PropertyListScreen extends StatelessWidget {
  final TownDto town;

  const PropertyListScreen({super.key, required this.town});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PropertyListViewModel(
        propertyRepository: serviceLocator.propertyRepository,
        errorHandler: serviceLocator.errorHandler,
        townId: town.id,
      ),
      child: _PropertyListContent(town: town),
    );
  }
}

class _PropertyListContent extends StatefulWidget {
  final TownDto town;

  const _PropertyListContent({required this.town});

  @override
  State<_PropertyListContent> createState() => _PropertyListContentState();
}

class _PropertyListContentState extends State<_PropertyListContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (!mounted) return;
      context.read<PropertyListViewModel>().setSearchTerm(
        _searchController.text,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _searchBar(BuildContext context, PropertyListViewModel viewModel) {
    return EntityListingSearchBar(
      controller: _searchController,
      theme: context.entityListingTheme,
      hintText: EntityListingConstants.propertySearchHint,
      onSubmitted: () => viewModel.setSearchTerm(_searchController.text),
      onClear: () {
        _searchController.clear();
        viewModel.setSearchTerm('');
      },
    );
  }

  Widget _searchPadding(Widget child) {
    return Padding(
      padding: EntityListingConstants.searchBarSectionPadding,
      child: child,
    );
  }

  void _openDetails(BuildContext context, PropertyListingCardDto listing) {
    final fallback = listing.address.trim().isNotEmpty
        ? listing.address
        : listing.ownerName;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PropertyDetailsScreen(
          listingId: listing.id,
          titleFallback: fallback,
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    return EntityListingHeroHeader(
      theme: context.entityListingTheme,
      categoryIcon: Icons.home_work_rounded,
      subCategoryName: 'Property listings',
      categoryName: 'Properties',
      townName: widget.town.name,
    );
  }

  Widget _band(BuildContext context, int count) {
    return ListingResultsBand(
      count: count,
      categoryName: '${widget.town.name} · ${widget.town.province}',
      bandColor: context.entityListingTheme.resultsBand,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PropertyListViewModel>();

    return Scaffold(
      backgroundColor: context.entityListing.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody(context, viewModel)),
            const ListingBackFooter(label: 'Back to properties'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PropertyListViewModel viewModel) {
    return switch (viewModel.state) {
      PropertyListLoading() => Column(
        children: [
          _hero(context),
          _band(context, 0),
          _searchPadding(_searchBar(context, viewModel)),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      ),
      PropertyListSuccess(
        items: final items,
        totalCount: final totalCount,
        hasNextPage: final hasNextPage,
        isLoadingMore: final isLoadingMore,
      ) =>
        _buildSuccessOrFilteredEmpty(
          context,
          viewModel,
          items,
          totalCount,
          hasNextPage,
          isLoadingMore,
        ),
      PropertyListError(error: final error) => _buildError(
        context,
        viewModel,
        error,
      ),
    };
  }

  Widget _buildSuccessOrFilteredEmpty(
    BuildContext context,
    PropertyListViewModel viewModel,
    List<PropertyListingCardDto> items,
    int totalCount,
    bool hasNextPage,
    bool isLoadingMore,
  ) {
    final visible = viewModel.filteredItems(items);
    final hasSearch = viewModel.searchTerm.trim().isNotEmpty;
    final bandCount = hasSearch ? visible.length : totalCount;

    if (items.isEmpty) {
      return Column(
        children: [
          _hero(context),
          _band(context, 0),
          _searchPadding(_searchBar(context, viewModel)),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No property listings in this town yet.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
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
          _hero(context),
          _band(context, 0),
          _searchPadding(_searchBar(context, viewModel)),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 52,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No matching listings',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      EntityListingConstants.searchNoMatchesHint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        viewModel.setSearchTerm('');
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text(
                        EntityListingConstants.clearSearchLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _hero(context),
        _band(context, bandCount),
        _searchPadding(_searchBar(context, viewModel)),
        Expanded(
          child: ListView.separated(
            padding: EntityListingConstants.cardListScrollPadding,
            itemCount: visible.length + (hasNextPage ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == visible.length) {
                if (!isLoadingMore) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    viewModel.loadMore();
                  });
                }
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return PropertyListingCardWidget(
                listing: visible[index],
                listingTheme: context.entityListingTheme,
                onTap: () => _openDetails(context, visible[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildError(
    BuildContext context,
    PropertyListViewModel viewModel,
    AppError error,
  ) {
    if (error.actionText != null && error.action != null) {
      return Column(
        children: [
          _hero(context),
          _band(context, 0),
          _searchPadding(_searchBar(context, viewModel)),
          Expanded(child: ErrorView(error: error)),
        ],
      );
    }
    return Column(
      children: [
        _hero(context),
        _band(context, 0),
        _searchPadding(_searchBar(context, viewModel)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              ErrorView(error: error),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: viewModel.load,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
