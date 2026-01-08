import 'package:flutter/material.dart';
import '../../../core/constants/service_sub_category_constants.dart';
import '../../../models/models.dart';

/// Card widget for displaying service sub-categories
/// Handles disabled state when no services available and navigation logic
class SubCategoryCard extends StatelessWidget {
  final ServiceSubCategoryDto subCategory;
  final bool countsAvailable;
  final VoidCallback? onTap;

  const SubCategoryCard({
    super.key,
    required this.subCategory,
    required this.countsAvailable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDisabled = countsAvailable && subCategory.serviceCount == 0;

    return Card(
      margin: const EdgeInsets.only(
        bottom: ServiceSubCategoryConstants.cardMarginBottom,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ServiceSubCategoryConstants.cardBorderRadius,
        ),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(
            ServiceSubCategoryConstants.cardBorderOpacity,
          ),
        ),
      ),
      child: Opacity(
        opacity: isDisabled ? ServiceSubCategoryConstants.disabledOpacity : 1.0,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(
            ServiceSubCategoryConstants.cardBorderRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ServiceSubCategoryConstants.subCategoryCardPaddingHorizontal,
              vertical: ServiceSubCategoryConstants.subCategoryCardPaddingVertical,
            ),
            child: Row(
              children: [
                Container(
                  width: ServiceSubCategoryConstants.iconContainerSize,
                  height: ServiceSubCategoryConstants.iconContainerSize,
                  decoration: BoxDecoration(
                    color: isDisabled
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(
                      ServiceSubCategoryConstants.iconContainerBorderRadius,
                    ),
                  ),
                  child: Icon(
                    Icons.build,
                    size: ServiceSubCategoryConstants.iconSize,
                    color: isDisabled
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSecondaryContainer,
                  ),
                ),
                SizedBox(width: ServiceSubCategoryConstants.iconSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        subCategory.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: ServiceSubCategoryConstants.titleMediumWeight,
                          color: isDisabled
                              ? colorScheme.onSurface.withOpacity(
                                  ServiceSubCategoryConstants.disabledTextOpacity,
                                )
                              : colorScheme.onSurface,
                        ),
                        maxLines: ServiceSubCategoryConstants.maxTitleLines,
                        overflow: ServiceSubCategoryConstants.textOverflow,
                      ),
                      Text(
                        _getSubtitleText(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: ServiceSubCategoryConstants.maxDescriptionLines,
                        overflow: ServiceSubCategoryConstants.textOverflow,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: ServiceSubCategoryConstants.arrowIconSize,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSubtitleText() {
    final isDisabled = countsAvailable && subCategory.serviceCount == 0;

    if (isDisabled) {
      return ServiceSubCategoryConstants.noServicesAvailable;
    }

    if (countsAvailable) {
      return '${subCategory.serviceCount} ${ServiceSubCategoryConstants.servicesCount}';
    }

    return ServiceSubCategoryConstants.viewServices;
  }
}