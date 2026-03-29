import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import 'creative_spaces_state.dart';
import 'creative_spaces_view_model.dart';
import 'widgets/creative_space_card.dart';

class CreativeSpacesListPage extends StatelessWidget {
  final TownDto town;
  final CreativeCategoryDto category;
  final CreativeSubCategoryDto? subCategory;

  const CreativeSpacesListPage({
    super.key,
    required this.town,
    required this.category,
    this.subCategory,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreativeSpacesViewModel(
        creativeSpaceRepository: serviceLocator.creativeSpaceRepository,
        errorHandler: serviceLocator.errorHandler,
        townId: town.id,
        initialCategoryId: category.id,
        initialSubCategoryId: subCategory?.id,
      ),
      child: _CreativeSpacesListPageContent(
        town: town,
        category: category,
        subCategory: subCategory,
      ),
    );
  }
}

class _CreativeSpacesListPageContent extends StatefulWidget {
  final TownDto town;
  final CreativeCategoryDto category;
  final CreativeSubCategoryDto? subCategory;

  const _CreativeSpacesListPageContent({
    required this.town,
    required this.category,
    this.subCategory,
  });

  @override
  State<_CreativeSpacesListPageContent> createState() =>
      _CreativeSpacesListPageContentState();
}

class _CreativeSpacesListPageContentState
    extends State<_CreativeSpacesListPageContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(CreativeSpacesViewModel viewModel) {
    viewModel.search(_searchController.text);
  }

  void _clearSearch(CreativeSpacesViewModel viewModel) {
    _searchController.clear();
    viewModel.search(null);
  }

  String get _listTitle {
    final selectedName = widget.subCategory?.name ?? widget.category.name;
    return CreativeSpacesConstants.listHeaderTitleTemplate.replaceAll(
      '{name}',
      selectedName,
    );
  }

  String get _listSubtitle {
    if (widget.subCategory == null) {
      return CreativeSpacesConstants.listSubtitleCategoryTemplate.replaceAll(
        '{town}',
        widget.town.name,
      );
    }
    return CreativeSpacesConstants.listSubtitleSubCategoryTemplate
        .replaceAll('{category}', widget.category.name)
        .replaceAll('{town}', widget.town.name);
  }

  String _resultsSummaryText(int totalItemCount) {
    if (totalItemCount == 1) {
      return '1 creative space';
    }

    return CreativeSpacesConstants.resultCountTemplate.replaceAll(
      '{count}',
      totalItemCount.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: _listTitle,
              subtitle: _listSubtitle,
              height: CreativeSpacesConstants.pageHeaderHeight,
              headerType: HeaderType.creative,
            ),
            Expanded(
              child: Consumer<CreativeSpacesViewModel>(
                builder: (context, viewModel, child) {
                  final state = viewModel.state;

                  if (state is CreativeSpacesLoading) {
                    return _buildLoading();
                  }

                  if (state is CreativeSpacesError) {
                    return _buildErrorState(
                      context,
                      viewModel: viewModel,
                      error: state.error,
                    );
                  }

                  if (state is! CreativeSpacesSuccess &&
                      state is! CreativeSpacesLoadingMore) {
                    return const SizedBox.shrink();
                  }

                  final isLoadingMore = state is CreativeSpacesLoadingMore;
                  final spaces = state.spaces;
                  final hasNextPage = state.hasNextPage;

                  return RefreshIndicator(
                    onRefresh: viewModel.refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                      children: [
                        _buildSearchBar(viewModel),
                        const SizedBox(
                          height: CreativeSpacesConstants.sectionSpacing,
                        ),
                        _buildResultsSummaryCard(
                          context,
                          isLoadingMore,
                          state.totalItemCount,
                        ),
                        const SizedBox(
                          height: CreativeSpacesConstants.sectionSpacing,
                        ),
                        spaces.isEmpty
                            ? _buildEmptyState(context, viewModel)
                            : _buildSpacesList(
                                context,
                                spaces,
                                hasNextPage,
                                isLoadingMore,
                                viewModel,
                              ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const BackNavigationFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              CreativeSpacesConstants.loadingSpacesText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              CreativeSpacesConstants.loadingSubtitleText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(CreativeSpacesViewModel viewModel) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _searchController,
      builder: (context, value, child) {
        return TextField(
          controller: _searchController,
          onSubmitted: (_) => _submitSearch(viewModel),
          textInputAction: TextInputAction.search,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.2),
          decoration: InputDecoration(
            hintText: CreativeSpacesConstants.searchHint,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () => _clearSearch(viewModel),
                  ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: CreativeSpacesConstants.searchBarContentPadding,
            ),
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.2,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                CreativeSpacesConstants.searchBarRadius,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                CreativeSpacesConstants.searchBarRadius,
              ),
              borderSide: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.16),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                CreativeSpacesConstants.searchBarRadius,
              ),
              borderSide: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.45),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsSummaryCard(
    BuildContext context,
    bool isLoadingMore,
    int totalItemCount,
  ) {
    final currentSearch = _searchController.text.trim();
    final detailChips = [
      if (widget.subCategory != null)
        _SummaryChipData(
          icon: Icons.category_rounded,
          label: widget.category.name,
        ),
      if (currentSearch.isNotEmpty)
        _SummaryChipData(
          icon: Icons.search_rounded,
          label: '${CreativeSpacesConstants.searchChipPrefix}: $currentSearch',
        ),
    ];

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: CreativeSpacesConstants.creativeTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.palette_outlined,
                    size: 18,
                    color: CreativeSpacesConstants.creativePrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _resultsSummaryText(totalItemCount),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentSearch.isEmpty
                            ? 'Browse the spaces that match this selection.'
                            : 'Showing spaces that match your current search.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoadingMore)
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            if (detailChips.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: detailChips
                    .map((chip) => _buildContextChip(context, chip))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContextChip(BuildContext context, _SummaryChipData chip) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.16),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            chip.icon,
            size: 14,
            color: CreativeSpacesConstants.creativePrimary,
          ),
          const SizedBox(width: 6),
          Text(
            chip.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSpacesList(
    BuildContext context,
    List<CreativeSpaceDto> spaces,
    bool hasNextPage,
    bool isLoadingMore,
    CreativeSpacesViewModel viewModel,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: spaces.length + (hasNextPage ? 1 : 0),
      separatorBuilder: (_, _) =>
          const SizedBox(height: CreativeSpacesConstants.cardSpacing),
      itemBuilder: (context, index) {
        if (index == spaces.length) {
          if (isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: OutlinedButton.icon(
              onPressed: viewModel.loadMore,
              icon: const Icon(Icons.expand_more_rounded),
              label: const Text(CreativeSpacesConstants.loadMoreSpacesLabel),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                side: BorderSide(
                  color: CreativeSpacesConstants.creativePrimary.withValues(
                    alpha: 0.35,
                  ),
                ),
              ),
            ),
          );
        }

        return CreativeSpaceCard(space: spaces[index]);
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    CreativeSpacesViewModel viewModel,
  ) {
    final hasSearch = (_searchController.text.trim().isNotEmpty);
    final emptyMessage = hasSearch
        ? CreativeSpacesConstants.noSpacesWithFiltersSubtitle
        : CreativeSpacesConstants.noSpacesForSelection;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 52,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            CreativeSpacesConstants.noSpacesTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            emptyMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (hasSearch)
            TextButton.icon(
              onPressed: () => _clearSearch(viewModel),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(CreativeSpacesConstants.clearSearchLabel),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context, {
    required CreativeSpacesViewModel viewModel,
    required AppError error,
  }) {
    if (error.actionText != null && error.action != null) {
      return ErrorView(error: error);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ErrorView(error: error),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: viewModel.retry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text(CreativeSpacesConstants.retryLabel),
        ),
      ],
    );
  }
}

class _SummaryChipData {
  final IconData icon;
  final String label;

  const _SummaryChipData({required this.icon, required this.label});
}
