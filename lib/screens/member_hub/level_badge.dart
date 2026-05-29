import 'package:flutter/material.dart';

import '../../theme/member_level_tier_style.dart';

/// Compact ring + level for board cards; [full] adds title line for profile / progress.
/// [prominent] uses a larger ring and type for profile-style plaques.
class LevelBadge extends StatelessWidget {
  const LevelBadge({
    super.key,
    required this.level,
    this.title,
    this.full = false,
    this.prominent = false,
  });

  final int? level;
  final String? title;
  final bool full;
  final bool prominent;

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
            Icon(
              Icons.military_tech_outlined,
              size: 14,
              color: style.accentColor,
            ),
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
    final ring = prominent ? 44.0 : 36.0;
    final borderW = prominent ? 2.5 : 2.0;
    final titleStyle = prominent
        ? theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: labelColor,
          )
        : theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: labelColor,
          );
    final digitStyle = prominent
        ? theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: labelColor,
          )
        : theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: labelColor,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: ring,
              height: ring,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: style.ringColor, width: borderW),
                color: style.accentColor.withValues(
                  alpha: prominent ? 0.18 : 0.15,
                ),
              ),
              child: Text('$lv', style: digitStyle),
            ),
            SizedBox(width: prominent ? 12 : 10),
            Expanded(child: Text(displayTitle, style: titleStyle)),
          ],
        ),
      ],
    );
  }
}
