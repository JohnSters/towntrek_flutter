import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../core/widgets/app_scaffold_messenger.dart';
import '../../models/models.dart';
import '../../theme/member_level_tier_style.dart';

/// XP toast, optional level-up sheet, staggered achievement snackbars (root messenger).
class ParcelXpFeedback {
  ParcelXpFeedback._();

  static void showForDetail(ParcelDetailDto detail) {
    final delta = detail.xpDelta;
    if (delta == null || !delta.hasAward) {
      return;
    }

    final messenger = AppScaffoldMessenger.state;
    if (messenger == null) {
      return;
    }

    if (delta.awarded > 0) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('+${delta.awarded} XP'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (delta.leveledUp) {
      final title = delta.newLevelTitle ?? 'Level up!';
      final style = tierStyleForLevel(delta.currentLevel);
      final ctx = messenger.context;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!ctx.mounted) return;
        showModalBottomSheet<void>(
          context: ctx,
          showDragHandle: true,
          builder: (sheetCtx) {
            final theme = Theme.of(sheetCtx);
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Level up!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: style.accentColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You’re growing your TownTrek standing — keep helping neighbours.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                    child: const Text('Nice'),
                  ),
                ],
              ),
            );
          },
        );
      });
    }

    final ach = delta.achievementsUnlocked;
    if (ach.isEmpty) {
      return;
    }
    final first = _achievementLabel(ach.first);
    final more = ach.length - 1;
    final achText = more > 0
        ? 'Achievement: $first (+$more more)'
        : 'Achievement: $first';
    Future<void>.delayed(const Duration(milliseconds: 400), () {
      messenger.showSnackBar(
        SnackBar(
          content: Text(achText),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  static String _achievementLabel(String key) {
    final sets =
        serviceLocator.mobileSessionManager.memberProgression?.achievementSets ??
        const <AchievementSetProgressDto>[];
    for (final set in sets) {
      for (final achievement in set.achievements) {
        if (achievement.key == key && achievement.displayName.isNotEmpty) {
          return achievement.displayName;
        }
      }
    }

    return _humanizeAchievementKey(key);
  }

  static String _humanizeAchievementKey(String key) {
    final words = key
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .toList();
    return words.isEmpty ? key : words.join(' ');
  }
}
