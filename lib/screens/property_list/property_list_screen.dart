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

class _PropertyListContent extends StatelessWidget {
  final TownDto town;

  const _PropertyListContent({required this.town});

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
      theme: PropertyListScreen._theme,
      categoryIcon: Icons.home_work_rounded,
      subCategoryName: 'Property listings',
      categoryName: 'Properties',
      townName: town.name,
    );
  }

  Widget _band(int count) {
    return ListingResultsBand(
      count: count,
      categoryName: '${town.name} · ${town.province}',
      bandColor: PropertyListScreen._theme.resultsBand,
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
        _buildList(
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
          Expanded(child: ErrorView(error: error)),
        ],
      );
    }
    return Column(
      children: [
        _hero(),
        _band(0),
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

  Widget _buildList(
    BuildContext context,
    PropertyListViewModel viewModel,
    List<PropertyListingCardDto> items,
    int totalCount,
    bool hasNextPage,
    bool isLoadingMore,
  ) {
    if (items.isEmpty) {
      return Column(
        children: [
          _hero(),
          _band(0),
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

    return Column(
      children: [
        _hero(),
        _band(totalCount),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length + (hasNextPage ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == items.length) {
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
                listing: items[index],
                listingTheme: PropertyListScreen._theme,
                onTap: () => _openDetails(context, items[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
