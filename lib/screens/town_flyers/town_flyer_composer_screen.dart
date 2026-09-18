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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  Text(
                    TownFlyerConstants.composerHint,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  if (quota?.needsUpgrade == true) ...[
                    _InfoBanner(
                      body: TownFlyerConstants.upgradeBody,
                      actionLabel: TownFlyerConstants.upgradeCta,
                      busy: vm.upgrading,
                      onAction: () => vm.upgrade(),
                    ),
                    const SizedBox(height: 16),
                  ] else if (quota?.townCapFull == true) ...[
                    const _InfoBanner(body: TownFlyerConstants.capFullBody),
                    const SizedBox(height: 16),
                  ] else if (quota?.poolFull == true) ...[
                    const _InfoBanner(body: TownFlyerConstants.poolFullBody),
                    const SizedBox(height: 16),
                  ],
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

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.body,
    this.actionLabel,
    this.onAction,
    this.busy = false,
  });

  final String body;
  final String? actionLabel;
  final Future<bool> Function()? onAction;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 10),
              FilledButton(
                onPressed: busy ? null : () => onAction!(),
                child: busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
