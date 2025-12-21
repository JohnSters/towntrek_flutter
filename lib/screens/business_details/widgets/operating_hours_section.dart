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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                // Date-based Special Operating Hours (e.g. holiday closures)
                if (upcomingSpecialOperatingHours.isNotEmpty) ...[
                  _buildSpecialOperatingHoursBanners(context, upcomingSpecialOperatingHours),
                  const SizedBox(height: 20),
                ],
              // Section Title
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 24,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Operating Hours',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Regular Hours
              if (regularHours.isNotEmpty) ...[
                ...regularHours.map((hour) => _buildHourRow(context, hour)),
                if (specialHours.isNotEmpty) const SizedBox(height: 20),
              ],

              // Special Hours
              if (specialHours.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Special Hours',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...specialHours.map((hour) => _buildHourRow(context, hour, isSpecial: true)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHourRow(BuildContext context, OperatingHourDto hour, {bool isSpecial = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final dayName = BusinessUtils.formatDayOfWeek(hour.dayOfWeek);
    final timeDisplay = hour.isOpen && hour.openTime != null && hour.closeTime != null
        ? '${BusinessUtils.formatTime(hour.openTime!)} - ${BusinessUtils.formatTime(hour.closeTime!)}'
        : 'Closed';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              dayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isSpecial ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ),
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

