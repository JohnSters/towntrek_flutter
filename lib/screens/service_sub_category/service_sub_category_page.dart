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
    final totalServices = state.category.serviceCount > 0
        ? state.category.serviceCount
        : state.sortedSubCategories.fold<int>(
            0,
            (sum, subCategory) => sum + subCategory.serviceCount,
          );

    return Column(
      children: [
        PageHeader(
          title: state.category.name,
          subtitle: '${ServiceSubCategoryConstants.subtitlePrefix} ${state.town.name}',
          height: ServiceSubCategoryConstants.pageHeaderHeight,
          headerType: HeaderType.service,
        ),
        _CategoryInfoBar(
          icon: Icons.handyman_rounded,
          text: '$totalServices services \u2022 ${state.category.name}',
          backgroundColor: const Color(0xFFE3F2FD),
          textColor: const Color(0xFF0D47A1),
          borderColor: const Color(0xFFBBDEFB),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      return SubCategoryCard(
                        subCategory: subCategory,
                        countsAvailable: state.countsAvailable,
                        townName: state.town.name,
                        onTap: () => _navigateToServiceList(context, state, subCategory),
                      );
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

class _CategoryInfoBar extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const _CategoryInfoBar({
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}