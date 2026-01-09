import 'package:flutter/material.dart';
import '../../../core/constants/service_category_constants.dart';

/// Empty state view when no service categories are found
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            ServiceCategoryConstants.emptyStateIcon,
            size: ServiceCategoryConstants.emptyIconSize,
            color: colorScheme.onSurface.withValues(
              alpha: ServiceCategoryConstants.emptyIconOpacity,
            ),
          ),
          SizedBox(height: ServiceCategoryConstants.emptyStateTextSpacing),
          Text(
            ServiceCategoryConstants.emptyStateTitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(
                alpha: ServiceCategoryConstants.emptyTextOpacity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}