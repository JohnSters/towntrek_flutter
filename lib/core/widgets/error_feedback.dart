import 'package:flutter/material.dart';

import '../network/api_client.dart';
import 'app_scaffold_messenger.dart';

/// Shows a user-facing error SnackBar from any thrown [error].
///
/// Always routes through [resolveUserFacingApiError] so wrapped [DioException]s
/// surface their mapped [ApiException.message] instead of a raw `toString()`.
/// Falls back to the root messenger so the snackbar survives [Navigator.pop].
void showErrorSnack(BuildContext context, Object error) {
  final message = resolveUserFacingApiError(error);
  final messenger =
      ScaffoldMessenger.maybeOf(context) ?? AppScaffoldMessenger.state;
  messenger?.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    ),
  );
}

/// Centered error state for failed loads, rendering a user-facing message and an
/// optional retry action. Use in place of inline `Text(error.toString())`.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.error,
    this.onRetry,
    this.retryLabel = 'Try again',
  });

  /// Either a raw thrown error/exception or an already-resolved message string.
  final Object error;
  final Future<void> Function()? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = error is String
        ? error as String
        : resolveUserFacingApiError(error);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 36,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () => onRetry!(),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
