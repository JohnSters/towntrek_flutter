import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';

class EventLocationSection extends StatelessWidget {
  final EventDetailDto event;

  const EventLocationSection({
    super.key,
    required this.event,
  });

  Future<void> _openMap(BuildContext context) async {
    final hasCoords = event.latitude != null && event.longitude != null;

    // Prefer the same "Take me there" style flow used by Businesses (directions to lat/lng)
    if (hasCoords) {
      final result = await serviceLocator.navigationService.openExternalNavigation(
        event.latitude!,
        event.longitude!,
        event.venue ?? event.name,
      );

      if (result.isFailure && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Unable to open navigation'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Fallback: map search by address/name (still better than doing nothing)
    final parts = <String>[
      if (event.venue?.trim().isNotEmpty == true) event.venue!.trim(),
      if (event.venueAddress?.trim().isNotEmpty == true) event.venueAddress!.trim(),
      if (event.physicalAddress.trim().isNotEmpty) event.physicalAddress.trim(),
    ];
    final query = parts.join(' ');

    if (query.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location not available for this event'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );

    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No maps app available'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasCoords = event.latitude != null && event.longitude != null;
    final hasAddress = event.physicalAddress.trim().isNotEmpty ||
        (event.venueAddress?.trim().isNotEmpty ?? false) ||
        (event.venue?.trim().isNotEmpty ?? false);
    final canOpenMaps = hasCoords || hasAddress;

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
              Text(
                'Location',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (event.venue != null)
                          Text(
                            event.venue!,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        Text(
                          event.physicalAddress,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (event.venueAddress != null && event.venueAddress != event.physicalAddress)
                           Text(
                            event.venueAddress!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Map Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: canOpenMaps ? () => _openMap(context) : null,
                  icon: const Icon(Icons.map),
                  label: const Text('Open in Maps'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

