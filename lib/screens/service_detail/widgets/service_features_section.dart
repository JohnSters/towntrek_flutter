import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../core/constants/service_detail_constants.dart';

/// Data class for feature information
class _FeatureData {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureData({
    required this.icon,
    required this.label,
    required this.color,
  });
}

/// Service features and pricing section with icon grid
class ServiceFeaturesSection extends StatelessWidget {
  final ServiceDetailDto service;

  const ServiceFeaturesSection({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final features = _buildFeaturesData();

    if (features.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: ServiceDetailConstants.contentPadding,
        vertical: ServiceDetailConstants.sectionSpacing,
      ),
      padding: const EdgeInsets.all(ServiceDetailConstants.cardPadding),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: ServiceDetailConstants.cardBackgroundOpacity),
        borderRadius: BorderRadius.circular(ServiceDetailConstants.cardBorderRadius),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: ServiceDetailConstants.cardBorderOpacity),
          width: ServiceDetailConstants.cardBorderWidth,
        ),
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
                  Icons.star,
                  size: ServiceDetailConstants.contactIconSize,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Service Features',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: ServiceDetailConstants.titleFontWeight,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 icons per row for better spacing
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9, // Better proportion for larger icons
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: features.length,
            itemBuilder: (context, index) => _buildFeatureIcon(features[index], context),
          ),
        ],
      ),
    );
  }

  List<_FeatureData> _buildFeaturesData() {
    final features = <_FeatureData>[];

    // Pricing information
    if (service.hourlyRate != null) {
      features.add(_FeatureData(
        icon: Icons.attach_money,
        label: 'Hourly Rate: \$${service.hourlyRate!.toStringAsFixed(2)}/hour',
        color: Colors.green,
      ));
    }

    if (service.priceRange != null && service.priceRange!.isNotEmpty) {
      features.add(_FeatureData(
        icon: Icons.price_change,
        label: 'Price Range: ${service.priceRange}',
        color: Colors.blue,
      ));
    }

    if (service.offersQuotes) {
      features.add(_FeatureData(
        icon: Icons.assignment,
        label: 'Quotes Available',
        color: Colors.purple,
      ));
    }

    // Service availability features
    if (service.emergencyService) {
      features.add(_FeatureData(
        icon: Icons.emergency,
        label: '24/7 Emergency Service',
        color: Colors.red,
      ));
    }

    if (service.availableWeekends) {
      features.add(_FeatureData(
        icon: Icons.weekend,
        label: 'Weekend Availability',
        color: Colors.orange,
      ));
    }

    if (service.availableAfterHours) {
      features.add(_FeatureData(
        icon: Icons.nightlight_round,
        label: 'After Hours Service',
        color: Colors.indigo,
      ));
    }

    // Service types
    if (service.mobileService) {
      features.add(_FeatureData(
        icon: Icons.drive_eta,
        label: 'Mobile Service',
        color: Colors.teal,
      ));
    }

    if (service.onSiteService) {
      features.add(_FeatureData(
        icon: Icons.location_on,
        label: 'On-Site Service',
        color: Colors.cyan,
      ));
    }

    return features;
  }

  Widget _buildFeatureIcon(_FeatureData feature, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56, // Larger size for better visibility
          height: 56, // Larger size for better visibility
          decoration: BoxDecoration(
            color: feature.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: feature.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            feature.icon,
            size: 28, // Larger icon for 56px container
            color: feature.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          feature.label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 9.5, // Slightly larger for readability
            fontWeight: FontWeight.w500,
            height: 1.1, // Better line height
          ),
          textAlign: TextAlign.center,
          maxLines: 2, // Reduce from 3 to 2 lines for compactness
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}