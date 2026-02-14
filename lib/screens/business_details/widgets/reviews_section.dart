import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../core/utils/business_utils.dart';
import '../../../core/constants/business_details_constants.dart';

class ReviewsSection extends StatelessWidget {
  final List<ReviewDto> reviews;
  final VoidCallback? onViewAllPressed;

  const ReviewsSection({
    super.key,
    required this.reviews,
    this.onViewAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              // Section Title
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: BusinessDetailsConstants.iconSizeMedium,
                    color: Colors.amber,
                  ),
                  SizedBox(width: BusinessDetailsConstants.smallSpacing),
                  Text(
                    BusinessDetailsConstants.reviewsSectionTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(width: BusinessDetailsConstants.tinySpacing),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: BusinessDetailsConstants.smallSpacing,
                      vertical: BusinessDetailsConstants.tinySpacing,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(BusinessDetailsConstants.borderRadiusSmall),
                    ),
                    child: Text(
                      '${reviews.length}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: BusinessDetailsConstants.contentSpacing),

              // Reviews List
              ...reviews.take(BusinessDetailsConstants.maxReviewsToShow).map((review) => _buildReviewCard(context, review)),

              // Show more button if there are more reviews
              if (reviews.length > BusinessDetailsConstants.maxReviewsToShow)
                Padding(
                  padding: EdgeInsets.only(top: BusinessDetailsConstants.sectionVerticalMargin),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onViewAllPressed,
                      icon: const Icon(Icons.expand_more),
                      label: Text(BusinessDetailsConstants.viewAllReviewsLabel),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: BusinessDetailsConstants.buttonVerticalPadding),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(BusinessDetailsConstants.borderRadiusSmall),
                        ),
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

  Widget _buildReviewCard(BuildContext context, ReviewDto review) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.only(bottom: BusinessDetailsConstants.smallSpacing),
      elevation: BusinessDetailsConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BusinessDetailsConstants.reviewCardBorderRadius),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: BusinessDetailsConstants.cardBorderAlpha),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(BusinessDetailsConstants.contentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reviewer info and rating
            Row(
              children: [
                CircleAvatar(
                  radius: BusinessDetailsConstants.avatarRadius,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                SizedBox(width: BusinessDetailsConstants.smallSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (review.isVerified)
                        Text(
                          BusinessDetailsConstants.verifiedReviewLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                // Star rating
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      size: BusinessDetailsConstants.starIconSize,
                      color: index < review.rating ? Colors.amber : colorScheme.onSurfaceVariant.withValues(alpha: BusinessDetailsConstants.lowOpacity),
                    );
                  }),
                ),
              ],
            ),

            SizedBox(height: BusinessDetailsConstants.smallSpacing),

            // Review comment
            if (review.comment != null && review.comment!.isNotEmpty)
              Text(
                review.comment!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: BusinessDetailsConstants.reviewLineHeight,
                ),
              ),

            SizedBox(height: BusinessDetailsConstants.tinySpacing),

            // Review date
            Text(
              BusinessUtils.formatReviewDate(review.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: BusinessDetailsConstants.mediumOpacity),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

