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

  static const double _headerHeight = 140;
  static const double _horizontalPadding = 16;

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
    final fallback = listing.address.trim().isNotEmpty ? listing.address : listing.ownerName;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PropertyDetailsPage(
          listingId: listing.id,
          titleFallback: fallback,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PropertyListViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: 'Properties',
              subtitle: '${town.name} • ${town.province}',
              height: PropertyListScreen._headerHeight,
              headerType: HeaderType.business,
            ),
            Expanded(child: _buildBody(context, viewModel)),
            const BackNavigationFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PropertyListViewModel viewModel) {
    return switch (viewModel.state) {
      PropertyListLoading() => const Center(child: CircularProgressIndicator()),
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
      return ErrorView(error: error);
    }
    return ListView(
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
      return Center(
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
      );
    }

    return Column(
      children: [
        _ListInfoBar(
          icon: Icons.home_work_rounded,
          text:
              '$totalCount listing${totalCount == 1 ? '' : 's'} · Properties in ${town.name}',
          backgroundColor: const Color(0xFFE9F7EF),
          textColor: const Color(0xFF1D7A38),
          borderColor: const Color(0xFFBFE5CB),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(PropertyListScreen._horizontalPadding),
            itemCount: items.length + (hasNextPage ? 1 : 0),
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
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < items.length - 1 || hasNextPage ? 16 : 0,
                ),
                child: PropertyListingCardWidget(
                  listing: items[index],
                  onTap: () => _openDetails(context, items[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ListInfoBar extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const _ListInfoBar({
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
