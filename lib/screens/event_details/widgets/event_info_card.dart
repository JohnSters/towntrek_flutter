import 'package:flutter/material.dart';
import '../../../models/models.dart';
import 'event_detail_ui.dart';

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
                Text(
                  event.shortDescription!.trim(),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    color: colorScheme.onSurface.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        EventDetailSectionShell(
          title: 'Schedule & pricing',
          icon: Icons.event_rounded,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(
                context,
                Icons.calendar_today,
                event.displayDate,
                colorScheme.primary,
                colorScheme.primaryContainer,
              ),
              if (event.startTime != null)
                _buildChip(
                  context,
                  Icons.access_time,
                  '${event.startTime} ${event.endTime != null ? '- ${event.endTime}' : ''}',
                  colorScheme.secondary,
                  colorScheme.secondaryContainer,
                ),
              _buildChip(
                context,
                Icons.attach_money,
                event.displayPrice,
                event.isFreeEvent ? Colors.green : colorScheme.tertiary,
                event.isFreeEvent
                    ? Colors.green.withValues(alpha: 0.1)
                    : colorScheme.tertiaryContainer,
              ),
              if (event.ageRestrictions != null && event.ageRestrictions!.isNotEmpty)
                _buildChip(
                  context,
                  Icons.warning_amber_rounded,
                  event.ageRestrictions!,
                  Colors.orange,
                  Colors.orange.withValues(alpha: 0.1),
                ),
            ],
          ),
        ),
        if (_hasFeatures(event)) ...[
          const SizedBox(height: 12),
          EventDetailSectionShell(
            title: 'Features',
            icon: Icons.bolt_rounded,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (event.isOutdoorEvent)
                  EventDetailQuickIconButton(
                    tooltip: 'Outdoor',
                    icon: Icons.landscape_rounded,
                    backgroundColor: const Color(0xFFE0F2F1),
                    iconColor: const Color(0xFF00695C),
                    onPressed: () {},
                  ),
                if (event.hasParking)
                  EventDetailQuickIconButton(
                    tooltip: 'Parking',
                    icon: Icons.local_parking_rounded,
                    backgroundColor: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF2E7D32),
                    onPressed: () {},
                  ),
                if (event.hasRefreshments)
                  EventDetailQuickIconButton(
                    tooltip: 'Refreshments',
                    icon: Icons.restaurant_rounded,
                    backgroundColor: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFEF6C00),
                    onPressed: () {},
                  ),
                if (event.hasWeatherBackup)
                  EventDetailQuickIconButton(
                    tooltip: 'Weather backup',
                    icon: Icons.umbrella_rounded,
                    backgroundColor: const Color(0xFFE3F2FD),
                    iconColor: const Color(0xFF1565C0),
                    onPressed: () {},
                  ),
              ],
            ),
          ),
        ],
        if (event.description?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 12),
          EventDetailSectionShell(
            title: 'About',
            icon: Icons.notes_rounded,
            child: Text(
              event.description!.trim(),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ),
        ],
        if (event.ticketInfo != null && event.ticketInfo!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          EventDetailSectionShell(
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
          EventDetailSectionShell(
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

  Widget _buildChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
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
