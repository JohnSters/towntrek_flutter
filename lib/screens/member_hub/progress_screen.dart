import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../core/progression/xp_level_math.dart';
import '../../models/models.dart';
import '../../theme/member_level_tier_style.dart';
import 'level_badge.dart';

/// Three tabs: tier ladder, achievement sets, paginated XP history.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  XpHistoryPageDto? _historyPage;
  bool _historyLoading = false;
  String? _historyError;
  int _historyPageNum = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTab);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      serviceLocator.mobileSessionManager.loadProgression();
      _loadHistory();
    });
  }

  void _onTab() {
    if (_tabController.index == 2 && _historyPage == null && !_historyLoading) {
      _loadHistory();
    }
  }

  Future<void> _loadHistory({int page = 1}) async {
    setState(() {
      _historyLoading = true;
      _historyError = null;
      _historyPageNum = page;
    });
    try {
      final pageDto = await serviceLocator.memberRepository.getXpHistory(
        page: page,
        pageSize: 25,
      );
      if (mounted) {
        setState(() {
          _historyPage = pageDto;
          _historyLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _historyError = e.toString();
          _historyLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTab);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listing = context.entityListing;
    final session = serviceLocator.mobileSessionManager;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: listing.pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EntityListingHeroHeader(
              theme: context.entityListingTheme,
              categoryIcon: Icons.trending_up_rounded,
              subCategoryName: 'Progress',
              categoryName: TownFeatureConstants.parcelsTitle,
              townName: 'Your account',
            ),
            TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.35),
              tabs: const [
                Tab(text: 'Tiers'),
                Tab(text: 'Sets'),
                Tab(text: 'Sources'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ListenableBuilder(
                    listenable: session,
                    builder: (context, _) {
                      final p = session.memberProgression;
                      return _TiersTab(progression: p);
                    },
                  ),
                  ListenableBuilder(
                    listenable: session,
                    builder: (context, _) {
                      final sets =
                          session.memberProgression?.achievementSets ??
                          const [];
                      final listing = context.entityListing;
                      if (sets.isEmpty) {
                        return ListView(
                          padding: const EdgeInsets.fromLTRB(14, 24, 14, 24),
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                28,
                                20,
                                28,
                              ),
                              decoration: BoxDecoration(
                                color: listing.cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withValues(alpha: 0.18),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.emoji_events_outlined,
                                    size: 52,
                                    color: listing.accent.withValues(
                                      alpha: 0.9,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Achievement sets unlock as you earn XP.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: listing.textTitle,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Complete deliveries, post requests, and '
                                    'stay active — your first awards will '
                                    'appear here.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: listing.bodyText,
                                          height: 1.45,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                        itemCount: sets.length,
                        itemBuilder: (context, i) {
                          return _AchievementSetCard(
                            set: sets[i],
                            paletteIndex: i,
                          );
                        },
                      );
                    },
                  ),
                  _buildHistoryTab(context),
                ],
              ),
            ),
            const ListingBackFooter(label: 'Back'),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    if (_historyLoading && _historyPage == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_historyError != null && _historyPage == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_historyError!),
        ),
      );
    }
    final page = _historyPage;
    if (page == null) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            itemCount: page.items.length,
            itemBuilder: (context, i) {
              final item = page.items[i];
              final when = item.awardedAt.toLocal();
              return ListTile(
                title: Text(item.eventLabel),
                subtitle: Text(
                  '${when.year}-${when.month.toString().padLeft(2, '0')}-${when.day.toString().padLeft(2, '0')}',
                ),
                trailing: Text(
                  '+${item.amount}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              );
            },
          ),
        ),
        if (page.total > page.pageSize)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _historyPageNum <= 1 || _historyLoading
                      ? null
                      : () => _loadHistory(page: _historyPageNum - 1),
                  child: const Text('Previous'),
                ),
                Text('Page ${page.page}'),
                TextButton(
                  onPressed:
                      _historyPageNum * page.pageSize >= page.total ||
                          _historyLoading
                      ? null
                      : () => _loadHistory(page: _historyPageNum + 1),
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

String _tierXpRangeLabel(int level) {
  final min = XpLevelMath.minXpForLevel(level);
  if (level >= 12) {
    return '$min+ XP total';
  }
  final nextMin = XpLevelMath.minXpForLevel(level + 1);
  return '$min – ${nextMin - 1} XP';
}

double _tierLadderFill({
  required int level,
  required int currentLevel,
  required int xpIntoLevel,
  required int xpForNext,
}) {
  if (level < currentLevel) return 1;
  if (level > currentLevel) return 0;
  if (xpForNext <= 0) return 1;
  final denom = xpIntoLevel + xpForNext;
  if (denom <= 0) return 0;
  return (xpIntoLevel / denom).clamp(0.0, 1.0);
}

class _TiersTab extends StatelessWidget {
  const _TiersTab({required this.progression});

  final MemberProgressionDto? progression;

  @override
  Widget build(BuildContext context) {
    final listing = context.entityListing;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final currentLevel = progression?.currentLevel ?? 1;
    final totalXp = progression?.totalXp ?? 0;
    final xpInto =
        progression?.xpIntoLevel ??
        XpLevelMath.xpIntoCurrentLevel(totalXp, currentLevel);
    final xpForNext =
        progression?.xpForNext ??
        XpLevelMath.xpToNextLevel(totalXp, currentLevel);
    final currentStyle = tierStyleForLevel(currentLevel);

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      children: [
        if (progression != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: currentStyle.ringColor.withValues(alpha: 0.5),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  currentStyle.accentColor.withValues(
                    alpha: isDark ? 0.26 : 0.14,
                  ),
                  isDark
                      ? colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.95,
                        )
                      : Colors.white.withValues(alpha: 0.55),
                  listing.cardBg,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: currentStyle.accentColor.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LevelBadge(
                  level: progression!.currentLevel,
                  title: progression!.currentLevelTitle,
                  full: true,
                ),
                const SizedBox(height: 12),
                Text(
                  '$totalXp total XP',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: listing.textTitle,
                  ),
                ),
                const SizedBox(height: 10),
                if (progression!.xpForNext > 0) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value:
                          progression!.xpIntoLevel /
                          (progression!.xpIntoLevel + progression!.xpForNext),
                      minHeight: 8,
                      color: currentStyle.accentColor,
                      backgroundColor: currentStyle.accentColor.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${progression!.xpIntoLevel} XP this tier · '
                    '${progression!.xpForNext} XP to ${tierStyleForLevel(currentLevel + 1).title}',
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
            ),
          ),
          const SizedBox(height: 22),
        ] else ...[
          Text(
            'Connect your device to see your level, XP, and tier ladder.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: listing.bodyText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          'All tiers',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: listing.textTitle,
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 12),
        for (var lv = 1; lv <= 12; lv++)
          _TierLadderRow(
            level: lv,
            currentLevel: currentLevel,
            xpIntoLevel: xpInto,
            xpForNext: xpForNext,
            listing: listing,
            theme: theme,
            colorScheme: colorScheme,
          ),
      ],
    );
  }
}

