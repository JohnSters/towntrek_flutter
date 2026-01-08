import 'package:flutter/material.dart';
import '../../../core/constants/service_category_constants.dart';
import '../../../models/models.dart';

/// Card widget for displaying service categories
/// Handles disabled state when no services available and navigation
class CategoryCard extends StatelessWidget {
  final ServiceCategoryDto category;
  final bool countsAvailable;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.countsAvailable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDisabled = countsAvailable && category.serviceCount == 0;

    return Card(
      elevation: ServiceCategoryConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ServiceCategoryConstants.categoryCardBorderRadius,
        ),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(
            ServiceCategoryConstants.outlineOpacity,
          ),
        ),
      ),
      child: Opacity(
        opacity: isDisabled ? ServiceCategoryConstants.disabledOpacity : 1.0,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(
            ServiceCategoryConstants.categoryCardBorderRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ServiceCategoryConstants.categoryCardPaddingHorizontal,
              vertical: ServiceCategoryConstants.categoryCardPaddingVertical,
            ),
            child: Row(
              children: [
                Container(
                  width: ServiceCategoryConstants.categoryIconSize,
                  height: ServiceCategoryConstants.categoryIconSize,
                  decoration: BoxDecoration(
                    color: isDisabled
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(
                      ServiceCategoryConstants.categoryIconBorderRadius,
                    ),
                  ),
                  child: Icon(
                    ServiceCategoryConstants.categoryIcon,
                    size: ServiceCategoryConstants.iconSize,
                    color: isDisabled
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSecondaryContainer,
                  ),
                ),
                SizedBox(width: ServiceCategoryConstants.categoryIconSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: ServiceCategoryConstants.titleMediumWeight,
                          color: isDisabled
                              ? colorScheme.onSurface.withOpacity(
                                  ServiceCategoryConstants.disabledTextOpacity,
                                )
                              : colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        _getSubtitleText(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  ServiceCategoryConstants.chevronRightIcon,
                  color: colorScheme.onSurfaceVariant.withOpacity(
                    ServiceCategoryConstants.chevronOpacity,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSubtitleText() {
    final isDisabled = countsAvailable && category.serviceCount == 0;

    if (isDisabled) {
      return ServiceCategoryConstants.noServicesAvailable;
    }

    if (countsAvailable) {
      return '${category.serviceCount} ${ServiceCategoryConstants.servicesCount}';
    }

    return ServiceCategoryConstants.viewServices;
  }
}