import '../models/models.dart';
import '../services/stats_api_service.dart';

/// Abstract interface for stats data operations
abstract class StatsRepository {
  Future<LandingStatsDto> getLandingStats({int? townId});
}

/// Implementation of StatsRepository using API service
class StatsRepositoryImpl implements StatsRepository {
  final StatsApiService _apiService;

  StatsRepositoryImpl(this._apiService);

  @override
  Future<LandingStatsDto> getLandingStats({int? townId}) async {
    return await _apiService.getLandingStats(townId: townId);
  }
}


