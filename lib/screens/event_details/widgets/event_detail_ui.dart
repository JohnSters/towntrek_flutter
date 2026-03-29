import 'package:flutter/material.dart';

/// Section container matching [business_details_page] `_SectionShell`.
class EventDetailSectionShell extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const EventDetailSectionShell({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// Square quick-action control matching [business_details_page] `_QuickActionIconButton`.
class EventDetailQuickIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onPressed;

  const EventDetailQuickIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 56,
        height: 56,
        child: IconButton(
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: Icon(
            icon,
            size: 24,
            color: onPressed == null
                ? iconColor.withValues(alpha: 0.38)
                : iconColor,
          ),
        ),
      ),
    );
  }
}
