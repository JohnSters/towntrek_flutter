import 'package:flutter/material.dart';

import '../../../core/constants/creative_spaces_constants.dart';
import '../../../models/models.dart';

class DetailReviewTile extends StatelessWidget {
  const DetailReviewTile({super.key, required this.review});

  final ReviewDto review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                review.userName,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (review.isVerified) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified_rounded, size: 14),
              ],
              const Spacer(),
              Text(
                CreativeSpacesConstants.reviewRatingTemplate.replaceAll(
                  '{rating}',
                  review.rating.toStringAsFixed(1),
                ),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (review.comment != null && review.comment!.trim().isNotEmpty)
            Text(review.comment!.trim(), style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(
            CreativeSpacesConstants.dateIsoTemplate
                .replaceAll('{year}', review.createdAt.year.toString())
                .replaceAll(
                  '{month}',
                  review.createdAt.month.toString().padLeft(2, '0'),
                )
                .replaceAll(
                  '{day}',
                  review.createdAt.day.toString().padLeft(2, '0'),
                ),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
