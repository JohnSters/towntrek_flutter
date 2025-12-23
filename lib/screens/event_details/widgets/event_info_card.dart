import 'package:flutter/material.dart';
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
               // Date and Time Chips
               Wrap(
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
                     event.isFreeEvent ? Colors.green.withValues(alpha: 0.1) : colorScheme.tertiaryContainer,
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
              
              const SizedBox(height: 20),
              
              // Features Grid (Outdoor, Parking, etc)
              if (_hasFeatures(event)) ...[
                 _buildFeaturesGrid(context, event),
                 const SizedBox(height: 20),
              ],

              Text(
                'About',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              if (event.description?.isNotEmpty == true)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event.description!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ),

               if (event.ticketInfo != null && event.ticketInfo!.isNotEmpty) ...[
                 const SizedBox(height: 16),
                  Text(
                    'Ticket Info',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.ticketInfo!,
                    style: theme.textTheme.bodyMedium,
                  ),
               ],
               
               if (event.eventProgram != null && event.eventProgram!.isNotEmpty) ...[
                 const SizedBox(height: 16),
                  Text(
                    'Program',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.eventProgram!,
                    style: theme.textTheme.bodyMedium,
                  ),
               ],
            ],
          ),
        ),
      ),
    );
  }

  bool _hasFeatures(EventDetailDto event) {
    return event.isOutdoorEvent || event.hasParking || event.hasRefreshments || event.hasWeatherBackup;
  }

  Widget _buildFeaturesGrid(BuildContext context, EventDetailDto event) {
    final features = <Widget>[];
    
    if (event.isOutdoorEvent) {
       features.add(_buildFeatureItem(context, Icons.landscape, 'Outdoor'));
    }
    if (event.hasParking) {
      features.add(_buildFeatureItem(context, Icons.local_parking, 'Parking'));
    }
    if (event.hasRefreshments) {
      features.add(_buildFeatureItem(context, Icons.restaurant, 'Refreshments'));
    }
    if (event.hasWeatherBackup) {
      features.add(_buildFeatureItem(context, Icons.umbrella, 'Weather Backup'));
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: features,
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
      BuildContext context, IconData icon, String label, Color color, Color backgroundColor) {
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

