import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../core/utils/business_utils.dart';

class OperatingHoursSection extends StatelessWidget {
  final List<OperatingHourDto> operatingHours;
  final List<SpecialOperatingHourDto> specialOperatingHours;

  const OperatingHoursSection({
    super.key,
    required this.operatingHours,
    required this.specialOperatingHours,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Group hours by regular and special
    final regularHours = operatingHours.where((h) => !h.isSpecialHours).toList();
    final specialHours = operatingHours.where((h) => h.isSpecialHours).toList();
    final upcomingSpecialOperatingHours = BusinessUtils.getUpcomingSpecialOperatingHours(specialOperatingHours);

    // Sort hours by day of week
    regularHours.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
    specialHours.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: OutlinedButton(
        onPressed: null, // Not clickable, just for styling
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(20),
          side: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.1),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: colorScheme.primary.withValues(alpha: 0.02),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Pill-shaped title
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
                    Icons.access_time,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Operating Hours',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Date-based Special Operating Hours (e.g. holiday closures)
            if (upcomingSpecialOperatingHours.isNotEmpty) ...[
              _buildSpecialOperatingHoursBanners(context, upcomingSpecialOperatingHours),
              const SizedBox(height: 20),
            ],

            // Day-by-day operating hours with color coding
            ...regularHours.map((hour) => _buildDayCard(context, hour)),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, OperatingHourDto hour) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final dayName = BusinessUtils.formatDayOfWeek(hour.dayOfWeek);
    final timeDisplay = hour.isOpen && hour.openTime != null && hour.closeTime != null
        ? '${BusinessUtils.formatTime(hour.openTime!)} - ${BusinessUtils.formatTime(hour.closeTime!)}'
        : 'Closed';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hour.isOpen
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hour.isOpen
              ? colorScheme.outline.withValues(alpha: 0.2)
              : colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Day indicator
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: hour.isOpen
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              dayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: hour.isOpen ? colorScheme.primary : colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          // Hours display
          Expanded(
            child: Text(
              hour.isSpecialHours && hour.specialHoursNote != null
                  ? hour.specialHoursNote!
                  : timeDisplay,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: hour.isOpen ? colorScheme.onSurfaceVariant : colorScheme.error,
                fontStyle: hour.isSpecialHours ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialOperatingHoursBanners(BuildContext context, List<SpecialOperatingHourDto> items) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((s) {
        final dateText = DateFormat('MMM d, yyyy').format(s.date);
        final hasRange = (s.openTime?.isNotEmpty ?? false) && (s.closeTime?.isNotEmpty ?? false);
        final timeText = hasRange ? '${BusinessUtils.formatTime(s.openTime!)} - ${BusinessUtils.formatTime(s.closeTime!)}' : null;
        final reason = (s.reason?.trim().isNotEmpty ?? false) ? s.reason!.trim() : 'Special hours';
        final notes = (s.notes?.trim().isNotEmpty ?? false) ? s.notes!.trim() : null;

        final isClosed = s.isClosed;
        final bg = isClosed
            ? colorScheme.errorContainer.withValues(alpha: 0.65)
            : colorScheme.primaryContainer.withValues(alpha: 0.45);
        final border = (isClosed ? colorScheme.error : colorScheme.primary).withValues(alpha: 0.25);
        final fg = isClosed ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer;
        final icon = isClosed ? Icons.event_busy : Icons.event;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: border.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: fg, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isClosed
                          ? (timeText != null ? 'Closed on $dateText ($timeText)' : 'Closed on $dateText')
                          : (timeText != null ? 'Special hours on $dateText: $timeText' : 'Special hours on $dateText'),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reason: $reason',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: fg.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (notes != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Notes: $notes',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: fg.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

