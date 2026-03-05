import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import 'creative_spaces_state.dart';
import 'creative_spaces_view_model.dart';
import 'widgets/creative_category_card.dart';
import 'creative_spaces_list_page.dart';
import 'creative_spaces_sub_category_page.dart';

class CreativeSpacesCategoryPage extends StatelessWidget {
  static const String routeName = CreativeSpacesNavigation.categoryRouteName;

  final TownDto town;

  const CreativeSpacesCategoryPage({
    super.key,
    required this.town,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreativeSpacesViewModel(
        creativeSpaceRepository: serviceLocator.creativeSpaceRepository,
        errorHandler: serviceLocator.errorHandler,
        townId: town.id,
      ),
      child: _CreativeSpacesCategoryPageContent(town: town),
    );
  }
}

class _CreativeSpacesCategoryPageContent extends StatelessWidget {
  final TownDto town;

  const _CreativeSpacesCategoryPageContent({
    required this.town,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<CreativeSpacesViewModel>(
                builder: (context, viewModel, child) {
                  final state = viewModel.state;

                  if (state is CreativeSpacesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CreativeSpacesError) {
                    return _buildErrorState(
                      context,
                      error: state.error,
                      viewModel: viewModel,
                    );
                  }

                  if (state is! CreativeSpacesSuccess && state is! CreativeSpacesLoadingMore) {
                    return const SizedBox.shrink();
                  }

                  final categories = state.categories;
                  final countsAvailable = viewModel.countsAvailable;

                  return RefreshIndicator(
                    onRefresh: viewModel.refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        PageHeader(
                          title: '${TownFeatureConstants.creativeSpacesTitle} in ${town.name}',
                          subtitle: CreativeSpacesConstants.categoryHeaderHint,
                          height: CreativeSpacesConstants.pageHeaderHeight,
                          headerType: HeaderType.creative,
                        ),
                        _buildFlavorBanner(context),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            CreativeSpacesConstants.pagePadding,
                            CreativeSpacesConstants.sectionSpacing,
                            CreativeSpacesConstants.pagePadding,
                            CreativeSpacesConstants.sectionSpacing,
                          ),
                          child: categories.isEmpty
                              ? _buildEmptyState(context)
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: categories.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
                                  itemBuilder: (context, index) {
                                    final category = categories[index];
                                    return CreativeCategoryCard(
                                      category: category,
                                      countsAvailable: countsAvailable,
                                      onTap: () => _openCategory(context, category, countsAvailable),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const BackNavigationFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildFlavorBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        CreativeSpacesConstants.pagePadding,
        CreativeSpacesConstants.sectionSpacing,
        CreativeSpacesConstants.pagePadding,
        0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CreativeSpacesConstants.creativeTint,
            CreativeSpacesConstants.creativeHighlight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CreativeSpacesConstants.creativePrimary.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: CreativeSpacesConstants.creativePrimary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              CreativeSpacesConstants.categoryHeader,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.2,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 28),
        Icon(
          Icons.category_outlined,
          size: 58,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(
          CreativeSpacesConstants.categoryUnavailableTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          CreativeSpacesConstants.categoryUnavailableSubtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.2,
              ),
        ),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context, {
    required AppError error,
    required CreativeSpacesViewModel viewModel,
  }) {
    if (error.actionText != null && error.action != null) {
      return ErrorView(error: error);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ErrorView(error: error),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: viewModel.retry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text(CreativeSpacesConstants.retryLabel),
        ),
      ],
    );
  }

  void _openCategory(
    BuildContext context,
    CreativeCategoryDto category,
    bool countsAvailable,
  ) {
    if (category.subCategories.isEmpty) {
      CreativeSpacesNavigation.pushListPage(
        context,
        pageBuilder: (_) => CreativeSpacesListPage(
          town: town,
          category: category,
        ),
      );
      return;
    }

    CreativeSpacesNavigation.pushSubCategoryPage(
      context,
      pageBuilder: (_) => CreativeSpacesSubCategoryPage(
        town: town,
        category: category,
        countsAvailable: countsAvailable,
      ),
    );
  }
}
