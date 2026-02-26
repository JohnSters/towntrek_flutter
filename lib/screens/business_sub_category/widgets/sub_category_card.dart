import 'package:flutter/material.dart';
import '../../../core/config/business_category_config.dart';
import '../../../models/models.dart';
import '../../business_card/business_card.dart';
import '../../../core/constants/business_sub_category_constants.dart';

/// Card widget for displaying a sub-category with navigation functionality
class SubCategoryCard extends StatelessWidget {
  final SubCategoryWithCountDto subCategory;
  final CategoryWithCountDto category;
  final TownDto town;

  const SubCategoryCard({
    super.key,
    required this.subCategory,
    required this.category,
    required this.town,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDisabled = subCategory.businessCount == 0;
    final intro = 'Explore ${subCategory.name} businesses in ${town.name}';

    return OutlinedButton(
      onPressed: isDisabled ? null : () => _navigateToBusinessCardPage(context),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(14),
        side: BorderSide(
          color: isDisabled
              ? colorScheme.outline.withValues(alpha: 0.2)
              : colorScheme.primary.withValues(alpha: 0.25),
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: isDisabled
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.1)
            : colorScheme.primary.withValues(alpha: 0.02),
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
                  : colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              BusinessCategoryConfig.getCategoryIcon(category.key),
              size: 22,
              color: isDisabled
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSecondaryContainer,
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
                  subCategory.businessCount == 0
                      ? BusinessSubCategoryConstants.noBusinessesYet
                      : '${subCategory.businessCount} ${BusinessSubCategoryConstants.businessesLabel}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  intro,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isDisabled
                ? colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                : colorScheme.primary.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }

  void _navigateToBusinessCardPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BusinessCardPage(
          category: category,
          subCategory: subCategory,
          town: town,
        ),
      ),
    );
  }
}