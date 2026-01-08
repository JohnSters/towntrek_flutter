import 'package:flutter/material.dart';
import '../../../core/constants/current_events_constants.dart';

/// Widget that displays metadata information in a pill format
class InfoPill extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const InfoPill({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CurrentEventsConstants.pillPaddingHorizontal,
        vertical: CurrentEventsConstants.pillPaddingVertical,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(CurrentEventsConstants.pillBorderRadius),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: CurrentEventsConstants.infoPillFontWeight,
        ),
      ),
    );
  }
}