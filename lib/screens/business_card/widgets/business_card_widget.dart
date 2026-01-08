import 'package:flutter/material.dart';
import '../../../core/constants/business_card_constants.dart';
import '../../../core/utils/url_utils.dart';
import '../../../models/business_dto.dart';

/// Reusable business card widget for displaying business information
class BusinessCardWidget extends StatelessWidget {
  final BusinessDto business;
  final VoidCallback? onTap;

  const BusinessCardWidget({
    super.key,
    required this.business,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.only(bottom: BusinessCardConstants.cardBottomMargin),
      elevation: BusinessCardConstants.cardElevation,
      shadowColor: colorScheme.shadow.withValues(alpha: BusinessCardConstants.cardShadowAlpha),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BusinessCardConstants.cardBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BusinessCardConstants.cardBorderRadius),
        child: Padding(
          padding: EdgeInsets.all(BusinessCardConstants.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business Header Row
              Row(
                children: [
                  // Logo
                  Container(
                    width: BusinessCardConstants.logoSize,
                    height: BusinessCardConstants.logoSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(BusinessCardConstants.logoBorderRadius),
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    child: business.logoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(BusinessCardConstants.logoBorderRadius),
                            child: Image.network(
                              UrlUtils.resolveImageUrl(business.logoUrl!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.business,
                                  size: BusinessCardConstants.logoFallbackIconSize,
                                  color: colorScheme.onSurfaceVariant.withValues(alpha: BusinessCardConstants.mediumOpacity),
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.business,
                            size: BusinessCardConstants.logoFallbackIconSize,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: BusinessCardConstants.mediumOpacity),
                          ),
                  ),

                  const SizedBox(width: 16),

                  // Business Name and Rating
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Business Name
                        Text(
                          business.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Rating Row
                        Row(
                          children: [
                            // Stars
                            Row(
                              children: List.generate(5, (starIndex) {
                                final rating = business.rating ?? 0.0;
                                final starValue = starIndex + 1;
                                return Icon(
                                  starValue <= rating
                                      ? Icons.star
                                      : starValue - 0.5 <= rating
                                          ? Icons.star_half
                                          : Icons.star_outline,
                                  size: BusinessCardConstants.starIconSize,
                                  color: starValue <= rating + 0.5
                                      ? Colors.amber
                                      : colorScheme.onSurfaceVariant.withValues(alpha: BusinessCardConstants.lowOpacity),
                                );
                              }),
                            ),

                            SizedBox(width: BusinessCardConstants.starTextSpacing),

                            // Rating Text
                            Text(
                              business.rating != null
                                  ? '${business.rating!.toStringAsFixed(1)} (${business.totalReviews})'
                                  : BusinessCardConstants.noReviewsText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Short Description
              if (business.shortDescription != null && business.shortDescription!.isNotEmpty)
                Text(
                  business.shortDescription!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: BusinessCardConstants.descriptionLineHeight,
                  ),
                  maxLines: BusinessCardConstants.descriptionMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),

              SizedBox(height: BusinessCardConstants.buttonSpacing),

              // Business Details Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onTap,
                  icon: Icon(Icons.info_outline, size: BusinessCardConstants.buttonIconSize),
                  label: const Text(BusinessCardConstants.businessDetailsLabel),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: BusinessCardConstants.buttonVerticalPadding),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BusinessCardConstants.buttonBorderRadius),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}