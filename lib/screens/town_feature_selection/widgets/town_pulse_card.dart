import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import '../../../services/weather_service.dart';

class _PulseConstants {
  static const double outerRadius = 14.0;
  static const double headerPaddingH = 14.0;
  static const double headerPaddingV = 10.0;
  static const double tilePaddingH = 12.0;
  static const double tilePaddingV = 12.0;
  static const double tileIconBox = 34.0;
  static const double tileIconSize = 18.0;
  static const double tileIconRadius = 8.0;
  static const double dividerWidth = 1.0;
  static const double liveDotSize = 6.0;
  static const double borderOpacity = 0.14;
  static const double tileBackgroundOpacity = 0.05;
  static const double shimmerHeight = 100.0;
  static const int maxEventsPageSize = 100;

  static const Color businessColor = Color(0xFF1565C0);
  static const Color serviceColor = Color(0xFFEF6C00);
  static const Color eventColor = Color(0xFF6A1B9A);
  static const Color liveGreen = Color(0xFF43A047);
}

/// A compact 2x2 dashboard card showing live town stats:
/// business count, service count, active events, and current weather.
///
/// Self-contained — manages its own async data loading internally.
class TownPulseCard extends StatefulWidget {
  final TownDto town;

  const TownPulseCard({super.key, required this.town});

  @override
  State<TownPulseCard> createState() => _TownPulseCardState();
}

class _TownPulseCardState extends State<TownPulseCard> {
  WeatherData? _weather;
  int? _activeEventsCount;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLiveData();
  }

  Future<void> _loadLiveData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    await Future.wait([_fetchWeather(), _fetchActiveEvents()]);

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _fetchWeather() async {
    final lat = widget.town.latitude;
    final lng = widget.town.longitude;
    if (lat == null || lng == null) return;

    try {
      final data = await WeatherService().getCurrentWeather(lat, lng);
      if (!mounted) return;
      setState(() => _weather = data);
    } catch (_) {}
  }

  Future<void> _fetchActiveEvents() async {
    try {
      final response = await serviceLocator.eventRepository.getCurrentEvents(
        townId: widget.town.id,
        pageSize: _PulseConstants.maxEventsPageSize,
      );
      if (!mounted) return;
      final count = response.events.where((e) => !e.shouldHide).length;
      setState(() => _activeEventsCount = count);
    } catch (_) {}
  }

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
            _PulseHeader(isLoading: _isLoading),
            Container(height: _PulseConstants.dividerWidth, color: dividerColor),
            _isLoading
                ? _buildLoadingGrid(colorScheme)
                : _buildStatsGrid(context, dividerColor),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid(ColorScheme colorScheme) {
    return SizedBox(
      height: _PulseConstants.shimmerHeight,
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

  Widget _buildStatsGrid(BuildContext context, Color dividerColor) {
    final town = widget.town;
    final theme = Theme.of(context);

    final weatherValue = _weather != null
        ? '${_weather!.temperature.round()}°C'
        : '–';
    final weatherLabel = _weather?.description ?? 'Weather';
    final weatherIcon = _weather?.icon ?? Icons.wb_cloudy_rounded;
    final weatherColor = _weather != null
        ? _weatherColor(_weather!.weatherCode)
        : const Color(0xFF78909C);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.store_rounded,
                  value: '${town.businessCount}',
                  label: 'Businesses',
                  color: _PulseConstants.businessColor,
                  theme: theme,
                ),
              ),
              Container(
                width: _PulseConstants.dividerWidth,
                color: dividerColor,
              ),
              Expanded(
                child: _StatTile(
                  icon: Icons.handyman_rounded,
                  value: '${town.servicesCount}',
                  label: 'Services',
                  color: _PulseConstants.serviceColor,
                  theme: theme,
                ),
              ),
            ],
          ),
        ),
        Container(height: _PulseConstants.dividerWidth, color: dividerColor),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.event_rounded,
                  value: _activeEventsCount != null
                      ? '$_activeEventsCount'
                      : '–',
                  label: 'Events today',
                  color: _PulseConstants.eventColor,
                  theme: theme,
                ),
              ),
              Container(
                width: _PulseConstants.dividerWidth,
                color: dividerColor,
              ),
              Expanded(
                child: _StatTile(
                  icon: weatherIcon,
                  value: weatherValue,
                  label: weatherLabel,
                  color: weatherColor,
                  theme: theme,
                ),
              ),
            ],
          ),
        ),
      ],
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
          Icon(Icons.bolt_rounded, size: 16, color: colorScheme.primary),
          const SizedBox(width: 5),
          Text(
            'Town Pulse',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
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
// Individual stat tile (one cell of the 2x2 grid)
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
        horizontal: _PulseConstants.tilePaddingH,
        vertical: _PulseConstants.tilePaddingV,
      ),
      color: color.withValues(alpha: _PulseConstants.tileBackgroundOpacity),
      child: Row(
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
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
          ),
        ],
      ),
    );
  }
}
