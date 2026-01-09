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
      child: Card(
        elevation: ServiceDetailConstants.cardElevation,
        shadowColor: colorScheme.shadow.withValues(alpha: ServiceDetailConstants.shadowOpacity),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ServiceDetailConstants.cardBorderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(ServiceDetailConstants.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    ServiceDetailConstants.clockIcon,
                    size: ServiceDetailConstants.contactIconSize,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    ServiceDetailConstants.operatingHoursTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: ServiceDetailConstants.titleFontWeight,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...sortedHours.map((hour) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        _formatDayOfWeek(hour.dayOfWeek),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: ServiceDetailConstants.subtitleFontWeight,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        hour.isAvailable && hour.startTime != null && hour.endTime != null
                            ? '${_formatTime(hour.startTime!)} - ${_formatTime(hour.endTime!)}'
                            : ServiceDetailConstants.closedTodayText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: hour.isAvailable ? colorScheme.onSurfaceVariant : colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
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