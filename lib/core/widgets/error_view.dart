import 'package:flutter/material.dart';
import '../errors/app_error.dart';

/// A reusable widget for displaying errors consistently across the app
class ErrorView extends StatelessWidget {
  final AppError error;
  final bool showIcon;
  final EdgeInsetsGeometry padding;
  final double iconSize;

  const ErrorView({
    super.key,
    required this.error,
    this.showIcon = true,
    this.padding = const EdgeInsets.all(24.0),
    this.iconSize = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Icon(
              _getErrorIcon(),
              size: iconSize,
              color: _getErrorColor(colorScheme),
            ),
            const SizedBox(height: 16),
          ],

          // Title
          Text(
            error.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Message
          Text(
            error.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          // Action button
          if (error.actionText != null && error.action != null) ...[
            const SizedBox(height: 24),
            FilledButton(
              onPressed: error.action,
              child: Text(error.actionText!),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getErrorIcon() {
    if (error is NetworkError) {
      return Icons.wifi_off;
    } else if (error is ServerError) {
      return Icons.cloud_off;
    } else if (error is LocationError) {
      return Icons.location_off;
    } else if (error is ValidationError) {
      return Icons.error_outline;
    } else {
      return Icons.warning;
    }
  }

  Color _getErrorColor(ColorScheme colorScheme) {
    if (error is NetworkError) {
      return colorScheme.primary;
    } else if (error is ServerError) {
      return colorScheme.error;
    } else if (error is LocationError) {
      return colorScheme.secondary;
    } else if (error is ValidationError) {
      return colorScheme.error;
    } else {
      return colorScheme.onSurfaceVariant;
    }
  }
}

/// A compact version for inline error display
class ErrorBanner extends StatelessWidget {
  final AppError error;
  final VoidCallback? onDismiss;

  const ErrorBanner({
    super.key,
    required this.error,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getErrorIcon(),
            color: colorScheme.onErrorContainer,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  error.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (error.actionText != null && error.action != null) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: error.action,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onErrorContainer,
                textStyle: theme.textTheme.labelSmall,
              ),
              child: Text(error.actionText!),
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: colorScheme.onErrorContainer.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getErrorIcon() {
    if (error is NetworkError) {
      return Icons.wifi_off;
    } else if (error is ServerError) {
      return Icons.cloud_off;
    } else if (error is LocationError) {
      return Icons.location_off;
    } else if (error is ValidationError) {
      return Icons.error_outline;
    } else {
      return Icons.warning;
    }
  }
}

/// Extension to show error as a SnackBar
extension ErrorSnackBar on BuildContext {
  void showErrorSnackBar(AppError error, {Duration duration = const Duration(seconds: 4)}) {
    final theme = Theme.of(this);
    final colorScheme = theme.colorScheme;

    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(error),
              color: colorScheme.onErrorContainer,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.errorContainer,
        duration: duration,
        action: error.actionText != null && error.action != null
            ? SnackBarAction(
                label: error.actionText!,
                textColor: colorScheme.onErrorContainer,
                onPressed: error.action!,
              )
            : null,
      ),
    );
  }

  IconData _getErrorIcon(AppError error) {
    if (error is NetworkError) {
      return Icons.wifi_off;
    } else if (error is ServerError) {
      return Icons.cloud_off;
    } else if (error is LocationError) {
      return Icons.location_off;
    } else if (error is ValidationError) {
      return Icons.error_outline;
    } else {
      return Icons.warning;
    }
  }
}
