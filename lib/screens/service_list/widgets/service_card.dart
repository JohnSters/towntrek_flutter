import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../core/constants/service_list_constants.dart';
import '../../../core/utils/url_utils.dart';
import '../../service_detail_page.dart';

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

    return Card(
      margin: const EdgeInsets.only(
        bottom: ServiceListConstants.cardMarginBottom,
      ),
      elevation: ServiceListConstants.cardElevation,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ServiceListConstants.cardBorderRadius,
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToServiceDetails(context),
        borderRadius: BorderRadius.circular(
          ServiceListConstants.cardBorderRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            ServiceListConstants.serviceCardPaddingHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildServiceLogo(colorScheme),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: ServiceListConstants.titleFontWeight,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: ServiceListConstants.maxTitleLines,
                          overflow: ServiceListConstants.textOverflow,
                        ),
                        const SizedBox(height: 4),
                        _buildRatingAndVerificationRow(colorScheme, theme),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (service.shortDescription != null &&
                  service.shortDescription!.isNotEmpty)
                Text(
                  service.shortDescription!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  maxLines: ServiceListConstants.maxDescriptionLines,
                  overflow: ServiceListConstants.textOverflow,
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _navigateToServiceDetails(context),
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Service Details'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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

  Widget _buildServiceLogo(ColorScheme colorScheme) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surfaceContainerHighest,
      ),
      child: service.logoUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                UrlUtils.resolveImageUrl(service.logoUrl!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.handyman,
                    size: 30,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  );
                },
              ),
            )
          : Icon(
              Icons.handyman,
              size: 30,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
    );
  }

  Widget _buildRatingAndVerificationRow(ColorScheme colorScheme, ThemeData theme) {
    return Row(
      children: [
        if (service.isVerified) ...[
          Icon(Icons.verified, size: 16, color: Colors.blue),
          const SizedBox(width: 4),
          Text(
            'Verified',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
        ],

        // Rating Row
        Row(
          children: List.generate(5, (starIndex) {
            final rating = service.rating ?? 0.0;
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

        const SizedBox(width: 6),

        // Rating Text
        Text(
          service.rating != null
              ? '${service.rating!.toStringAsFixed(1)} (${service.totalReviews})'
              : 'No reviews',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
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