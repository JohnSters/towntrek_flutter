import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import 'access_code_entry_screen.dart';
import 'parcel_ui.dart';
import 'board_screen.dart';

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
      await repository.rate(
        id: requestId,
        score: score,
        rateClaimer: rateClaimer,
        note: note,
      );
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

class _RequestDetailBody extends StatelessWidget {
  const _RequestDetailBody({required this.guestMode});

  final bool guestMode;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RequestDetailViewModel>();
    final detail = viewModel.detail;
    return Scaffold(
      appBar: AppBar(title: const Text('Parcel request')),
      body: Builder(
        builder: (context) {
          if (viewModel.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null || detail == null) {
            return Center(child: Text(viewModel.error ?? 'Unable to load request'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ParcelCard(parcel: detail),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status timeline',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _TimelineRow(
                        label: 'Posted',
                        value: detail.createdAt.toLocal().toString(),
                      ),
                      if (detail.activeClaim != null)
                        _TimelineRow(
                          label: 'Claimed',
                          value:
                              '${detail.activeClaim!.claimedByDisplayName} • ${detail.activeClaim!.claimedAt.toLocal()}',
                        ),
                      if (detail.activeClaim?.pickedUpAt != null)
                        _TimelineRow(
                          label: 'Picked up',
                          value: detail.activeClaim!.pickedUpAt!.toLocal().toString(),
                        ),
                      if (detail.activeClaim?.deliveredAt != null)
                        _TimelineRow(
                          label: 'Delivered',
                          value: detail.activeClaim!.deliveredAt!.toLocal().toString(),
                        ),
                      if (detail.activeClaim?.confirmedAt != null)
                        _TimelineRow(
                          label: 'Confirmed',
                          value: detail.activeClaim!.confirmedAt!.toLocal().toString(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Addresses',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Pickup: ${detail.fullPickupAddress ?? detail.pickupLocation}'),
                      const SizedBox(height: 8),
                      Text('Drop-off: ${detail.fullDropoffAddress ?? detail.dropoffLocation}'),
                    ],
                  ),
                ),
              ),
              if (detail.cancelReason?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Cancel reason: ${detail.cancelReason}'),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ..._buildActions(context, viewModel, detail),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    RequestDetailViewModel viewModel,
    ParcelDetailDto detail,
  ) {
    final actions = <Widget>[];

    if (guestMode) {
      actions.add(
        FilledButton(
          onPressed: viewModel.actionLoading
              ? null
              : () => showGuestParcelPrompt(context),
          child: const Text('Join to help with this'),
        ),
      );
      return actions;
    }

    Future<void> guardedAction(Future<bool> Function() action) async {
      final ok = await serviceLocator.mobileSessionManager.ensureAuthenticated();
      if (!ok) {
        if (context.mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AccessCodeEntryScreen()),
          );
        }
        return;
      }

      try {
        final changed = await action();
        if (changed && context.mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        }
      }
    }

    if (detail.canClaim) {
      actions.add(
        FilledButton(
          onPressed: viewModel.actionLoading ? null : () => guardedAction(viewModel.claim),
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
                      const SnackBar(content: Text('Thanks. We\'ll review it.')),
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error.toString())),
                    );
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rating sent.')),
                      );
                    }
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error.toString())),
                      );
                    }
                  }
                },
          child: const Text('Leave rating'),
        ),
      );
    }

    return [
      for (final action in actions) ...[
        action,
        const SizedBox(height: 10),
      ],
    ];
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 92, child: Text(label)),
          Expanded(child: Text(value)),
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
            (index) => DropdownMenuItem(
              value: index + 1,
              child: Text('${index + 1}'),
            ),
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
