import 'package:flutter/material.dart';
import '../../core/utils/business_utils.dart';
import '../../models/models.dart';

class EventAllReviewsScreen extends StatelessWidget {
  final String eventName;
  final List<EventReviewDto> reviews;

  const EventAllReviewsScreen({
    super.key,
    required this.eventName,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews • $eventName'),
      ),
      body: reviews.isEmpty
          ? const Center(child: Text('No reviews yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final review = reviews[index];
                final userName = review.userName?.trim().isNotEmpty == true
                    ? review.userName!.trim()
                    : 'Anonymous';

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
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
                                  size: 16,
                                  color: filled
                                      ? Colors.amber
                                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
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
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}


