import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../core/constants/business_details_constants.dart';

class BusinessInfoCard extends StatelessWidget {
  final BusinessDetailDto business;

  const BusinessInfoCard({
    super.key,
    required this.business,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Only show if there's description or address
    if (business.description.isEmpty && business.physicalAddress == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: BusinessDetailsConstants.cardHorizontalMargin,
        vertical: BusinessDetailsConstants.cardVerticalMargin,
      ),
      child: Card(
        elevation: BusinessDetailsConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BusinessDetailsConstants.cardBorderRadius),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: BusinessDetailsConstants.cardBorderAlpha),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(BusinessDetailsConstants.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              if (business.description.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(BusinessDetailsConstants.contentPadding),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: BusinessDetailsConstants.highOpacity),
                    borderRadius: BorderRadius.circular(BusinessDetailsConstants.borderRadiusSmall),
                  ),
                  child: Text(
                    business.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: BusinessDetailsConstants.descriptionLineHeight,
                    ),
                  ),
                ),

              if (business.description.isNotEmpty && business.physicalAddress != null)
                SizedBox(height: BusinessDetailsConstants.sectionVerticalMargin),

              // Address
              if (business.physicalAddress != null)
                Container(
                  padding: EdgeInsets.all(BusinessDetailsConstants.smallSpacing),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: BusinessDetailsConstants.highOpacity),
                    borderRadius: BorderRadius.circular(BusinessDetailsConstants.borderRadiusSmall),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: BusinessDetailsConstants.mediumOpacity),
                      width: BusinessDetailsConstants.borderWidth,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: BusinessDetailsConstants.iconSizeSmall,
                        color: colorScheme.primary,
                      ),
                      SizedBox(width: BusinessDetailsConstants.smallSpacing),
                      Expanded(
                        child: Text(
                          business.physicalAddress!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

