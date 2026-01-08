import 'package:flutter/material.dart';
import '../../../core/constants/business_card_constants.dart';
import '../../../core/config/business_category_config.dart';
import '../../../models/category_with_count_dto.dart';

/// Widget for displaying empty state when no businesses are found
class BusinessEmptyView extends StatelessWidget {
  final CategoryWithCountDto category;

  const BusinessEmptyView({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: BusinessCardConstants.emptyContainerSize,
            height: BusinessCardConstants.emptyContainerSize,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(BusinessCardConstants.emptyContainerBorderRadius),
            ),
            child: Icon(
              BusinessCategoryConfig.getCategoryIcon(category.key),
              size: BusinessCardConstants.emptyIconSize,
              color: colorScheme.onSurfaceVariant.withValues(alpha: BusinessCardConstants.mediumOpacity),
            ),
          ),
          SizedBox(height: BusinessCardConstants.emptySpacing),
          Text(
            BusinessCardConstants.noBusinessesFound,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            BusinessCardConstants.noBusinessesMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: BusinessCardConstants.highOpacity),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}