import 'package:flutter/material.dart';

import '../../../core/constants/creative_spaces_constants.dart';
import '../../../core/utils/operating_hours_display_format.dart';

class DetailHourRow extends StatelessWidget {
  const DetailHourRow({
    super.key,
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    required this.isOpen,
    this.note,
    this.isSpecial = false,
  });

  final String dayOfWeek;
  final String? openTime;
  final String? closeTime;
  final bool isOpen;
  final bool isSpecial;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeText = openTime == null ||
            closeTime == null ||
            openTime!.trim().isEmpty ||
            closeTime!.trim().isEmpty
        ? (isOpen
            ? CreativeSpacesConstants.openLabel
            : CreativeSpacesConstants.closedBadge)
        : CreativeSpacesConstants.timeRangeTemplate
            .replaceAll(
              '{start}',
              formatOperatingHoursTimeForDisplay(openTime!),
            )
            .replaceAll(
              '{end}',
              formatOperatingHoursTimeForDisplay(closeTime!),
            );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dayOfWeek,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (isSpecial && isOpen == false)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                CreativeSpacesConstants.specialLabel,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Text(
            timeText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isOpen
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (note != null && note!.trim().isNotEmpty) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                note!.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
