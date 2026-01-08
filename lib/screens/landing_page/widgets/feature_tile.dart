import 'package:flutter/material.dart';
import '../../../core/constants/landing_page_constants.dart';

/// Feature tile widget for displaying business/service/event counts
class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int? count;
  final bool isLoading;

  const FeatureTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.count,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(LandingPageConstants.borderRadiusMedium),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: LandingPageConstants.featureIconSize,
            ),
            const SizedBox(height: LandingPageConstants.verticalSpacingSmall),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (count != null && !isLoading) ...[
              const SizedBox(height: LandingPageConstants.verticalSpacingSmall - 6),
              Text(
                '$count+',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ] else if (count != null && isLoading) ...[
              const SizedBox(height: LandingPageConstants.verticalSpacingSmall - 6),
              SizedBox(
                width: LandingPageConstants.loadingIndicatorSize,
                height: LandingPageConstants.loadingIndicatorSize,
                child: CircularProgressIndicator(
                  strokeWidth: LandingPageConstants.loadingIndicatorStrokeWidth,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}