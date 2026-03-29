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

  static const EntityListingTheme _theme = EntityListingTheme.properties;

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
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  EntityListingTheme get _theme => PropertyListScreen._theme;

  List<PropertyListingCardDto> _visibleItems(
    List<PropertyListingCardDto> items,
  ) {
    final t = _searchController.text.trim().toLowerCase();
    if (t.isEmpty) return items;
    return items.where((p) {
      return p.ownerName.toLowerCase().contains(t) ||
          p.address.toLowerCase().contains(t) ||
          (p.summary?.toLowerCase().contains(t) ?? false) ||
          p.townName.toLowerCase().contains(t) ||
          p.province.toLowerCase().contains(t);
    }).toList();
  }

  Widget _searchBar() {
    return EntityListingSearchBar(
      controller: _searchController,
      theme: _theme,
      hintText: EntityListingConstants.propertySearchHint,
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

  void _openDetails(BuildContext context, PropertyListingCardDto listing) {
    final fallback =
        listing.address.trim().isNotEmpty ? listing.address : listing.ownerName;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PropertyDetailsPage(
          listingId: listing.id,
          titleFallback: fallback,
        ),
      ),
    );
  }

  Widget _hero() {
    return EntityListingHeroHeader(
      theme: _theme,
      categoryIcon: Icons.home_work_rounded,
      subCategoryName: 'Property listings',
      categoryName: 'Properties',
      townName: widget.town.name,
    );
  }

  Widget _band(int count) {
    return ListingResultsBand(
      count: count,
      categoryName: '${widget.town.name} · ${widget.town.province}',
      bandColor: _theme.resultsBand,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PropertyListViewModel>();

    return Scaffold(
      backgroundColor: EntityListingTheme.pageBg,
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
            _hero(),
            _band(0),
            _searchPadding(_searchBar()),
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
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
      PropertyListError(error: final error) => _buildError(context, viewModel, error),
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
    final visible = _visibleItems(items);
    final hasSearch = _searchController.text.trim().isNotEmpty;
    final bandCount = hasSearch ? visible.length : totalCount;

    if (items.isEmpty) {
      return Column(
        children: [
          _hero(),
          _band(0),
          _searchPadding(_searchBar()),
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
          _hero(),
          _band(0),
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
                        setState(() {});
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

    return Column(
      children: [
        _hero(),
        _band(bandCount),
        _searchPadding(_searchBar()),
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
                listingTheme: _theme,
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
          _hero(),
          _band(0),
          _searchPadding(_searchBar()),
          Expanded(child: ErrorView(error: error)),
        ],
      );
    }
    return Column(
      children: [
        _hero(),
        _band(0),
        _searchPadding(_searchBar()),
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
