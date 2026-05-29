import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import 'level_badge.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, required this.town});

  final TownDto town;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _season = 'alltime';
  LeaderboardResponseDto? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final canLoad = await _maybeShowDisclosure();
      if (!mounted || !canLoad) return;
      await _load();
    });
  }

  Future<bool> _maybeShowDisclosure() async {
    final session = serviceLocator.mobileSessionManager;
    await session.loadProgression();
    if (!mounted) return false;
    final seen =
        session.memberProgression?.leaderboardDisclosureSeen ?? true;
    if (seen) return true;

    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Leaderboard & visibility',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'The leaderboard shows your display name, level, and XP for this town. '
                'You can turn off appearing on the leaderboard from your profile settings on the website. '
                'By continuing, you confirm you understand how this information is shown to other members '
                '(POPIA transparency).',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('I understand'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Go back'),
              ),
            ],
          ),
        );
      },
    );

    if (accepted == true && mounted) {
      try {
        await serviceLocator.memberRepository.markLeaderboardDisclosureSeen();
        serviceLocator.mobileSessionManager.setLeaderboardDisclosureSeenLocal();
      } catch (_) {
        /* non-blocking */
      }
      return true;
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
    return false;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await serviceLocator.memberRepository.getLeaderboard(
        townId: widget.town.id,
        season: _season,
      );
      if (mounted) {
        setState(() {
          _data = res;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = context.entityListing;
    return Scaffold(
      backgroundColor: listing.pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EntityListingHeroHeader(
              theme: context.entityListingTheme,
              categoryIcon: Icons.leaderboard_outlined,
              subCategoryName: 'Leaderboard',
              categoryName: TownFeatureConstants.parcelsTitle,
              townName: widget.town.name,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'alltime', label: Text('All-time')),
                  ButtonSegment(value: 'current', label: Text('Season')),
                ],
                selected: {_season},
                onSelectionChanged: (s) {
                  if (s.isEmpty) return;
                  setState(() => _season = s.first);
                  _load();
                },
              ),
            ),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                  itemCount: _data?.rows.length ?? 0,
                  itemBuilder: (context, i) {
                    final row = _data!.rows[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${i + 1}'),
                        ),
                        title: Text(row.displayName),
                        subtitle: Text('${row.levelTitle} • ${row.xpValue} XP'),
                        trailing: LevelBadge(level: row.level),
                      ),
                    );
                  },
                ),
              ),
            const ListingBackFooter(label: 'Back'),
          ],
        ),
      ),
    );
  }
}
