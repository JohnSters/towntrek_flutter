import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../services/weather_service.dart';

/// Routes available from compact Town Pulse cells (weather is shown but not navigable).
enum TownPulseDestination {
  businesses,
  services,
  events,
  creativeSpaces,
  whatToDo,
  properties,
  equipmentRentals,
}

class _PulseConstants {
  static const double outerRadius = 12.0;
  static const double headerPaddingH = 12.0;
  static const double headerPaddingV = 8.0;
  static const double cellPaddingH = 6.0;
  static const double cellPaddingV = 8.0;
  static const double tileIconBox = 26.0;
  static const double tileIconSize = 15.0;
  static const double tileIconRadius = 7.0;
  static const double dividerWidth = 1.0;
  static const double liveDotSize = 5.0;
  static const double borderOpacity = 0.14;
  static const double tileBackgroundOpacity = 0.05;
  static const double loadingMinHeight = 132.0;

  static const Color businessColor = Color(0xFF1565C0);
  static const Color serviceColor = Color(0xFFEF6C00);
  static const Color eventColor = Color(0xFF6A1B9A);
  static const Color creativeColor = Color(0xFFD81B60);
  static const Color whatToDoColor = Color(0xFF00897B);
  static const Color propertiesColor = Color(0xFF2E7D32);
  static const Color equipmentColor = Color(0xFFFF9800);
  static const Color liveGreen = Color(0xFF43A047);
}

/// Compact dashboard: metrics from [TownFeatureViewModel], weather, and navigation.
class TownPulseCard extends StatelessWidget {
  final TownDto town;
  final bool isLoading;
  final WeatherData? weather;
  final int? activeEventsCount;
  final int? creativeTotal;
  final int? propertiesTotal;
  final int? equipmentTotal;
  final void Function(TownPulseDestination destination) onNavigate;

  const TownPulseCard({
    super.key,
    required this.town,
    required this.isLoading,
    required this.weather,
    required this.activeEventsCount,
    required this.creativeTotal,
    required this.propertiesTotal,
    required this.equipmentTotal,
    required this.onNavigate,
  });

