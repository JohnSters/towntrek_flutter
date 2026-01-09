import 'package:flutter/material.dart';
import '../../../core/constants/service_category_constants.dart';

/// Reusable action button for service category page
/// Used for actions like "Change Town" with consistent styling
class CategoryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const CategoryActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: ServiceCategoryConstants.surfaceContainerHighestOpacity,
      ),
      borderRadius: BorderRadius.circular(
        ServiceCategoryConstants.actionButtonBorderRadius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          ServiceCategoryConstants.actionButtonBorderRadius,
        ),
        child: Container(
          height: ServiceCategoryConstants.actionButtonHeight,
          padding: const EdgeInsets.all(
            ServiceCategoryConstants.actionButtonPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: ServiceCategoryConstants.actionIconSize,
                color: color,
              ),
              SizedBox(height: ServiceCategoryConstants.actionButtonTextSpacing),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: ServiceCategoryConstants.actionButtonWeight,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}