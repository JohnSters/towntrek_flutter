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
      height: LandingScreenConstants.featureGridHeight,
      child: Row(
        children: [
          FeatureTile(
            icon: Icons.store_mall_directory,
            label: LandingScreenConstants.businessLabel,
            count: businessCount,
            color: const Color(LandingScreenConstants.businessTileColor),
            isLoading: isLoading,
          ),
          const SizedBox(width: LandingScreenConstants.featureTileSpacing),
          FeatureTile(
            icon: Icons.handyman,
            label: LandingScreenConstants.serviceLabel,
            count: serviceCount,
            color: const Color(LandingScreenConstants.serviceTileColor),
            isLoading: isLoading,
          ),
          const SizedBox(width: LandingScreenConstants.featureTileSpacing),
          FeatureTile(
            icon: Icons.calendar_month,
            label: LandingScreenConstants.eventLabel,
            count: eventCount,
            color: const Color(LandingScreenConstants.eventTileColor),
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
