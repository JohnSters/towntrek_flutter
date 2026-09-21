import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import 'town_flyer_auth_screen.dart';
import 'town_flyer_composer_view_model.dart';

class TownFlyerComposerScreen extends StatelessWidget {
  const TownFlyerComposerScreen({super.key, required this.town});

  final TownDto town;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = TownFlyerComposerViewModel(
          town: town,
          repository: serviceLocator.townFlyerRepository,
          initialPhone: serviceLocator.mobileSessionManager.profile?.phoneNumber,
        );
        if (serviceLocator.mobileSessionManager.isAuthenticated) {
          vm.loadQuota();
        }
        return vm;
      },
      child: const _ComposerBody(),
    );
  }
}

class _ComposerBody extends StatelessWidget {
  const _ComposerBody();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: serviceLocator.mobileSessionManager,
      builder: (context, _) {
        if (!serviceLocator.mobileSessionManager.isAuthenticated) {
          return TownFlyerAuthScreen(
            onAuthenticated: () {
              context.read<TownFlyerComposerViewModel>().loadQuota();
            },
          );
        }
        return const _ComposerForm();
      },
    );
  }
}

class _ComposerForm extends StatelessWidget {
  const _ComposerForm();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TownFlyerComposerViewModel>();
    final theme = Theme.of(context);
    final quota = vm.quota;

