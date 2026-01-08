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

    return Card(
      margin: const EdgeInsets.only(
        bottom: BusinessSubCategoryConstants.cardMarginBottom,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          BusinessSubCategoryConstants.cardBorderRadius,
        ),
        side: BorderSide(
          color: colorScheme.outline.withValues(
            alpha: BusinessSubCategoryConstants.cardBorderOpacity,
          ),
        ),
      ),
      child: Opacity(
        opacity: isDisabled
            ? BusinessSubCategoryConstants.disabledOpacity
            : 1.0,
        child: InkWell(
          onTap: isDisabled ? null : () => _navigateToBusinessCardPage(context),
          borderRadius: BorderRadius.circular(
            BusinessSubCategoryConstants.cardBorderRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BusinessSubCategoryConstants.subCategoryCardPaddingHorizontal,
              vertical: BusinessSubCategoryConstants.subCategoryCardPaddingVertical,
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: BusinessSubCategoryConstants.iconContainerSize,
                  height: BusinessSubCategoryConstants.iconContainerSize,
                  decoration: BoxDecoration(
                    color: BusinessCategoryConfig.getCategoryColor(
                      category.key,
                      colorScheme,
                    ),
                    borderRadius: BorderRadius.circular(
                      BusinessSubCategoryConstants.iconContainerBorderRadius,
                    ),
                  ),
                  child: Icon(
                    BusinessCategoryConfig.getCategoryIcon(category.key),
                    size: BusinessSubCategoryConstants.iconSize,
                    color: BusinessCategoryConfig.getCategoryIconColor(
                      category.key,
                      colorScheme,
                    ),
                  ),
                ),

                const SizedBox(width: BusinessSubCategoryConstants.iconSpacing),

                // Title and Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        subCategory.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDisabled
                              ? colorScheme.onSurface.withValues(
                                  alpha: BusinessSubCategoryConstants.disabledTextOpacity,
                                )
                              : colorScheme.onSurface,
                        ),
                        maxLines: BusinessSubCategoryConstants.maxTitleLines,
                        overflow: BusinessSubCategoryConstants.textOverflow,
                      ),

                      const SizedBox(height: BusinessSubCategoryConstants.titleSpacing),

                      // Description
                      Text(
                        subCategory.businessCount == 0
                            ? BusinessSubCategoryConstants.noBusinessesYet
                            : '${subCategory.businessCount} ${BusinessSubCategoryConstants.businessesLabel}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDisabled
                              ? colorScheme.onSurfaceVariant.withValues(
                                  alpha: BusinessSubCategoryConstants.disabledTextOpacity,
                                )
                              : colorScheme.onSurfaceVariant,
                        ),
                        maxLines: BusinessSubCategoryConstants.maxDescriptionLines,
                        overflow: BusinessSubCategoryConstants.textOverflow,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: BusinessSubCategoryConstants.arrowIconSpacing),

                // Arrow Icon
                Icon(
                  Icons.chevron_right,
                  size: BusinessSubCategoryConstants.arrowIconSize,
                  color: isDisabled
                      ? colorScheme.onSurfaceVariant.withValues(
                          alpha: BusinessSubCategoryConstants.disabledArrowOpacity,
                        )
                      : colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
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