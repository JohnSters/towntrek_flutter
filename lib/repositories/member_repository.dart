import '../models/models.dart';
import '../services/member_api_service.dart';

abstract class MemberRepository {
  Future<MemberProfileDto> getMyProfile();

  Future<MemberActivityDto> getMyActivity();
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
}
