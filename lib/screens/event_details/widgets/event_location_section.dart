import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import 'event_detail_ui.dart';

class EventLocationSection extends StatelessWidget {
  final EventDetailDto event;

  const EventLocationSection({
    super.key,
    required this.event,
  });

  /// Normalizes for comparison so we can treat "same street, different formatting" as one address.
  static String _normalizeAddressKey(String s) {
    return s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// When [physicalAddress] and [venueAddress] are the same place (one is a shorter/longer variant),
  /// show a single line — usually the more complete one.
  static List<String> _dedupedAddressLines(String physical, String? venue) {
    final p = physical.trim();
    final v = venue?.trim() ?? '';
    if (p.isEmpty && v.isEmpty) return const [];
    if (p.isEmpty) return [v];
    if (v.isEmpty) return [p];
    if (p == v) return [p];

    final pKey = _normalizeAddressKey(p);
    final vKey = _normalizeAddressKey(v);
    if (pKey == vKey) return [p];

    if (pKey.contains(vKey) || vKey.contains(pKey)) {
      return [p.length >= v.length ? p : v];
    }

    return [p, v];
  }

  Future<void> _openMap(BuildContext context) async {
    final hasCoords = event.latitude != null && event.longitude != null;

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
    final hasCoords = event.latitude != null && event.longitude != null;
    final hasAddress = event.physicalAddress.trim().isNotEmpty ||
        (event.venueAddress?.trim().isNotEmpty ?? false) ||
        (event.venue?.trim().isNotEmpty ?? false);
    if (!hasCoords && !hasAddress) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final canOpenMaps = hasCoords || hasAddress;
    final addressLines = _dedupedAddressLines(
      event.physicalAddress,
      event.venueAddress,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: EventDetailSectionShell(
        title: 'Location',
        icon: Icons.place_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.venue != null && event.venue!.trim().isNotEmpty)
              Text(
                event.venue!.trim(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            for (var i = 0; i < addressLines.length; i++) ...[
              if (i > 0 || (event.venue != null && event.venue!.trim().isNotEmpty))
                const SizedBox(height: 6),
              Text(
                addressLines[i],
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.35,
                  color: colorScheme.onSurface.withValues(alpha: 0.88),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                EventDetailQuickIconButton(
                  tooltip: 'Take me there',
                  icon: Icons.directions_rounded,
                  backgroundColor: const Color(0xFFE0F2F1),
                  iconColor: const Color(0xFF00695C),
                  onPressed: canOpenMaps ? () => _openMap(context) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
