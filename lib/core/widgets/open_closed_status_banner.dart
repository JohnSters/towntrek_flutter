import 'package:flutter/material.dart';

/// A prominent Open/Closed status banner meant to sit directly under the page header.
class OpenClosedStatusBanner extends StatelessWidget {
  final bool isOpen;
  final String openText;
  final String closedText;
  final String? subtitle;

  const OpenClosedStatusBanner({
    super.key,
    required this.isOpen,
    this.openText = 'Open Now',
    this.closedText = 'Closed',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bg = isOpen
        ? const Color(0xFFE8F5E9) // light green
        : const Color(0xFFFFEBEE); // light red
    final accent = isOpen ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final text = isOpen ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          bottom: BorderSide(
            color: (isOpen ? colorScheme.primary : colorScheme.error).withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time_filled, size: 18, color: accent),
          const SizedBox(width: 8),
          Text(
            isOpen ? openText : closedText,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: text,
              letterSpacing: 0.4,
            ),
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: text.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                subtitle!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

