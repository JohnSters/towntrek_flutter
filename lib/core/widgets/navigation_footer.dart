import 'package:flutter/material.dart';

/// Reusable navigation footer component for consistent app navigation
/// Provides back button and optional additional actions
class NavigationFooter extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final List<Widget>? additionalActions;
  final bool showBackButton;
  final String? backButtonText;
  final EdgeInsetsGeometry? padding;

  const NavigationFooter({
    super.key,
    this.onBackPressed,
    this.additionalActions,
    this.showBackButton = true,
    this.backButtonText,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: padding ?? const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Back Button
            if (showBackButton) ...[
              Expanded(
                child: FilledButton.icon(
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, size: 20),
                  label: Text(
                    backButtonText ?? 'Back',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
            ],

            // Additional Actions
            if (additionalActions != null && additionalActions!.isNotEmpty) ...[
              if (showBackButton) const SizedBox(width: 16),
              ...additionalActions!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Convenience method for simple back navigation footer
class BackNavigationFooter extends StatelessWidget {
  final String? backText;

  const BackNavigationFooter({
    super.key,
    this.backText,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationFooter(
      backButtonText: backText,
    );
  }
}
