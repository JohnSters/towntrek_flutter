import 'package:flutter/material.dart';
import '../../../core/constants/business_card_constants.dart';
import '../../../core/config/business_category_config.dart';
import '../../../models/models.dart';

/// Widget for displaying business count information
class BusinessCountInfo extends StatelessWidget {
  final CategoryWithCountDto category;
  final SubCategoryWithCountDto subCategory;

  const BusinessCountInfo({
    super.key,
    required this.category,
    required this.subCategory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: BusinessCardConstants.horizontalMargin,
        vertical: BusinessCardConstants.verticalMargin,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: BusinessCardConstants.horizontalPadding,
        vertical: BusinessCardConstants.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(BusinessCardConstants.countContainerBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            BusinessCategoryConfig.getCategoryIcon(category.key),
            size: BusinessCardConstants.countIconSize,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: BusinessCardConstants.countIconTextSpacing),
          Flexible(
            child: Text(
              '${subCategory.businessCount} businesses • ${category.name}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}