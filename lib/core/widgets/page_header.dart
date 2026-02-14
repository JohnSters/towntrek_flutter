import 'package:flutter/material.dart';
import '../../core/config/api_config.dart';

/// Enum to define different header types with distinct color schemes
enum HeaderType {
  business,
  service,
  event,
  default_,
}

/// Reusable page header component with proper mobile design
/// Features background, centered title, and proper spacing for longer titles
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool centerTitle;
  final double height;
  final EdgeInsetsGeometry? padding;
  final String? backgroundImage;
  final HeaderType headerType;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.centerTitle = true,
    this.height = 120,
    this.padding,
    this.backgroundImage,
    this.headerType = HeaderType.default_,
  });

  /// Get gradient colors based on header type for distinct visual identity
  LinearGradient _getGradient(ColorScheme colorScheme) {
    switch (headerType) {
      case HeaderType.business:
        // Business screens: Strong dark blue gradient
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade700,
            Colors.blue.shade900,
          ],
        );

      case HeaderType.service:
        // Service screens: Strong dark green gradient
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade700,
            Colors.green.shade900,
          ],
        );

      case HeaderType.event:
        // Event screens: Strong dark orange gradient
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade700,
            Colors.orange.shade900,
          ],
        );

      case HeaderType.default_:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ImageProvider? bgImage;
    if (backgroundImage != null) {
      if (backgroundImage!.startsWith('http')) {
        bgImage = NetworkImage(backgroundImage!);
      } else {
        // Construct full URL if it's a relative path
        bgImage = NetworkImage('${ApiConfig.baseUrl}$backgroundImage');
      }
    }

    return Container(
      // Removed fixed height constraint
      // height: height,
      constraints: BoxConstraints(minHeight: height),
      decoration: BoxDecoration(
        image: bgImage != null
            ? DecorationImage(
                image: bgImage,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.5),
                  BlendMode.darken,
                ),
              )
            : null,
        gradient: bgImage == null ? _getGradient(colorScheme) : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: padding ?? const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Allow column to shrink to content
            children: [
              // Leading widget (optional)
              if (leading != null) ...[
                Row(
                  children: [
                    leading!,
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Title and Subtitle Row
              Row(
                mainAxisAlignment: centerTitle ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title - No wrapping, single line with ellipsis
                        Text(
                          title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: centerTitle ? TextAlign.center : TextAlign.left,
                        ),

                        // Subtitle (optional)
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: centerTitle ? TextAlign.center : TextAlign.left,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Trailing widget (optional)
                  if (trailing != null) ...[
                    if (!centerTitle) const SizedBox(width: 16),
                    trailing!,
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Specialized business header for business details pages
class BusinessHeader extends StatelessWidget {
  final String businessName;
  final String? tagline;
  final Widget? statusIndicator;

  const BusinessHeader({
    super.key,
    required this.businessName,
    this.tagline,
    this.statusIndicator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Top section with gradient background and business info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer.withValues(alpha: 0.3),
                  colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Business Name - Smaller but bolder, multi-line allowed
                  Text(
                    businessName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Tagline or subtitle
                  if (tagline != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      tagline!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Status indicator bar (Full width)
          if (statusIndicator != null)
            statusIndicator!,
        ],
      ),
    );
  }
}
