import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';

class EventInfoCard extends StatelessWidget {
  final EventDetailDto event;

  const EventInfoCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer.withValues(alpha: 0.72),
                colorScheme.secondaryContainer.withValues(alpha: 0.50),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface.withValues(alpha: 0.92),
                  height: 1.25,
                ),
              ),
              if (event.shortDescription != null &&
                  event.shortDescription!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                CollapsibleDetailTextBlock(
                  text: event.shortDescription!.trim(),
                  headerLabel: 'Summary',
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    color: colorScheme.onSurface.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        DetailSectionShell(
          expandTitle: true,
          title: 'Schedule & pricing',
          icon: Icons.event_rounded,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDetailTag(
                context,
                Icons.calendar_today_rounded,
                event.displayDate,
              ),
              if (event.startTime != null)
                _buildDetailTag(
                  context,
                  Icons.schedule_rounded,
                  '${event.startTime} ${event.endTime != null ? '- ${event.endTime}' : ''}',
                ),
              _buildDetailTag(
                context,
                Icons.payments_outlined,
                event.displayPrice,
              ),
              if (event.ageRestrictions != null && event.ageRestrictions!.isNotEmpty)
                _buildDetailTag(
                  context,
                  Icons.warning_amber_rounded,
                  event.ageRestrictions!,
                ),
            ],
          ),
        ),
        if (_hasFeatures(event)) ...[
          const SizedBox(height: 12),
          DetailSectionShell(
            expandTitle: true,
            title: 'Features',
            icon: Icons.grid_view_rounded,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (event.isOutdoorEvent)
                  _buildDetailTag(context, Icons.landscape_rounded, 'Outdoor'),
                if (event.hasParking)
                  _buildDetailTag(context, Icons.local_parking_rounded, 'Parking'),
                if (event.hasRefreshments)
                  _buildDetailTag(context, Icons.restaurant_rounded, 'Refreshments'),
                if (event.hasWeatherBackup)
                  _buildDetailTag(context, Icons.umbrella_rounded, 'Weather backup'),
              ],
            ),
          ),
        ],
        if (event.description?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 12),
          DetailSectionShell(
            expandTitle: true,
            title: 'About',
            icon: Icons.notes_rounded,
            child: CollapsibleDetailTextBlock(
              text: event.description!.trim(),
              headerLabel: 'Full description',
              textStyle: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ),
        ],
        if (event.ticketInfo != null && event.ticketInfo!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          DetailSectionShell(
            expandTitle: true,
            title: 'Ticket info',
            icon: Icons.confirmation_number_outlined,
            child: Text(
              event.ticketInfo!.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ),
        ],
        if (event.eventProgram != null && event.eventProgram!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          DetailSectionShell(
            expandTitle: true,
            title: 'Program',
            icon: Icons.list_alt_rounded,
            child: Text(
              event.eventProgram!.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ),
        ],
      ],
    );
  }

  bool _hasFeatures(EventDetailDto event) {
    return event.isOutdoorEvent ||
        event.hasParking ||
        event.hasRefreshments ||
        event.hasWeatherBackup;
  }

  /// Matches Business/Services & Features pill styling.
  Widget _buildDetailTag(BuildContext context, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
