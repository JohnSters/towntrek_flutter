import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../town_selection_screen.dart';
import '../town_feature_selection_screen.dart';
import '../service_sub_category_page.dart';
import '../../core/constants/service_category_constants.dart';
import 'service_category_state.dart';
import 'service_category_view_model.dart';
import 'widgets/widgets.dart';

/// Service Category Page - Shows available service categories for a town
/// Uses Provider pattern with ViewModel and sealed classes for clean architecture
class ServiceCategoryPage extends StatelessWidget {
  final TownDto town;

  const ServiceCategoryPage({
    super.key,
    required this.town,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiceCategoryViewModel(
        town: town,
        serviceRepository: serviceLocator.serviceRepository,
        errorHandler: serviceLocator.errorHandler,
      ),
      child: const _ServiceCategoryPageContent(),
    );
  }
}

class _ServiceCategoryPageContent extends StatelessWidget {
  const _ServiceCategoryPageContent();

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
    return Consumer<ServiceCategoryViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;

        if (state is ServiceCategoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ServiceCategoryError) {
          return ErrorView(error: state.error);
        }

        if (state is ServiceCategorySuccess) {
          return _buildCategoriesView(context, state);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildCategoriesView(
    BuildContext context,
    ServiceCategorySuccess state,
  ) {
    final viewModel = context.read<ServiceCategoryViewModel>();

    return Column(
      children: [
        PageHeader(
          title: viewModel.town.name,
          subtitle: '${viewModel.town.province} • ${ServiceCategoryConstants.servicesSubtitle}',
          height: ServiceCategoryConstants.pageHeaderHeight,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(ServiceCategoryConstants.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActionButtons(context),
                const SizedBox(height: ServiceCategoryConstants.actionButtonSpacing),
                if (state.categories.isEmpty)
                  const EmptyStateView()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.categories.length,
                    separatorBuilder: (context, index) => const SizedBox(
                      height: ServiceCategoryConstants.cardSpacing,
                    ),
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      return CategoryCard(
                        category: category,
                        countsAvailable: state.countsAvailable,
                        onTap: () => _navigateToSubCategories(context, category, state.countsAvailable),
                      );
                    },
                  ),
                const SizedBox(height: ServiceCategoryConstants.contentBottomSpacing),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CategoryActionButton(
            icon: ServiceCategoryConstants.changeTownIcon,
            label: ServiceCategoryConstants.changeTownLabel,
            onTap: () => _changeTown(context),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: ServiceCategoryConstants.actionButtonSpacing),
        const Expanded(
          child: SizedBox(), // Placeholder for Events or other action
        ),
      ],
    );
  }

  void _navigateToSubCategories(
    BuildContext context,
    ServiceCategoryDto category,
    bool countsAvailable,
  ) {
    final viewModel = context.read<ServiceCategoryViewModel>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceSubCategoryPage(
          category: category,
          town: viewModel.town,
          countsAvailable: countsAvailable,
        ),
      ),
    );
  }

  void _changeTown(BuildContext context) {
    Navigator.of(context).push<TownDto>(
      MaterialPageRoute(
        builder: (context) => const TownSelectionScreen(),
      ),
    ).then((selectedTown) {
      if (selectedTown != null && context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TownFeatureSelectionScreen(town: selectedTown),
          ),
        );
      }
    });
  }
}