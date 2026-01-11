import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../../services/services.dart';
import '../town_feature_selection/town_feature_selection_screen.dart';
import '../town_selection/town_selection_screen.dart';
import 'town_loader_state.dart';

// ViewModel for business logic separation
class TownLoaderViewModel extends ChangeNotifier {
  TownLoaderState _state = TownLoaderLoadingLocation();
  TownLoaderState get state => _state;

  final TownRepository _townRepository;
  final GeolocationService _geolocationService;
  final ErrorHandler _errorHandler;

  TownLoaderViewModel({
    required TownRepository townRepository,
    required GeolocationService geolocationService,
    required ErrorHandler errorHandler,
  }) : _townRepository = townRepository,
       _geolocationService = geolocationService,
       _errorHandler = errorHandler {
    detectLocationAndLoadTown();
  }

  Future<void> detectLocationAndLoadTown() async {
    _state = TownLoaderLoadingLocation();
    notifyListeners();

    try {
      // Get all towns first
      final townsResult = await _townRepository.getTowns();

      if (townsResult.isEmpty) {
        final noDataError = AppErrors.noDataAvailable(detectLocationAndLoadTown);
        _state = TownLoaderLocationError(noDataError);
        notifyListeners();
        return;
      }

      // Try to find nearest town based on location
      final nearestTownResult = await _geolocationService.findNearestTown(townsResult);

      if (nearestTownResult.isSuccess) {
        _state = TownLoaderConfirmTown(nearestTownResult.data);
        notifyListeners();
      } else {
        // Location detection failed, show town selection
        _state = TownLoaderSelectTown(nearestTownResult.error);
        notifyListeners();
      }
    } catch (e) {
      final appError = await _errorHandler.handleError(e, retryAction: detectLocationAndLoadTown);
      _state = TownLoaderLocationError(appError);
      notifyListeners();
    }
  }

  void skipLocationDetection() {
    _state = TownLoaderSelectTown();
    notifyListeners();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<TownDto?> selectTownManually(BuildContext context) async {
    return await Navigator.of(context).push<TownDto>(
      MaterialPageRoute(
        builder: (context) => const TownSelectionScreen(),
      ),
    );
  }

  void confirmDetectedTown(TownDto town) {
    _state = TownLoaderLocationSuccess(town);
    notifyListeners();
  }

  void rejectDetectedTown() {
    _state = TownLoaderSelectTown();
    notifyListeners();
  }

  void navigateToFeatureSelection(BuildContext context, TownDto town) {
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TownFeatureSelectionScreen(town: town),
      ),
    );
  }
}