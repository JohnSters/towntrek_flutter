import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../core/utils/url_utils.dart';
import 'access_code_entry_view_model.dart';
import 'scan_access_code_screen.dart';

class AccessCodeEntryScreen extends StatelessWidget {
  const AccessCodeEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AccessCodeEntryViewModel(
        sessionManager: serviceLocator.mobileSessionManager,
      ),
      child: const _AccessCodeEntryScreenBody(),
    );
  }
}

class _AccessCodeEntryScreenBody extends StatefulWidget {
  const _AccessCodeEntryScreenBody();

  @override
  State<_AccessCodeEntryScreenBody> createState() =>
      _AccessCodeEntryScreenBodyState();
}

class _AccessCodeEntryScreenBodyState
    extends State<_AccessCodeEntryScreenBody> {
  final _codeController = TextEditingController();
  final _deviceController = TextEditingController(
    text: 'TownTrek ${Platform.operatingSystem}',
  );

  @override
  void dispose() {
    _codeController.dispose();
    _deviceController.dispose();
    super.dispose();
  }

  Future<void> _scanCode() async {
    final scanned = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScanAccessCodeScreen()),
    );
    if (scanned == null || !mounted) return;
    _codeController.text = scanned;
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    final deviceName = _deviceController.text.trim();
    final viewModel = context.read<AccessCodeEntryViewModel>();
    if (code.isEmpty) {
      viewModel.setSubmitError('Enter your TownTrek code');
      return;
    }

    final defaultDeviceName = 'TownTrek ${Platform.operatingSystem}';
    final ok = await viewModel.submit(
      code: code,
      deviceName: deviceName.isEmpty ? defaultDeviceName : deviceName,
      mapError: resolveUserFacingApiError,
    );
    if (ok && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AccessCodeEntryViewModel>();
    final listing = context.entityListing;
    final theme = Theme.of(context);
    final baseHint = theme.textTheme.bodySmall?.copyWith(
      color: listing.footerHint,
      height: 1.4,
    );
    final linkHint = baseHint?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: theme.colorScheme.primary,
    );
    return Scaffold(
      backgroundColor: listing.pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EntityListingHeroHeader(
              theme: context.entityListingTheme,
              categoryIcon: Icons.key_rounded,
              subCategoryName: 'Connect device',
              categoryName: TownFeatureConstants.parcelsTitle,
              townName: 'TownTrek code',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Link this phone with a short code from My Devices on your TownTrek profile. Enter or paste the code here.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: listing.bodyText,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DetailSectionShell(
                      title: 'Connect device',
                      icon: Icons.key_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _codeController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              labelText: 'Enter your TownTrek code',
                              hintText: 'TREK-0000-XXXX',
                              suffixIcon: IconButton(
                                tooltip: 'Scan QR code',
                                icon: const Icon(Icons.qr_code_scanner_rounded),
                                onPressed: viewModel.submitting ? null : _scanCode,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _deviceController,
                            decoration: const InputDecoration(
                              labelText: 'Device name',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(
                        style: baseHint,
                        children: [
                          const TextSpan(
                            text: 'Get your code from My Devices at ',
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: () => UrlUtils.launchTowntrekRegister(),
                              child: Text('towntrek.co.za', style: linkHint),
                            ),
                          ),
                          const TextSpan(
                            text:
                                '. Copy and paste it here, or type it. Scan QR only if the code is on another screen.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (viewModel.submitError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Material(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: theme.colorScheme.onErrorContainer,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            viewModel.submitError!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: viewModel.submitting ? null : _submit,
                  child: Text(
                    viewModel.submitting
                        ? 'Connecting…'
                        : 'Connect this device',
                  ),
                ),
              ),
            ),
            const ListingBackFooter(label: 'Back'),
          ],
        ),
      ),
    );
  }
}
