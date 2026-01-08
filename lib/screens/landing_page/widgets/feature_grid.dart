import 'package:flutter/material.dart';
import '../../../core/constants/landing_page_constants.dart';
import 'feature_tile.dart';

/// Feature grid displaying businesses, services, and events
class FeatureGrid extends StatelessWidget {
  final int? businessCount;
  final int? serviceCount;
  final int? eventCount;
  final bool isLoading;

  const FeatureGrid({
    super.key,
    this.businessCount,
    this.serviceCount,
    this.eventCount,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: LandingPageConstants.featureGridHeight,
      child: Row(
        children: [
          FeatureTile(
            icon: Icons.store_mall_directory,
            label: LandingPageConstants.businessLabel,
            count: businessCount,
            color: const Color(LandingPageConstants.businessTileColor),
            isLoading: isLoading,
          ),
          const SizedBox(width: LandingPageConstants.featureTileSpacing),
          FeatureTile(
            icon: Icons.handyman,
            label: LandingPageConstants.serviceLabel,
            count: serviceCount,
            color: const Color(LandingPageConstants.serviceTileColor),
            isLoading: isLoading,
          ),
          const SizedBox(width: LandingPageConstants.featureTileSpacing),
          FeatureTile(
            icon: Icons.calendar_month,
            label: LandingPageConstants.eventLabel,
            count: eventCount,
            color: const Color(LandingPageConstants.eventTileColor),
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}