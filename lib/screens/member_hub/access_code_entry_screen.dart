import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../core/utils/url_utils.dart';
import '../../core/widgets/app_scaffold_messenger.dart';

class AccessCodeEntryScreen extends StatefulWidget {
  const AccessCodeEntryScreen({super.key});

  @override
  State<AccessCodeEntryScreen> createState() => _AccessCodeEntryScreenState();
}

class _AccessCodeEntryScreenState extends State<AccessCodeEntryScreen> {
  final _codeController = TextEditingController();
  final _deviceController = TextEditingController(
    text: 'TownTrek ${Platform.operatingSystem}',
  );
  bool _submitting = false;
  String? _submitError;

  @override
  void dispose() {
    _codeController.dispose();
    _deviceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    final deviceName = _deviceController.text.trim();
    if (code.isEmpty || deviceName.isEmpty) return;

    setState(() {
      _submitting = true;
      _submitError = null;
    });
    Object? err;
    try {
      await serviceLocator.mobileSessionManager.signInWithCode(
        code: code,
        deviceName: deviceName,
      );
    } catch (e) {
      err = e;
    }
    if (!mounted) {
      if (err != null) {
        final msg = resolveUserFacingApiError(err);
        AppScaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }
    setState(() {
      _submitting = false;
      _submitError = err == null ? null : resolveUserFacingApiError(err);
    });
    if (err == null) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      'Link this phone with a short code from your TownTrek profile.',
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
                            decoration: const InputDecoration(
                              labelText: 'Enter your TownTrek code',
                              hintText: 'TREK-0000-XXXX',
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_submitError != null)
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
                            _submitError!,
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
                  onPressed: _submitting ? null : _submit,
                  child: Text(_submitting ? 'Connecting…' : 'Connect this device'),
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
