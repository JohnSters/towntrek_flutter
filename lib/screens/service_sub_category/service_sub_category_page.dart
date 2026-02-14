import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../core/widgets/navigation_footer.dart';
import '../../core/widgets/page_header.dart';
import '../service_list/service_list_page.dart';
import '../../core/constants/service_sub_category_constants.dart';
import 'service_sub_category_state.dart';
import 'service_sub_category_view_model.dart';
import 'widgets/widgets.dart';

/// Service Sub-Category Page - Shows available service sub-categories for a category
/// Uses Provider pattern with ViewModel and sealed classes for clean architecture
class ServiceSubCategoryPage extends StatelessWidget {
  final ServiceCategoryDto category;
  final TownDto town;
  final bool countsAvailable;

  const ServiceSubCategoryPage({
    super.key,
    required this.category,
    required this.town,
    this.countsAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiceSubCategoryViewModel(
        category: category,
        town: town,
        countsAvailable: countsAvailable,
      ),
      child: const _ServiceSubCategoryPageContent(),
    );
  }
}

class _ServiceSubCategoryPageContent extends StatelessWidget {
  const _ServiceSubCategoryPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildContent(),
            ),
            const BackNavigationFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<ServiceSubCategoryViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;

        if (state is ServiceSubCategoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ServiceSubCategoryError) {
          return Center(
            child: Text(
              state.message,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        if (state is ServiceSubCategorySuccess) {
          return _buildSubCategoriesView(context, state);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildSubCategoriesView(
    BuildContext context,
    ServiceSubCategorySuccess state,
  ) {
    return Column(
      children: [
        PageHeader(
          title: state.category.name,
          subtitle: '${ServiceSubCategoryConstants.subtitlePrefix} ${state.town.name}',
          height: ServiceSubCategoryConstants.pageHeaderHeight,
          headerType: HeaderType.service,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryInfoBadge(
                  subCategoryCount: state.sortedSubCategories.length,
                ),
                const SizedBox(height: 16),
                if (state.sortedSubCategories.isEmpty)
                  const ServiceEmptyStateView()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.sortedSubCategories.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final subCategory = state.sortedSubCategories[index];
                      return _buildSubCategoryCard(context, subCategory, state.countsAvailable, state);
                    },
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategoryCard(
    BuildContext context,
    ServiceSubCategoryDto subCategory,
    bool countsAvailable,
    ServiceSubCategorySuccess state,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDisabled = countsAvailable && subCategory.serviceCount == 0;

    return OutlinedButton(
      onPressed: isDisabled ? null : () => _navigateToServiceList(context, state, subCategory),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        side: BorderSide(
          color: isDisabled
              ? colorScheme.outline.withValues(alpha: 0.2)
              : colorScheme.primary.withValues(alpha: 0.25),
          width: 1.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: isDisabled
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.1)
            : colorScheme.primary.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDisabled
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.build,
              size: 24,
              color: isDisabled
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subCategory.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDisabled
                        ? colorScheme.onSurface.withValues(alpha: 0.6)
                        : colorScheme.onSurface,
                  ),
                ),
                Text(
                  _getSubCategorySubtitle(subCategory, countsAvailable, isDisabled),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isDisabled
                ? colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                : colorScheme.primary.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }

  String _getSubCategorySubtitle(ServiceSubCategoryDto subCategory, bool countsAvailable, bool isDisabled) {
    if (isDisabled) {
      return 'No services available';
    }

    if (countsAvailable) {
      return '${subCategory.serviceCount} services';
    }

    return 'View services';
  }

  void _navigateToServiceList(
    BuildContext context,
    ServiceSubCategorySuccess state,
    ServiceSubCategoryDto subCategory,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceListPage(
          category: state.category,
          subCategory: subCategory,
          town: state.town,
        ),
      ),
    );
  }
}