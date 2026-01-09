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

    return OutlinedButton(
      onPressed: isDisabled ? null : onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        side: BorderSide(
          color: isDisabled
              ? colorScheme.outline.withValues(alpha: 0.2)
              : colorScheme.primary.withValues(alpha: 0.25),
          width: 1.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: isDisabled
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.1)
            : colorScheme.primary.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDisabled
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.build,
              size: 24,
              color: isDisabled
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDisabled
                        ? colorScheme.onSurface.withValues(alpha: 0.6)
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
            Icons.chevron_right,
            color: isDisabled
                ? colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                : colorScheme.primary.withValues(alpha: 0.6),
          ),
        ],
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