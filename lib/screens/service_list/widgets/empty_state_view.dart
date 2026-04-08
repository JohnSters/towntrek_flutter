import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import '../../../core/constants/service_list_constants.dart';

/// Empty state when no services are found (listing shell matches success state).
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
    final listingTheme = context.entityListingTheme;

    return Column(
      children: [
        EntityListingHeroHeader(
          theme: listingTheme,
          categoryIcon: Icons.handyman_rounded,
          subCategoryName: subCategory.name,
          categoryName: category.name,
          townName: town.name,
        ),
        ListingResultsBand(
          count: subCategory.serviceCount,
          categoryName: subCategory.name,
          bandColor: listingTheme.resultsBand,
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  ServiceListConstants.emptyIcon,
                  size: ServiceListConstants.errorIconSize,
                  color: colorScheme.onSurface.withValues(
                    alpha: ServiceListConstants.emptyStateIconOpacity,
                  ),
                ),
                SizedBox(height: ServiceListConstants.errorSpacing),
                Text(
                  ServiceListConstants.emptyStateTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(
                      alpha: ServiceListConstants.emptyStateTextOpacity,
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
