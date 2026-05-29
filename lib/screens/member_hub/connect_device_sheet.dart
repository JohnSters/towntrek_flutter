import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../core/utils/url_utils.dart';
import '../../core/widgets/app_scaffold_messenger.dart';

enum _ConnectedAccountDecision { continueCurrent, useDifferentCode }

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
    if (!context.mounted) return true;
    final decision = await _askHowToUseExistingSession(context, sessionManager);
    if (decision == null) return false;
    if (decision == _ConnectedAccountDecision.continueCurrent) {
      if (onConnected != null && context.mounted) {
        await onConnected();
      }
      return true;
    }

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

Future<_ConnectedAccountDecision?> _askHowToUseExistingSession(
  BuildContext context,
  MobileSessionManager sessionManager,
) {
  final displayName = sessionManager.currentDisplayName?.trim();
  final accountLabel = displayName?.isNotEmpty == true
      ? displayName!
      : 'your current account';

  return showModalBottomSheet<_ConnectedAccountDecision>(
    context: context,
    showDragHandle: true,
    backgroundColor: context.entityListing.cardBg,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final listing = sheetContext.entityListing;
      final colorScheme = theme.colorScheme;

      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'This device is already connected',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: listing.textTitle,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You are currently signed in as $accountLabel. Continue with this account or switch to a different TREK code on this emulator.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: listing.bodyText,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            if (displayName?.isNotEmpty == true)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        displayName!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: listing.textTitle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (displayName?.isNotEmpty == true) const SizedBox(height: 18),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  sheetContext,
                ).pop(_ConnectedAccountDecision.continueCurrent);
              },
              child: Text('Continue as $accountLabel'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.of(
                  sheetContext,
                ).pop(_ConnectedAccountDecision.useDifferentCode);
              },
              child: const Text('Use a different access code'),
            ),
          ],
        ),
      );
    },
  );
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
  late final TextEditingController _deviceNameController;
  bool _submitting = false;
  bool _helpExpanded = false;
  /// Shown in-sheet: parent [ListenableBuilder]s on [MobileSessionManager] rebuild
  /// during redeem and can prevent post-frame snackbars from ever displaying.
  String? _submitError;

  String get _defaultDeviceName => 'TownTrek ${Platform.operatingSystem}';

  @override
  void initState() {
    super.initState();
    _deviceNameController = TextEditingController(text: _defaultDeviceName);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _deviceNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    final deviceName = _deviceNameController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _submitting = true;
      _submitError = null;
    });
    Object? err;
    try {
      await serviceLocator.mobileSessionManager.signInWithCode(
        code: code,
        deviceName: deviceName.isEmpty ? _defaultDeviceName : deviceName,
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
    if (err != null) return;
    widget.onSuccess();
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
          const SizedBox(height: 14),
          TextField(
            controller: _deviceNameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Device name',
              hintText: 'e.g. My phone or Work tablet',
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
          _myDevicesHintRichText(theme, listing),
          if (_submitError != null) ...[
            const SizedBox(height: 14),
            Material(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: colorScheme.onErrorContainer,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _submitError!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onErrorContainer,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
                          _registerHelpStepRichText(theme, listing),
                        ),
                        const SizedBox(height: 12),
                        _helpStep(
                          theme,
                          listing,
                          '2',
                          Text(
                            'Go to your profile and tap My Devices',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: listing.bodyText,
                              height: 1.45,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _helpStep(
                          theme,
                          listing,
                          '3',
                          Text(
                            'Generate your TREK code and enter it here',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: listing.bodyText,
                              height: 1.45,
                            ),
                          ),
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
    Widget detail,
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
        Expanded(child: detail),
      ],
    );
  }

  TextStyle? _bodyLinkStyle(
    ThemeData theme,
    EntityListingThemeExtension listing,
    TextStyle? base,
  ) {
    return base?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: theme.colorScheme.primary,
    );
  }

  Widget _myDevicesHintRichText(
    ThemeData theme,
    EntityListingThemeExtension listing,
  ) {
    final baseStyle = theme.textTheme.bodySmall?.copyWith(
      color: listing.bodyText,
      height: 1.4,
    );
    final linkStyle = _bodyLinkStyle(theme, listing, baseStyle);
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(
            text:
                'Get your code from My Devices at ',
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () => UrlUtils.launchTowntrekRegister(),
              child: Text('towntrek.co.za', style: linkStyle),
            ),
          ),
          const TextSpan(
            text:
                '. You can also rename this device so it is easier to manage later.',
          ),
        ],
      ),
    );
  }

  Widget _registerHelpStepRichText(
    ThemeData theme,
    EntityListingThemeExtension listing,
  ) {
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(
      color: listing.bodyText,
      height: 1.45,
    );
    final linkStyle = _bodyLinkStyle(theme, listing, baseStyle);
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () => UrlUtils.launchTowntrekRegister(),
              child: Text(
                'Register free at towntrek.co.za',
                style: linkStyle,
              ),
            ),
          ),
          const TextSpan(text: ' — it takes 2 minutes'),
        ],
      ),
    );
  }
}
