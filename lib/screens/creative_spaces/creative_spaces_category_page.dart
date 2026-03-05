import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import 'creative_spaces_state.dart';
import 'creative_spaces_view_model.dart';
import 'widgets/creative_space_card.dart';

class CreativeSpacesCategoryPage extends StatelessWidget {
  final TownDto town;

  const CreativeSpacesCategoryPage({
    super.key,
    required this.town,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreativeSpacesViewModel(
        creativeSpaceRepository: serviceLocator.creativeSpaceRepository,
        errorHandler: serviceLocator.errorHandler,
        townId: town.id,
      ),
      child: _CreativeSpacesCategoryPageContent(town: town),
    );
  }
}

class _CreativeSpacesCategoryPageContent extends StatefulWidget {
  final TownDto town;

  const _CreativeSpacesCategoryPageContent({
    required this.town,
  });

  @override
  State<_CreativeSpacesCategoryPageContent> createState() =>
      _CreativeSpacesCategoryPageContentState();
}

class _CreativeSpacesCategoryPageContentState
    extends State<_CreativeSpacesCategoryPageContent> {
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

  void _clearFilters(CreativeSpacesViewModel viewModel) {
    _searchController.clear();
    viewModel.clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: '${TownFeatureConstants.creativeSpacesTitle} in ${widget.town.name}',
              subtitle: CreativeSpacesConstants.pageSubtitle,
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
                      error: state.error,
                      viewModel: viewModel,
                    );
                  }

                  if (state is! CreativeSpacesSuccess && state is! CreativeSpacesLoadingMore) {
                    return const SizedBox.shrink();
                  }

                  final isLoadingMore = state is CreativeSpacesLoadingMore;
                  final spaces = state.spaces;
                  final categories = state.categories;
                  final hasNextPage = state.hasNextPage;
                  final totalItemCount = state.totalItemCount;
                  final hasActiveFilters =
                      viewModel.selectedCategoryId != null ||
                          viewModel.selectedSubCategoryId != null ||
                          (viewModel.searchTerm?.trim().isNotEmpty ?? false);

                  return RefreshIndicator(
                    onRefresh: viewModel.refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: CreativeSpacesConstants.pagePadding,
                        vertical: 14,
                      ),
                      children: [
                        _buildSearchBar(context, viewModel),
                        const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
                        if (categories.isNotEmpty) ...[
                          _buildFilterBlock(
                            context: context,
                            title: CreativeSpacesConstants.categoryLabel,
                            chips: [
                              _buildFilterChip(
                                context: context,
                                label: CreativeSpacesConstants.filterAll,
                                isActive: viewModel.selectedCategoryId == null,
                                onTap: () => viewModel.selectCategory(null),
                              ),
                              for (final category in categories)
                                _buildFilterChip(
                                  context: context,
                                  label: '${category.name} (${category.spaceCount})',
                                  isActive: viewModel.selectedCategoryId == category.id,
                                  onTap: () => viewModel.selectCategory(category.id),
                                ),
                            ],
                          ),
                          const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
                        ],
                        if (viewModel.selectedCategoryId != null &&
                            viewModel.availableSubCategories.isNotEmpty) ...[
                          _buildFilterBlock(
                            context: context,
                            title: CreativeSpacesConstants.subCategoryLabel,
                            chips: [
                              _buildFilterChip(
                                context: context,
                                label: CreativeSpacesConstants.filterAll,
                                isActive: viewModel.selectedSubCategoryId == null,
                                onTap: () => viewModel.selectSubCategory(null),
                              ),
                              for (final subCategory
                                  in viewModel.availableSubCategories)
                                _buildFilterChip(
                                  context: context,
                                  label: '${subCategory.name} (${subCategory.spaceCount})',
                                  isActive:
                                      viewModel.selectedSubCategoryId == subCategory.id,
                                  onTap: () =>
                                      viewModel.selectSubCategory(subCategory.id),
                                ),
                            ],
                          ),
                          const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
                        ],
                        spaces.isEmpty
                            ? _buildEmptyState(
                                context,
                                viewModel: viewModel,
                                hasActiveFilters: hasActiveFilters,
                              )
                            : _buildResultSummary(context, totalItemCount, spaces.length),
                        const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
                        for (final space in spaces)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: CreativeSpacesConstants.cardSpacing,
                            ),
                            child: CreativeSpaceCard(space: space),
                          ),
                        if (hasNextPage)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: isLoadingMore
                                ? const Center(child: CircularProgressIndicator())
                                : OutlinedButton(
                                    onPressed: viewModel.loadMore,
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(44),
                                      side: BorderSide(
                                        color: CreativeSpacesConstants.sectionAccent
                                            .withValues(alpha: 0.35),
                                      ),
                                    ),
                                    child: const Text('Load more'),
                                  ),
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

  Widget _buildSearchBar(
    BuildContext context,
    CreativeSpacesViewModel viewModel,
  ) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _searchController,
      builder: (context, value, child) {
        return TextField(
          controller: _searchController,
          onSubmitted: (_) => _submitSearch(viewModel),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: CreativeSpacesConstants.searchHint,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () => _clearSearch(viewModel),
                  ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterBlock({
    required BuildContext context,
    required String title,
    required List<Widget> chips,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips,
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
      ),
      selected: isActive,
      onSelected: (_) => onTap(),
      selectedColor: CreativeSpacesConstants.sectionAccent,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      side: BorderSide(
        color: isActive
            ? CreativeSpacesConstants.sectionAccent
            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildResultSummary(
    BuildContext context,
    int totalCount,
    int currentCount,
  ) {
    final displayedCount = totalCount > 0 ? totalCount : currentCount;
    return Text(
      CreativeSpacesConstants.resultCountTemplate.replaceAll(
        '{count}',
        displayedCount.toString(),
      ),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );
  }

  Widget _buildErrorState(
    BuildContext context, {
    required AppError error,
    required CreativeSpacesViewModel viewModel,
  }) {
    if (error.actionText != null && error.action != null) {
      return ErrorView(error: error);
    }

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        ErrorView(error: error),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: viewModel.retry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required CreativeSpacesViewModel viewModel,
    required bool hasActiveFilters,
  }) {
    final title = hasActiveFilters
        ? CreativeSpacesConstants.noSpacesWithFiltersTitle
        : CreativeSpacesConstants.noSpacesTitle;
    final subtitle = hasActiveFilters
        ? CreativeSpacesConstants.noSpacesWithFiltersSubtitle
        : CreativeSpacesConstants.noSpacesSubtitle;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44),
      child: Column(
        children: [
          Icon(
            Icons.palette_outlined,
            size: 52,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          if (hasActiveFilters) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _clearFilters(viewModel),
              icon: const Icon(Icons.clear_all_rounded),
              label: const Text(CreativeSpacesConstants.clearFiltersLabel),
            ),
          ],
        ],
      ),
    );
  }
}
