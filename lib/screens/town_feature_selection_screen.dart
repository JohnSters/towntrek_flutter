import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import 'business_category/business_category.dart';
import 'current_events_screen.dart';
import 'service_category_page.dart';
import 'town_selection_screen.dart';
import 'town_feature_selection/widgets/widgets.dart';

// State classes for type-safe state management
sealed class TownFeatureState {}

class TownFeatureLoaded extends TownFeatureState {
  final TownDto town;

  TownFeatureLoaded(this.town);
}

// ViewModel for navigation logic separation
class TownFeatureViewModel extends ChangeNotifier {
  final TownFeatureState _state;
  TownFeatureState get state => _state;

  TownFeatureViewModel(TownDto town) : _state = TownFeatureLoaded(town);

  Future<void> changeTown(BuildContext context) async {
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

  void navigateToBusinesses(BuildContext context, TownDto town) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BusinessCategoryPage(town: town),
      ),
    );
  }

  void navigateToServices(BuildContext context, TownDto town) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceCategoryPage(town: town),
      ),
    );
  }

  void navigateToEvents(BuildContext context, TownDto town) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CurrentEventsScreen(
          townId: town.id,
          townName: town.name,
        ),
      ),
    );
  }
}

class TownFeatureSelectionScreen extends StatelessWidget {
  final TownDto town;

  const TownFeatureSelectionScreen({
    super.key,
    required this.town,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TownFeatureViewModel(town),
      child: const _TownFeatureSelectionScreenContent(),
    );
  }
}

class _TownFeatureSelectionScreenContent extends StatelessWidget {
  const _TownFeatureSelectionScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TownFeatureViewModel>();
    final town = switch (viewModel.state) {
      TownFeatureLoaded(town: final town) => town,
    };

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: town.name,
            subtitle: town.province,
            height: TownFeatureConstants.pageHeaderHeight,
            trailing: IconButton(
              icon: Icon(Icons.location_on, color: colorScheme.primary),
              onPressed: () => viewModel.changeTown(context),
              tooltip: TownFeatureConstants.changeTownTooltip,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(TownFeatureConstants.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    TownFeatureConstants.pageTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: TownFeatureConstants.titleFontWeight,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: TownFeatureConstants.contentSpacing),

                  // Feature Cards
                  ..._buildFeatureCards(context, viewModel, town),
                ],
              ),
            ),
          ),
          const BackNavigationFooter(),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureCards(BuildContext context, TownFeatureViewModel viewModel, TownDto town) {
    final features = [
      FeatureData(
        title: TownFeatureConstants.businessesTitle,
        description: TownFeatureConstants.businessesDescription,
        icon: Icons.store_mall_directory,
        color: const Color(TownFeatureConstants.businessesColor),
        onTap: () => viewModel.navigateToBusinesses(context, town),
      ),
      FeatureData(
        title: TownFeatureConstants.servicesTitle,
        description: TownFeatureConstants.servicesDescription,
        icon: Icons.handyman,
        color: const Color(TownFeatureConstants.servicesColor),
        onTap: () => viewModel.navigateToServices(context, town),
      ),
      FeatureData(
        title: TownFeatureConstants.eventsTitle,
        description: TownFeatureConstants.eventsDescription,
        icon: Icons.event,
        color: const Color(TownFeatureConstants.eventsColor),
        onTap: () => viewModel.navigateToEvents(context, town),
      ),
    ];

    return features.map((feature) {
      return Column(
        children: [
          FeatureCard(feature: feature),
          if (feature != features.last) const SizedBox(height: TownFeatureConstants.cardSpacing),
        ],
      );
    }).toList();
  }
}