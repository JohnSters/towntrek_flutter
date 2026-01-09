import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../core/core.dart';
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
      body: Column(
        children: [
          Expanded(
            child: _buildContent(),
          ),
          const BackNavigationFooter(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<BusinessSubCategoryViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;

        if (state is BusinessSubCategoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BusinessSubCategoryError) {
          return Center(
            child: Text(
              state.message,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        if (state is BusinessSubCategorySuccess) {
          return _buildSubCategoriesView(context, state);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildSubCategoriesView(
    BuildContext context,
    BusinessSubCategorySuccess state,
  ) {
    return Column(
      children: [
        PageHeader(
          title: state.category.name,
          subtitle: '${BusinessSubCategoryConstants.subtitlePrefix} ${state.town.name}',
          height: BusinessSubCategoryConstants.pageHeaderHeight,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(
              BusinessSubCategoryConstants.contentPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryInfoBadge(
                  category: state.category,
                  town: state.town,
                ),
                const SizedBox(height: BusinessSubCategoryConstants.infoBadgeSpacing),
                if (state.sortedSubCategories.isEmpty)
                  _buildEmptyState()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: state.sortedSubCategories.length,
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