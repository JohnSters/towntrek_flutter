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
    final normalizedSubtitle = subtitle?.trim();
    final fallbackHeadline = isOpen ? openText : closedText;
    final effectiveHeadline = _buildHeadline(
      normalizedSubtitle,
      fallbackHeadline,
    );
    final effectiveSubtitle = _buildSubtitle(
      normalizedSubtitle,
      effectiveHeadline,
      fallbackHeadline,
    );

    final bg = isOpen
        ? const Color(0xFFE8F5E9) // light green
        : const Color(0xFFFFEBEE); // light red
    final accent = isOpen ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final text = isOpen ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(
          color: (isOpen ? colorScheme.primary : colorScheme.error).withValues(
            alpha: 0.12,
          ),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time_filled, size: 18, color: accent),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  effectiveHeadline,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: text,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          if (effectiveSubtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              effectiveSubtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: accent,
                height: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _buildHeadline(String? normalizedSubtitle, String fallbackHeadline) {
    if (normalizedSubtitle == null || normalizedSubtitle.isEmpty) {
      return fallbackHeadline;
    }

    final lowerSubtitle = normalizedSubtitle.toLowerCase();
    final lowerHeadline = fallbackHeadline.toLowerCase();
    if (lowerSubtitle == lowerHeadline ||
        lowerSubtitle.startsWith(lowerHeadline) ||
        lowerSubtitle.contains('currently $lowerHeadline')) {
      return normalizedSubtitle;
    }

    return fallbackHeadline;
  }

  String? _buildSubtitle(
    String? normalizedSubtitle,
    String effectiveHeadline,
    String fallbackHeadline,
  ) {
    if (normalizedSubtitle == null || normalizedSubtitle.isEmpty) {
      return null;
    }

    if (effectiveHeadline == normalizedSubtitle) {
      return null;
    }

    if (normalizedSubtitle.toLowerCase() == fallbackHeadline.toLowerCase()) {
      return null;
    }

    return normalizedSubtitle;
  }
}
