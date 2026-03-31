import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import 'town_feature_selection_state.dart';
import 'town_feature_selection_view_model.dart';
import 'widgets/widgets.dart';

class TownFeatureSelectionScreen extends StatelessWidget {
  final TownDto town;

  const TownFeatureSelectionScreen({super.key, required this.town});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TownFeatureViewModel(town),
      child: _TownFeatureSelectionScreenContent(initialTown: town),
    );
  }
}

class _TownFeatureSelectionScreenContent extends StatefulWidget {
  final TownDto initialTown;

  const _TownFeatureSelectionScreenContent({required this.initialTown});

  @override
  State<_TownFeatureSelectionScreenContent> createState() =>
      _TownFeatureSelectionScreenContentState();
}

class _TownFeatureSelectionScreenContentState
    extends State<_TownFeatureSelectionScreenContent> {
  bool _isFavouriteActionRunning = false;

  @override
  void initState() {
    super.initState();
    FavouriteTownStorage.ensureInitialized();
  }

  Future<void> _toggleFavourite(TownDto town, bool isFavourite) async {
    if (_isFavouriteActionRunning) return;

    setState(() {
      _isFavouriteActionRunning = true;
    });

    try {
      if (isFavourite) {
        await FavouriteTownStorage.clearFavouriteTown();
      } else {
        await FavouriteTownStorage.setFavouriteTown(town);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavourite
                ? '${town.name} removed from favourites'
                : '${town.name} saved as favourite',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFavouriteActionRunning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TownFeatureViewModel>();
    final town = switch (viewModel.state) {
      TownFeatureLoaded(town: final town) => town,
    };

    return Scaffold(
      backgroundColor: EntityListingTheme.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            EntityListingHeroHeader(
              theme: EntityListingTheme.business,
              categoryIcon: Icons.explore_rounded,
              // Town hub: main prompt + PROVINCE • TOWN in uppercase line
              subCategoryName: TownFeatureConstants.pageTitle,
              categoryName: town.province,
              townName: town.name,
              trailing: ValueListenableBuilder<TownDto?>(
                valueListenable: FavouriteTownStorage.favouriteTownNotifier,
                builder: (context, favouriteTown, _) {
                  final isFavourite = favouriteTown?.id == town.id;
                  return IconButton(
                    onPressed: _isFavouriteActionRunning
                        ? null
                        : () => _toggleFavourite(town, isFavourite),
                    tooltip: isFavourite
                        ? 'Remove favourite town'
                        : 'Set as favourite town',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                    ),
                    icon: Icon(
                      isFavourite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(TownFeatureConstants.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TownPulseCard(
                      town: town,
                      isLoading: viewModel.pulseLoading,
                      weather: viewModel.pulseWeather,
                      activeEventsCount: viewModel.pulseActiveEventsCount,
                      creativeTotal: viewModel.pulseCreativeTotal,
                      propertiesTotal: viewModel.pulsePropertiesTotal,
                      equipmentTotal: viewModel.pulseEquipmentTotal,
                      discoveriesTotal: viewModel.pulseDiscoveriesCount,
                      onNavigate: (destination) => _onPulseNavigate(
                        context,
                        viewModel,
                        town,
                        destination,
                      ),
                    ),
                    const SizedBox(height: TownFeatureConstants.sectionGap),
                    _buildFeatureGrid(context, viewModel, town),
                  ],
                ),
              ),
            ),
            const ListingBackFooter(label: 'Back'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(
    BuildContext context,
    TownFeatureViewModel viewModel,
    TownDto town,
  ) {
    final creativeSpaces = FeatureData(
      title: TownFeatureConstants.creativeSpacesTitle,
      description: TownFeatureConstants.creativeSpacesDescription,
      icon: Icons.palette_rounded,
      color: const Color(TownFeatureConstants.creativeSpacesColor),
      onTap: () => viewModel.navigateToCreativeSpaces(context, town),
    );

    final businesses = FeatureData(
      title: TownFeatureConstants.businessesTitle,
      description: TownFeatureConstants.businessesDescription,
      icon: Icons.store_mall_directory,
      color: const Color(TownFeatureConstants.businessesColor),
      onTap: () => viewModel.navigateToBusinesses(context, town),
    );

    final services = FeatureData(
      title: TownFeatureConstants.servicesTitle,
      description: TownFeatureConstants.servicesDescription,
      icon: Icons.handyman,
      color: const Color(TownFeatureConstants.servicesColor),
      onTap: () => viewModel.navigateToServices(context, town),
    );

    final events = FeatureData(
      title: TownFeatureConstants.eventsTitle,
      description: TownFeatureConstants.eventsDescription,
      icon: Icons.event,
      color: const Color(TownFeatureConstants.eventsColor),
      onTap: () => viewModel.navigateToEvents(context, town),
      showLiveBadge: viewModel.eventsLive,
    );

    final whatToDo = FeatureData(
      title: TownFeatureConstants.whatToDoTitle,
      description: TownFeatureConstants.whatToDoDescription,
      icon: Icons.travel_explore,
      color: const Color(TownFeatureConstants.whatToDoColor),
      onTap: () => viewModel.navigateToWhatToDo(context, town),
    );

    final properties = FeatureData(
      title: TownFeatureConstants.propertiesTitle,
      description: TownFeatureConstants.propertiesDescription,
      icon: Icons.home_work_rounded,
      color: const Color(TownFeatureConstants.propertiesColor),
      onTap: () => viewModel.navigateToProperties(context, town),
    );

    final equipmentRentals = FeatureData(
      title: TownFeatureConstants.equipmentRentalsTitle,
      description: TownFeatureConstants.equipmentRentalsDescription,
      icon: Icons.construction,
      color: const Color(TownFeatureConstants.equipmentRentalsColor),
      onTap: () => viewModel.navigateToEquipmentRentals(context, town),
    );

    const gap = SizedBox(height: TownFeatureConstants.gridGap);
    const hGap = SizedBox(width: TownFeatureConstants.gridGap);

    return Column(
      children: [
        FeatureHeroCard(feature: creativeSpaces),
        gap,
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: FeatureGridCard(feature: businesses)),
              hGap,
              Expanded(child: FeatureGridCard(feature: services)),
            ],
          ),
        ),
        gap,
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: FeatureGridCard(feature: events)),
              hGap,
              Expanded(child: FeatureGridCard(feature: whatToDo)),
            ],
          ),
        ),
        gap,
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: FeatureGridCard(feature: properties)),
              hGap,
              Expanded(child: FeatureGridCard(feature: equipmentRentals)),
            ],
          ),
        ),
      ],
    );
  }

  void _onPulseNavigate(
    BuildContext context,
    TownFeatureViewModel viewModel,
    TownDto town,
    TownPulseDestination destination,
  ) {
    switch (destination) {
      case TownPulseDestination.businesses:
        viewModel.navigateToBusinesses(context, town);
      case TownPulseDestination.services:
        viewModel.navigateToServices(context, town);
      case TownPulseDestination.events:
        viewModel.navigateToEvents(context, town);
      case TownPulseDestination.creativeSpaces:
        viewModel.navigateToCreativeSpaces(context, town);
      case TownPulseDestination.whatToDo:
        viewModel.navigateToWhatToDo(context, town);
      case TownPulseDestination.properties:
        viewModel.navigateToProperties(context, town);
      case TownPulseDestination.equipmentRentals:
        viewModel.navigateToEquipmentRentals(context, town);
    }
  }
}
