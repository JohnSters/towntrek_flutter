import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/business_category_config.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import 'business_sub_category.dart';

/// Page for displaying business sub-categories for a selected category
/// Uses Provider pattern with BusinessSubCategoryViewModel for state management
class BusinessSubCategoryPage extends StatelessWidget {
  final CategoryWithCountDto category;
  final TownDto town;

  const BusinessSubCategoryPage({
    super.key,
    required this.category,
    required this.town,
  });

  static const EntityListingTheme _theme = EntityListingTheme.business;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BusinessSubCategoryViewModel(
        category: category,
        town: town,
      ),
      child: const _BusinessSubCategoryPageContent(),
    );
  }
}

class _BusinessSubCategoryPageContent extends StatelessWidget {
  const _BusinessSubCategoryPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EntityListingTheme.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildContent(),
            ),
            const ListingBackFooter(label: 'Back'),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BusinessSubCategoryViewModel viewModel) {
    return EntityListingHeroHeader(
      theme: BusinessSubCategoryPage._theme,
      categoryIcon: BusinessCategoryConfig.getCategoryIcon(viewModel.category.key),
      subCategoryName: viewModel.category.name,
      categoryName: TownFeatureConstants.businessesTitle,
      townName: viewModel.town.name,
    );
  }

  Widget _buildBand(BusinessSubCategoryViewModel viewModel) {
    return ListingResultsBand(
      count: viewModel.category.businessCount,
      categoryName: viewModel.category.name,
      bandColor: BusinessSubCategoryPage._theme.resultsBand,
    );
  }

  Widget _buildContent() {
    return Consumer<BusinessSubCategoryViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;

        if (state is BusinessSubCategoryLoading) {
          return Column(
            children: [
              _buildHero(viewModel),
              _buildBand(viewModel),
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        }

        if (state is BusinessSubCategoryError) {
          return _buildErrorState(
            context,
            error: state.error,
            viewModel: viewModel,
          );
        }

        if (state is BusinessSubCategorySuccess) {
          return _buildSubCategoriesView(context, state);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildErrorState(
    BuildContext context, {
    required AppError error,
    required BusinessSubCategoryViewModel viewModel,
  }) {
    if (error.actionText != null && error.action != null) {
      return Column(
        children: [
          _buildHero(viewModel),
          _buildBand(viewModel),
          Expanded(child: ErrorView(error: error)),
        ],
      );
    }

    return Column(
      children: [
        _buildHero(viewModel),
        _buildBand(viewModel),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            children: [
              ErrorView(error: error),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: viewModel.retry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategoriesView(
    BuildContext context,
    BusinessSubCategorySuccess state,
  ) {
    return Column(
      children: [
        EntityListingHeroHeader(
          theme: BusinessSubCategoryPage._theme,
          categoryIcon: BusinessCategoryConfig.getCategoryIcon(state.category.key),
          subCategoryName: state.category.name,
          categoryName: TownFeatureConstants.businessesTitle,
          townName: state.town.name,
        ),
        ListingResultsBand(
          count: state.category.businessCount,
          categoryName: state.category.name,
          bandColor: BusinessSubCategoryPage._theme.resultsBand,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              BusinessSubCategoryConstants.contentPadding,
              0,
              BusinessSubCategoryConstants.contentPadding,
              BusinessSubCategoryConstants.contentPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.sortedSubCategories.isEmpty)
                  _buildEmptyState()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.sortedSubCategories.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final subCategory = state.sortedSubCategories[index];
                      return SubCategoryCard(
                        subCategory: subCategory,
                        category: state.category,
                        town: state.town,
                      );
                    },
                  ),
                const SizedBox(height: BusinessSubCategoryConstants.bottomSpacing),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Consumer<BusinessSubCategoryViewModel>(
      builder: (context, viewModel, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.category,
                size: BusinessSubCategoryConstants.emptyStateIconSize,
                color: colorScheme.onSurface.withValues(
                  alpha: BusinessSubCategoryConstants.emptyStateIconOpacity,
                ),
              ),
              SizedBox(height: BusinessSubCategoryConstants.emptyStateIconSpacing),
              Text(
                BusinessSubCategoryConstants.noSubCategoriesFound,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(
                    alpha: BusinessSubCategoryConstants.emptyStateTextOpacity,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
