import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import '../../shared/detail_widgets/detail_widgets.dart';

class EventReviewsSection extends StatelessWidget {
  final List<EventReviewDto> reviews;
  final VoidCallback? onViewAllPressed;

  const EventReviewsSection({
    super.key,
    required this.reviews,
    this.onViewAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DetailSectionShell(
        expandTitle: true,
        title: 'Reviews',
        icon: Icons.rate_review_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Text(
                    '${reviews.length}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  reviews.length == 1 ? 'review' : 'reviews',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...reviews
                .take(3)
                .map((review) => DetailEventReviewTile(review: review)),
            if (reviews.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onViewAllPressed,
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('View all reviews'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

}
