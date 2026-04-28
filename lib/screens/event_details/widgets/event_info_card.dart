import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import '../../shared/detail_widgets/detail_widgets.dart';

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
              DetailMetadataTag(
                label: event.displayDate,
                icon: Icons.calendar_today_rounded,
              ),
              if (event.startTime != null)
                DetailMetadataTag(
                  label:
                      '${event.startTime} ${event.endTime != null ? '- ${event.endTime}' : ''}',
                  icon: Icons.schedule_rounded,
                ),
              DetailMetadataTag(
                label: event.displayPrice,
                icon: Icons.payments_outlined,
              ),
              if (event.ageRestrictions != null && event.ageRestrictions!.isNotEmpty)
                DetailMetadataTag(
                  label: event.ageRestrictions!,
                  icon: Icons.warning_amber_rounded,
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
                  const DetailMetadataTag(
                    label: 'Outdoor',
                    icon: Icons.landscape_rounded,
                  ),
                if (event.hasParking)
                  const DetailMetadataTag(
                    label: 'Parking',
                    icon: Icons.local_parking_rounded,
                  ),
                if (event.hasRefreshments)
                  const DetailMetadataTag(
                    label: 'Refreshments',
                    icon: Icons.restaurant_rounded,
                  ),
                if (event.hasWeatherBackup)
                  const DetailMetadataTag(
                    label: 'Weather backup',
                    icon: Icons.umbrella_rounded,
                  ),
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
}
