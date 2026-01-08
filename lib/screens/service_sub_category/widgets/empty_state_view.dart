import 'package:flutter/material.dart';
import '../../../core/constants/service_sub_category_constants.dart';

/// Empty state view when no service sub-categories are found
class ServiceEmptyStateView extends StatelessWidget {
  const ServiceEmptyStateView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category,
            size: ServiceSubCategoryConstants.emptyStateIconSize,
            color: colorScheme.onSurface.withOpacity(
              ServiceSubCategoryConstants.emptyStateIconOpacity,
            ),
          ),
          SizedBox(height: ServiceSubCategoryConstants.emptyStateIconSpacing),
          Text(
            ServiceSubCategoryConstants.noSubCategoriesFound,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(
                ServiceSubCategoryConstants.emptyStateTextOpacity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}