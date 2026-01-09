import 'package:flutter/material.dart';
import '../../../core/constants/business_category_constants.dart';
import '../../../models/models.dart';
import '../../../core/config/business_category_config.dart';

/// Card widget for displaying business categories using Material 3 OutlinedButton pattern
/// Matches the design of ServiceCategoryCard for consistency
class BusinessCategoryCard extends StatelessWidget {
  final CategoryWithCountDto category;
  final VoidCallback? onTap;

  const BusinessCategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDisabled = category.businessCount == 0;

    return OutlinedButton(
      onPressed: isDisabled ? null : onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        side: BorderSide(
          color: isDisabled
              ? colorScheme.outline.withValues(alpha: 0.2) // Disabled: 20% opacity
              : colorScheme.primary.withValues(alpha: 0.25), // Enabled: 25% opacity
          width: 1.0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isDisabled
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.1) // Disabled: 10%
            : colorScheme.primary.withValues(alpha: 0.05), // Enabled: 5%
      ),
      child: Row(
        children: [
          // Icon container (48x48)
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
              BusinessCategoryConfig.getCategoryIcon(category.key),
              size: 24,
              color: isDisabled
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          // Content column
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
          // Chevron
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
    if (category.businessCount == 0) {
      return BusinessCategoryConstants.noBusinessesText;
    }

    return '${category.businessCount} ${category.businessCount == 1 ? 'business' : 'businesses'}';
  }
}