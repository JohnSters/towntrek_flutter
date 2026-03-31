import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../../services/discovery_api_service.dart';

sealed class DiscoveryDetailState {}

class DiscoveryDetailLoading extends DiscoveryDetailState {}

class DiscoveryDetailError extends DiscoveryDetailState {
  final AppError error;
  DiscoveryDetailError(this.error);
}

class DiscoveryDetailSuccess extends DiscoveryDetailState {
  final TownDiscoveryDetailDto discovery;
  DiscoveryDetailSuccess(this.discovery);
}

class DiscoveryDetailViewModel extends ChangeNotifier {
  DiscoveryDetailViewModel({
    required int discoveryId,
    required DiscoveryApiService discoveryApiService,
    required ErrorHandler errorHandler,
  }) : _id = discoveryId,
       _discoveryApiService = discoveryApiService,
       _errorHandler = errorHandler {
    load();
  }

  final int _id;
  final DiscoveryApiService _discoveryApiService;
  final ErrorHandler _errorHandler;

  DiscoveryDetailState _state = DiscoveryDetailLoading();
  DiscoveryDetailState get state => _state;

  Future<void> load() async {
    _state = DiscoveryDetailLoading();
    notifyListeners();
    try {
      final d = await _discoveryApiService.getDetail(_id);
      _state = DiscoveryDetailSuccess(d);
      notifyListeners();
    } catch (e) {
      final err = await _errorHandler.handleError(e, retryAction: load);
      _state = DiscoveryDetailError(err);
      notifyListeners();
    }
  }
}
