import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import 'parcel_ui.dart';
import 'request_detail_screen.dart';

class MyActivityViewModel extends ChangeNotifier {
  MyActivityViewModel({required MemberRepository repository})
    : _repository = repository {
    load();
  }

  final MemberRepository _repository;

  bool loading = true;
  String? error;
  MemberActivityDto? activity;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      activity = await _repository.getMyActivity();
    } catch (err) {
      error = err.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

class MyActivityScreen extends StatelessWidget {
  const MyActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          MyActivityViewModel(repository: serviceLocator.memberRepository),
      child: const _MyActivityBody(),
    );
  }
}

class _MyActivityBody extends StatelessWidget {
  const _MyActivityBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyActivityViewModel>();
    final listing = context.entityListing;
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: listing.pageBg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EntityListingHeroHeader(
                theme: context.entityListingTheme,
                categoryIcon: Icons.history_rounded,
                subCategoryName: 'My activity',
                categoryName: TownFeatureConstants.parcelsTitle,
                townName: 'Your account',
              ),
              TabBar(
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                indicatorColor: colorScheme.primary,
                dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.35),
                tabs: const [
                  Tab(text: 'My Requests'),
                  Tab(text: 'My Deliveries'),
                ],
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (viewModel.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (viewModel.error != null || viewModel.activity == null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            viewModel.error ?? 'Unable to load activity',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return TabBarView(
                      children: [
                        _ParcelListView(
                          items: viewModel.activity!.myRequests,
                        ),
                        _ParcelListView(
                          items: viewModel.activity!.myDeliveries,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const ListingBackFooter(label: 'Back'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParcelListView extends StatelessWidget {
  const _ParcelListView({required this.items});

  final List<ParcelSummaryDto> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(14, 24, 14, 24),
        children: [
          _ActivityEmptyCard(
            icon: Icons.inbox_outlined,
            message:
                'Nothing here yet. Open requests you post or deliveries you take on will show up in these tabs.',
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final parcel = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ParcelCard(
            parcel: parcel,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RequestDetailScreen(requestId: parcel.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ActivityEmptyCard extends StatelessWidget {
  const _ActivityEmptyCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final listing = context.entityListing;
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outline.withValues(alpha: 0.18);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      decoration: BoxDecoration(
        color: listing.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: outline),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: listing.accent.withValues(alpha: 0.85)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: listing.bodyText,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
