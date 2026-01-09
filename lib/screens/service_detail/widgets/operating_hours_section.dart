import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../core/constants/service_detail_constants.dart';

/// Operating hours section for service details
class OperatingHoursSection extends StatelessWidget {
  final List<ServiceOperatingHourDto> operatingHours;

  const OperatingHoursSection({
    super.key,
    required this.operatingHours,
  });

  @override
  Widget build(BuildContext context) {
    if (operatingHours.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final sortedHours = [...operatingHours]..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));

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
                  ServiceDetailConstants.clockIcon,
                  size: ServiceDetailConstants.contactIconSize,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  ServiceDetailConstants.operatingHoursTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: ServiceDetailConstants.titleFontWeight,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...sortedHours.map((hour) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hour.isAvailable
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : colorScheme.errorContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hour.isAvailable
                    ? colorScheme.outline.withValues(alpha: 0.2)
                    : colorScheme.error.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Day indicator
                Container(
                  width: 110,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hour.isAvailable
                        ? colorScheme.primary.withValues(alpha: 0.1)
                        : colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatDayOfWeek(hour.dayOfWeek),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: hour.isAvailable ? colorScheme.primary : colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      if (hour.isAvailable && hour.startTime != null && hour.endTime != null) ...[
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_formatTime(hour.startTime!)} - ${_formatTime(hour.endTime!)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else ...[
                        Icon(
                          Icons.cancel,
                          size: 16,
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ServiceDetailConstants.closedTodayText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _formatDayOfWeek(int dayOfWeek) {
    // Handle different day numbering systems
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    // If dayOfWeek is 0, treat as Sunday (C# backend uses 0=Sunday..6=Saturday)
    if (dayOfWeek == 0) {
      return 'Sunday';
    }

    // Handle negative values or values > 7 (fallback to Sunday)
    if (dayOfWeek < 0) {
      return 'Invalid Day';
    }

    // If dayOfWeek is 1-7, use as 1-indexed array (1=Monday, 7=Sunday)
    if (dayOfWeek >= 1 && dayOfWeek <= 7) {
      return days[dayOfWeek - 1];
    }

    // Handle values 1-6 as potentially 0-indexed (0=Sunday, 1=Monday, etc.)
    if (dayOfWeek >= 1 && dayOfWeek <= 6) {
      return days[dayOfWeek];
    }

    // Fallback for unexpected values
    return 'Day $dayOfWeek';
  }

  String _formatTime(String time) {
    // Simple time formatting - could be enhanced
    return time;
  }
}