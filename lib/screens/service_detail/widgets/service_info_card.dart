import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../core/constants/service_detail_constants.dart';

/// Service information card displaying description and service area
class ServiceInfoCard extends StatelessWidget {
  final ServiceDetailDto service;

  const ServiceInfoCard({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: ServiceDetailConstants.contentPadding,
        vertical: ServiceDetailConstants.sectionSpacing,
      ),
      padding: const EdgeInsets.all(ServiceDetailConstants.cardPadding),
      decoration: BoxDecoration(
        // Different background - more prominent with gradient effect
        gradient: LinearGradient(
          colors: [
            colorScheme.surfaceContainerLowest.withValues(alpha: 0.8),
            colorScheme.surfaceContainerLowest.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ServiceDetailConstants.cardBorderRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 1.5,
        ),
        // Subtle shadow for depth
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Centered pill-shaped title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info,
                  size: ServiceDetailConstants.contactIconSize,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Service Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: ServiceDetailConstants.titleFontWeight,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (service.description.isNotEmpty) ...[
            // Description with better typography
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                service.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: ServiceDetailConstants.descriptionHeight,
                  fontSize: 15,
                ),
                maxLines: ServiceDetailConstants.maxDescriptionLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (service.serviceArea != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.location_on,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service Area',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          service.serviceArea!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: ServiceDetailConstants.subtitleFontWeight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}