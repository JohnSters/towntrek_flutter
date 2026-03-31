import 'package:flutter/material.dart';

import '../../../core/constants/creative_spaces_constants.dart';
import '../../../models/models.dart';

/// Card widget for displaying a Creative Space sub-category
class CreativeSubCategoryCard extends StatelessWidget {
  final CreativeSubCategoryDto subCategory;
  final bool countsAvailable;
  final VoidCallback? onTap;

  const CreativeSubCategoryCard({
    super.key,
    required this.subCategory,
    required this.countsAvailable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDisabled = countsAvailable && subCategory.spaceCount == 0;
    final intro = isDisabled
        ? CreativeSpacesConstants.noSpacesSubCategoryLabel
        : 'Explore spaces in this creative style';

    return OutlinedButton(
      onPressed: isDisabled ? null : onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(14),
        side: BorderSide(
          color: isDisabled
              ? colorScheme.outline.withValues(alpha: 0.2)
              : colorScheme.primary.withValues(alpha: 0.26),
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isDisabled
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerLow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDisabled
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.secondaryContainer.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDisabled
                    ? colorScheme.outline.withValues(alpha: 0.25)
                    : colorScheme.primary.withValues(alpha: 0.16),
              ),
            ),
            child: Icon(
              Icons.palette_rounded,
              size: 22,
              color: isDisabled
                  ? colorScheme.onSurfaceVariant
                  : CreativeSpacesConstants.creativeSecondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subCategory.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDisabled
                        ? colorScheme.onSurface.withValues(alpha: 0.6)
                        : colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${subCategory.spaceCount} spaces',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isDisabled
                        ? colorScheme.onSurfaceVariant
                        : CreativeSpacesConstants.creativeSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  intro,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isDisabled
                ? colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                : CreativeSpacesConstants.creativeSecondary,
          ),
        ],
      ),
    );
  }
}
