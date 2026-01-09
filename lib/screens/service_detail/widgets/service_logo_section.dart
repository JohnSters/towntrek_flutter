import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../core/constants/service_detail_constants.dart';
import '../../../core/utils/url_utils.dart';

/// Service logo section displaying the service's logo
class ServiceLogoSection extends StatelessWidget {
  final ServiceDetailDto service;

  const ServiceLogoSection({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    // Only show if logo URL exists
    if (service.logoUrl == null || service.logoUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: ServiceDetailConstants.sectionSpacing,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Full width logo display with thick whitesmoke border
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8), // whitesmoke color
                width: 8, // thicker border for larger display
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                UrlUtils.resolveImageUrl(service.logoUrl!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.business,
                    size: 80,
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}