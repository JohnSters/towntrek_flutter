import 'package:flutter/material.dart';

enum LandingMessageBannerTone { info, issue }

class LandingMessageBanner extends StatelessWidget {
  final String message;
  final LandingMessageBannerTone tone;

  const LandingMessageBanner({
    super.key,
    required this.message,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isIssue = tone == LandingMessageBannerTone.issue;
    final accent = isIssue ? colorScheme.error : const Color(0xFF1B8A4B);
    final background = isIssue
        ? colorScheme.errorContainer.withValues(alpha: 0.62)
        : const Color(0xFFEAF8EF);
    final border = accent.withValues(alpha: 0.32);
    final badgeBackground = accent.withValues(alpha: 0.14);
    final label = isIssue ? 'Issue alert' : 'Update';
    final icon = isIssue ? Icons.warning_amber_rounded : Icons.info_outline_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBackground,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
