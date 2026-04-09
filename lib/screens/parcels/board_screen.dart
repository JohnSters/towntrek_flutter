import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import 'access_code_entry_screen.dart';
import 'my_activity_screen.dart';
import 'parcel_ui.dart';
import 'post_request_screen.dart';
import 'profile_screen.dart';
import 'request_detail_screen.dart';

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
    return Scaffold(
      backgroundColor: listing.pageBg,
      appBar: AppBar(
        title: Text('${town.name} Parcels'),
        actions: authenticatedMode
            ? [
                IconButton(
                  icon: const Icon(Icons.history_rounded),
                  onPressed: () async {
                    if (!await _ensureSignedIn(context)) return;
                    if (!context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MyActivityScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline_rounded),
                  onPressed: () async {
                    if (!await _ensureSignedIn(context)) return;
                    if (!context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: viewModel.load,
        child: Builder(
          builder: (context) {
            if (viewModel.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.error != null) {
              return ListView(
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
            if (viewModel.items.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                children: [
                  _ParcelBoardMessageCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'No open requests',
                    body:
                        'Nothing is open right now. Check back soon or post the first request.',
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 88),
              itemCount: viewModel.items.length,
              itemBuilder: (context, index) {
                final parcel = viewModel.items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ParcelCard(
                    parcel: parcel,
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                    ),
                    onTap: () async {
                      final changed = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => RequestDetailScreen(
                            requestId: parcel.id,
                            guestMode: !authenticatedMode,
                          ),
                        ),
                      );
                      if (changed == true && context.mounted) {
                        await context.read<ParcelBoardViewModel>().load();
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!authenticatedMode) {
            await showGuestParcelPrompt(context);
            return;
          }
          if (!await _ensureSignedIn(context)) return;
          if (!context.mounted) return;
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => PostRequestScreen(town: town)),
          );
          if (created == true && context.mounted) {
            await context.read<ParcelBoardViewModel>().load();
          }
        },
        icon: Icon(
          authenticatedMode ? Icons.add_rounded : Icons.favorite_border,
        ),
        label: Text(authenticatedMode ? 'Post request' : 'Join to post'),
      ),
    );
  }

  Future<bool> _ensureSignedIn(BuildContext context) async {
    final sessionManager = serviceLocator.mobileSessionManager;
    if (await sessionManager.ensureAuthenticated()) {
      return true;
    }

    if (!context.mounted) return false;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AccessCodeEntryScreen()),
    );
    return result == true;
  }
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

Future<void> showGuestParcelPrompt(BuildContext context) async {
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
              'TownTrek members keep this community running.',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: listing.textTitle,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'It\'s free, always will be, and takes about 2 minutes to join. If you already have an account, use your mobile access code.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: listing.bodyText,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                Navigator.of(sheetContext).pop();
                await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => const AccessCodeEntryScreen(),
                  ),
                );
              },
              child: const Text('Enter access code'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () async {
                final uri = Uri.parse(
                  '${LandingPageConstants.ownerWebsiteUrl}/Auth/Register',
                );
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              child: const Text('Register free on the web'),
            ),
          ],
        ),
      );
    },
  );
}
