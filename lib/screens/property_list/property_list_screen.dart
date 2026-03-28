import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../core/utils/url_utils.dart';
import '../../models/models.dart';
import 'property_list_state.dart';
import 'property_list_view_model.dart';

class PropertyListScreen extends StatelessWidget {
  final TownDto town;

  const PropertyListScreen({super.key, required this.town});

  static const double _headerHeight = 100;
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
              headerType: HeaderType.default_,
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
        hasNextPage: final hasNextPage,
        isLoadingMore: final isLoadingMore,
      ) =>
        _buildList(context, viewModel, items, hasNextPage, isLoadingMore),
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

    return ListView.builder(
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
          padding: EdgeInsets.only(bottom: index < items.length - 1 || hasNextPage ? 12 : 0),
          child: _PropertyListingCard(listing: items[index]),
        );
      },
    );
  }
}

class _PropertyListingCard extends StatelessWidget {
  final PropertyListingCardDto listing;

  const _PropertyListingCard({required this.listing});

  String get _typeLabel => listing.listingType == 1 ? 'For sale' : 'For rent';

  String _formatPrice() {
    return NumberFormat.currency(
      symbol: 'R ',
      decimalDigits: 0,
    ).format(listing.price);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final imageUrl = listing.primaryImageUrl != null && listing.primaryImageUrl!.trim().isNotEmpty
        ? UrlUtils.resolveImageUrl(listing.primaryImageUrl!.trim())
        : null;

    return Card(
      elevation: 0,
      color: colorScheme.primary.withValues(alpha: 0.02),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumb(imageUrl, colorScheme),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              listing.address.trim().isNotEmpty ? listing.address : listing.ownerName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (listing.isFeatured)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.tertiary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Featured',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatPrice(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _pill(context, Icons.home_outlined, _typeLabel),
                          if (listing.townName.trim().isNotEmpty)
                            _pill(context, Icons.location_on_outlined, listing.townName),
                        ],
                      ),
                      if (listing.summary != null && listing.summary!.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          listing.summary!.trim(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(BuildContext context, IconData icon, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumb(String? imageUrl, ColorScheme colorScheme) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: imageUrl == null
          ? Icon(
              Icons.home_work_rounded,
              size: 32,
              color: colorScheme.onSurfaceVariant,
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: 86,
                height: 86,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.home_work_rounded,
                    size: 32,
                    color: colorScheme.onSurfaceVariant,
                  );
                },
              ),
            ),
    );
  }
}
