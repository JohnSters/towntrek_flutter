import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../core/utils/url_utils.dart';
import '../../models/models.dart';
import 'what_to_do_state.dart';
import 'what_to_do_view_model.dart';

class WhatToDoScreen extends StatelessWidget {
  final TownDto town;

  const WhatToDoScreen({super.key, required this.town});

  static const EntityListingTheme _theme = EntityListingTheme.business;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WhatToDoViewModel(
        discoveryApiService: serviceLocator.discoveryApiService,
        errorHandler: serviceLocator.errorHandler,
        town: town,
      ),
      child: const _WhatToDoScreenContent(),
    );
  }
}

class _WhatToDoScreenContent extends StatelessWidget {
  const _WhatToDoScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WhatToDoViewModel>();

    return Scaffold(
      backgroundColor: EntityListingTheme.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildContent(context, viewModel)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => viewModel.openSuggest(context),
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Suggest a discovery'),
                ),
              ),
            ),
            const ListingBackFooter(label: 'Back'),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(TownDto town) {
    return EntityListingHeroHeader(
      theme: WhatToDoScreen._theme,
      categoryIcon: Icons.travel_explore_rounded,
      subCategoryName: '${WhatToDoConstants.titlePrefix} ${town.name}',
      categoryName: TownFeatureConstants.whatToDoTitle,
      townName: town.name,
    );
  }

  Widget _buildContent(BuildContext context, WhatToDoViewModel viewModel) {
    final state = viewModel.state;

    return switch (state) {
      WhatToDoLoading() => Column(
          children: [
            _buildHero(viewModel.town),
            ListingResultsBand(
              count: 0,
              categoryName: viewModel.town.name,
              bandColor: WhatToDoScreen._theme.resultsBand,
            ),
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      WhatToDoError(error: final error) => Column(
          children: [
            _buildHero(viewModel.town),
            ListingResultsBand(
              count: 0,
              categoryName: viewModel.town.name,
              bandColor: WhatToDoScreen._theme.resultsBand,
            ),
            Expanded(child: ErrorView(error: error)),
          ],
        ),
      WhatToDoSuccess(
        town: final town,
        totalCount: final totalCount,
        categories: final categories,
        featured: final featured,
        items: final items,
        selectedCategoryId: final selectedCat,
        hasNextPage: final hasNext,
        loadingMore: final loadingMore,
      ) =>
        NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.pixels > n.metrics.maxScrollExtent - 400) {
              viewModel.loadMore();
            }
            return false;
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHero(town)),
              SliverToBoxAdapter(
                child: ListingResultsBand(
                  count: totalCount,
                  categoryName: town.name,
                  bandColor: WhatToDoScreen._theme.resultsBand,
                ),
              ),
              if (featured.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      'Featured',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
              if (featured.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: featured.length,
                      separatorBuilder: (context, _) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final d = featured[i];
                        return _FeaturedCard(
                          discovery: d,
                          onTap: () => viewModel.openDiscoveryDetail(
                            context,
                            d.id,
                            d.title,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('All'),
                            selected: selectedCat == null,
                            onSelected: (_) => viewModel.selectCategory(null),
                          ),
                        ),
                        for (final c in categories)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(c.name),
                              selected: selectedCat == c.id,
                              onSelected: (_) => viewModel.selectCategory(c.id),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (items.isEmpty && !loadingMore)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyDiscoveries(
                    townName: town.name,
                    onSuggest: () => viewModel.openSuggest(context),
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= items.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final d = items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _DiscoveryListCard(
                            discovery: d,
                            onTap: () => viewModel.openDiscoveryDetail(
                              context,
                              d.id,
                              d.title,
                            ),
                          ),
                        );
                      },
                      childCount: items.length + (loadingMore && hasNext ? 1 : 0),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
    };
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.discovery, required this.onTap});

  final TownDiscoveryDto discovery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final raw = discovery.thumbnailUrl ?? discovery.coverImageUrl;
    final url = raw != null && raw.isNotEmpty ? UrlUtils.resolveImageUrl(raw) : null;

    return Material(
      color: EntityListingTheme.cardBg,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 200,
          child: Row(
            children: [
              SizedBox(
                width: 88,
                height: double.infinity,
                child: url != null
                    ? CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            const ColoredBox(color: Color(0xFFE0E0E0)),
                      )
                    : const ColoredBox(color: Color(0xFFE0E0E0)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        discovery.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const Spacer(),
                      ListingInfoChip(
                        icon: Icons.category_outlined,
                        label: discovery.categoryName,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscoveryListCard extends StatelessWidget {
  const _DiscoveryListCard({required this.discovery, required this.onTap});

  final TownDiscoveryDto discovery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final raw = discovery.thumbnailUrl ?? discovery.coverImageUrl;
    final url = raw != null && raw.isNotEmpty ? UrlUtils.resolveImageUrl(raw) : null;

    return Material(
      color: EntityListingTheme.cardBg,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
                child: SizedBox(
                  width: 108,
                  height: 108,
                  child: url != null
                      ? CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          placeholder: (context, progress) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.image_not_supported),
                        )
                      : ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            WhatToDoConstants.emptyIcon,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        discovery.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          ListingInfoChip(
                            icon: Icons.sell_outlined,
                            label: discovery.categoryName,
                          ),
                          if (discovery.difficulty != null &&
                              discovery.difficulty!.isNotEmpty)
                            ListingInfoChip(
                              icon: Icons.terrain_outlined,
                              label: discovery.difficulty!,
                            ),
                          if (discovery.duration != null &&
                              discovery.duration!.isNotEmpty)
                            ListingInfoChip(
                              icon: Icons.schedule_outlined,
                              label: discovery.duration!,
                            ),
                          ListingInfoChip(
                            icon: discovery.isFreeAccess
                                ? Icons.money_off_outlined
                                : Icons.payments_outlined,
                            label: discovery.isFreeAccess ? 'Free' : 'Paid',
                          ),
                        ],
                      ),
                      if (discovery.quickTip != null &&
                          discovery.quickTip!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          discovery.quickTip!.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyDiscoveries extends StatelessWidget {
  const _EmptyDiscoveries({required this.townName, required this.onSuggest});

  final String townName;
  final VoidCallback onSuggest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.all(WhatToDoConstants.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            WhatToDoConstants.emptyIcon,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          Text(
            WhatToDoConstants.emptyTitle,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            WhatToDoConstants.emptyDescription(townName),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onSuggest,
            child: const Text('Suggest a discovery'),
          ),
        ],
      ),
    );
  }
}
