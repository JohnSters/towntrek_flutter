import 'package:flutter/material.dart';
import '../../../core/utils/business_utils.dart';
import '../../../core/constants/event_all_reviews_constants.dart';
import '../../../models/models.dart';

class EventReviewCard extends StatelessWidget {
  final EventReviewDto review;

  const EventReviewCard({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userName = review.userName?.trim().isNotEmpty == true
        ? review.userName!.trim()
        : 'Anonymous';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(EventAllReviewsConstants.cardBorderRadius),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: EventAllReviewsConstants.cardBorderAlpha),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(EventAllReviewsConstants.contentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: EventAllReviewsConstants.avatarRadius,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    userName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(5, (i) {
                    final filled = i < review.rating;
                    return Icon(
                      filled ? Icons.star : Icons.star_border,
                      size: EventAllReviewsConstants.starIconSize,
                      color: filled
                          ? Colors.amber
                          : colorScheme.onSurfaceVariant.withValues(alpha: EventAllReviewsConstants.lowOpacity),
                    );
                  }),
                ),
              ],
            ),
            if (review.comment?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(
                review.comment!.trim(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              BusinessUtils.formatReviewDate(review.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: EventAllReviewsConstants.mediumOpacity),
              ),
            ),
          ],
        ),
      ),
    );
  }
}