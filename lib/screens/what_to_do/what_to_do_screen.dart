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
      backgroundColor: context.entityListing.pageBg,
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

  Widget _buildHero(BuildContext context, TownDto town) {
    return EntityListingHeroHeader(
      theme: context.entityListingTheme,
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
          _buildHero(context, viewModel.town),
          ListingResultsBand(
            count: 0,
            categoryName: viewModel.town.name,
            bandColor: context.entityListingTheme.resultsBand,
          ),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      ),
      WhatToDoError(error: final error) => Column(
        children: [
          _buildHero(context, viewModel.town),
          ListingResultsBand(
            count: 0,
            categoryName: viewModel.town.name,
            bandColor: context.entityListingTheme.resultsBand,
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
              SliverToBoxAdapter(child: _buildHero(context, town)),
              SliverToBoxAdapter(
                child: ListingResultsBand(
                  count: totalCount,
                  categoryName: town.name,
                  bandColor: context.entityListingTheme.resultsBand,
                ),
              ),
              if (featured.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 22,
                          decoration: BoxDecoration(
                            color: context.entityListingTheme.accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Featured',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.entityListingTheme.textTitle,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (featured.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                      itemCount: featured.length,
                      separatorBuilder: (context, _) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final d = featured[i];
                        return _FeaturedCard(
                          listingTheme: context.entityListingTheme,
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
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _WhatToDoCategoryChip(
                            label: 'All',
                            selected: selectedCat == null,
                            onSelected: (sel) {
                              if (sel) viewModel.selectCategory(null);
                            },
                          ),
                        ),
                        for (final c in categories)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _WhatToDoCategoryChip(
                              label: c.name,
                              selected: selectedCat == c.id,
                              onSelected: (sel) {
                                if (sel) viewModel.selectCategory(c.id);
                              },
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _DiscoveryListCard(
                            listingTheme: context.entityListingTheme,
                            discovery: d,
                            votePending: viewModel.isVotePending(d.id),
                            onVoteUp: () => viewModel.vote(
                              context,
                              d,
                              d.currentDeviceVote == 1 ? 0 : 1,
                            ),
                            onVoteDown: () => viewModel.vote(
                              context,
                              d,
                              d.currentDeviceVote == -1 ? 0 : -1,
                            ),
                            onTap: () => viewModel.openDiscoveryDetail(
                              context,
                              d.id,
                              d.title,
                            ),
                          ),
                        );
                      },
                      childCount:
                          items.length + (loadingMore && hasNext ? 1 : 0),
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

class _WhatToDoCategoryChip extends StatelessWidget {
  const _WhatToDoCategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = selected
        ? colorScheme.primary
        : colorScheme.outline.withValues(alpha: 0.38);

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: true,
      checkmarkColor: colorScheme.onPrimary,
      selectedColor: colorScheme.primary,
      backgroundColor: context.entityListing.cardBg,
      side: BorderSide(color: borderColor, width: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.listingTheme,
    required this.discovery,
    required this.onTap,
  });

  final EntityListingTheme listingTheme;
  final TownDiscoveryDto discovery;
  final VoidCallback onTap;

  static const double _radius = 18;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final raw = discovery.thumbnailUrl ?? discovery.coverImageUrl;
    final url = raw != null && raw.isNotEmpty
        ? UrlUtils.resolveImageUrl(raw)
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        child: Ink(
          width: 208,
          decoration: BoxDecoration(
            color: context.entityListing.cardBg,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius - 0.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 88,
                  child: ColoredBox(
                      color: colorScheme.surfaceContainerHighest,
                      child: url != null
                          ? CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              placeholder: (context, progress) => Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: listingTheme.accent,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, _) => Icon(
                                WhatToDoConstants.emptyIcon,
                                color: listingTheme.accent,
                              ),
                            )
                          : Icon(
                              WhatToDoConstants.emptyIcon,
                              color: listingTheme.accent,
                              size: 32,
                            ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          discovery.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: listingTheme.textTitle,
                            height: 1.25,
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
      ),
    );
  }
}

/// Single-line meta pill for discovery cards (compact vs [ListingInfoChip]).
class _DiscoveryCompactMetaChip extends StatelessWidget {
  const _DiscoveryCompactMetaChip({
    required this.icon,
    required this.label,
    required this.maxWidth,
  });

  final IconData icon;
  final String label;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final w = maxWidth.clamp(28.0, 400.0);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: w),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: context.entityListing.chipBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 12,
              color: context.entityListing.chipIconAndLabel,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: context.entityListing.chipIconAndLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<({IconData icon, String label})> _discoveryMetaEntries(
  TownDiscoveryDto d,
) {
  final list = <({IconData icon, String label})>[
    (icon: Icons.sell_outlined, label: d.categoryName),
  ];
  if (d.difficulty != null && d.difficulty!.trim().isNotEmpty) {
    list.add((icon: Icons.terrain_outlined, label: d.difficulty!.trim()));
  }
  if (d.duration != null && d.duration!.trim().isNotEmpty) {
    list.add((icon: Icons.schedule_outlined, label: d.duration!.trim()));
  }
  list.add(
    (
      icon: d.isFreeAccess ? Icons.money_off_outlined : Icons.payments_outlined,
      label: d.isFreeAccess ? 'Free' : 'Paid',
    ),
  );
  return list;
}

class _DiscoveryListCard extends StatelessWidget {
  const _DiscoveryListCard({
    required this.listingTheme,
    required this.discovery,
    required this.onTap,
    required this.onVoteUp,
    required this.onVoteDown,
    this.votePending = false,
  });

  final EntityListingTheme listingTheme;
  final TownDiscoveryDto discovery;
  final VoidCallback onTap;
  final VoidCallback onVoteUp;
  final VoidCallback onVoteDown;
  final bool votePending;

  static const double _radius = 18;
  static const double _thumbWidth = 108;
  static const double _minCardHeight = 108;
  /// Tall source images must not drive list row height via intrinsic sizing.
  static const double _maxThumbHeight = 240;
  static const double _voteRailWidth = 60;
  static const double _dividerWidth = 1;
  /// Horizontal padding on meta chip strip (6 + 6); subtract from `midW` for slot math.
  static const double _metaChipRowHPadding = 12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final raw = discovery.thumbnailUrl ?? discovery.coverImageUrl;
    final url = raw != null && raw.isNotEmpty
        ? UrlUtils.resolveImageUrl(raw)
        : null;
    final dividerColor = colorScheme.outline.withValues(alpha: 0.12);
    final metaEntries = _discoveryMetaEntries(discovery);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        child: Ink(
          decoration: BoxDecoration(
            color: context.entityListing.cardBg,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius - 0.5),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: _minCardHeight),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final midW = (constraints.maxWidth -
                          _thumbWidth -
                          _dividerWidth -
                          _voteRailWidth)
                      .clamp(48.0, double.infinity);
                  final n = metaEntries.length;
                  final chipRowW =
                      (midW - _metaChipRowHPadding).clamp(0.0, double.infinity);
                  final metaSlotW = n > 0 ? chipRowW / n : 0.0;

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: _minCardHeight,
                            maxHeight: _maxThumbHeight,
                          ),
                          child: SizedBox(
                            width: _thumbWidth,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(17),
                              ),
                              child: url != null
                                  ? CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                    placeholder: (context, progress) =>
                                        ColoredBox(
                                      color: colorScheme.surfaceContainerHighest,
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: listingTheme.accent,
                                          ),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, failedUrl, error) =>
                                        ColoredBox(
                                      color: colorScheme.surfaceContainerHighest,
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: listingTheme.accent,
                                      ),
                                    ),
                                    imageBuilder: (context, imageProvider) =>
                                        SizedBox.expand(
                                      child: Image(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.center,
                                      ),
                                    ),
                                  )
                                  : ColoredBox(
                                      color: colorScheme.surfaceContainerHighest,
                                      child: Center(
                                        child: Icon(
                                          WhatToDoConstants.emptyIcon,
                                          color: listingTheme.accent,
                                          size: 36,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: midW,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLow
                                      .withValues(alpha: 0.72),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: colorScheme.outline
                                          .withValues(alpha: 0.1),
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 6,
                                  ),
                                  child: n == 0
                                      ? const SizedBox.shrink()
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            for (var i = 0; i < n; i++)
                                              SizedBox(
                                                width: metaSlotW,
                                                child: Center(
                                                  child:
                                                      _DiscoveryCompactMetaChip(
                                                    icon: metaEntries[i].icon,
                                                    label:
                                                        metaEntries[i].label,
                                                    maxWidth: (metaSlotW - 4)
                                                        .clamp(20.0, 400.0),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 10, 8, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      discovery.title,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: listingTheme.textTitle,
                                        height: 1.25,
                                        letterSpacing: -0.15,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (discovery.quickTip != null &&
                                        discovery.quickTip!.trim().isNotEmpty)
                                      ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          discovery.quickTip!.trim(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: _dividerWidth,
                          child: ColoredBox(color: dividerColor),
                        ),
                        SizedBox(
                          width: _voteRailWidth,
                          child: DiscoveryVoteRail(
                            voteScore: discovery.voteScore,
                            currentDeviceVote: discovery.currentDeviceVote,
                            votePending: votePending,
                            onVoteUp: onVoteUp,
                            onVoteDown: onVoteDown,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
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
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
