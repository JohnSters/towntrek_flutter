import 'package:flutter/material.dart';
import '../models/models.dart';
import '../core/widgets/page_header.dart';
import '../core/widgets/navigation_footer.dart';
import 'business_category_page.dart';
import 'town_selection_screen.dart';
import 'current_events_screen.dart';
import 'service_category_page.dart';

class TownFeatureSelectionScreen extends StatelessWidget {
  final TownDto town;

  const TownFeatureSelectionScreen({
    super.key,
    required this.town,
  });

  void _changeTown(BuildContext context) async {
    final selectedTown = await Navigator.of(context).push<TownDto>(
      MaterialPageRoute(
        builder: (context) => const TownSelectionScreen(),
      ),
    );

    if (selectedTown != null && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => TownFeatureSelectionScreen(town: selectedTown),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: town.name,
            subtitle: town.province,
            height: 120,
            trailing: IconButton(
              icon: Icon(Icons.location_on, color: colorScheme.primary),
              onPressed: () => _changeTown(context),
              tooltip: 'Change Town',
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'What are you looking for?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Businesses Card
                  _FeatureCard(
                    title: 'Businesses',
                    description: 'Find local shops, restaurants, and more',
                    icon: Icons.store_mall_directory,
                    color: Colors.blue.shade600,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BusinessCategoryPage(town: town),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Services Card
                  _FeatureCard(
                    title: 'Services',
                    description: 'Plumbers, electricians, and other pros',
                    icon: Icons.handyman,
                    color: Colors.orange.shade600,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ServiceCategoryPage(town: town),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Events Card
                  _FeatureCard(
                    title: 'Events',
                    description: 'Discover what\'s happening in town',
                    icon: Icons.event,
                    color: Colors.purple.shade600,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CurrentEventsScreen(
                            townId: town.id,
                            townName: town.name,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const BackNavigationFooter(),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 8)),
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                theme.colorScheme.surface,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

