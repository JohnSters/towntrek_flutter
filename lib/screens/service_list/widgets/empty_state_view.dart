import 'package:flutter/material.dart';
import '../../../core/widgets/page_header.dart';
import '../../../models/models.dart';
import '../../../core/constants/service_list_constants.dart';

/// Empty state view for service list page when no services are found
class ServiceListEmptyStateView extends StatelessWidget {
  final ServiceCategoryDto category;
  final ServiceSubCategoryDto subCategory;
  final TownDto town;

  const ServiceListEmptyStateView({
    super.key,
    required this.category,
    required this.subCategory,
    required this.town,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        PageHeader(
          title: subCategory.name,
          subtitle: '${category.name} in ${town.name}',
          height: ServiceListConstants.pageHeaderHeight,
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  ServiceListConstants.emptyIcon,
                  size: ServiceListConstants.errorIconSize,
                  color: colorScheme.onSurface.withOpacity(
                    ServiceListConstants.emptyStateIconOpacity,
                  ),
                ),
                SizedBox(height: ServiceListConstants.errorSpacing),
                Text(
                  ServiceListConstants.emptyStateTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(
                      ServiceListConstants.emptyStateTextOpacity,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ServiceListConstants.errorSpacing * 0.5),
                Text(
                  ServiceListConstants.emptyStateMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}