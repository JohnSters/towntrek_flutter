import 'package:flutter/material.dart';
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

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.primary.withValues(alpha: 0.02),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business Header Row
          Row(
            children: [
              // Logo with border
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: business.logoUrl != null
                      ? Image.network(
                          UrlUtils.resolveImageUrl(business.logoUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.business,
                                size: 32,
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.business,
                            size: 32,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

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
                              size: 16,
                              color: starValue <= rating + 0.5
                                  ? Colors.amber
                                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                            );
                          }),
                        ),

                        const SizedBox(width: 8),

                        // Rating Text
                        Text(
                          business.rating != null
                              ? '${business.rating!.toStringAsFixed(1)} (${business.totalReviews})'
                              : 'No reviews',
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

          // Short Description
          if (business.shortDescription != null && business.shortDescription!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              business.shortDescription!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 16),

          // View Details Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('View Details'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
                shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}