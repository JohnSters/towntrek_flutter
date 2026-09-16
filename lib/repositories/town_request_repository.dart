import '../models/town_request_dto.dart';
import '../services/town_request_api_service.dart';

export '../services/town_request_api_service.dart' show TownRequestException;

abstract class TownRequestRepository {
  Future<TownRequestSubmitResult> submit({
    required String name,
    required String province,
    String? notes,
    String? requesterEmail,
  });
}

class TownRequestRepositoryImpl implements TownRequestRepository {
  TownRequestRepositoryImpl(this._apiService);

  final TownRequestApiService _apiService;

  @override
  Future<TownRequestSubmitResult> submit({
    required String name,
    required String province,
    String? notes,
    String? requesterEmail,
  }) {
    return _apiService.submit(
      name: name,
      province: province,
      notes: notes,
      requesterEmail: requesterEmail,
    );
  }
}
