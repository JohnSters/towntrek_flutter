import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/core.dart';

/// Shows the connect-device bottom sheet. Returns `true` if the user ends with a
/// valid session (including when already authenticated before the sheet opens).
///
/// On successful redemption, [onConnected] runs after the sheet is popped (if
/// [context] is still mounted).
Future<bool> showConnectDeviceSheet(
  BuildContext context, {
  Future<void> Function()? onConnected,
}) async {
  final sessionManager = serviceLocator.mobileSessionManager;
  if (await sessionManager.ensureAuthenticated()) {
    if (onConnected != null && context.mounted) {
      await onConnected();
    }
    return true;
  }

  if (!context.mounted) return false;

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: context.entityListing.cardBg,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: _ConnectDeviceSheetBody(
          parentContext: context,
          onSuccess: () {
            Navigator.of(sheetContext).pop(true);
          },
        ),
      );
    },
  );

  if (result == true && context.mounted && onConnected != null) {
    await onConnected();
  }
  return result == true;
}

/// Runs [action] after a valid session exists, showing [showConnectDeviceSheet]
/// when the session must be restored with a TREK code.
Future<void> runWithParcelSession(
  BuildContext context,
  Future<void> Function() action,
) async {
  final sessionManager = serviceLocator.mobileSessionManager;
  if (await sessionManager.ensureAuthenticated()) {
    await action();
    return;
  }
  if (!context.mounted) return;
  await showConnectDeviceSheet(context, onConnected: action);
}

class _ConnectDeviceSheetBody extends StatefulWidget {
  const _ConnectDeviceSheetBody({
    required this.parentContext,
    required this.onSuccess,
  });

  final BuildContext parentContext;
  final VoidCallback onSuccess;

  @override
  State<_ConnectDeviceSheetBody> createState() =>
      _ConnectDeviceSheetBodyState();
}

class _ConnectDeviceSheetBodyState extends State<_ConnectDeviceSheetBody> {
  final _codeController = TextEditingController();
  final _deviceName = 'TownTrek ${Platform.operatingSystem}';
  bool _submitting = false;
  bool _helpExpanded = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _submitting = true);
    try {
      await serviceLocator.mobileSessionManager.signInWithCode(
        code: code,
        deviceName: _deviceName,
      );
      if (!mounted) return;
      widget.onSuccess();
    } catch (error) {
      if (!mounted) return;
      if (!widget.parentContext.mounted) return;
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(content: Text('Could not use that code: $error')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = context.entityListing;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Connect this device',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: listing.textTitle,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            decoration: InputDecoration(
              labelText: 'Enter your TownTrek code',
              hintText: 'TREK-0000-XXXX',
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.35,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Get your code from My Devices at towntrek.co.za',
            style: theme.textTheme.bodySmall?.copyWith(
              color: listing.bodyText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(_submitting ? 'Connecting…' : 'Connect this device'),
          ),
          const SizedBox(height: 16),
          Material(
            color: colorScheme.primaryContainer.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => setState(() => _helpExpanded = !_helpExpanded),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'How do I get a code?',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: listing.textTitle,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _helpExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: listing.bodyText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _helpExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 14, left: 4, right: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _helpStep(
                          theme,
                          listing,
                          '1',
                          'Register free at towntrek.co.za — it takes 2 minutes',
                        ),
                        const SizedBox(height: 12),
                        _helpStep(
                          theme,
                          listing,
                          '2',
                          'Go to your profile and tap My Devices',
                        ),
                        const SizedBox(height: 12),
                        _helpStep(
                          theme,
                          listing,
                          '3',
                          'Generate your TREK code and enter it here',
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _helpStep(
    ThemeData theme,
    EntityListingThemeExtension listing,
    String number,
    String text,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: listing.bodyText,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
