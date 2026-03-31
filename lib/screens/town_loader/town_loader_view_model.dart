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
  bool _userCancelledAutoDetect = false;
  bool _isNavigatingToFeatureSelection = false;
  bool _isSelectingTownManually = false;

  bool get userCancelledAutoDetect => _userCancelledAutoDetect;

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
    _cancelPendingDetection();
    super.dispose();
  }

  bool _shouldAbortDetection(int runId) {
    return _isDisposed || _userCancelledAutoDetect || runId != _detectionRunId;
  }

  void _cancelPendingDetection({bool persistCancellation = false}) {
    if (persistCancellation) {
      _userCancelledAutoDetect = true;
    }
    _detectionRunId++;
  }

  Future<void> detectLocationAndLoadTown({bool userInitiatedRetry = false}) async {
    if (_isDisposed) return;
    if (_userCancelledAutoDetect && !userInitiatedRetry) return;
    if (userInitiatedRetry) {
      _userCancelledAutoDetect = false;
    }

    final runId = ++_detectionRunId;
    _state = TownLoaderLoadingLocation();
    notifyListeners();

    try {
      // Get all towns first
      final townsResult = await _townRepository.getTowns();
      if (_shouldAbortDetection(runId)) return;

      if (townsResult.isEmpty) {
        final noDataError = AppErrors.noDataAvailable(() => detectLocationAndLoadTown());
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
        final errorMessage = nearestTownResult.error;
        final shouldSilentlyBypassAutoDetect =
            errorMessage != null &&
            errorMessage.startsWith('No nearby town found within');
        _state = shouldSilentlyBypassAutoDetect
            ? TownLoaderSelectTown()
            : TownLoaderSelectTown(errorMessage);
        notifyListeners();
      }
    } catch (e) {
      if (_shouldAbortDetection(runId)) return;
      final appError = await _errorHandler.handleError(
        e,
        retryAction: () => detectLocationAndLoadTown(),
      );
      if (_shouldAbortDetection(runId)) return;
      _state = TownLoaderLocationError(appError);
      notifyListeners();
    }
  }

  void skipLocationDetection() {
    if (_isDisposed) return;
    _cancelPendingDetection(persistCancellation: true);
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
    if (_isDisposed || _isSelectingTownManually || !context.mounted) return null;

    _cancelPendingDetection(persistCancellation: true);
    _isSelectingTownManually = true;
    try {
      return await Navigator.of(context).push<TownDto>(
        MaterialPageRoute(
          builder: (context) => const TownSelectionScreen(),
        ),
      );
    } finally {
      _isSelectingTownManually = false;
    }
  }

  void confirmDetectedTown(TownDto town) {
    if (_isDisposed || _userCancelledAutoDetect) return;
    _state = TownLoaderLocationSuccess(town);
    notifyListeners();
  }

  void rejectDetectedTown() {
    if (_isDisposed) return;
    _cancelPendingDetection(persistCancellation: true);
    _state = TownLoaderSelectTown();
    notifyListeners();
  }

  void navigateToFeatureSelection(BuildContext context, TownDto town) {
    if (_isDisposed || _isNavigatingToFeatureSelection || !context.mounted) return;

    _isNavigatingToFeatureSelection = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TownFeatureSelectionScreen(town: town),
      ),
    ).whenComplete(() {
      _isNavigatingToFeatureSelection = false;
    });
  }
}