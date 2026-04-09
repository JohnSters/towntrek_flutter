import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import 'board_screen.dart';
import 'connect_device_sheet.dart';
import 'parcel_ui.dart';
import 'parcel_xp_feedback.dart';

class RequestDetailViewModel extends ChangeNotifier {
  RequestDetailViewModel({
    required this.requestId,
    required this.repository,
    required this.sessionManager,
  }) {
    load();
  }

  final int requestId;
  final ParcelRepository repository;
  final MobileSessionManager sessionManager;

  bool loading = true;
  bool actionLoading = false;
  String? error;
  ParcelDetailDto? detail;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      detail = await repository.getDetail(requestId);
    } catch (err) {
      error = err.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> claim() async {
    final current = detail;
    if (current == null) return false;
    return _runOptimistic(
      optimistic: current.copyWith(
        status: ParcelStatus.claimed,
        canClaim: false,
      ),
      action: () => repository.claim(requestId),
    );
  }

  Future<bool> pickedUp() async {
    final current = detail;
    if (current == null) return false;
    return _runOptimistic(
      optimistic: current.copyWith(status: ParcelStatus.pickedUp),
      action: () => repository.pickedUp(requestId),
    );
  }

  Future<bool> delivered() async {
    final current = detail;
    if (current == null) return false;
    return _runOptimistic(
      optimistic: current.copyWith(status: ParcelStatus.delivered),
      action: () => repository.delivered(requestId),
    );
  }

  Future<bool> confirm() async {
    final current = detail;
    if (current == null) return false;
    return _runOptimistic(
      optimistic: current.copyWith(status: ParcelStatus.confirmed),
      action: () => repository.confirm(requestId),
    );
  }

  Future<bool> cancel(String reason) async {
    final current = detail;
    if (current == null) return false;
    return _runOptimistic(
      optimistic: current.copyWith(
        status: ParcelStatus.cancelled,
        cancelReason: reason,
      ),
      action: () => repository.cancel(requestId, reason),
    );
  }

  Future<void> report(String reason) async {
    actionLoading = true;
    notifyListeners();
    try {
      await repository.report(requestId, reason);
    } finally {
      actionLoading = false;
      notifyListeners();
    }
  }

  Future<void> rate({
    required int score,
    required bool rateClaimer,
    String? note,
  }) async {
    actionLoading = true;
    notifyListeners();
    try {
      final updated = await repository.rate(
        id: requestId,
        score: score,
        rateClaimer: rateClaimer,
        note: note,
      );
      detail = updated;
      sessionManager.mergeFromParcelDetail(updated);
    } finally {
      actionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _runOptimistic({
    required ParcelDetailDto optimistic,
    required Future<ParcelDetailDto> Function() action,
  }) async {
    final previous = detail;
    if (previous == null) return false;
    actionLoading = true;
    detail = optimistic;
    notifyListeners();
    try {
      detail = await action();
      return true;
    } catch (_) {
      detail = previous;
      rethrow;
    } finally {
      actionLoading = false;
      notifyListeners();
    }
  }
}

class RequestDetailScreen extends StatelessWidget {
  const RequestDetailScreen({
    super.key,
    required this.requestId,
    this.guestMode = false,
  });

  final int requestId;
  final bool guestMode;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RequestDetailViewModel(
        requestId: requestId,
        repository: serviceLocator.parcelRepository,
        sessionManager: serviceLocator.mobileSessionManager,
      ),
      child: _RequestDetailBody(guestMode: guestMode),
    );
  }
}

String _formatParcelWhen(DateTime utc) {
  final local = utc.toLocal();
  return DateFormat('EEE, d MMM yyyy • HH:mm').format(local);
}

