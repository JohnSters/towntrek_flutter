import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../core/utils/url_utils.dart';
import '../../service_detail/service_detail_page.dart';

/// Card widget for displaying service information with navigation
class ServiceCard extends StatelessWidget {
  final ServiceDto service;

  const ServiceCard({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final introText = service.shortDescription?.trim().isNotEmpty == true
        ? service.shortDescription!.trim()
        : '${service.subCategoryName ?? service.categoryName ?? 'Local service'} in ${service.townName}';

    return OutlinedButton(
      onPressed: () => _navigateToServiceDetails(context),
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
              _buildServiceLogo(colorScheme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: theme.textTheme.titleLarge?.copyWith(
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
              onPressed: () => _navigateToServiceDetails(context),
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

  Widget _buildServiceLogo(ColorScheme colorScheme) {
    return Container(
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
      child: service.logoUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                UrlUtils.resolveImageUrl(service.logoUrl!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.business_rounded,
                    size: 28,
                    color: colorScheme.primary.withValues(alpha: 0.6),
                  );
                },
              ),
            )
          : Icon(
              Icons.business_rounded,
              size: 28,
              color: colorScheme.primary.withValues(alpha: 0.6),
            ),
    );
  }

  Widget _buildRatingAndVerificationRow(ColorScheme colorScheme, ThemeData theme) {
    return Row(
      children: [
        // Verified Badge
        if (service.isVerified)
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

        // Rating with Stars and Count (Business Card Style)
        Row(
          children: [
            // Stars
            Row(
              children: List.generate(5, (starIndex) {
                final rating = service.rating ?? 0.0;
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

            // Rating Text with Count
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
                service.rating != null
                    ? '${service.rating!.toStringAsFixed(1)} (${service.totalReviews})'
                    : 'No reviews',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.amber.shade800,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToServiceDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceDetailPage(
          serviceId: service.id,
          serviceName: service.name,
        ),
      ),
    );
  }
}