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

    return Card(
      elevation: ServiceDetailConstants.cardElevation,
      shadowColor: colorScheme.shadow.withOpacity(ServiceDetailConstants.shadowOpacity),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ServiceDetailConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ServiceDetailConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (service.description.isNotEmpty)
              Text(
                service.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: ServiceDetailConstants.descriptionHeight,
                ),
                maxLines: ServiceDetailConstants.maxDescriptionLines,
                overflow: TextOverflow.ellipsis,
              ),

            if (service.serviceArea != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.map,
                    size: ServiceDetailConstants.actionIconSize,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Service Area: ${service.serviceArea}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: ServiceDetailConstants.subtitleFontWeight,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}