import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/core.dart';

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

    setState(() => _submitting = true);
    try {
      await serviceLocator.mobileSessionManager.signInWithCode(
        code: code,
        deviceName: deviceName,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not use that code: $error')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = context.entityListing;
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
                    Text(
                      'Get your code from My Devices at towntrek.co.za',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: listing.footerHint,
                        height: 1.4,
                      ),
                    ),
                  ],
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