class _TierLevelCircle extends StatelessWidget {
  const _TierLevelCircle({
    required this.level,
    required this.style,
    required this.theme,
    required this.dimmed,
  });

  final int level;
  final TierStyle style;
  final ThemeData theme;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final label = isDark ? style.labelColorDark : style.labelColorLight;
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: style.ringColor.withValues(alpha: dimmed ? 0.35 : 1),
          width: 2,
        ),
        color: style.accentColor.withValues(alpha: dimmed ? 0.06 : 0.16),
      ),
      child: Text(
        '$level',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: dimmed ? theme.colorScheme.onSurfaceVariant : label,
        ),
      ),
    );
  }
}

class _TierLadderRow extends StatelessWidget {
  const _TierLadderRow({
    required this.level,
    required this.currentLevel,
    required this.xpIntoLevel,
    required this.xpForNext,
    required this.listing,
    required this.theme,
    required this.colorScheme,
  });

  final int level;
  final int currentLevel;
  final int xpIntoLevel;
  final int xpForNext;
  final EntityListingThemeExtension listing;
  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final rowStyle = tierStyleForLevel(level);
    final isCurrent = level == currentLevel;
    final isPast = level < currentLevel;
    final isFuture = level > currentLevel;
    final fill = _tierLadderFill(
      level: level,
      currentLevel: currentLevel,
      xpIntoLevel: xpIntoLevel,
      xpForNext: xpForNext,
    );
    final trackColor = isFuture
        ? colorScheme.outlineVariant.withValues(alpha: 0.35)
        : rowStyle.accentColor.withValues(alpha: 0.14);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: listing.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent
              ? rowStyle.ringColor.withValues(alpha: 0.65)
              : colorScheme.outline.withValues(alpha: 0.14),
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: rowStyle.accentColor.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isCurrent) Container(width: 5, color: rowStyle.accentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TierLevelCircle(
                            level: level,
                            style: rowStyle,
                            theme: theme,
                            dimmed: isFuture,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        rowStyle.title,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: listing.textTitle,
                                            ),
                                      ),
                                    ),
                                    if (isPast)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 22,
                                        color: const Color(0xFF059669),
                                      )
                                    else if (isCurrent)
                                      Icon(
                                        Icons.place_rounded,
                                        size: 22,
                                        color: rowStyle.accentColor,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _tierXpRangeLabel(level),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: rowStyle.accentColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  rowStyle.perkTagline,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: listing.bodyText,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: fill,
                          minHeight: 7,
                          color: isFuture
                              ? colorScheme.outline.withValues(alpha: 0.25)
                              : rowStyle.accentColor,
                          backgroundColor: trackColor,
                        ),
                      ),
                    ],
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

