import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../core/progression/xp_level_math.dart';
import '../../models/models.dart';
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
                      if (sets.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Achievement progress will appear after your first XP awards.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                        itemCount: sets.length,
                        itemBuilder: (context, i) {
                          final s = sets[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          s.setName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                      ),
                                      if (s.isComplete)
                                        Icon(
                                          Icons.verified_rounded,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${s.unlockedCount} / ${s.totalCount} unlocked',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 10),
                                  ...s.achievements.map(
                                    (a) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 6,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            a.unlocked
                                                ? Icons.check_circle_outline
                                                : Icons.radio_button_unchecked,
                                            size: 18,
                                            color: a.unlocked
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.outline,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              a.displayName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          ),
                                          if (a.xpValue > 0)
                                            Text(
                                              '+${a.xpValue}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
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

class _TiersTab extends StatelessWidget {
  const _TiersTab({required this.progression});

  final MemberProgressionDto? progression;

  @override
  Widget build(BuildContext context) {
    final listing = context.entityListing;
    final theme = Theme.of(context);
    final current = progression?.currentLevel ?? 1;
    final totalXp = progression?.totalXp ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      children: [
        if (progression != null) ...[
          Text(
            '${progression!.currentLevelTitle} • $totalXp XP',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: listing.textTitle,
            ),
          ),
          const SizedBox(height: 8),
          if (progression!.xpForNext > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progression!.xpIntoLevel /
                    (progression!.xpIntoLevel + progression!.xpForNext),
                minHeight: 8,
              ),
            )
          else
            Text(
              'Max tier reached — XP still counts toward seasonal standings.',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
            ),
          const SizedBox(height: 6),
          Text(
            progression!.xpForNext > 0
                ? '${progression!.xpIntoLevel} XP into this level • ${progression!.xpForNext} to next'
                : 'Level 12',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
        ],
        Text(
          'All tiers',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        for (var lv = 1; lv <= 12; lv++)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: lv == current
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
                  : listing.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '$lv',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'From ${XpLevelMath.minXpForLevel(lv)} XP',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                if (lv == current)
                  Icon(
                    Icons.flag_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
