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

  const CreativeSpacesCategoryPage({super.key, required this.town});

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

  const _CreativeSpacesCategoryPageContent({required this.town});

  static const EntityListingTheme _theme = EntityListingTheme.business;

  Widget _browseHero() {
    return EntityListingHeroHeader(
      theme: _theme,
      categoryIcon: Icons.palette_rounded,
      subCategoryName: TownFeatureConstants.creativeSpacesTitle,
      categoryName: town.name,
      townName: town.province,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EntityListingTheme.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<CreativeSpacesViewModel>(
                builder: (context, viewModel, child) {
                  final state = viewModel.state;

                  if (state is CreativeSpacesLoading) {
                    return Column(
                      children: [
                        _browseHero(),
                        ListingResultsBand(
                          count: 0,
                          categoryName: town.name,
                          bandColor: _theme.resultsBand,
                        ),
                        const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ],
                    );
                  }

                  if (state is CreativeSpacesError) {
                    return _buildErrorState(
                      context,
                      error: state.error,
                      viewModel: viewModel,
                    );
                  }

                  if (state is! CreativeSpacesSuccess &&
                      state is! CreativeSpacesLoadingMore) {
                    return const SizedBox.shrink();
                  }

                  final categories = state.categories;
                  final countsAvailable = viewModel.countsAvailable;

                  return Column(
                    children: [
                      _browseHero(),
                      ListingResultsBand(
                        count: categories.length,
                        categoryName: town.name,
                        bandColor: _theme.resultsBand,
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: viewModel.refresh,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                              CreativeSpacesConstants.pagePadding,
                              CreativeSpacesConstants.sectionSpacing,
                              CreativeSpacesConstants.pagePadding,
                              CreativeSpacesConstants.sectionSpacing,
                            ),
                            children: [
                              _buildFlavorBanner(context),
                              if (categories.isEmpty)
                                _buildEmptyState(context)
                              else
                                ..._categoryCards(
                                  context,
                                  categories,
                                  countsAvailable,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const ListingBackFooter(label: 'Back'),
          ],
        ),
      ),
    );
  }

  List<Widget> _categoryCards(
    BuildContext context,
    List<CreativeCategoryDto> categories,
    bool countsAvailable,
  ) {
    final out = <Widget>[];
    for (var i = 0; i < categories.length; i++) {
      if (i > 0) {
        out.add(
          const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
        );
      }
      final category = categories[i];
      out.add(
        CreativeCategoryCard(
          category: category,
          countsAvailable: countsAvailable,
          onTap: () => _openCategory(
            context,
            category,
            countsAvailable,
          ),
        ),
      );
    }
    return out;
  }

  Widget _buildFlavorBanner(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
            colorScheme.primaryContainer.withValues(alpha: 0.7),
            colorScheme.secondaryContainer.withValues(alpha: 0.45),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: CreativeSpacesConstants.creativePrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CreativeSpacesConstants.categoryHeader,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  CreativeSpacesConstants.categoryHeaderHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
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
    Widget chrome({required Widget child}) {
      return Column(
        children: [
          _browseHero(),
          ListingResultsBand(
            count: 0,
            categoryName: town.name,
            bandColor: _CreativeSpacesCategoryPageContent._theme.resultsBand,
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
      ),
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
        pageBuilder: (_) =>
            CreativeSpacesListPage(town: town, category: category),
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
