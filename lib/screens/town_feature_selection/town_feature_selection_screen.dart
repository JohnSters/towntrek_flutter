import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../member_hub/connect_device_sheet.dart';
import 'town_feature_selection_state.dart';
import 'town_feature_selection_view_model.dart';
import 'town_hub_member_sheet.dart';
import 'widgets/widgets.dart';

class TownFeatureSelectionScreen extends StatelessWidget {
  final TownDto town;

  const TownFeatureSelectionScreen({super.key, required this.town});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TownFeatureViewModel(
        town,
        eventRepository: serviceLocator.eventRepository,
        creativeSpaceRepository: serviceLocator.creativeSpaceRepository,
        propertyRepository: serviceLocator.propertyRepository,
        discoveryRepository: serviceLocator.discoveryRepository,
        townFlyerRepository: serviceLocator.townFlyerRepository,
        businessRepository: serviceLocator.businessRepository,
        townRepository: serviceLocator.townRepository,
        weatherService: serviceLocator.weatherService,
        sessionManager: serviceLocator.mobileSessionManager,
      ),
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
  @override
  void initState() {
    super.initState();
    FavouriteTownStorage.ensureInitialized();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TownFeatureViewModel>();
    final town = switch (viewModel.state) {
      TownFeatureLoaded(town: final town) => town,
    };

    final listing = context.entityListing;
    final sessionManager = serviceLocator.mobileSessionManager;
    final bottomFabInset =
        TownFeatureConstants.floatingHubActionBottomInset +
        MediaQuery.paddingOf(context).bottom;

    return ListenableBuilder(
      listenable: sessionManager,
      builder: (context, _) {
        final authed = sessionManager.isAuthenticated;
        return Scaffold(
          backgroundColor: listing.pageBg,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: bottomFabInset),
            child: authed
                ? TownHubLevelFab(
                    level: sessionManager.memberProgression?.currentLevel ?? 1,
                    showVerified:
                        sessionManager.profile?.trustLevel ==
                        MemberTrustLevel.trusted,
                    onPressed: () =>
                        showTownHubMemberQuickPanel(context, town: town),
                  )
                : TownHubConnectDeviceFab(
                    onPressed: () => showConnectDeviceSheet(context),
                  ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                EntityListingHeroHeader(
                  theme: context.entityListingTheme,
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
                        onPressed: viewModel.isFavouriteActionRunning
                            ? null
                            : () async {
                                final message = await viewModel.toggleFavourite(
                                  town,
                                  isFavourite,
                                );
                                if (!context.mounted || message == null) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              },
                        tooltip: isFavourite
                            ? 'Remove favourite town'
                            : 'Set as favourite town',
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withValues(alpha: 0.2),
                        ),
                        icon: Icon(
                          isFavourite
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(
                      TownFeatureConstants.pagePadding,
                    ),
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
                        if (viewModel.townNotices.isNotEmpty) ...[
                          TownNoticeBoard(notices: viewModel.townNotices),
                          const SizedBox(
                            height: TownFeatureConstants.sectionGap,
                          ),
                        ],
                        if (viewModel.townAdminProfile != null) ...[
                          TownAdminBanner(
                            profile: viewModel.townAdminProfile!,
                            profiles: viewModel.townAdminProfiles,
                            onSelect: viewModel.selectTownAdmin,
                            onOpenDetail: () => showTownAdminDetailSheet(
                              context,
                              profile: viewModel.townAdminProfile!,
                            ),
                          ),
                          const SizedBox(
                            height: TownFeatureConstants.sectionGap,
                          ),
                        ],
                        TownHubSection(
                          title: TownFeatureConstants.exploreSectionTitle,
                          description:
                              TownFeatureConstants.exploreSectionDescription,
                          icon: Icons.storefront_rounded,
                          emphasized: true,
                          accentColor: const Color(
                            TownFeatureConstants.exploreAccent,
                          ),
                          child: _buildFeatureGrid(context, viewModel, town),
                        ),
                        if (viewModel.showTownMedia || town.isFlyersEnabled) ...[
                          const SizedBox(
                            height: TownFeatureConstants.sectionGap,
                          ),
                          TownHubSection(
                            title: TownFeatureConstants.aroundTownSectionTitle,
                            description: TownFeatureConstants
                                .aroundTownSectionDescription,
                            icon: Icons.headphones_rounded,
                            accentColor: const Color(
                              TownFeatureConstants.aroundTownAccent,
                            ),
                            initiallyExpanded: false,
                            child: _buildAroundTown(viewModel, town),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const ListingBackFooter(label: 'Back'),
              ],
            ),
          ),
        );
      },
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

    final parcels = FeatureData(
      title: TownFeatureConstants.parcelsTitle,
      description: TownFeatureConstants.parcelsDescription,
      icon: Icons.local_shipping_outlined,
      color: const Color(TownFeatureConstants.parcelsColor),
      onTap: () => viewModel.navigateToParcels(context, town),
    );

    final forum = FeatureData(
      title: TownFeatureConstants.forumTitle,
      description: TownFeatureConstants.forumDescription,
      icon: Icons.forum_outlined,
      color: const Color(TownFeatureConstants.forumColor),
      onTap: () => viewModel.navigateToForum(context, town),
    );

    const gap = SizedBox(height: TownFeatureConstants.gridGap);
    const hGap = SizedBox(width: TownFeatureConstants.gridGap);

    final features = <FeatureData>[
      businesses,
      services,
      events,
      whatToDo,
      properties,
      equipmentRentals,
      creativeSpaces,
      if (town.isParcelBoardEnabled) parcels,
      if (town.isForumEnabled) forum,
    ];

    final rows = <Widget>[];
    for (var i = 0; i < features.length; i += 2) {
      if (rows.isNotEmpty) rows.add(gap);
      final left = features[i];
      final right = i + 1 < features.length ? features[i + 1] : null;
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: FeatureGridCard(feature: left)),
              hGap,
              Expanded(
                child: right == null
                    ? const SizedBox.shrink()
                    : FeatureGridCard(feature: right),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildAroundTown(
    TownFeatureViewModel viewModel,
    TownDto town,
  ) {
    return Column(
      children: [
        if (viewModel.showTownMedia)
          TownMediaStrip(
            town: town,
            media: viewModel.townMedia!,
          ),
        if (town.isFlyersEnabled) ...[
          if (viewModel.showTownMedia)
            const SizedBox(height: TownFeatureConstants.hubActionGap),
          TownFlyerStrip(
            townName: town.name,
            flyers: viewModel.townFlyers,
            loading: viewModel.flyersLoading,
            onOpenGallery: (index) =>
                viewModel.openFlyerGallery(context, index),
          ),
        ],
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