Future<void> _tryParcelActionAfterConnect(
  BuildContext context,
  RequestDetailViewModel viewModel,
  Future<bool> Function() action,
) async {
  try {
    final changed = await action();
    if (changed && context.mounted) {
      final d = viewModel.detail;
      if (d != null) {
        serviceLocator.mobileSessionManager.mergeFromParcelDetail(d);
        ParcelXpFeedback.showForDetail(d);
      }
      Navigator.of(context).pop(true);
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

class _RequestDetailBody extends StatelessWidget {
  const _RequestDetailBody({required this.guestMode});

  final bool guestMode;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RequestDetailViewModel>();
    final detail = viewModel.detail;
    final pageBg = context.entityListing.pageBg;

    final d = detail;
    final headerSub = viewModel.loading
        ? 'Loading…'
        : (viewModel.error != null || d == null
              ? 'Unavailable'
              : parcelStatusLabel(d.status));
    final headerTownLine = d == null
        ? 'Request'
        : '${d.pickupLocation} → ${d.dropoffLocation}';

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            EntityListingHeroHeader(
              theme: context.entityListingTheme,
              categoryIcon: Icons.inventory_2_outlined,
              subCategoryName: headerSub,
              categoryName: TownFeatureConstants.parcelsTitle,
              townName: headerTownLine,
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: serviceLocator.mobileSessionManager,
                builder: (context, _) {
                  return Builder(
                    builder: (context) {
                      if (viewModel.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (viewModel.error != null || detail == null) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                          child: Center(
                            child: Text(
                              viewModel.error ?? 'Unable to load request',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        );
                      }

                      final effectiveGuest =
                          guestMode &&
                          !serviceLocator.mobileSessionManager.isAuthenticated;

                      final timelineEntries =
                          <({String title, String subtitle})>[
                            (
                              title: 'Posted',
                              subtitle: _formatParcelWhen(detail.createdAt),
                            ),
                          ];
                      final claim = detail.activeClaim;
                      if (claim != null) {
                        timelineEntries.add((
                          title: 'Claimed',
                          subtitle:
                              '${claim.claimedByDisplayName} • ${_formatParcelWhen(claim.claimedAt)}',
                        ));
                        if (claim.pickedUpAt != null) {
                          timelineEntries.add((
                            title: 'Picked up',
                            subtitle: _formatParcelWhen(claim.pickedUpAt!),
                          ));
                        }
                        if (claim.deliveredAt != null) {
                          timelineEntries.add((
                            title: 'Delivered',
                            subtitle: _formatParcelWhen(claim.deliveredAt!),
                          ));
                        }
                        if (claim.confirmedAt != null) {
                          timelineEntries.add((
                            title: 'Confirmed',
                            subtitle: _formatParcelWhen(claim.confirmedAt!),
                          ));
                        }
                      }

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                        children: [
                          ParcelCard(parcel: detail, dense: true),
                          const SizedBox(height: 12),
                          DetailSectionShell(
                            title: 'Status timeline',
                            icon: Icons.timeline_rounded,
                            child: _ParcelTimeline(entries: timelineEntries),
                          ),
                          const SizedBox(height: 12),
                          DetailSectionShell(
                            title: 'Addresses',
                            icon: Icons.place_outlined,
                            child: Column(
                              children: [
                                _AddressBlock(
                                  icon: Icons.north_east_rounded,
                                  label: 'Pickup',
                                  value:
                                      detail.fullPickupAddress ??
                                      detail.pickupLocation,
                                  padBottom: true,
                                ),
                                _AddressBlock(
                                  icon: Icons.south_west_rounded,
                                  label: 'Drop-off',
                                  value:
                                      detail.fullDropoffAddress ??
                                      detail.dropoffLocation,
                                  padBottom: false,
                                ),
                              ],
                            ),
                          ),
                          if (detail.cancelReason?.isNotEmpty == true) ...[
                            const SizedBox(height: 12),
                            DetailSectionShell(
                              title: 'Cancellation',
                              icon: Icons.info_outline_rounded,
                              child: Text(
                                detail.cancelReason!,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(height: 1.45),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          DetailSectionShell(
                            title: 'Actions',
                            icon: Icons.touch_app_outlined,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ..._buildActions(
                                  context,
                                  viewModel,
                                  detail,
                                  effectiveGuest,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    },
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

  List<Widget> _buildActions(
    BuildContext context,
    RequestDetailViewModel viewModel,
    ParcelDetailDto detail,
    bool effectiveGuest,
  ) {
    final actions = <Widget>[];

    if (effectiveGuest) {
      actions.add(
        FilledButton(
          onPressed: viewModel.actionLoading
              ? null
              : () async {
                  await showGuestParcelPrompt(
                    context,
                    onDeviceConnected: () => _tryParcelActionAfterConnect(
                      context,
                      viewModel,
                      viewModel.claim,
                    ),
                  );
                },
          child: const Text('Connect your device to continue'),
        ),
      );
      return actions;
    }

    Future<void> guardedAction(Future<bool> Function() action) async {
      await runWithParcelSession(context, () async {
        try {
          final changed = await action();
          if (changed && context.mounted) {
            final d = viewModel.detail;
            if (d != null) {
              serviceLocator.mobileSessionManager.mergeFromParcelDetail(d);
              ParcelXpFeedback.showForDetail(d);
            }
            Navigator.of(context).pop(true);
          }
        } catch (error) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error.toString())));
          }
        }
      });
    }

    if (detail.canClaim) {
      actions.add(
        FilledButton(
          onPressed: viewModel.actionLoading
              ? null
              : () => guardedAction(viewModel.claim),
          child: const Text("I'll do this"),
        ),
      );
    }
    if (detail.canMarkPickedUp) {
      actions.add(
        FilledButton(
          onPressed: viewModel.actionLoading
              ? null
              : () => guardedAction(viewModel.pickedUp),
          child: const Text("I've collected it"),
        ),
      );
    }
    if (detail.canMarkDelivered) {
      actions.add(
        FilledButton(
          onPressed: viewModel.actionLoading
              ? null
              : () => guardedAction(viewModel.delivered),
          child: const Text('Dropped off'),
        ),
      );
    }
    if (detail.canConfirm) {
      actions.add(
        FilledButton(
          onPressed: viewModel.actionLoading
              ? null
              : () => guardedAction(viewModel.confirm),
          child: const Text('Received, thank you'),
        ),
      );
    }
    if (detail.canCancel) {
      actions.add(
        OutlinedButton(
          onPressed: viewModel.actionLoading
              ? null
              : () async {
                  final reason = await _askForText(
                    context,
                    title: 'Cancel request',
                    label: 'Reason',
                  );
                  if (reason == null || reason.trim().isEmpty) return;
                  await guardedAction(() => viewModel.cancel(reason));
                },
          child: const Text('Cancel'),
        ),
      );
    }

    actions.add(
      TextButton(
        onPressed: viewModel.actionLoading
            ? null
            : () async {
                final reason = await _askForText(
                  context,
                  title: 'Report request',
                  label: 'Tell us what looks wrong',
                );
                if (reason == null || reason.trim().isEmpty) return;
                try {
                  await viewModel.report(reason);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thanks. We\'ll review it.'),
                      ),
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error.toString())));
                  }
                }
              },
        child: const Text('Report'),
      ),
    );

    if (detail.canRate) {
      actions.add(
        TextButton(
          onPressed: viewModel.actionLoading
              ? null
              : () async {
                  final score = await _askForRating(context);
                  if (score == null) return;
                  try {
                    await viewModel.rate(
                      score: score,
                      rateClaimer: detail.isRequester,
                    );
                    if (context.mounted) {
                      final d = viewModel.detail;
                      if (d != null) {
                        ParcelXpFeedback.showForDetail(d);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rating sent.')),
                      );
                    }
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error.toString())));
                    }
                  }
                },
          child: const Text('Leave rating'),
        ),
      );
    }

    return [
      for (var i = 0; i < actions.length; i++) ...[
        if (i > 0) const SizedBox(height: 10),
        actions[i],
      ],
    ];
  }
}

