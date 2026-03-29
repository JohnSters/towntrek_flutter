import 'package:flutter/material.dart';

class _StatsConstants {
  static const double outerRadius = 12.0;
  static const double barPaddingH = 12.0;
  static const double barPaddingV = 10.0;
  static const double tilePaddingH = 6.0;
  static const double tilePaddingV = 8.0;
  static const double tileIconBox = 28.0;
  static const double tileIconSize = 15.0;
  static const double tileIconRadius = 7.0;
  static const double dividerWidth = 1.0;
  static const double borderOpacity = 0.14;
  static const double tileBackgroundOpacity = 0.05;
  static const double loadingExpandedHeight = 96.0;

  static const Color businessColor = Color(0xFF42B0D5);
  static const Color serviceColor = Color(0xFFFDB750);
  static const Color eventColor = Color(0xFFFF6F61);
  static const Color creativeColor = Color(0xFFD81B60);
  static const Color propertiesColor = Color(0xFF2E7D32);
  static const Color equipmentColor = Color(0xFFFF9800);
}

/// Collapsible platform stats: tap the bottom bar to expand the grid (`/api/stats/summary`).
class PlatformStatsCard extends StatefulWidget {
  final int? businessCount;
  final int? serviceCount;
  final int? eventCount;
  final int? creativeSpaceCount;
  final int? propertyListingCount;
  final int? equipmentRentalBusinessCount;
  final bool isLoading;

  const PlatformStatsCard({
    super.key,
    this.businessCount,
    this.serviceCount,
    this.eventCount,
    this.creativeSpaceCount,
    this.propertyListingCount,
    this.equipmentRentalBusinessCount,
    this.isLoading = false,
  });

  @override
  State<PlatformStatsCard> createState() => _PlatformStatsCardState();
}

class _PlatformStatsCardState extends State<PlatformStatsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = colorScheme.outline.withValues(
      alpha: _StatsConstants.borderOpacity,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(_StatsConstants.outerRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: dividerColor),
          borderRadius: BorderRadius.circular(_StatsConstants.outerRadius),
          color: colorScheme.surfaceContainerLow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isLoading)
                          SizedBox(
                            height: _StatsConstants.loadingExpandedHeight,
                            child: Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          )
                        else
                          _buildStatsBody(
                            Theme.of(context),
                            dividerColor,
                          ),
                      ],
                    )
                  : const SizedBox(width: double.infinity),
            ),
            Container(height: _StatsConstants.dividerWidth, color: dividerColor),
            _ExpandBar(
              expanded: _expanded,
              loading: widget.isLoading,
              onTap: () => setState(() => _expanded = !_expanded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBody(ThemeData theme, Color dividerColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _statsRow(
          theme,
          dividerColor,
          [
            (
              Icons.store_rounded,
              _formatCount(widget.businessCount),
              'Businesses',
              _StatsConstants.businessColor,
            ),
            (
              Icons.handyman_rounded,
              _formatCount(widget.serviceCount),
              'Services',
              _StatsConstants.serviceColor,
            ),
            (
              Icons.event_rounded,
              _formatCount(widget.eventCount),
              'Events',
              _StatsConstants.eventColor,
            ),
          ],
        ),
        Container(height: _StatsConstants.dividerWidth, color: dividerColor),
        _statsRow(
          theme,
          dividerColor,
          [
            (
              Icons.palette_rounded,
              _formatCount(widget.creativeSpaceCount),
              'Creative',
              _StatsConstants.creativeColor,
            ),
            (
              Icons.home_work_rounded,
              _formatCount(widget.propertyListingCount),
              'Properties',
              _StatsConstants.propertiesColor,
            ),
            (
              Icons.construction_rounded,
              _formatCount(widget.equipmentRentalBusinessCount),
              'Equipment',
              _StatsConstants.equipmentColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _statsRow(
    ThemeData theme,
    Color dividerColor,
    List<(IconData, String, String, Color)> tiles,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0)
              Container(
                width: _StatsConstants.dividerWidth,
                color: dividerColor,
              ),
            Expanded(
              child: _StatTile(
                icon: tiles[i].$1,
                value: tiles[i].$2,
                label: tiles[i].$3,
                color: tiles[i].$4,
                theme: theme,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatCount(int? count) {
    if (count == null) return '–';
    return '$count+';
  }
}

class _ExpandBar extends StatelessWidget {
  final bool expanded;
  final bool loading;
  final VoidCallback onTap;

  const _ExpandBar({
    required this.expanded,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _StatsConstants.barPaddingH,
            vertical: _StatsConstants.barPaddingV,
          ),
          child: Row(
            children: [
              Icon(
                Icons.insights_rounded,
                size: 15,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'TownTrek at a Glance',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.15,
                    fontSize: 13,
                  ),
                ),
              ),
              if (loading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary.withValues(alpha: 0.45),
                  ),
                )
              else
                Icon(
                  expanded
                      ? Icons.expand_more_rounded
                      : Icons.expand_less_rounded,
                  size: 22,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final ThemeData theme;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _StatsConstants.tilePaddingH,
        vertical: _StatsConstants.tilePaddingV,
      ),
      color: color.withValues(alpha: _StatsConstants.tileBackgroundOpacity),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: _StatsConstants.tileIconBox,
            height: _StatsConstants.tileIconBox,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(
                _StatsConstants.tileIconRadius,
              ),
            ),
            child: Icon(
              icon,
              size: _StatsConstants.tileIconSize,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.05,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.1,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
