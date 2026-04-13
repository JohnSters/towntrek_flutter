import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../core/utils/url_utils.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import 'connect_device_sheet.dart';
import 'parcel_ui.dart';
import '../town_feature_selection/town_hub_member_sheet.dart';
import 'post_request_screen.dart';
import 'request_detail_screen.dart';

enum BoardListFilter { all, parcels, routes }

/// Sub-filter for route rows when primary filter is All or Routes.
enum BoardRoutePerspectiveFilter { any, needLift, offeringLift }

class ParcelBoardViewModel extends ChangeNotifier {
  ParcelBoardViewModel({
    required this.town,
    required ParcelRepository repository,
  }) : _repository = repository {
    load();
  }

  final TownDto town;
  final ParcelRepository _repository;

  bool loading = true;
  String? error;
  List<ParcelSummaryDto> items = [];
  BoardListFilter listFilter = BoardListFilter.all;
  BoardRoutePerspectiveFilter routePerspectiveFilter =
      BoardRoutePerspectiveFilter.any;

  List<ParcelSummaryDto> get visibleItems {
    Iterable<ParcelSummaryDto> row = switch (listFilter) {
      BoardListFilter.all => items,
      BoardListFilter.parcels => items.where(
        (p) => p.requestType == ParcelRequestType.standardParcel,
      ),
      BoardListFilter.routes => items.where(
        (p) => p.requestType == ParcelRequestType.routeRequest,
      ),
    };
    if (listFilter == BoardListFilter.all ||
        listFilter == BoardListFilter.routes) {
      if (routePerspectiveFilter == BoardRoutePerspectiveFilter.needLift) {
        row = row.where(
          (p) =>
              p.requestType != ParcelRequestType.routeRequest ||
              p.routeListingPerspective == RouteListingPerspective.needLift,
        );
      } else if (routePerspectiveFilter ==
          BoardRoutePerspectiveFilter.offeringLift) {
        row = row.where(
          (p) =>
              p.requestType != ParcelRequestType.routeRequest ||
              p.routeListingPerspective ==
                  RouteListingPerspective.offeringLift,
        );
      }
    }
    return row.toList();
  }

  void setListFilter(BoardListFilter value) {
    if (listFilter == value) return;
    listFilter = value;
    notifyListeners();
  }

  void setRoutePerspectiveFilter(BoardRoutePerspectiveFilter value) {
    if (routePerspectiveFilter == value) return;
    routePerspectiveFilter = value;
    notifyListeners();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final response = await _repository.getBoard(town.id);
      items = response.items;
    } catch (err) {
      error = err.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key, required this.town});

  final TownDto town;

  @override
  Widget build(BuildContext context) {
    return ParcelBoardScaffold(town: town, authenticatedMode: true);
  }
}

class ParcelBoardScaffold extends StatelessWidget {
  const ParcelBoardScaffold({
    super.key,
    required this.town,
    required this.authenticatedMode,
  });

  final TownDto town;
  final bool authenticatedMode;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ParcelBoardViewModel(
        town: town,
        repository: serviceLocator.parcelRepository,
      ),
      child: _ParcelBoardBody(town: town, authenticatedMode: authenticatedMode),
    );
  }
}

class _ParcelBoardBody extends StatelessWidget {
  const _ParcelBoardBody({required this.town, required this.authenticatedMode});

  final TownDto town;
  final bool authenticatedMode;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ParcelBoardViewModel>();
    final listing = context.entityListing;
    final bottomFabInset =
        TownFeatureConstants.floatingHubActionBottomInset +
        MediaQuery.paddingOf(context).bottom;

