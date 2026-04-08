import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import 'creative_spaces_list_page.dart';
import 'widgets/creative_sub_category_card.dart';

class CreativeSpacesSubCategoryPage extends StatelessWidget {
  final TownDto town;
  final CreativeCategoryDto category;
  final bool countsAvailable;

  const CreativeSpacesSubCategoryPage({
    super.key,
    required this.town,
    required this.category,
    this.countsAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.entityListing.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody(context)),
            const ListingBackFooter(label: 'Back'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        EntityListingHeroHeader(
          theme: context.entityListingTheme,
          categoryIcon: Icons.palette_rounded,
          subCategoryName: CreativeSpacesConstants.categoryStylesTemplate
              .replaceAll('{name}', category.name),
          categoryName: TownFeatureConstants.creativeSpacesTitle,
          townName: town.name,
        ),
        ListingResultsBand(
          count: category.spaceCount,
          categoryName: category.name,
          bandColor: context.entityListingTheme.resultsBand,
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (category.subCategories.isEmpty) {
      return _buildNoSubCategories(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        CreativeSpacesConstants.pagePadding,
        0,
        CreativeSpacesConstants.pagePadding,
        CreativeSpacesConstants.sectionSpacing,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: category.subCategories.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: CreativeSpacesConstants.cardSpacing),
        itemBuilder: (context, index) {
          final subCategory = category.subCategories[index];
          return CreativeSubCategoryCard(
            subCategory: subCategory,
            countsAvailable: countsAvailable,
            onTap: () => _openList(context, category, subCategory),
          );
        },
      ),
    );
  }

  Widget _buildNoSubCategories(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CreativeSpacesConstants.pagePadding,
          vertical: 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.format_paint_outlined,
              size: 54,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              CreativeSpacesConstants.noSubCategoriesFound,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              CreativeSpacesConstants.noSubCategoryFallbackMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _openList(context, category, null),
              icon: const Icon(Icons.view_list_rounded),
              label: Text(
                CreativeSpacesConstants.allInContextLabelTemplate
                    .replaceAll(
                      '{label}',
                      CreativeSpacesConstants.allSpacesLabel,
                    )
                    .replaceAll('{context}', category.name),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openList(
    BuildContext context,
    CreativeCategoryDto category,
    CreativeSubCategoryDto? subCategory,
  ) {
    CreativeSpacesNavigation.pushListPage(
      context,
      pageBuilder: (_) => CreativeSpacesListPage(
        town: town,
        category: category,
        subCategory: subCategory,
      ),
    );
  }
}
