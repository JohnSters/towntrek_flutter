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
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2.0),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.14),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 12,
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              if (count != null && !isLoading) ...[
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$count+',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: color,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ] else if (count != null && isLoading) ...[
                SizedBox(
                  width: LandingPageConstants.loadingIndicatorSize,
                  height: LandingPageConstants.loadingIndicatorSize,
                  child: CircularProgressIndicator(
                    strokeWidth: LandingPageConstants.loadingIndicatorStrokeWidth,
                    color: color.withValues(alpha: 0.8),
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