class _AchievementSetCard extends StatelessWidget {
  const _AchievementSetCard({required this.set, required this.paletteIndex});

  final AchievementSetProgressDto set;
  final int paletteIndex;

  @override
  Widget build(BuildContext context) {
    final listing = context.entityListing;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent =
        achievementSetCardAccents[paletteIndex %
            achievementSetCardAccents.length];
    final ratio = set.totalCount > 0 ? set.unlockedCount / set.totalCount : 0.0;
    const unlockGreen = Color(0xFF059669);

    // Blend accent into card base only slightly — avoids a harsh white diagonal
    // when [listing.cardBg] is near-white between two tinted stops.
    final base = listing.cardBg;
    final cornerTint = isDark ? 0.11 : 0.07;
    final midTint = isDark ? 0.035 : 0.022;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: set.isComplete
              ? unlockGreen.withValues(alpha: 0.45)
              : colorScheme.outline.withValues(alpha: 0.14),
          width: set.isComplete ? 1.5 : 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.42, 0.58, 1.0],
          colors: [
            Color.lerp(base, accent, cornerTint)!,
            Color.lerp(base, accent, midTint)!,
            Color.lerp(base, accent, midTint)!,
            Color.lerp(base, accent, cornerTint * 0.85)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: isDark ? 0.35 : 0.22),
                    border: Border.all(color: accent.withValues(alpha: 0.55)),
                  ),
                  child: Icon(
                    Icons.workspace_premium_outlined,
                    color: isDark ? Colors.white : accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        set.setName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: listing.textTitle,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: ratio.clamp(0.0, 1.0),
                                minHeight: 6,
                                color: set.isComplete ? unlockGreen : accent,
                                backgroundColor: colorScheme.outlineVariant
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${set.unlockedCount}/${set.totalCount}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: listing.textTitle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (set.isComplete)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Icon(
                      Icons.verified_rounded,
                      color: unlockGreen,
                      size: 28,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...set.achievements.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      a.unlocked
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: a.unlocked ? unlockGreen : colorScheme.outline,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        a.displayName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: a.unlocked
                              ? listing.textTitle
                              : colorScheme.onSurfaceVariant,
                          fontWeight: a.unlocked
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (a.xpValue > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: a.unlocked
                              ? accent.withValues(alpha: isDark ? 0.35 : 0.2)
                              : colorScheme.surfaceContainerHighest.withValues(
                                  alpha: 0.6,
                                ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+${a.xpValue}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: a.unlocked ? accent : colorScheme.outline,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
