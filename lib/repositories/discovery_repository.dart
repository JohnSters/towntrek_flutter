import 'dart:io';

import '../models/discovery_dto.dart';
import '../services/discovery_api_service.dart';

export '../services/discovery_api_service.dart'
    show DiscoveryVoteException, DiscoverySubmitException;

/// Abstract interface for town-discovery data operations.
abstract class DiscoveryRepository {
  Future<List<DiscoveryCategoryDto>> getCategories();

  Future<int> getDiscoveryCount(int townId);

  Future<List<TownDiscoveryDto>> getFeatured(int townId, {int count = 5});

  Future<DiscoveryListResponse> getDiscoveries(
    int townId, {
    int? category,
    int page = 1,
    int pageSize = 20,
  });

  Future<TownDiscoveryDetailDto> getDetail(int id);

  Future<TownDiscoveryVoteSummaryDto> voteDiscovery(int id, String vote);

  Future<void> submitSuggestion({
    required int townId,
    required String title,
    required int category,
    String? description,
    String? quickTip,
    String? difficulty,
    String? duration,
    bool isFreeAccess = true,
    String? entryInfo,
    String? seasonalNote,
    String? directionsHint,
    double? latitude,
    double? longitude,
    String? submitterDisplayName,
    List<File> images = const [],
  });
}

/// Implementation of [DiscoveryRepository] using [DiscoveryApiService].
class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final DiscoveryApiService _apiService;

  DiscoveryRepositoryImpl(this._apiService);

  @override
  Future<List<DiscoveryCategoryDto>> getCategories() {
    return _apiService.getCategories();
  }

  @override
  Future<int> getDiscoveryCount(int townId) {
    return _apiService.getDiscoveryCount(townId);
  }

  @override
  Future<List<TownDiscoveryDto>> getFeatured(int townId, {int count = 5}) {
    return _apiService.getFeatured(townId, count: count);
  }

  @override
  Future<DiscoveryListResponse> getDiscoveries(
    int townId, {
    int? category,
    int page = 1,
    int pageSize = 20,
  }) {
    return _apiService.getDiscoveries(
      townId,
      category: category,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<TownDiscoveryDetailDto> getDetail(int id) {
    return _apiService.getDetail(id);
  }

  @override
  Future<TownDiscoveryVoteSummaryDto> voteDiscovery(int id, String vote) {
    return _apiService.voteDiscovery(id, vote);
  }

  @override
  Future<void> submitSuggestion({
    required int townId,
    required String title,
    required int category,
    String? description,
    String? quickTip,
    String? difficulty,
    String? duration,
    bool isFreeAccess = true,
    String? entryInfo,
    String? seasonalNote,
    String? directionsHint,
    double? latitude,
    double? longitude,
    String? submitterDisplayName,
    List<File> images = const [],
  }) {
    return _apiService.submitSuggestion(
      townId: townId,
      title: title,
      category: category,
      description: description,
      quickTip: quickTip,
      difficulty: difficulty,
      duration: duration,
      isFreeAccess: isFreeAccess,
      entryInfo: entryInfo,
      seasonalNote: seasonalNote,
      directionsHint: directionsHint,
      latitude: latitude,
      longitude: longitude,
      submitterDisplayName: submitterDisplayName,
      images: images,
    );
  }
}
