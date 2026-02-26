import 'package:flutter/material.dart';

class _StatsConstants {
  static const double outerRadius = 14.0;
  static const double headerPaddingH = 14.0;
  static const double headerPaddingV = 10.0;
  static const double tilePaddingH = 12.0;
  static const double tilePaddingV = 12.0;
  static const double tileIconBox = 34.0;
  static const double tileIconSize = 18.0;
  static const double tileIconRadius = 8.0;
  static const double dividerWidth = 1.0;
  static const double borderOpacity = 0.14;
  static const double tileBackgroundOpacity = 0.05;

  static const Color businessColor = Color(0xFF42B0D5);
  static const Color serviceColor = Color(0xFFFDB750);
  static const Color eventColor = Color(0xFFFF6F61);
}

/// A compact, connected-grid card showing platform-wide stats
/// (businesses, services, events) in the same visual language as the
/// Town Pulse card on the town feature selection page.
class PlatformStatsCard extends StatelessWidget {
  final int? businessCount;
  final int? serviceCount;
  final int? eventCount;
  final bool isLoading;

  const PlatformStatsCard({
    super.key,
    this.businessCount,
    this.serviceCount,
    this.eventCount,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = colorScheme.outline.withValues(
      alpha: _StatsConstants.borderOpacity,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(_StatsConstants.outerRadius),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: dividerColor),
          borderRadius: BorderRadius.circular(_StatsConstants.outerRadius),
          color: colorScheme.surfaceContainerLow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatsHeader(),
            Container(
              height: _StatsConstants.dividerWidth,
              color: dividerColor,
            ),
            isLoading
                ? _buildLoading(colorScheme)
                : _buildGrid(context, dividerColor),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(ColorScheme colorScheme) {
    return const SizedBox(
      height: 56,
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, Color dividerColor) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatTile(
              icon: Icons.store_rounded,
              value: _formatCount(businessCount),
              label: 'Businesses',
              color: _StatsConstants.businessColor,
              theme: theme,
            ),
          ),
          Container(
            width: _StatsConstants.dividerWidth,
            color: dividerColor,
          ),
          Expanded(
            child: _StatTile(
              icon: Icons.handyman_rounded,
              value: _formatCount(serviceCount),
              label: 'Services',
              color: _StatsConstants.serviceColor,
              theme: theme,
            ),
          ),
          Container(
            width: _StatsConstants.dividerWidth,
            color: dividerColor,
          ),
          Expanded(
            child: _StatTile(
              icon: Icons.event_rounded,
              value: _formatCount(eventCount),
              label: 'Events',
              color: _StatsConstants.eventColor,
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatCount(int? count) {
    if (count == null) return '–';
    return '$count+';
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _StatsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _StatsConstants.headerPaddingH,
        vertical: _StatsConstants.headerPaddingV,
      ),
      child: Row(
        children: [
          Icon(
            Icons.insights_rounded,
            size: 16,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 5),
          Text(
            'TownTrek at a Glance',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual stat tile
// ---------------------------------------------------------------------------

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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _StatsConstants.tilePaddingH,
        vertical: _StatsConstants.tilePaddingV,
      ),
      color: color.withValues(alpha: _StatsConstants.tileBackgroundOpacity),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
