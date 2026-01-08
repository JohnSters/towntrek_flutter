import 'package:flutter/material.dart';
import '../../../core/widgets/page_header.dart';
import '../../../models/models.dart';
import '../../../core/constants/service_list_constants.dart';

/// Error view for service list page
class ServiceListErrorView extends StatelessWidget {
  final ServiceCategoryDto category;
  final ServiceSubCategoryDto subCategory;
  final TownDto town;
  final String title;
  final String message;
  final VoidCallback onRetry;

  const ServiceListErrorView({
    super.key,
    required this.category,
    required this.subCategory,
    required this.town,
    required this.title,
    required this.message,
    required this.onRetry,
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
            child: Padding(
              padding: const EdgeInsets.all(ServiceListConstants.errorViewPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    ServiceListConstants.errorIcon,
                    size: ServiceListConstants.errorIconSize,
                    color: colorScheme.error.withOpacity(
                      ServiceListConstants.errorIconOpacity,
                    ),
                  ),
                  SizedBox(height: ServiceListConstants.errorSpacing),
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(
                        ServiceListConstants.errorTextOpacity,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ServiceListConstants.errorSpacing * 0.5),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ServiceListConstants.errorButtonSpacing),
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}