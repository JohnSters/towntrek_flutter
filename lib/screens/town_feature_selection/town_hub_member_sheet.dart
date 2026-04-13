import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../../screens/parcels/parcel_member_hub_navigation.dart';
import '../../theme/member_level_tier_style.dart';

/// Bottom sheet: member summary + 2×2 hub actions (same destinations as parcel board footer).
void showTownHubMemberQuickPanel(
  BuildContext context, {
  required TownDto town,
}) {
  final listing = context.entityListing;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: listing.cardBg,
    builder: (sheetContext) {
      return ListenableBuilder(
        listenable: serviceLocator.mobileSessionManager,
        builder: (context, _) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: _TownHubMemberPanelBody(
              town: town,
              sheetContext: sheetContext,
              parentContext: context,
            ),
          );
        },
      );
    },
  );
}

Color _onTierAccentFill(Color accent) =>
    accent.computeLuminance() > 0.55 ? const Color(0xFF1C1B1F) : Colors.white;

String? _resolvedMemberAvatarUrl(String? raw) {
  final t = raw?.trim();
  if (t == null || t.isEmpty) return null;
  final lower = t.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) return t;
  final base = ApiConfig.baseUrl.trim();
  final path = t.startsWith('/') ? t : '/$t';
  return '$base$path';
}

class _TownHubMemberPanelBody extends StatelessWidget {
  const _TownHubMemberPanelBody({
    required this.town,
    required this.sheetContext,
    required this.parentContext,
  });

  final TownDto town;
  final BuildContext sheetContext;
  final BuildContext parentContext;

  void _popThenNavigate(ParcelMemberHubAction action) {
    Navigator.of(sheetContext).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!parentContext.mounted) return;
      openParcelMemberHubAction(parentContext, town: town, action: action);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = serviceLocator.mobileSessionManager;
    final listing = context.entityListing;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profile = session.profile;
    final progression = session.memberProgression;
    final currentLevel = progression?.currentLevel ?? 1;
    final tierStyle = tierStyleForLevel(currentLevel);
    final isDark = theme.brightness == Brightness.dark;
    final onAvatar = _onTierAccentFill(tierStyle.accentColor);

