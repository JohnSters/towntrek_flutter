import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../core/presentation/event_display.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../../services/weather_service.dart';
import '../business_category/business_category.dart';
import '../current_events/current_events_screen.dart';
import '../creative_spaces/creative_spaces_category_screen.dart';
import '../service_category/service_category_screen.dart';
import '../town_selection/town_selection_screen.dart';
import '../what_to_do/what_to_do_screen.dart';
import '../property_list/property_list_screen.dart';
import '../member_hub.dart';
import '../forum/forum_list_screen.dart';
import 'town_feature_selection_screen.dart';
import 'town_feature_selection_state.dart';

/// ViewModel for town hub navigation and Town Pulse metrics (counts + weather).
class TownFeatureViewModel extends ChangeNotifier {
  final TownFeatureState _state;
  TownFeatureState get state => _state;

  TownDto get town => switch (_state) {
    TownFeatureLoaded(town: final t) => t,
  };

  WeatherData? pulseWeather;
  int? pulseActiveEventsCount;
  int? pulseCreativeTotal;
  int? pulsePropertiesTotal;
  int? pulseEquipmentTotal;
  int? pulseDiscoveriesCount;
  bool pulseLoading = true;
  bool isFavouriteActionRunning = false;

  PublicTownAdminProfileDto? townAdminProfile;
  List<PublicTownNoticeDto> townNotices = const [];

  /// Shown when there is an assigned admin and/or published notices.
  bool get showTownAdminHub =>
      townAdminProfile != null || townNotices.isNotEmpty;

  bool _alive = true;

  /// True when current-events fetch succeeded and at least one event is active.
  bool get eventsLive =>
      pulseActiveEventsCount != null && pulseActiveEventsCount! > 0;

  final EventRepository _eventRepository;
  final CreativeSpaceRepository _creativeSpaceRepository;
  final PropertyRepository _propertyRepository;
  final DiscoveryRepository _discoveryRepository;
  final BusinessRepository _businessRepository;
  final TownRepository _townRepository;
  final WeatherService _weatherService;
  final MobileSessionManager _sessionManager;

  TownFeatureViewModel(
    TownDto town, {
    required EventRepository eventRepository,
    required CreativeSpaceRepository creativeSpaceRepository,
    required PropertyRepository propertyRepository,
    required DiscoveryRepository discoveryRepository,
    required BusinessRepository businessRepository,
    required TownRepository townRepository,
    required WeatherService weatherService,
    required MobileSessionManager sessionManager,
  }) : _state = TownFeatureLoaded(town),
       _eventRepository = eventRepository,
       _creativeSpaceRepository = creativeSpaceRepository,
       _propertyRepository = propertyRepository,
       _discoveryRepository = discoveryRepository,
       _businessRepository = businessRepository,
       _townRepository = townRepository,
       _weatherService = weatherService,
       _sessionManager = sessionManager {
    _loadPulseMetrics(town);
  }

  @override
  void dispose() {
    _alive = false;
    super.dispose();
  }

  Future<void> _loadPulseMetrics(TownDto town) async {
    pulseLoading = true;
    notifyListeners();

    await Future.wait([
      _fetchWeather(town),
      _fetchActiveEvents(town),
      _fetchCreativeTotal(town),
      _fetchPropertiesTotal(town),
      _fetchEquipmentTotal(town),
      _fetchDiscoveriesCount(town),
      _fetchTownAdminHub(town),
    ]);

    if (!_alive) return;
    pulseLoading = false;
    notifyListeners();
  }

  Future<void> _fetchWeather(TownDto town) async {
    final lat = town.latitude;
    final lng = town.longitude;
    if (lat == null || lng == null) return;
    try {
      final data = await _weatherService.getCurrentWeather(lat, lng);
      if (!_alive) return;
      pulseWeather = data;
    } catch (_) {}
  }

  Future<void> _fetchActiveEvents(TownDto town) async {
    try {
      final response = await _eventRepository.getCurrentEvents(
        townId: town.id,
        pageSize: 100,
      );
      if (!_alive) return;
      pulseActiveEventsCount = response.events
          .where((e) => !e.shouldHide)
          .length;
    } catch (_) {}
  }

