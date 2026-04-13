import '../models/models.dart';
import '../services/member_api_service.dart';

abstract class MemberRepository {
  Future<MemberProfileDto> getMyProfile();

  Future<MemberActivityDto> getMyActivity();

  Future<MemberProgressionDto> getMyProgression();

  Future<void> markLeaderboardDisclosureSeen();

  Future<XpHistoryPageDto> getXpHistory({int page, int pageSize});

  Future<LeaderboardResponseDto> getLeaderboard({
    required int townId,
    String season,
  });
}

class MemberRepositoryImpl implements MemberRepository {
  MemberRepositoryImpl(this._apiService);

  final MemberApiService _apiService;

  @override
  Future<MemberActivityDto> getMyActivity() async {
    return _apiService.getMyActivity();
  }

  @override
  Future<MemberProfileDto> getMyProfile() async {
    return _apiService.getMyProfile();
  }

  @override
  Future<MemberProgressionDto> getMyProgression() async {
    return _apiService.getMyProgression();
  }

  @override
  Future<void> markLeaderboardDisclosureSeen() async {
    await _apiService.markLeaderboardDisclosureSeen();
  }

  @override
  Future<XpHistoryPageDto> getXpHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    return _apiService.getXpHistory(page: page, pageSize: pageSize);
  }

  @override
  Future<LeaderboardResponseDto> getLeaderboard({
    required int townId,
    String season = 'alltime',
  }) async {
    return _apiService.getLeaderboard(townId: townId, season: season);
  }
}
