import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../core/core.dart';
import '../service_list/service_list_page.dart';
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

  static const EntityListingTheme _theme = EntityListingTheme.business;

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

  Widget _buildHero(ServiceSubCategoryViewModel viewModel) {
    return EntityListingHeroHeader(
      theme: ServiceSubCategoryPage._theme,
      categoryIcon: Icons.handyman_rounded,
      subCategoryName: viewModel.category.name,
      categoryName: TownFeatureConstants.servicesTitle,
      townName: viewModel.town.name,
    );
  }

  Widget _buildBand(ServiceSubCategoryViewModel viewModel, int serviceCount) {
    return ListingResultsBand(
      count: serviceCount,
      categoryName: viewModel.category.name,
      bandColor: ServiceSubCategoryPage._theme.resultsBand,
    );
  }

  int _serviceCountForBand(ServiceSubCategoryViewModel viewModel) {
    final c = viewModel.category;
    if (c.serviceCount > 0) return c.serviceCount;
    return c.subCategories.fold<int>(0, (sum, s) => sum + s.serviceCount);
  }

  Widget _buildContent() {
    return Consumer<ServiceSubCategoryViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;

        if (state is ServiceSubCategoryLoading) {
          return Column(
            children: [
              _buildHero(viewModel),
              _buildBand(viewModel, _serviceCountForBand(viewModel)),
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        }

        if (state is ServiceSubCategoryError) {
          return _buildErrorState(
            context,
            error: state.error,
            viewModel: viewModel,
          );
        }

        if (state is ServiceSubCategorySuccess) {
          return _buildSubCategoriesView(context, state);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildErrorState(
    BuildContext context, {
    required AppError error,
    required ServiceSubCategoryViewModel viewModel,
  }) {
    final count = _serviceCountForBand(viewModel);
    if (error.actionText != null && error.action != null) {
      return Column(
        children: [
          _buildHero(viewModel),
          _buildBand(viewModel, count),
          Expanded(child: ErrorView(error: error)),
        ],
      );
    }

    return Column(
      children: [
        _buildHero(viewModel),
        _buildBand(viewModel, count),
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
        EntityListingHeroHeader(
          theme: ServiceSubCategoryPage._theme,
          categoryIcon: Icons.handyman_rounded,
          subCategoryName: state.category.name,
          categoryName: TownFeatureConstants.servicesTitle,
          townName: state.town.name,
        ),
        ListingResultsBand(
          count: totalServices,
          categoryName: state.category.name,
          bandColor: ServiceSubCategoryPage._theme.resultsBand,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
