import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import 'level_badge.dart';
import 'leaderboard_state.dart';
import 'leaderboard_view_model.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key, required this.town});

  final TownDto town;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LeaderboardViewModel(
        town: town,
        memberRepository: serviceLocator.memberRepository,
        sessionManager: serviceLocator.mobileSessionManager,
      ),
      child: const _LeaderboardScreenBody(),
    );
  }
}

class _LeaderboardScreenBody extends StatefulWidget {
  const _LeaderboardScreenBody();

  @override
  State<_LeaderboardScreenBody> createState() => _LeaderboardScreenBodyState();
}

class _LeaderboardScreenBodyState extends State<_LeaderboardScreenBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureDisclosure());
  }

  Future<void> _ensureDisclosure() async {
    if (!mounted) return;
    final viewModel = context.read<LeaderboardViewModel>();
    if (!viewModel.requiresDisclosure) return;

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

    if (!mounted) return;
    if (accepted == true) {
      await viewModel.acceptDisclosure();
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LeaderboardViewModel>();
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
              townName: viewModel.town.name,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'alltime', label: Text('All-time')),
                  ButtonSegment(value: 'current', label: Text('Season')),
                ],
                selected: {viewModel.season},
                onSelectionChanged: (s) {
                  if (s.isEmpty) return;
                  viewModel.selectSeason(s.first);
                },
              ),
            ),
            Expanded(
              child: switch (viewModel.state) {
                LeaderboardLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                LeaderboardError(message: final message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(message),
                  ),
                ),
                LeaderboardSuccess(data: final data) => ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                  itemCount: data.rows.length,
                  itemBuilder: (context, i) {
                    final row = data.rows[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${i + 1}')),
                        title: Text(row.displayName),
                        subtitle: Text('${row.levelTitle} • ${row.xpValue} XP'),
                        trailing: LevelBadge(level: row.level),
                      ),
                    );
                  },
                ),
              },
            ),
            const ListingBackFooter(label: 'Back'),
          ],
        ),
      ),
    );
  }
}
