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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody(context)),
            const BackNavigationFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        PageHeader(
          title: CreativeSpacesConstants.categoryStylesTemplate.replaceAll(
            '{name}',
            category.name,
          ),
          subtitle: CreativeSpacesConstants.subCategoryHeaderSubtitleTemplate
              .replaceAll('{category}', category.name)
              .replaceAll('{town}', town.name),
          height: CreativeSpacesConstants.pageHeaderHeight,
          headerType: HeaderType.creative,
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(
            CreativeSpacesConstants.pagePadding,
            CreativeSpacesConstants.sectionSpacing,
            CreativeSpacesConstants.pagePadding,
            CreativeSpacesConstants.sectionSpacing,
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: CreativeSpacesConstants.contextStripActionSpacing,
                runSpacing: CreativeSpacesConstants.contextStripActionSpacing,
                children: [
                  _Pill(
                    icon: Icons.style,
                    label: CreativeSpacesConstants.resultsForLabel
                        .replaceAll('{count}', category.spaceCount.toString())
                        .replaceAll('{context}', category.name),
                  ),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.apps_rounded, size: 16),
                    label: const Text(CreativeSpacesConstants.viewAllLabel),
                    onPressed: () => _openList(context, category, null),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      minimumSize: const Size.fromHeight(30),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Pick a creative style to see the spaces that match it.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
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

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: CreativeSpacesConstants.creativePrimary.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: CreativeSpacesConstants.contextStripActionSpacing,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: CreativeSpacesConstants.creativePrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