    final displayName = profile?.displayName.trim().isNotEmpty == true
        ? profile!.displayName
        : 'TownTrek member';
    final tierTitle = progression?.currentLevelTitle.trim().isNotEmpty == true
        ? progression!.currentLevelTitle
        : tierStyle.title;
    final rating = profile?.averageRating ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Your TownTrek',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: listing.textTitle,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: tierStyle.ringColor.withValues(alpha: 0.45),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tierStyle.accentColor.withValues(alpha: isDark ? 0.26 : 0.12),
                  isDark
                      ? colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.9,
                        )
                      : Colors.white.withValues(alpha: 0.5),
                  listing.cardBg,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: tierStyle.accentColor.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: tierStyle.ringColor, width: 2),
                  ),
                  child: _HubAvatar(
                    profile: profile,
                    tierStyle: tierStyle,
                    theme: theme,
                    onLetterColor: onAvatar,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: listing.textTitle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        label: rating > 0
                            ? 'Average community rating '
                                '${rating.toStringAsFixed(1)} out of five'
                            : 'No average community rating yet',
                        child: MergeSemantics(
                          child: Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 22,
                                color: Colors.amber.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating > 0 ? rating.toStringAsFixed(1) : '—',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: listing.textTitle,
                                ),
                              ),
                              Text(
                                ' avg',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: listing.bodyText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: tierStyle.accentColor.withValues(
                        alpha: isDark ? 0.22 : 0.14,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: tierStyle.ringColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Semantics(
                      label: 'Level $currentLevel, $tierTitle',
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$currentLevel',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: tierStyle.accentColor,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tierTitle,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: tierStyle.accentColor,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (progression != null) ...[
            const SizedBox(height: 16),
            if (progression.xpForNext > 0) ...[
              Text(
                'Progress to next tier',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: listing.textTitle,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value:
                      progression.xpIntoLevel /
                      (progression.xpIntoLevel + progression.xpForNext),
                  minHeight: 8,
                  color: tierStyle.accentColor,
                  backgroundColor: tierStyle.accentColor.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${progression.xpIntoLevel} XP this tier · '
                '${progression.xpForNext} XP to ${tierStyleForLevel(currentLevel + 1).title}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: listing.bodyText,
                  height: 1.35,
                ),
              ),
            ] else
              Text(
                'Max tier (${tierStyleForLevel(12).title}) — XP still counts '
                'toward seasonal standings.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: listing.bodyText,
                  height: 1.35,
                ),
              ),
          ],
          const SizedBox(height: 22),
          Text(
            'Quick links',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: listing.textTitle,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _hubActionTile(
                  context,
                  icon: Icons.leaderboard_outlined,
                  label: 'Leaderboard',
                  color: const Color(0xFF5E35B1),
                  onTap: () =>
                      _popThenNavigate(ParcelMemberHubAction.leaderboard),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _hubActionTile(
                  context,
                  icon: Icons.trending_up_rounded,
                  label: 'Progress',
                  color: const Color(0xFF00897B),
                  onTap: () => _popThenNavigate(ParcelMemberHubAction.progress),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _hubActionTile(
                  context,
                  icon: Icons.history_rounded,
                  label: 'Activity',
                  color: const Color(0xFFE65100),
                  onTap: () => _popThenNavigate(ParcelMemberHubAction.activity),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _hubActionTile(
                  context,
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  color: const Color(0xFF1565C0),
                  onTap: () => _popThenNavigate(ParcelMemberHubAction.profile),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _hubActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.45),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubAvatar extends StatelessWidget {
  const _HubAvatar({
    required this.profile,
    required this.tierStyle,
    required this.theme,
    required this.onLetterColor,
  });

  final MemberProfileDto? profile;
  final TierStyle tierStyle;
  final ThemeData theme;
  final Color onLetterColor;

  static const double _d = 52;

  @override
  Widget build(BuildContext context) {
    final name = profile?.displayName ?? 'M';
    final letter = name.isNotEmpty ? name[0].toUpperCase() : 'M';
    final url = _resolvedMemberAvatarUrl(profile?.avatarUrl);

    Widget letterFallback() {
      return Container(
        width: _d,
        height: _d,
        color: tierStyle.accentColor,
        alignment: Alignment.center,
        child: Text(
          letter,
          style: theme.textTheme.titleLarge?.copyWith(
            color: onLetterColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return ClipOval(
      child: url != null
          ? CachedNetworkImage(
              imageUrl: url,
              width: _d,
              height: _d,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 200),
              memCacheWidth: 128,
              placeholder: (context, _) => Container(
                width: _d,
                height: _d,
                color: tierStyle.accentColor,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: onLetterColor,
                  ),
                ),
              ),
              errorWidget: (context, url, err) => letterFallback(),
            )
          : letterFallback(),
    );
  }
}

/// Compact “Connect device” FAB for the town hub and parcel board (bottom-right).
class TownHubConnectDeviceFab extends StatelessWidget {
  const TownHubConnectDeviceFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: const Icon(Icons.phonelink_rounded, size: 20),
      label: Text(
        'Connect device',
        style: theme.textTheme.labelLarge?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),
      backgroundColor: scheme.primary.withValues(alpha: 0.76),
      foregroundColor: scheme.onPrimary,
      elevation: 3,
      extendedPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      extendedIconLabelSpacing: 8,
    );
  }
}

/// Tier-styled profile FAB for the town hub (opens member quick panel).
class TownHubLevelFab extends StatelessWidget {
  const TownHubLevelFab({
    super.key,
    required this.level,
    required this.showVerified,
    required this.onPressed,
  });

  static const double _fabSize = 50;
  static const double _iconSize = 25;
  static const double _ringWidth = 2.5;

  /// Used for tier ring colors (same visual language as before the icon swap).
  final int level;
  final bool showVerified;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = tierStyleForLevel(level);
    return Material(
      elevation: 3,
      shadowColor: style.accentColor.withValues(alpha: 0.3),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Ink(
          width: _fabSize,
          height: _fabSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: style.ringColor, width: _ringWidth),
            color: style.accentColor.withValues(alpha: 0.18),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.person_rounded,
                size: _iconSize,
                color: style.accentColor,
              ),
              if (showVerified)
                Positioned(
                  top: -1,
                  right: -1,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: Colors.teal.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
