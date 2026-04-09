import 'package:flutter/material.dart';

import '../../theme/member_level_tier_style.dart';

/// Compact ring + level for board cards; [full] adds title line for profile / progress.
class LevelBadge extends StatelessWidget {
  const LevelBadge({
    super.key,
    required this.level,
    this.title,
    this.full = false,
  });

  final int? level;
  final String? title;
  final bool full;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    if (level == null || level! < 1) {
      return Text(
        full ? 'Level —' : '—',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    final lv = level!.clamp(1, 12);
    final style = tierStyleForLevel(lv);
    final labelColor = isDark ? style.labelColorDark : style.labelColorLight;

    if (!full) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: style.ringColor, width: 1.4),
          color: style.accentColor.withValues(alpha: 0.12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.military_tech_outlined, size: 14, color: style.accentColor),
            const SizedBox(width: 4),
            Text(
              '$lv',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: labelColor,
              ),
            ),
          ],
        ),
      );
    }

    final displayTitle = title ?? style.title;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: style.ringColor, width: 2),
                color: style.accentColor.withValues(alpha: 0.15),
              ),
              child: Text(
                '$lv',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: labelColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                displayTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
