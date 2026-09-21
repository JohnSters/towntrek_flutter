import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/core.dart';

/// Compact hub row: preview image on the left, title/subtitle, optional trailing.
///
/// Matches Town Admin / Town Pulse surfaces so media and flyers sit in the same
/// visual language as the rest of the town page.
class TownHubActionTile extends StatelessWidget {
  const TownHubActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.fallbackIcon = Icons.place_rounded,
    this.accentColor = const Color(0xFF0175C2),
    this.tintColor,
    this.tintStrength = TownFeatureConstants.hubActionTintStrength,
    this.height,
    this.compact = false,
    this.emphasized = false,
    this.pulse,
    this.expanded,
    this.imageUrl,
    this.leading,
    this.showPlayOverlay = false,
    this.showChevron = true,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final IconData fallbackIcon;
  final Color accentColor;
  final Color? tintColor;
  final double tintStrength;
  final double? height;
  final bool compact;
  final bool emphasized;
  final Animation<double>? pulse;

  /// Fold state for collapsible rows. `null` means a destination row (always open).
  final bool? expanded;
  final String? imageUrl;
  final Widget? leading;
  final bool showPlayOverlay;
  final bool showChevron;
  final Widget? trailing;

  static const _animDuration = Duration(milliseconds: 220);

  bool get _isOpen => expanded != false;

  @override
  Widget build(BuildContext context) {
    if (pulse == null) return _buildTile(context);

    return AnimatedBuilder(
      animation: pulse!,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(pulse!.value);
        final glow = tintColor ?? accentColor;
        final glowScale = _isOpen ? 1.0 : 0.55;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              TownFeatureConstants.hubActionRadius,
            ),
            boxShadow: [
              BoxShadow(
                color: glow.withValues(
                  alpha: (0.10 + 0.16 * t) * glowScale,
                ),
                blurRadius: 8 + 8 * t,
                spreadRadius: 0.2 + 1.1 * t,
              ),
            ],
          ),
          child: _buildTile(context),
        );
      },
    );
  }

  Widget _buildTile(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final listing = context.entityListing;
    final tint = tintColor ?? accentColor;
    final open = _isOpen;
    final tileHeight = height ??
        (compact
            ? TownFeatureConstants.hubActionUtilityHeight
            : TownFeatureConstants.hubActionHeight);
    final baseTint = emphasized
        ? TownFeatureConstants.hubActionExploreTintStrength
        : tintStrength;
    final strength = open
        ? baseTint + TownFeatureConstants.hubActionExpandedTintBoost
        : TownFeatureConstants.hubActionCollapsedTintStrength;
    final bg = Color.alphaBlend(
      tint.withValues(alpha: strength),
      colorScheme.surfaceContainerLow,
    );
    final border = Color.alphaBlend(
      tint.withValues(alpha: open ? (emphasized ? 0.52 : 0.36) : 0.14),
      colorScheme.outline.withValues(alpha: open ? 0.16 : 0.10),
    );
    final resolved = (imageUrl ?? '').trim();

    return AnimatedContainer(
      duration: _animDuration,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(
          TownFeatureConstants.hubActionRadius,
        ),
        border: Border.all(color: border, width: emphasized && open ? 1.4 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            TownFeatureConstants.hubActionRadius,
          ),
          child: SizedBox(
            height: tileHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: TownFeatureConstants.hubActionPreviewWidth,
                  height: tileHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      leading ??
                          _Preview(
                            imageUrl: resolved,
                            fallbackIcon: fallbackIcon,
                            accentColor: accentColor,
                            showPlayOverlay: showPlayOverlay,
                          ),
                      IgnorePointer(
                        child: AnimatedOpacity(
                          duration: _animDuration,
                          curve: Curves.easeInOut,
                          opacity: open
                              ? 0
                              : TownFeatureConstants.hubActionCollapsedLeadDim,
                          child: const ColoredBox(color: Color(0xFF1B1B1B)),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12, compact ? 6 : 10, 8, compact ? 6 : 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: listing.textTitle,
                            fontSize: compact ? 14 : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: compact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: listing.footerHint,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ?trailing,
                if (showChevron)
                  Padding(
                    padding: EdgeInsets.only(right: trailing == null ? 12 : 4),
                    child: Center(
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else if (trailing == null)
                  const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Filled left slot: large icon on an accent wash, no rounded badge.
class TownHubIconLead extends StatelessWidget {
  const TownHubIconLead({
    super.key,
    required this.icon,
    required this.accentColor,
    this.iconSize = TownFeatureConstants.hubActionIconSize,
  });

  final IconData icon;
  final Color accentColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor,
            Color.lerp(accentColor, Colors.black, 0.22)!,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.imageUrl,
    required this.fallbackIcon,
    required this.accentColor,
    required this.showPlayOverlay,
  });

  final String imageUrl;
  final IconData fallbackIcon;
  final Color accentColor;
  final bool showPlayOverlay;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorWidget: (_, _, _) => TownHubIconLead(
              icon: fallbackIcon,
              accentColor: accentColor,
            ),
          )
        else
          TownHubIconLead(icon: fallbackIcon, accentColor: accentColor),
        if (showPlayOverlay)
          const DecoratedBox(
            decoration: BoxDecoration(color: Color(0x38000000)),
            child: Center(
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
      ],
    );
  }
}
