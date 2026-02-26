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
    final introText = business.shortDescription?.trim().isNotEmpty == true
        ? business.shortDescription!.trim()
        : (business.description.trim().isNotEmpty
              ? business.description.trim()
              : '${business.category}${business.subCategory != null ? ' · ${business.subCategory}' : ''}');

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(14),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: colorScheme.primary.withValues(alpha: 0.02),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.4),
                    width: 1.6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: business.logoUrl != null
                      ? Image.network(
                          UrlUtils.resolveImageUrl(business.logoUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.business_rounded,
                              size: 28,
                              color: colorScheme.primary.withValues(alpha: 0.6),
                            );
                          },
                        )
                      : Icon(
                          Icons.business_rounded,
                          size: 28,
                          color: colorScheme.primary.withValues(alpha: 0.6),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _buildRatingAndVerificationRow(colorScheme, theme),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            introText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('View Details'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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

  Widget _buildRatingAndVerificationRow(ColorScheme colorScheme, ThemeData theme) {
    return Row(
      children: [
        if (business.isVerified)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.verified_rounded,
              size: 14,
              color: Colors.blue.shade700,
            ),
          ),
        Row(
          children: List.generate(5, (starIndex) {
            final rating = business.rating ?? 0.0;
            final starValue = starIndex + 1;
            return Icon(
              starValue <= rating
                  ? Icons.star_rounded
                  : starValue - 0.5 <= rating
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded,
              size: 16,
              color: starValue <= rating + 0.5
                  ? Colors.amber.shade600
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            );
          }),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Text(
            business.rating != null
                ? '${business.rating!.toStringAsFixed(1)} (${business.totalReviews})'
                : 'No reviews',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.amber.shade800,
            ),
          ),
        ),
      ],
    );
  }
}