class _ParcelTimeline extends StatelessWidget {
  const _ParcelTimeline({required this.entries});

  final List<({String title, String subtitle})> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          _TimelineStep(
            isLast: i == entries.length - 1,
            title: entries[i].title,
            subtitle: entries[i].subtitle,
          ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.isLast,
    required this.title,
    required this.subtitle,
  });

  final bool isLast;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lineColor = colorScheme.outlineVariant.withValues(alpha: 0.55);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary,
                    border: Border.all(color: colorScheme.surface, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.35),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: lineColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 6, bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressBlock extends StatelessWidget {
  const _AddressBlock({
    required this.icon,
    required this.label,
    required this.value,
    this.padBottom = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool padBottom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: padBottom ? 14 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<String?> _askForText(
  BuildContext context, {
  required String title,
  required String label,
}) async {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: const Text('Submit'),
        ),
      ],
    ),
  );
}

Future<int?> _askForRating(BuildContext context) async {
  int selected = 5;
  return showDialog<int>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Leave a rating'),
        content: DropdownButton<int>(
          value: selected,
          isExpanded: true,
          items: List.generate(
            5,
            (index) =>
                DropdownMenuItem(value: index + 1, child: Text('${index + 1}')),
          ),
          onChanged: (value) {
            if (value != null) setState(() => selected = value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(selected),
            child: const Text('Send'),
          ),
        ],
      ),
    ),
  );
}
