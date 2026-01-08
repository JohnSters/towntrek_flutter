import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../core/widgets/navigation_footer.dart';
import '../../core/widgets/page_header.dart';
import '../service_list_page.dart';
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
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(
              ServiceSubCategoryConstants.contentPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryInfoBadge(
                  subCategoryCount: state.sortedSubCategories.length,
                ),
                const SizedBox(height: ServiceSubCategoryConstants.infoBadgeSpacing),
                if (state.sortedSubCategories.isEmpty)
                  const ServiceEmptyStateView()
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
                        countsAvailable: state.countsAvailable,
                        onTap: () => _navigateToServiceList(context, state, subCategory),
                      );
                    },
                  ),
                const SizedBox(height: ServiceSubCategoryConstants.bottomSpacing),
              ],
            ),
          ),
        ),
      ],
    );
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