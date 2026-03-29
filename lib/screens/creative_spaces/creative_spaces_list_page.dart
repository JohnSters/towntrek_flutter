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

  static const EntityListingTheme _theme = EntityListingTheme.creativeSpaces;
  static const String _heroCategoryName = 'Creative Spaces';

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

  String get _titleName =>
      widget.subCategory?.name ?? widget.category.name;

  String get _resultsBandLabel => _titleName;

  Widget _hero() {
    return EntityListingHeroHeader(
      theme: CreativeSpacesListPage._theme,
      categoryIcon: Icons.palette_rounded,
      subCategoryName: _titleName,
      categoryName: CreativeSpacesListPage._heroCategoryName,
      townName: widget.town.name,
    );
  }

  Widget _band(int count) {
    return ListingResultsBand(
      count: count,
      categoryName: _resultsBandLabel,
      bandColor: CreativeSpacesListPage._theme.resultsBand,
    );
  }

  Widget _searchBar(CreativeSpacesViewModel viewModel) {
    return EntityListingSearchBar(
      controller: _searchController,
      theme: CreativeSpacesListPage._theme,
      hintText: CreativeSpacesConstants.searchHint,
      onSubmitted: () => _submitSearch(viewModel),
      onClear: () => _clearSearch(viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EntityListingTheme.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<CreativeSpacesViewModel>(
                builder: (context, viewModel, child) {
                  final state = viewModel.state;

                  if (state is CreativeSpacesLoading) {
                    return Column(
                      children: [
                        _hero(),
                        _band(0),
                        Padding(
                          padding: EntityListingConstants.searchBarSectionPadding,
                          child: _searchBar(viewModel),
                        ),
                        const Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 12),
                                Text(CreativeSpacesConstants.loadingSpacesText),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  if (state is CreativeSpacesError) {
                    return _buildError(context, viewModel, state.error);
                  }

                  if (state is! CreativeSpacesSuccess &&
                      state is! CreativeSpacesLoadingMore) {
                    return const SizedBox.shrink();
                  }

                  final isLoadingMore = state is CreativeSpacesLoadingMore;
                  final spaces = state.spaces;
                  final hasNextPage = state.hasNextPage;
                  final totalItemCount = state.totalItemCount;

                  return Column(
                    children: [
                      _hero(),
                      _band(totalItemCount),
                      Padding(
                        padding: EntityListingConstants.searchBarSectionPadding,
                        child: _searchBar(viewModel),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: viewModel.refresh,
                          child: spaces.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EntityListingConstants
                                      .cardListScrollPadding,
                                  children: [
                                    _buildEmptyState(context, viewModel),
                                  ],
                                )
                              : ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EntityListingConstants
                                      .cardListScrollPadding,
                                  itemCount:
                                      spaces.length + (hasNextPage ? 1 : 0),
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    if (index == spaces.length) {
                                      if (isLoadingMore) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 18,
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: OutlinedButton.icon(
                                          onPressed: viewModel.loadMore,
                                          icon: const Icon(
                                            Icons.expand_more_rounded,
                                          ),
                                          label: const Text(
                                            CreativeSpacesConstants
                                                .loadMoreSpacesLabel,
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            minimumSize:
                                                const Size.fromHeight(44),
                                            side: BorderSide(
                                              color: CreativeSpacesListPage
                                                  ._theme.accent
                                                  .withValues(alpha: 0.35),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return CreativeSpaceCard(
                                      space: spaces[index],
                                      listingTheme:
                                          CreativeSpacesListPage._theme,
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const ListingBackFooter(label: 'Back to spaces'),
          ],
        ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    CreativeSpacesViewModel viewModel,
    AppError error,
  ) {
    if (error.actionText != null && error.action != null) {
      return Column(
        children: [
          _hero(),
          _band(0),
          Padding(
            padding: EntityListingConstants.searchBarSectionPadding,
            child: _searchBar(viewModel),
          ),
          Expanded(child: ErrorView(error: error)),
        ],
      );
    }

    return Column(
      children: [
        _hero(),
        _band(0),
        Padding(
          padding: EntityListingConstants.searchBarSectionPadding,
          child: _searchBar(viewModel),
        ),
        Expanded(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EntityListingConstants.cardListScrollPadding,
            children: [
              ErrorView(error: error),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: viewModel.retry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(CreativeSpacesConstants.retryLabel),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    CreativeSpacesViewModel viewModel,
  ) {
    final hasSearch = _searchController.text.trim().isNotEmpty;
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
              label: const Text(EntityListingConstants.clearSearchLabel),
            ),
        ],
      ),
    );
  }
}
