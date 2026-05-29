import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../core/utils/business_category_copy.dart';
import '../../models/models.dart';
import 'business_card_state.dart';
import 'business_card_view_model.dart';
import 'widgets/widgets.dart';

/// Page for displaying businesses in a beautiful card layout for a selected sub-category
class BusinessCardPage extends StatelessWidget {
  final CategoryWithCountDto category;
  final SubCategoryWithCountDto subCategory;
  final TownDto town;

  const BusinessCardPage({
    super.key,
    required this.category,
    required this.subCategory,
    required this.town,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BusinessCardViewModel(
        category: category,
        subCategory: subCategory,
        town: town,
        businessRepository: serviceLocator.businessRepository,
        errorHandler: serviceLocator.errorHandler,
      ),
      child: const _BusinessCardPageContent(),
    );
  }
}

class _BusinessCardPageContent extends StatefulWidget {
  const _BusinessCardPageContent();

  @override
  State<_BusinessCardPageContent> createState() =>
      _BusinessCardPageContentState();
}

class _BusinessCardPageContentState extends State<_BusinessCardPageContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(BusinessCardViewModel viewModel) {
    viewModel.search(_searchController.text);
  }

  void _clearSearch(BusinessCardViewModel viewModel) {
    _searchController.clear();
    viewModel.search(null);
  }

  Widget _searchBar(
    BusinessCardViewModel viewModel,
    EntityListingTheme listingTheme,
  ) {
    return EntityListingSearchBar(
      controller: _searchController,
      theme: listingTheme,
      hintText: BusinessCardConstants.searchHint,
      onSubmitted: () => _submitSearch(viewModel),
      onClear: () => _clearSearch(viewModel),
    );
  }

  Widget _searchPadding(Widget child) {
    return Padding(
      padding: EntityListingConstants.searchBarSectionPadding,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BusinessCardViewModel>();
    final listingTheme =
        BusinessCategoryCopy.listingThemeOf(context, viewModel.category.key);
    final backLabel = BusinessCategoryCopy.businessCardBackFooterLabel(
      categoryName: viewModel.category.name,
      categoryKey: viewModel.category.key,
    );

    return Scaffold(
      backgroundColor: context.entityListing.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildContent(context, viewModel, listingTheme),
            ),
            ListingBackFooter(label: backLabel),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    BusinessCardViewModel viewModel,
    EntityListingTheme listingTheme,
  ) {
    final state = viewModel.state;

    if (state is BusinessCardLoading) {
      return BusinessLoadingView(
        category: viewModel.category,
        subCategory: viewModel.subCategory,
        town: viewModel.town,
        listingTheme: listingTheme,
        searchBar: _searchBar(viewModel, listingTheme),
      );
    }

    if (state is BusinessCardError) {
      return _buildErrorState(
        context,
        error: state.error,
        viewModel: viewModel,
        listingTheme: listingTheme,
      );
    }

    if (state is BusinessCardEmpty) {
      return _buildEmptyView(context, viewModel, listingTheme);
    }

    if (state is BusinessCardSuccess) {
      if (state.businesses.isEmpty) {
        return _buildSearchEmptyView(context, viewModel, listingTheme, state);
      }
      return _buildBusinessesView(context, viewModel, state, listingTheme);
    }

    return const SizedBox();
  }

  Widget _buildErrorState(
    BuildContext context, {
    required AppError error,
    required BusinessCardViewModel viewModel,
    required EntityListingTheme listingTheme,
  }) {
    final header = BusinessCardHeroHeader(
      theme: listingTheme,
      subCategoryName: viewModel.subCategory.name,
      categoryName: viewModel.category.name,
      categoryKey: viewModel.category.key,
      townName: viewModel.town.name,
    );

    if (error.actionText != null && error.action != null) {
      return Column(
        children: [
          header,
          ListingResultsBand(
            count: viewModel.bandCount(viewModel.state),
            categoryName: viewModel.subCategory.name,
            bandColor: listingTheme.resultsBand,
          ),
          _searchPadding(_searchBar(viewModel, listingTheme)),
          Expanded(child: ErrorView(error: error)),
        ],
      );
    }

    return Column(
      children: [
        header,
        ListingResultsBand(
          count: viewModel.subCategory.businessCount,
          categoryName: viewModel.subCategory.name,
          bandColor: listingTheme.resultsBand,
        ),
        _searchPadding(_searchBar(viewModel, listingTheme)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              ErrorView(error: error),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: viewModel.loadBusinesses,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyView(
    BuildContext context,
    BusinessCardViewModel viewModel,
    EntityListingTheme listingTheme,
  ) {
    return Column(
      children: [
        BusinessCardHeroHeader(
          theme: listingTheme,
          subCategoryName: viewModel.subCategory.name,
          categoryName: viewModel.category.name,
          categoryKey: viewModel.category.key,
          townName: viewModel.town.name,
        ),
        ListingResultsBand(
          count: viewModel.subCategory.businessCount,
          categoryName: viewModel.subCategory.name,
          bandColor: listingTheme.resultsBand,
        ),
        _searchPadding(_searchBar(viewModel, listingTheme)),
        Expanded(child: BusinessEmptyView(category: viewModel.category)),
      ],
    );
  }

  Widget _buildSearchEmptyView(
    BuildContext context,
    BusinessCardViewModel viewModel,
    EntityListingTheme listingTheme,
    BusinessCardSuccess state,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        BusinessCardHeroHeader(
          theme: listingTheme,
          subCategoryName: viewModel.subCategory.name,
          categoryName: viewModel.category.name,
          categoryKey: viewModel.category.key,
          townName: viewModel.town.name,
        ),
        ListingResultsBand(
          count: state.totalItemCount,
          categoryName: viewModel.subCategory.name,
          bandColor: listingTheme.resultsBand,
        ),
        _searchPadding(_searchBar(viewModel, listingTheme)),
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
                    BusinessCardConstants.emptySearchTitle,
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
                    onPressed: () => _clearSearch(viewModel),
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

  Widget _buildBusinessesView(
    BuildContext context,
    BusinessCardViewModel viewModel,
    BusinessCardSuccess state,
    EntityListingTheme listingTheme,
  ) {
    return Column(
      children: [
        BusinessCardHeroHeader(
          theme: listingTheme,
          subCategoryName: viewModel.subCategory.name,
          categoryName: viewModel.category.name,
          categoryKey: viewModel.category.key,
          townName: viewModel.town.name,
        ),
        ListingResultsBand(
          count: state.totalItemCount,
          categoryName: viewModel.subCategory.name,
          bandColor: listingTheme.resultsBand,
        ),
        _searchPadding(_searchBar(viewModel, listingTheme)),
        Expanded(
          child: _buildBusinessesList(context, viewModel, state, listingTheme),
        ),
      ],
    );
  }

  Widget _buildBusinessesList(
    BuildContext context,
    BusinessCardViewModel viewModel,
    BusinessCardSuccess state,
    EntityListingTheme listingTheme,
  ) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            !state.isLoadingMore &&
            state.hasMorePages) {
          viewModel.loadBusinesses(loadMore: true);
        }
        return false;
      },
      child: ListView.separated(
        padding: EntityListingConstants.cardListScrollPadding,
        itemCount: state.businesses.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == state.businesses.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final business = state.businesses[index];
          return BusinessCardWidget(
            business: business,
            categoryKey: viewModel.category.key,
            listingTheme: listingTheme,
            townName: viewModel.town.name,
            provinceName: viewModel.town.province,
            onTap: () => viewModel.onBusinessTap(context, business),
          );
        },
      ),
    );
  }
}
