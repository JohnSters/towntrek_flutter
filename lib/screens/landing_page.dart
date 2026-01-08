import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/core.dart';
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

  Future<void> _launchOwnerUrl() async {
    final Uri url = Uri.parse('https://towntrek.co.za');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch website')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
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

                    const SizedBox(height: 40),

                    // Business Owner CTA
                    _buildBusinessOwnerCTA(context),

                    const SizedBox(height: 24),

                    // Feature Grid (1x3)
                    SizedBox(
                      height: 110, // Fixed height for the row of squares
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildFeatureTile(
                              context,
                              icon: Icons.store_mall_directory,
                              label: 'Businesses',
                              count: _businessCount,
                              color: const Color(0xFF42B0D5), // Blue
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFeatureTile(
                              context,
                              icon: Icons.handyman,
                              label: 'Services',
                              count: _serviceCount,
                              color: const Color(0xFFFDB750), // Yellow/Orange
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFeatureTile(
                              context,
                              icon: Icons.calendar_month,
                              label: 'Events',
                              count: _eventCount,
                              color: const Color(0xFFFF6F61), // Red/Coral
                              borderRadius: BorderRadius.circular(16),
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

  Widget _buildBusinessOwnerCTA(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6A11CB), // Deep Purple
            Color(0xFF2575FC), // Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2575FC).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _launchOwnerUrl,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_business,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Business not listed?',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
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
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (count != null && !_isLoadingStats) ...[
            const SizedBox(height: 2),
            Text(
              '$count+',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ] else if (count != null && _isLoadingStats) ...[
            const SizedBox(height: 2),
            SizedBox(
              width: 12,
              height: 12,
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
