import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/core.dart';
import '../repositories/repositories.dart';
import 'town_loader_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _businessCount = 0;
  int _serviceCount = 0;
  int _eventCount = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final statsRepo = serviceLocator.statsRepository;
      final stats = await statsRepo.getLandingStats();

      if (mounted) {
        setState(() {
          _businessCount = stats.businessCount;
          _serviceCount = stats.serviceCount;
          _eventCount = stats.eventCount;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      // Silently fail or log error, keep counts at 0
      debugPrint('Error loading stats: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // App Logo with Card for emphasis
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      padding: const EdgeInsets.all(32.0),
                      child: SvgPicture.asset(
                        'assets/images/logos/towntrek_starter_logo2.svg',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Subtitle
                    Text(
                      'Explore South Africa\'s small towns like never before.',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Discover hidden gems, local favorites, and authentic experiences—all at the click of a button.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Feature Grid (2x2)
                    AspectRatio(
                      aspectRatio: 1.0, // Make the whole grid square
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildFeatureTile(
                                    context,
                                    icon: Icons.store_mall_directory,
                                    label: 'Businesses',
                                    count: _businessCount,
                                    color: const Color(0xFF42B0D5), // Blue
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: _buildFeatureTile(
                                    context,
                                    icon: Icons.handyman,
                                    label: 'Services',
                                    count: _serviceCount,
                                    color: const Color(0xFFFDB750), // Yellow/Orange
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(24),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildFeatureTile(
                                    context,
                                    icon: Icons.calendar_month,
                                    label: 'Events',
                                    count: _eventCount,
                                    color: const Color(0xFFFF6F61), // Red/Coral
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: _buildFeatureTile(
                                    context,
                                    icon: Icons.more_horiz,
                                    label: 'And More',
                                    count: null, // No count for "More"
                                    color: const Color(0xFF6BBF59), // Green
                                    borderRadius: const BorderRadius.only(
                                      bottomRight: Radius.circular(24),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),

            // Bottom Action Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TownLoaderScreen(),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.explore),
                        const SizedBox(width: 12),
                        Text(
                          'Start Exploring',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'TownTrek - Your Local Discovery Companion',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    int? count,
    BorderRadius? borderRadius,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius ?? BorderRadius.circular(0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (count != null && !_isLoadingStats) ...[
            const SizedBox(height: 4),
            Text(
              '$count+',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ] else if (count != null && _isLoadingStats) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
