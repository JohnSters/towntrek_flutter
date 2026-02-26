import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import '../../../services/weather_service.dart';

class _PulseConstants {
  static const double cardBorderRadius = 16.0;
  static const double cardPaddingH = 16.0;
  static const double cardPaddingV = 14.0;
  static const double headerSpacing = 12.0;
  static const double statIconSize = 22.0;
  static const double weatherIconSize = 26.0;
  static const double liveDotSize = 7.0;
  static const double borderOpacity = 0.18;
  static const double gradientStartOpacity = 0.08;
  static const double gradientEndOpacity = 0.03;
  static const double shimmerHeight = 88.0;
  static const int maxEventsPageSize = 100;
}

/// A compact, glanceable dashboard card showing live town stats:
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

    await Future.wait([
      _fetchWeather(),
      _fetchActiveEvents(),
    ]);

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
    } catch (_) {
      // Weather is non-critical; the card still shows other stats.
    }
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
    } catch (_) {
      // Events failure is non-critical.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: _PulseConstants.cardPaddingH,
        vertical: _PulseConstants.cardPaddingV,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_PulseConstants.cardBorderRadius),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(
              alpha: _PulseConstants.gradientStartOpacity,
            ),
            colorScheme.tertiary.withValues(
              alpha: _PulseConstants.gradientEndOpacity,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colorScheme.primary.withValues(
            alpha: _PulseConstants.borderOpacity,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PulseHeader(isLoading: _isLoading),
          const SizedBox(height: _PulseConstants.headerSpacing),
          _isLoading ? _buildShimmerRow(colorScheme) : _buildStatsRow(theme),
        ],
      ),
    );
  }

  Widget _buildShimmerRow(ColorScheme colorScheme) {
    return SizedBox(
      height: _PulseConstants.shimmerHeight,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    final town = widget.town;

    final items = <_StatItem>[
      _StatItem(
        icon: Icons.store_rounded,
        value: '${town.businessCount}',
        label: 'Businesses',
        color: const Color(0xFF1565C0),
      ),
      _StatItem(
        icon: Icons.handyman_rounded,
        value: '${town.servicesCount}',
        label: 'Services',
        color: const Color(0xFFEF6C00),
      ),
      _StatItem(
        icon: Icons.event_rounded,
        value: _activeEventsCount != null ? '$_activeEventsCount' : '–',
        label: 'Events\ntoday',
        color: const Color(0xFF6A1B9A),
      ),
    ];

    if (_weather != null) {
      items.add(
        _StatItem(
          icon: _weather!.icon,
          value: '${_weather!.temperature.round()}°C',
          label: _weather!.description,
          color: _weatherColor(_weather!.weatherCode),
          iconSize: _PulseConstants.weatherIconSize,
        ),
      );
    }

    return Row(
      children: items
          .map(
            (item) => Expanded(child: _StatColumn(item: item, theme: theme)),
          )
          .toList(),
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
// Sub-widgets
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

    return Row(
      children: [
        Icon(
          Icons.bolt_rounded,
          size: 18,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Text(
          'Town Pulse',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const Spacer(),
        if (!widget.isLoading)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _dotController.drive(
                  Tween(begin: 0.35, end: 1.0),
                ),
                child: Container(
                  width: _PulseConstants.liveDotSize,
                  height: _PulseConstants.liveDotSize,
                  decoration: const BoxDecoration(
                    color: Color(0xFF43A047),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Live',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF43A047),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _StatItem {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final double iconSize;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.iconSize = _PulseConstants.statIconSize,
  });
}

class _StatColumn extends StatelessWidget {
  final _StatItem item;
  final ThemeData theme;

  const _StatColumn({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.icon, size: item.iconSize, color: item.color),
        ),
        const SizedBox(height: 6),
        Text(
          item.value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