    return Scaffold(
      appBar: AppBar(title: const Text(TownFlyerConstants.composerTitle)),
      body: SafeArea(
        child: vm.loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  if (quota?.needsUpgrade == true)
                    _ComposerNotice(
                      icon: Icons.schedule_rounded,
                      title: TownFlyerConstants.upgradeNoticeTitle,
                      body: TownFlyerConstants.upgradeBody,
                      accent: const Color(0xFFEF6C00),
                      countdownUntil: quota?.communityAvailableAtUtc,
                      onCountdownElapsed: () => vm.loadQuota(showLoading: false),
                      actionLabel: TownFlyerConstants.upgradeCta,
                      busy: vm.upgrading,
                      onAction: () => vm.upgrade(),
                    )
                  else if (quota?.townCapFull == true)
                    const _ComposerNotice(
                      icon: Icons.inventory_2_outlined,
                      title: TownFlyerConstants.capNoticeTitle,
                      body: TownFlyerConstants.capFullBody,
                      accent: Color(0xFFC62828),
                    )
                  else if (quota?.poolFull == true)
                    const _ComposerNotice(
                      icon: Icons.photo_library_outlined,
                      title: TownFlyerConstants.poolNoticeTitle,
                      body: TownFlyerConstants.poolFullBody,
                      accent: Color(0xFFEF6C00),
                    )
                  else
                    Text(
                      TownFlyerConstants.composerHint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    TownFlyerConstants.imageLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AspectRatio(
                    aspectRatio: 3 / 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: vm.image == null
                          ? const Center(child: Icon(Icons.image_outlined, size: 40))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(vm.image!, fit: BoxFit.contain),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              vm.pickImage(image_picker.ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text(TownFlyerConstants.pickImage),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              vm.pickImage(image_picker.ImageSource.camera),
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text(TownFlyerConstants.takePhoto),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () => vm.pickPin(context),
                    icon: const Icon(Icons.place_outlined),
                    label: Text(
                      vm.pinLat == null
                          ? TownFlyerConstants.pickPin
                          : TownFlyerConstants.adjustPin,
                    ),
                  ),
                  if (vm.pinLat != null && vm.pinLng != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${vm.pinLat!.toStringAsFixed(5)}, ${vm.pinLng!.toStringAsFixed(5)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: vm.phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: TownFlyerConstants.phoneLabel,
                      hintText: TownFlyerConstants.phoneHint,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (vm.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      vm.error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: vm.canSubmit
                        ? () async {
                            final message = await vm.submit();
                            if (!context.mounted || message == null) return;
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                            Navigator.of(context).pop(true);
                          }
                        : null,
                    child: vm.submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(TownFlyerConstants.submit),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ComposerNotice extends StatefulWidget {
  const _ComposerNotice({
    required this.icon,
    required this.title,
    required this.body,
    required this.accent,
    this.countdownUntil,
    this.onCountdownElapsed,
    this.actionLabel,
    this.onAction,
    this.busy = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color accent;
  final DateTime? countdownUntil;
  final VoidCallback? onCountdownElapsed;
  final String? actionLabel;
  final Future<bool> Function()? onAction;
  final bool busy;

  @override
  State<_ComposerNotice> createState() => _ComposerNoticeState();
}

class _ComposerNoticeState extends State<_ComposerNotice> {
  var _expanded = true;

  void _toggle() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listing = context.entityListing;
    final bg = Color.alphaBlend(
      widget.accent.withValues(alpha: 0.12),
      theme.colorScheme.surface,
    );
    final border = widget.accent.withValues(alpha: 0.28);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: _toggle,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: listing.textTitle,
                            ),
                          ),
                          if (!_expanded && widget.countdownUntil != null) ...[
                            const SizedBox(height: 4),
                            _FlyerCountdown(
                              untilUtc: widget.countdownUntil!,
                              accent: widget.accent,
                              compact: true,
                              onElapsed: widget.onCountdownElapsed,
                            ),
                          ],
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: listing.bodyText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (widget.countdownUntil != null) ...[
                            _FlyerCountdown(
                              untilUtc: widget.countdownUntil!,
                              accent: widget.accent,
                              onElapsed: widget.onCountdownElapsed,
                            ),
                            const SizedBox(height: 12),
                          ],
                          Text(
                            widget.body,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: listing.bodyText,
                              height: 1.4,
                            ),
                          ),
                          if (widget.actionLabel != null &&
                              widget.onAction != null) ...[
                            const SizedBox(height: 14),
                            FilledButton(
                              onPressed: widget.busy
                                  ? null
                                  : () => widget.onAction!(),
                              style: FilledButton.styleFrom(
                                backgroundColor: widget.accent,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: widget.busy
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(widget.actionLabel!),
                            ),
                          ],
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlyerCountdown extends StatefulWidget {
  const _FlyerCountdown({
    required this.untilUtc,
    required this.accent,
    this.onElapsed,
    this.compact = false,
  });

  final DateTime untilUtc;
  final Color accent;
  final VoidCallback? onElapsed;
  final bool compact;

  @override
  State<_FlyerCountdown> createState() => _FlyerCountdownState();
}

class _FlyerCountdownState extends State<_FlyerCountdown> {
  Timer? _timer;
  var _elapsedNotified = false;

  Duration get _remaining {
    final until = widget.untilUtc.isUtc
        ? widget.untilUtc
        : widget.untilUtc.toUtc();
    return until.difference(DateTime.now().toUtc());
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      _notifyIfElapsed();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _notifyIfElapsed();
    });
  }

  @override
  void didUpdateWidget(covariant _FlyerCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.untilUtc != widget.untilUtc) {
      _elapsedNotified = false;
      _notifyIfElapsed();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _notifyIfElapsed() {
    if (_elapsedNotified || _remaining > Duration.zero) return;
    _elapsedNotified = true;
    widget.onElapsed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _remaining;
    final ready = remaining <= Duration.zero;
    final listing = context.entityListing;
    final clock = ready
        ? TownFlyerConstants.countdownReady
        : TownFlyerConstants.formatCountdown(remaining);

    if (widget.compact) {
      return Text(
        clock,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: widget.accent,
          letterSpacing: 0.6,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            Text(
              ready
                  ? TownFlyerConstants.countdownReady
                  : TownFlyerConstants.countdownLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: listing.bodyText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              TownFlyerConstants.formatCountdown(remaining),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: listing.textTitle,
                letterSpacing: 1.2,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

