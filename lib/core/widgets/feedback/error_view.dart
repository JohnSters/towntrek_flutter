import 'package:flutter/material.dart';
import '../../errors/app_error.dart';

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

          Text(
            error.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            error.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

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
