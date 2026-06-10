import '../services/town_api_service.dart';
import '../models/town_admin_public_dto.dart';
import '../models/town_dto.dart';

/// Abstract interface for town data operations
abstract class TownRepository {
  /// Get all active towns
  Future<List<TownDto>> getTowns();

  /// Get detailed information for a specific town
  Future<TownDto> getTownDetails(int townId);

  /// Active Town Admin public profile, or `null` if none.
  Future<PublicTownAdminProfileDto?> getTownAdminProfile(int townId);

  /// Published, non-expired notices for the mobile town hub.
  Future<List<PublicTownNoticeDto>> getPublishedTownNotices(
    int townId, {
    int page = 1,
    int pageSize = 10,
  });
}

/// Implementation of TownRepository using API service
class TownRepositoryImpl implements TownRepository {
  final TownApiService _apiService;

  TownRepositoryImpl(this._apiService);

  @override
  Future<List<TownDto>> getTowns() {
    return _apiService.getTowns();
  }

  @override
  Future<TownDto> getTownDetails(int townId) {
    return _apiService.getTownDetails(townId);
  }

  @override
  Future<PublicTownAdminProfileDto?> getTownAdminProfile(int townId) {
    return _apiService.getTownAdminProfile(townId);
  }

  @override
  Future<List<PublicTownNoticeDto>> getPublishedTownNotices(
    int townId, {
    int page = 1,
    int pageSize = 10,
  }) {
    return _apiService.getPublishedTownNotices(
      townId,
      page: page,
      pageSize: pageSize,
    );
  }
}
