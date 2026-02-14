import 'package:flutter/material.dart';
import '../../../core/config/business_category_config.dart';
import '../../../models/models.dart';
import '../../../core/constants/business_sub_category_constants.dart';

/// Widget that displays category information including business count and sub-category count
class CategoryInfoBadge extends StatelessWidget {
  final CategoryWithCountDto category;
  final TownDto town;

  const CategoryInfoBadge({
    super.key,
    required this.category,
    required this.town,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: BusinessSubCategoryConstants.infoBadgeMaxWidth,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: BusinessSubCategoryConstants.infoBadgePaddingHorizontal,
          vertical: BusinessSubCategoryConstants.infoBadgePaddingVertical,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(
            BusinessSubCategoryConstants.infoBadgeBorderRadius,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              BusinessCategoryConfig.getCategoryIcon(category.key),
              size: BusinessSubCategoryConstants.iconSize,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: BusinessSubCategoryConstants.infoBadgeIconSpacing),
            Flexible(
              child: Text(
                '${category.businessCount} ${BusinessSubCategoryConstants.totalBusinessesLabel} ${BusinessSubCategoryConstants.businessCountSeparator} ${category.subCategories.length} ${BusinessSubCategoryConstants.subCategoriesLabel}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                overflow: BusinessSubCategoryConstants.textOverflow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}