  Future<void> _fetchCreativeTotal(TownDto town) async {
    try {
      final categories = await _creativeSpaceRepository.getCategoriesWithCounts(
        town.id,
      );
      if (!_alive) return;
      var sum = 0;
      for (final c in categories) {
        final fromSubs = c.subCategories.fold<int>(
          0,
          (a, s) => a + s.spaceCount,
        );
        sum += c.spaceCount > 0 ? c.spaceCount : fromSubs;
      }
      pulseCreativeTotal = sum;
    } catch (_) {}
  }

  Future<void> _fetchPropertiesTotal(TownDto town) async {
    try {
      final list = await _propertyRepository.getList(
        townId: town.id,
        page: 1,
        pageSize: 1,
      );
      if (!_alive) return;
      pulsePropertiesTotal = list.totalCount;
    } catch (_) {}
  }

  Future<void> _fetchDiscoveriesCount(TownDto town) async {
    try {
      final n = await _discoveryRepository.getDiscoveryCount(town.id);
      if (!_alive) return;
      pulseDiscoveriesCount = n;
    } catch (_) {}
  }

  Future<void> _fetchEquipmentTotal(TownDto town) async {
    try {
      final categories = await _businessRepository.getCategoriesWithCounts(
        town.id,
      );
      if (!_alive) return;
      final target = TownFeatureConstants.equipmentRentalsCategoryKey
          .toLowerCase();
      for (final c in categories) {
        if (c.key.toLowerCase() == target) {
          pulseEquipmentTotal = c.businessCount;
          return;
        }
      }
      pulseEquipmentTotal = 0;
    } catch (_) {}
  }

  Future<void> _fetchTownAdminHub(TownDto town) async {
    try {
      final profile = await _townRepository.getTownAdminProfile(town.id);
      if (!_alive) return;
      townAdminProfile = profile;
    } catch (_) {}

    try {
      final list = await _townRepository.getPublishedTownNotices(
        town.id,
        pageSize: 10,
      );
      if (!_alive) return;
      townNotices = list;
    } catch (_) {
      if (!_alive) return;
      townNotices = const [];
    }
  }

  Future<void> changeTown(BuildContext context) async {
    final selectedTown = await Navigator.of(context).push<TownDto>(
      MaterialPageRoute(builder: (context) => const TownSelectionScreen()),
    );

    if (selectedTown != null && context.mounted) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => TownFeatureSelectionScreen(town: selectedTown),
        ),
      );
    }
  }

  void navigateToBusinesses(BuildContext context, TownDto town) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BusinessCategoryScreen(town: town),
      ),
    );
  }

  void navigateToEquipmentRentals(BuildContext context, TownDto town) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BusinessCategoryScreen(
          town: town,
          openCategoryKey: TownFeatureConstants.equipmentRentalsCategoryKey,
        ),
      ),
    );
  }

  void navigateToProperties(BuildContext context, TownDto town) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => PropertyListScreen(town: town)),
    );
  }

  void navigateToServices(BuildContext context, TownDto town) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceCategoryScreen(town: town),
      ),
    );
  }

  void navigateToEvents(BuildContext context, TownDto town) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CurrentEventsScreen(townId: town.id, townName: town.name),
      ),
    );
  }

  void navigateToWhatToDo(BuildContext context, TownDto town) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => WhatToDoScreen(town: town)));
  }

  void navigateToCreativeSpaces(BuildContext context, TownDto town) {
    CreativeSpacesNavigation.pushCategoryPage(
      context,
      pageBuilder: (_) => CreativeSpacesCategoryScreen(town: town),
    );
  }

  void navigateToParcels(BuildContext context, TownDto town) {
    final isAuthenticated = _sessionManager.isAuthenticated;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => isAuthenticated
            ? BoardScreen(town: town)
            : GuestBoardScreen(town: town),
      ),
    );
  }

  void navigateToForum(BuildContext context, TownDto town) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ForumListScreen(
          townId: town.id,
          townName: town.name,
        ),
      ),
    );
  }

  Future<String?> toggleFavourite(TownDto town, bool isFavourite) async {
    if (isFavouriteActionRunning) return null;
    isFavouriteActionRunning = true;
    notifyListeners();
    try {
      if (isFavourite) {
        await FavouriteTownStorage.clearFavouriteTown();
      } else {
        await FavouriteTownStorage.setFavouriteTown(town);
      }
      return isFavourite
          ? '${town.name} removed from favourites'
          : '${town.name} saved as favourite';
    } finally {
      isFavouriteActionRunning = false;
      notifyListeners();
    }
  }
}
