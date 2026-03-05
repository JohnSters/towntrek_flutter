import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import 'creative_spaces_category_page.dart';
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
  State<_CreativeSpacesListPageContent> createState() => _CreativeSpacesListPageContentState();
}

class _CreativeSpacesListPageContentState extends State<_CreativeSpacesListPageContent> {
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
    final subCategoryName = widget.subCategory?.name;
    if (subCategoryName == null || subCategoryName.trim().isEmpty) {
      return CreativeSpacesConstants.listHeaderTitleTemplate.replaceAll(
        '{name}',
        widget.category.name,
      );
    }
    return CreativeSpacesConstants.listHeaderTitleTemplate.replaceAll(
      '{name}',
      widget.subCategory!.name,
    );
  }

  String get _listSubtitle {
    if (widget.subCategory == null) {
      return CreativeSpacesConstants.listSubtitleCategoryTemplate
          .replaceAll('{category}', widget.category.name)
          .replaceAll('{town}', widget.town.name);
    }
    return CreativeSpacesConstants.listSubtitleSubCategoryTemplate
        .replaceAll('{subCategory}', widget.subCategory!.name)
        .replaceAll('{category}', widget.category.name);
  }

  void _navigateToCategoryFlow(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => CreativeSpacesCategoryPage(town: widget.town),
        settings: const RouteSettings(name: CreativeSpacesCategoryPage.routeName),
      ),
      (route) => route.isFirst,
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
                    return _buildErrorState(context, viewModel: viewModel, error: state.error);
                  }

                  if (state is! CreativeSpacesSuccess && state is! CreativeSpacesLoadingMore) {
                    return const SizedBox.shrink();
                  }

                  final isLoadingMore = state is CreativeSpacesLoadingMore;
                  final spaces = state.spaces;
                  final hasNextPage = state.hasNextPage;

                  return RefreshIndicator(
                    onRefresh: viewModel.refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: CreativeSpacesConstants.pagePadding,
                        vertical: 12,
                      ),
                      children: [
                        _buildSearchBar(viewModel),
                        const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
                        _buildContextStrip(context, isLoadingMore, state.totalItemCount),
                        const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
                        spaces.isEmpty
                            ? _buildEmptyState(context, viewModel)
                            : _buildSpacesList(context, spaces, hasNextPage, isLoadingMore, viewModel),
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
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.2,
              ),
          decoration: InputDecoration(
            hintText: CreativeSpacesConstants.searchHint,
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
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
              borderRadius: BorderRadius.circular(CreativeSpacesConstants.searchBarRadius),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CreativeSpacesConstants.searchBarRadius),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContextStrip(BuildContext context, bool isLoadingMore, int totalItemCount) {
    final selectedCategoryName = widget.category.name;
    final selectedSubCategoryName = widget.subCategory?.name;
    final hasSearch = _searchController.text.trim().isNotEmpty;
    final currentSearch = hasSearch ? _searchController.text.trim() : null;
    final resultSummary = totalItemCount > 0
        ? CreativeSpacesConstants.resultCountTemplate.replaceAll(
            '{count}',
            totalItemCount.toString(),
          )
        : CreativeSpacesConstants.numericValueTemplate
            .replaceAll('{count}', '0')
            .replaceAll('{label}', CreativeSpacesConstants.resultsLabel);
    final contextChipLabels = [
      resultSummary,
      CreativeSpacesConstants.contextChipValueTemplate
          .replaceAll('{label}', CreativeSpacesConstants.resultsForCategory)
          .replaceAll('{value}', selectedCategoryName),
      if (selectedSubCategoryName != null && selectedSubCategoryName.trim().isNotEmpty)
        CreativeSpacesConstants.contextChipValueTemplate
            .replaceAll('{label}', CreativeSpacesConstants.resultsForSubCategory)
            .replaceAll('{value}', selectedSubCategoryName.trim()),
      if (currentSearch != null)
        CreativeSpacesConstants.contextChipValueTemplate
            .replaceAll('{label}', CreativeSpacesConstants.searchChipPrefix)
            .replaceAll('{value}', currentSearch),
    ];

    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              CreativeSpacesConstants.creativeTint.withValues(alpha: 0.95),
              CreativeSpacesConstants.creativeHighlight.withValues(alpha: 0.65),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  size: 16,
                  color: CreativeSpacesConstants.creativePrimary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _listSubtitle,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.2,
                        ),
                  ),
                ),
                if (isLoadingMore)
                  const SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Wrap(
                key: ValueKey(contextChipLabels.join(CreativeSpacesConstants.contextChipSeparator)),
                spacing: 8,
                runSpacing: CreativeSpacesConstants.contextStripActionSpacing,
                children: contextChipLabels
                    .map((chipLabel) => _buildContextChip(context, chipLabel))
                    .toList(),
              ),
            ),
            const SizedBox(height: CreativeSpacesConstants.contextStripActionSpacing),
            TextButton.icon(
              onPressed: () => _navigateToCategoryFlow(context),
              icon: const Icon(Icons.grid_view_rounded, size: 16),
              label: Text(CreativeSpacesConstants.backToCategoriesLabel),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                minimumSize: const Size.fromHeight(0),
                textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                foregroundColor: CreativeSpacesConstants.creativePrimary,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextChip(BuildContext context, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: CreativeSpacesConstants.creativePrimary.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.2,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
      separatorBuilder: (_, _) => const SizedBox(height: CreativeSpacesConstants.cardSpacing),
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
                  color: CreativeSpacesConstants.creativePrimary.withValues(alpha: 0.35),
                ),
              ),
            ),
          );
        }

        return CreativeSpaceCard(space: spaces[index]);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, CreativeSpacesViewModel viewModel) {
    final hasSearch = (_searchController.text.trim().isNotEmpty);
    final emptyMessage =
        hasSearch ? CreativeSpacesConstants.noSpacesWithFiltersSubtitle : CreativeSpacesConstants.noSpacesForSelection;

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

