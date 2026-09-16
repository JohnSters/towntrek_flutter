import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../core/utils/url_utils.dart';
import '../member_hub/connect_device_sheet.dart';
import 'request_town_view_model.dart';

class RequestTownScreen extends StatelessWidget {
  const RequestTownScreen({super.key, this.initialName});

  final String? initialName;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RequestTownViewModel(
        repository: serviceLocator.townRequestRepository,
        initialName: initialName,
        initialEmail: serviceLocator.mobileSessionManager.profile?.email,
      ),
      child: const _RequestTownBody(),
    );
  }
}

class _RequestTownBody extends StatelessWidget {
  const _RequestTownBody();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: serviceLocator.mobileSessionManager,
      builder: (context, _) {
        if (!serviceLocator.mobileSessionManager.isAuthenticated) {
          return const _RequestTownSignInGate();
        }
        return const _RequestTownForm();
      },
    );
  }
}

class _RequestTownSignInGate extends StatelessWidget {
  const _RequestTownSignInGate();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text(RequestTownConstants.screenTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                RequestTownConstants.signInRequiredTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                RequestTownConstants.signInRequiredBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => showConnectDeviceSheet(context),
                icon: const Icon(Icons.link),
                label: const Text(RequestTownConstants.connectToRequestLabel),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: UrlUtils.launchTowntrekRegister,
                child: const Text(RequestTownConstants.createAccountLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestTownForm extends StatelessWidget {
  const _RequestTownForm();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RequestTownViewModel>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text(RequestTownConstants.screenTitle),
      ),
      body: SafeArea(
        child: Form(
          key: vm.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Text(
                RequestTownConstants.screenSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              if (vm.bannerMessage != null) ...[
                _ResultBanner(
                  message: vm.bannerMessage!,
                  isError: vm.bannerIsError,
                  isInfo: vm.result?.isAlreadyListed == true,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: vm.nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: RequestTownConstants.nameLabel,
                ),
                validator: vm.validateName,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: vm.selectedProvince,
                decoration: const InputDecoration(
                  labelText: RequestTownConstants.provinceLabel,
                ),
                items: RequestTownConstants.southAfricanProvinces
                    .map(
                      (province) => DropdownMenuItem(
                        value: province,
                        child: Text(province),
                      ),
                    )
                    .toList(),
                onChanged: vm.setProvince,
                validator: vm.validateProvince,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: vm.notesController,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: RequestTownConstants.notesLabel,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: vm.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: RequestTownConstants.emailLabel,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: vm.isSubmitting ? null : vm.submit,
                child: vm.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(RequestTownConstants.submitLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({
    required this.message,
    required this.isError,
    required this.isInfo,
  });

  final String message;
  final bool isError;
  final bool isInfo;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = isError
        ? colors.errorContainer
        : isInfo
        ? colors.secondaryContainer
        : colors.primaryContainer;
    final foreground = isError
        ? colors.onErrorContainer
        : isInfo
        ? colors.onSecondaryContainer
        : colors.onPrimaryContainer;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: foreground,
          ),
        ),
      ),
    );
  }
}
