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
  int _detectionRunId = 0;
  bool _isDisposed = false;
  bool _manualSelectionActive = false;

  TownLoaderViewModel({
    required TownRepository townRepository,
    required GeolocationService geolocationService,
    required ErrorHandler errorHandler,
  }) : _townRepository = townRepository,
       _geolocationService = geolocationService,
       _errorHandler = errorHandler {
    detectLocationAndLoadTown();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _detectionRunId++;
    super.dispose();
  }

  bool _shouldAbortDetection(int runId) {
    return _isDisposed || _manualSelectionActive || runId != _detectionRunId;
  }

  void _enterManualSelectionMode() {
    _manualSelectionActive = true;
    _detectionRunId++;
  }

  Future<void> detectLocationAndLoadTown() async {
    _manualSelectionActive = false;
    final runId = ++_detectionRunId;
    _state = TownLoaderLoadingLocation();
    notifyListeners();

    try {
      // Get all towns first
      final townsResult = await _townRepository.getTowns();
      if (_shouldAbortDetection(runId)) return;

      if (townsResult.isEmpty) {
        final noDataError = AppErrors.noDataAvailable(detectLocationAndLoadTown);
        _state = TownLoaderLocationError(noDataError);
        notifyListeners();
        return;
      }

      // Try to find nearest town based on location
      final nearestTownResult = await _geolocationService.findNearestTown(townsResult);
      if (_shouldAbortDetection(runId)) return;

      if (nearestTownResult.isSuccess) {
        _state = TownLoaderConfirmTown(nearestTownResult.data);
        notifyListeners();
      } else {
        // Location detection failed, show town selection
        _state = TownLoaderSelectTown(nearestTownResult.error);
        notifyListeners();
      }
    } catch (e) {
      if (_shouldAbortDetection(runId)) return;
      final appError = await _errorHandler.handleError(e, retryAction: detectLocationAndLoadTown);
      if (_shouldAbortDetection(runId)) return;
      _state = TownLoaderLocationError(appError);
      notifyListeners();
    }
  }

  void skipLocationDetection() {
    _enterManualSelectionMode();
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
    _enterManualSelectionMode();
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