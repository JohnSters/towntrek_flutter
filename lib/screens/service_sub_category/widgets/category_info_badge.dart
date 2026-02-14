import 'package:flutter/material.dart';
import '../../../core/constants/service_sub_category_constants.dart';

/// Badge displaying category information (number of sub-categories)
class CategoryInfoBadge extends StatelessWidget {
  final int subCategoryCount;

  const CategoryInfoBadge({
    super.key,
    required this.subCategoryCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: ServiceSubCategoryConstants.infoBadgeMaxWidth,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ServiceSubCategoryConstants.infoBadgePaddingHorizontal,
          vertical: ServiceSubCategoryConstants.infoBadgePaddingVertical,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(
            ServiceSubCategoryConstants.infoBadgeBorderRadius,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.build,
              size: ServiceSubCategoryConstants.infoBadgeIconSize,
              color: colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: ServiceSubCategoryConstants.infoBadgeIconSpacing),
            Flexible(
              child: Text(
                '$subCategoryCount ${ServiceSubCategoryConstants.subCategoriesLabel}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                overflow: ServiceSubCategoryConstants.textOverflow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}