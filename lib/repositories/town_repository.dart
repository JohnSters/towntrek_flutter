import '../services/town_api_service.dart';
import '../models/town_dto.dart';

/// Abstract interface for town data operations
abstract class TownRepository {
  /// Get all active towns
  Future<List<TownDto>> getTowns();

  /// Get detailed information for a specific town
  Future<TownDto> getTownDetails(int townId);
}

/// Implementation of TownRepository using API service
class TownRepositoryImpl implements TownRepository {
  final TownApiService _apiService;

  TownRepositoryImpl(this._apiService);

  @override
  Future<List<TownDto>> getTowns() async {
    try {
      return await _apiService.getTowns();
    } catch (e) {
      // Here you could add caching logic, error transformation, etc.
      rethrow;
    }
  }

  @override
  Future<TownDto> getTownDetails(int townId) async {
    try {
      return await _apiService.getTownDetails(townId);
    } catch (e) {
      rethrow;
    }
  }
}
