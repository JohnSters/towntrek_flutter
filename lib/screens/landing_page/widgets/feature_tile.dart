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
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(LandingPageConstants.borderRadiusMedium),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 3,
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: LandingPageConstants.featureIconSize,
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                child: Center(
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 11.0,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (count != null && !isLoading) ...[
              Flexible(
                flex: 2,
                child: Center(
                  child: Text(
                    '$count+',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
              ] else if (count != null && isLoading) ...[
                Flexible(
                  flex: 2,
                  child: Center(
                    child: SizedBox(
                      width: LandingPageConstants.loadingIndicatorSize,
                      height: LandingPageConstants.loadingIndicatorSize,
                      child: CircularProgressIndicator(
                        strokeWidth: LandingPageConstants.loadingIndicatorStrokeWidth,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}