    return ListenableBuilder(
      listenable: serviceLocator.mobileSessionManager,
      builder: (context, _) {
        final sessionManager = serviceLocator.mobileSessionManager;
        final authed = sessionManager.isAuthenticated;

        return Scaffold(
          backgroundColor: listing.pageBg,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: authenticatedMode
              ? Padding(
                  padding: EdgeInsets.only(bottom: bottomFabInset),
                  child: authed
                      ? TownHubLevelFab(
                          level:
                              sessionManager.memberProgression?.currentLevel ??
                                  1,
                          showVerified:
                              sessionManager.profile?.trustLevel ==
                                  MemberTrustLevel.trusted,
                          onPressed: () => showTownHubMemberQuickPanel(
                                context,
                                town: town,
                              ),
                        )
                      : TownHubConnectDeviceFab(
                          onPressed: () =>
                              showConnectDeviceSheet(context),
                        ),
                )
              : null,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EntityListingHeroHeader(
                  theme: context.entityListingTheme,
                  categoryIcon: Icons.inventory_2_outlined,
                  subCategoryName: 'Open requests',
                  categoryName: TownFeatureConstants.parcelsTitle,
                  townName: town.name,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (!authenticatedMode) {
                          await showGuestParcelPrompt(
                            context,
                            onDeviceConnected: () async {
                              if (!context.mounted) return;
                              await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PostRequestScreen(town: town),
                                ),
                              );
                            },
                          );
                          return;
                        }
                        if (!await _parcelBoardEnsureSignedIn(context)) {
                          return;
                        }
                        if (!context.mounted) return;
                        final created = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => PostRequestScreen(town: town),
                          ),
                        );
                        if (created == true && context.mounted) {
                          await context.read<ParcelBoardViewModel>().load();
                        }
                      },
                      icon: Icon(
                        authenticatedMode
                            ? Icons.add_rounded
                            : Icons.favorite_border,
                      ),
                      label: Text(
                        authenticatedMode
                            ? 'Post request'
                            : 'Connect your device to post or respond to listings',
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                  child: SegmentedButton<BoardListFilter>(
                    segments: const [
                      ButtonSegment<BoardListFilter>(
                        value: BoardListFilter.all,
                        label: Text('All'),
                      ),
                      ButtonSegment<BoardListFilter>(
                        value: BoardListFilter.parcels,
                        label: Text('Parcels'),
                      ),
                      ButtonSegment<BoardListFilter>(
                        value: BoardListFilter.routes,
                        label: Text('Routes'),
                      ),
                    ],
                    selected: {viewModel.listFilter},
                    onSelectionChanged: (selection) {
                      if (selection.isEmpty) return;
                      context.read<ParcelBoardViewModel>().setListFilter(
                        selection.first,
                      );
                    },
                  ),
                ),
                if (viewModel.listFilter == BoardListFilter.all ||
                    viewModel.listFilter == BoardListFilter.routes)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Route listings',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: listing.bodyText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SegmentedButton<BoardRoutePerspectiveFilter>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment<BoardRoutePerspectiveFilter>(
                              value: BoardRoutePerspectiveFilter.any,
                              label: Text('Any'),
                            ),
                            ButtonSegment<BoardRoutePerspectiveFilter>(
                              value: BoardRoutePerspectiveFilter.needLift,
                              label: Text('Need lift'),
                            ),
                            ButtonSegment<BoardRoutePerspectiveFilter>(
                              value: BoardRoutePerspectiveFilter.offeringLift,
                              label: Text('Offering'),
                            ),
                          ],
                          selected: {viewModel.routePerspectiveFilter},
                          onSelectionChanged: (selection) {
                            if (selection.isEmpty) return;
                            context.read<ParcelBoardViewModel>().setRoutePerspectiveFilter(
                              selection.first,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: viewModel.load,
                    child: Builder(
                      builder: (context) {
                        if (viewModel.loading) {
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              Center(child: CircularProgressIndicator()),
                            ],
                          );
                        }
                        if (viewModel.error != null) {
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                            children: [
                              _ParcelBoardMessageCard(
                                icon: Icons.error_outline_rounded,
                                title: 'Couldn\'t load the board',
                                body: viewModel.error!,
                              ),
                            ],
                          );
                        }

                        final visible = viewModel.visibleItems;
                        if (visible.isEmpty) {
                          final (title, body) = _emptyMessage(viewModel);
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                            children: [
                              _ParcelBoardMessageCard(
                                icon: Icons.inventory_2_outlined,
                                title: title,
                                body: body,
                              ),
                            ],
                          );
                        }

                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                          itemCount: visible.length,
                          itemBuilder: (context, index) {
                            final parcel = visible[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ParcelCard(
                                parcel: parcel,
                                trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                ),
                                onTap: () async {
                                  final changed = await Navigator.of(context)
                                      .push<bool>(
                                        MaterialPageRoute(
                                          builder: (_) => RequestDetailScreen(
                                            requestId: parcel.id,
                                            guestMode: !authenticatedMode,
                                          ),
                                        ),
                                      );
                                  if (changed == true && context.mounted) {
                                    await context
                                        .read<ParcelBoardViewModel>()
                                        .load();
                                  }
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const ListingBackFooter(label: 'Back'),
              ],
            ),
          ),
        );
      },
    );
  }
}

(String title, String body) _emptyMessage(ParcelBoardViewModel viewModel) {
  if (viewModel.items.isEmpty) {
    return (
      'No open requests',
      'Nothing is open right now. Check back soon or post the first request.',
    );
  }
  switch (viewModel.listFilter) {
    case BoardListFilter.parcels:
      return (
        'No parcel requests',
        'There are no parcel requests right now. Try All or Routes, or post one.',
      );
    case BoardListFilter.routes:
      return (
        'No route listings',
        'There are no route listings right now. Try All or Parcels, or post one.',
      );
    case BoardListFilter.all:
      return (
        'No open requests',
        'Nothing is open right now. Check back soon or post the first request.',
      );
  }
}

Future<bool> _parcelBoardEnsureSignedIn(BuildContext context) async {
  final sessionManager = serviceLocator.mobileSessionManager;
  if (await sessionManager.ensureAuthenticated()) {
    return true;
  }
  if (!context.mounted) return false;
  return showConnectDeviceSheet(context);
}

class _ParcelBoardMessageCard extends StatelessWidget {
  const _ParcelBoardMessageCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final listing = context.entityListing;
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outline.withValues(alpha: 0.18);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: listing.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: outline),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 44, color: listing.accent),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: listing.textTitle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
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

Future<void> showGuestParcelPrompt(
  BuildContext context, {
  Future<void> Function()? onDeviceConnected,
}) async {
  final listing = context.entityListing;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: listing.cardBg,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Connect your device to post or respond to listings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: listing.textTitle,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Enter the short TREK code from your TownTrek profile. '
              'It only links this phone — no separate app password.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: listing.bodyText,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                Navigator.of(sheetContext).pop();
                if (!context.mounted) return;
                await showConnectDeviceSheet(
                  context,
                  onConnected: onDeviceConnected,
                );
              },
              child: const Text('Connect device'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => UrlUtils.launchTowntrekRegister(),
              child: const Text('Register free at towntrek.co.za'),
            ),
          ],
        ),
      );
    },
  );
}
