import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../town_selection/town_selection_screen.dart';
import '../town_feature_selection/town_feature_selection_screen.dart';
import '../service_sub_category/service_sub_category_page.dart';
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
        eventRepository: serviceLocator.eventRepository,
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

  Widget _buildContent() {
    return Consumer<ServiceCategoryViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;

        if (state is ServiceCategoryLoading) {
          return Column(
            children: [
              EntityListingHeroHeader(
                theme: EntityListingTheme.business,
                categoryIcon: Icons.handyman_rounded,
                subCategoryName: TownFeatureConstants.servicesTitle,
                categoryName: viewModel.town.name,
                townName: viewModel.town.province,
              ),
              ListingResultsBand(
                count: 0,
                categoryName: viewModel.town.name,
                bandColor: EntityListingTheme.business.resultsBand,
              ),
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        }

        if (state is ServiceCategoryError) {
          return _buildErrorState(
            context,
            error: state.error,
            viewModel: viewModel,
          );
        }

        if (state is ServiceCategorySuccess) {
          return _buildCategoriesView(context, state);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildErrorState(
    BuildContext context, {
    required AppError error,
    required ServiceCategoryViewModel viewModel,
  }) {
    Widget chrome({required Widget child}) {
      return Column(
        children: [
          EntityListingHeroHeader(
            theme: EntityListingTheme.business,
            categoryIcon: Icons.handyman_rounded,
            subCategoryName: TownFeatureConstants.servicesTitle,
            categoryName: viewModel.town.name,
            townName: viewModel.town.province,
          ),
          ListingResultsBand(
            count: 0,
            categoryName: viewModel.town.name,
            bandColor: EntityListingTheme.business.resultsBand,
          ),
          Expanded(child: child),
        ],
      );
    }

    if (error.actionText != null && error.action != null) {
      return chrome(child: ErrorView(error: error));
    }

    return chrome(
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
    );
  }

  Widget _buildCategoriesView(
    BuildContext context,
    ServiceCategorySuccess state,
  ) {
    final viewModel = context.read<ServiceCategoryViewModel>();

    return Column(
      children: [
        EntityListingHeroHeader(
          theme: EntityListingTheme.business,
          categoryIcon: Icons.handyman_rounded,
          subCategoryName: TownFeatureConstants.servicesTitle,
          categoryName: viewModel.town.name,
          townName: viewModel.town.province,
        ),
        _buildConnectedActionButtons(context, viewModel, state),
        ListingResultsBand(
          count: state.categories.length,
          categoryName: viewModel.town.name,
          bandColor: EntityListingTheme.business.resultsBand,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              ServiceCategoryConstants.pagePadding,
              0,
              ServiceCategoryConstants.pagePadding,
              ServiceCategoryConstants.pagePadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categories grid
                if (state.categories.isEmpty)
                  const EmptyStateView()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.categories.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      return CategoryCard(
                        category: category,
                        countsAvailable: state.countsAvailable,
                        onTap: () => _navigateToSubCategories(context, category, state.countsAvailable),
                      );
                    },
                  ),

                SizedBox(height: ServiceCategoryConstants.contentBottomSpacing),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectedActionButtons(
    BuildContext context,
    ServiceCategoryViewModel viewModel,
    ServiceCategorySuccess state,
  ) {
    final bool hasEvents = state.currentEventCount > 0;

    return SizedBox(
      height: BusinessCategoryConstants.connectedButtonHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Change Town Button - Connected design
          Expanded(
            child: ConnectedWrongTownStripButton(
              onPressed: () => _changeTown(context),
            ),
          ),
          // Events Button - Connected design (no gap between buttons)
          Expanded(
            child: _buildConnectedEventsButton(
              context: context,
              hasEvents: hasEvents,
              eventCount: state.currentEventCount,
              onPressed: hasEvents ? () => viewModel.navigateToEvents(context) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedEventsButton({
    required BuildContext context,
    required bool hasEvents,
    required int eventCount,
    required VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!hasEvents) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.event),
        label: const Text('No Events'),
        style: BusinessCategoryConstants.connectedHeaderButtonStyle(
          theme,
          backgroundColor: colorScheme.surfaceContainerHighest,
          foregroundColor: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return LiveEventsStripButton(
      eventCount: eventCount,
      onPressed: onPressed!,
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