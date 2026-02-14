import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../core/constants/current_events_constants.dart';

/// Widget that displays event pricing information in a pill format
class PricePill extends StatelessWidget {
  final EventDto event;

  const PricePill({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isFree = event.isFreeEvent;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CurrentEventsConstants.pillPaddingHorizontal,
        vertical: CurrentEventsConstants.pillPaddingVertical,
      ),
      decoration: BoxDecoration(
        color: isFree
            ? Colors.green.withValues(alpha: CurrentEventsConstants.freePillBackgroundOpacity)
            : colorScheme.primary.withValues(alpha: CurrentEventsConstants.primaryPillBackgroundOpacity),
        borderRadius: BorderRadius.circular(CurrentEventsConstants.pillBorderRadius),
        border: Border.all(
          color: isFree
              ? Colors.green.withValues(alpha: CurrentEventsConstants.pillBorderOpacity)
              : colorScheme.primary.withValues(alpha: CurrentEventsConstants.pillBorderOpacity),
        ),
      ),
      child: Text(
        '${CurrentEventsConstants.entryFeeLabel} ${event.displayPrice}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: isFree ? Colors.green : colorScheme.primary,
          fontWeight: CurrentEventsConstants.pillFontWeight,
          fontSize: CurrentEventsConstants.pillFontSize,
        ),
      ),
    );
  }
}