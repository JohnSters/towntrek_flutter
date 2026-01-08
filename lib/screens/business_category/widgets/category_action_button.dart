import 'package:flutter/material.dart';
import '../../../core/constants/business_category_constants.dart';

/// A reusable action button for category pages
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
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: BusinessCategoryConstants.highAlpha),
      borderRadius: BorderRadius.circular(BusinessCategoryConstants.borderRadiusLarge),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BusinessCategoryConstants.borderRadiusLarge),
        child: Container(
          height: BusinessCategoryConstants.actionButtonHeight,
          padding: EdgeInsets.all(BusinessCategoryConstants.actionButtonPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: BusinessCategoryConstants.actionButtonIconSize, color: color),
              SizedBox(height: BusinessCategoryConstants.tinySpacing),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
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