  static String _countOrDash(int? v) => v != null ? '$v' : '–';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = colorScheme.outline.withValues(
      alpha: _PulseConstants.borderOpacity,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(_PulseConstants.outerRadius),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: dividerColor),
          borderRadius: BorderRadius.circular(_PulseConstants.outerRadius),
          color: colorScheme.surfaceContainerLow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PulseHeader(isLoading: isLoading),
            Container(height: _PulseConstants.dividerWidth, color: dividerColor),
            isLoading
                ? _buildLoadingArea(colorScheme)
                : _buildEntityTable(context, dividerColor),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingArea(ColorScheme colorScheme) {
    return SizedBox(
      height: _PulseConstants.loadingMinHeight,
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildEntityTable(BuildContext context, Color dividerColor) {
    final theme = Theme.of(context);

    final weatherValue =
        weather != null ? '${weather!.temperature.round()}°' : '–';
    final weatherLabel =
        weather != null ? _shortWeatherLabel(weather!.description) : 'Weather';
    final weatherIcon = weather?.icon ?? Icons.wb_cloudy_rounded;
    final weatherColor = weather != null
        ? _weatherColor(weather!.weatherCode)
        : const Color(0xFF78909C);

    final eventsValue = _countOrDash(activeEventsCount);
    final eventsLive =
        activeEventsCount != null && activeEventsCount! > 0;

    final creativeValue = _countOrDash(creativeTotal);
    final propertiesValue = _countOrDash(propertiesTotal);
    final equipmentValue = _countOrDash(equipmentTotal);

    return Table(
      defaultColumnWidth: const FlexColumnWidth(1),
      border: TableBorder.all(
        color: dividerColor,
        width: _PulseConstants.dividerWidth,
      ),
      children: [
        TableRow(
          children: [
            _navCell(
              context,
              theme,
              icon: Icons.store_rounded,
              value: '${town.businessCount}',
              label: 'Businesses',
              color: _PulseConstants.businessColor,
              onTap: () => onNavigate(TownPulseDestination.businesses),
            ),
            _navCell(
              context,
              theme,
              icon: Icons.handyman_rounded,
              value: '${town.servicesCount}',
              label: 'Services',
              color: _PulseConstants.serviceColor,
              onTap: () => onNavigate(TownPulseDestination.services),
            ),
            _maybeAnimateEventsCell(
              eventsLive: eventsLive,
              child: _navCell(
                context,
                theme,
                icon: Icons.event_rounded,
                value: eventsValue,
                label: 'Events',
                color: _PulseConstants.eventColor,
                onTap: () => onNavigate(TownPulseDestination.events),
              ),
            ),
            _navCell(
              context,
              theme,
              icon: Icons.palette_rounded,
              value: creativeValue,
              label: 'Creative',
              color: _PulseConstants.creativeColor,
              onTap: () => onNavigate(TownPulseDestination.creativeSpaces),
            ),
          ],
        ),
        TableRow(
          children: [
            _navCell(
              context,
              theme,
              icon: Icons.travel_explore_rounded,
              value: '·',
              label: 'What to do',
              color: _PulseConstants.whatToDoColor,
              onTap: () => onNavigate(TownPulseDestination.whatToDo),
            ),
            _navCell(
              context,
              theme,
              icon: Icons.home_work_rounded,
              value: propertiesValue,
              label: 'Properties',
              color: _PulseConstants.propertiesColor,
              onTap: () => onNavigate(TownPulseDestination.properties),
            ),
            _navCell(
              context,
              theme,
              icon: Icons.construction_rounded,
              value: equipmentValue,
              label: 'Equipment',
              color: _PulseConstants.equipmentColor,
              onTap: () => onNavigate(TownPulseDestination.equipmentRentals),
            ),
            _staticCell(
              context,
              theme,
              icon: weatherIcon,
              value: weatherValue,
              label: weatherLabel,
              color: weatherColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _maybeAnimateEventsCell({
    required bool eventsLive,
    required Widget child,
  }) {
    if (!eventsLive) return child;
    return _LiveEventsPulseCellWrapper(child: child);
  }

  /// Keeps weather line to one short row under the value.
  static String _shortWeatherLabel(String description) {
    final t = description.trim();
    if (t.length <= 10) return t;
    return '${t.substring(0, 9)}…';
  }

  Widget _navCell(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _PulseCell(
      theme: theme,
      icon: icon,
      value: value,
      label: label,
      color: color,
      onTap: onTap,
    );
  }

  Widget _staticCell(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return _PulseCell(
      theme: theme,
      icon: icon,
      value: value,
      label: label,
      color: color,
      onTap: null,
    );
  }

  static Color _weatherColor(int code) {
    return switch (code) {
      0 || 1 => const Color(0xFFF9A825),
      2 || 3 => const Color(0xFF78909C),
      45 || 48 => const Color(0xFF90A4AE),
      >= 51 && <= 67 => const Color(0xFF42A5F5),
      >= 71 && <= 86 => const Color(0xFF90CAF9),
      >= 95 => const Color(0xFF5C6BC0),
      _ => const Color(0xFF78909C),
    };
  }
}

// ---------------------------------------------------------------------------
// Subtle live animation for Events cell (Town Pulse)
// ---------------------------------------------------------------------------

class _LiveEventsPulseCellWrapper extends StatefulWidget {
  final Widget child;

  const _LiveEventsPulseCellWrapper({required this.child});

  @override
  State<_LiveEventsPulseCellWrapper> createState() =>
      _LiveEventsPulseCellWrapperState();
}

class _LiveEventsPulseCellWrapperState extends State<_LiveEventsPulseCellWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ).value;
          final scale = 1.0 + 0.035 * t;
          final glow = 0.1 + 0.12 * t;
          return DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: _PulseConstants.eventColor
                      .withValues(alpha: glow * 0.4),
                  blurRadius: 5 + 5 * t,
                  spreadRadius: 0.35 * t,
                ),
              ],
            ),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header with pulsing "Live" indicator
// ---------------------------------------------------------------------------

class _PulseHeader extends StatefulWidget {
  final bool isLoading;

  const _PulseHeader({required this.isLoading});

  @override
  State<_PulseHeader> createState() => _PulseHeaderState();
}

class _PulseHeaderState extends State<_PulseHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _PulseConstants.headerPaddingH,
        vertical: _PulseConstants.headerPaddingV,
      ),
      child: Row(
        children: [
          Icon(Icons.bolt_rounded, size: 15, color: colorScheme.primary),
          const SizedBox(width: 5),
          Text(
            'Town Pulse',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.15,
            ),
          ),
          const Spacer(),
          if (!widget.isLoading) ...[
            FadeTransition(
              opacity: _dotController.drive(
                Tween(begin: 0.3, end: 1.0),
              ),
              child: Container(
                width: _PulseConstants.liveDotSize,
                height: _PulseConstants.liveDotSize,
                decoration: const BoxDecoration(
                  color: _PulseConstants.liveGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Live',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 10,
                color: _PulseConstants.liveGreen,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// One compact cell (tappable or static)
// ---------------------------------------------------------------------------

class _PulseCell extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _PulseCell({
    required this.theme,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    final child = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _PulseConstants.cellPaddingH,
        vertical: _PulseConstants.cellPaddingV,
      ),
      color: color.withValues(alpha: _PulseConstants.tileBackgroundOpacity),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _PulseConstants.tileIconBox,
            height: _PulseConstants.tileIconBox,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(
                _PulseConstants.tileIconRadius,
              ),
            ),
            child: Icon(icon, size: _PulseConstants.tileIconSize, color: color),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.0,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.05,
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return child;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: child,
      ),
    );
  }
}
