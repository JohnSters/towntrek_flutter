import '../models/models.dart';
import '../services/parcel_api_service.dart';

abstract class ParcelRepository {
  Future<ParcelBoardResponse> getBoard(int townId);

  Future<ParcelDetailDto> getDetail(int id);

  Future<ParcelDetailDto> create(CreateParcelRequestDto request);

  Future<ParcelDetailDto> claim(int id);

  Future<ParcelDetailDto> pickedUp(int id);

  Future<ParcelDetailDto> delivered(int id);

  Future<ParcelDetailDto> confirm(int id);

  Future<ParcelDetailDto> cancel(int id, String reason);

  Future<void> report(int id, String reason);

  Future<void> rate({
    required int id,
    required int score,
    required bool rateClaimer,
    String? note,
  });
}

class ParcelRepositoryImpl implements ParcelRepository {
  ParcelRepositoryImpl(this._apiService);

  final ParcelApiService _apiService;

  @override
  Future<ParcelDetailDto> cancel(int id, String reason) async {
    return _apiService.cancel(id, reason);
  }

  @override
  Future<ParcelDetailDto> claim(int id) async {
    return _apiService.claim(id);
  }

  @override
  Future<ParcelDetailDto> confirm(int id) async {
    return _apiService.confirm(id);
  }

  @override
  Future<ParcelDetailDto> create(CreateParcelRequestDto request) async {
    return _apiService.create(request);
  }

  @override
  Future<ParcelDetailDto> delivered(int id) async {
    return _apiService.delivered(id);
  }

  @override
  Future<ParcelBoardResponse> getBoard(int townId) async {
    return _apiService.getBoard(townId);
  }

  @override
  Future<ParcelDetailDto> getDetail(int id) async {
    return _apiService.getDetail(id);
  }

  @override
  Future<ParcelDetailDto> pickedUp(int id) async {
    return _apiService.pickedUp(id);
  }

  @override
  Future<void> rate({
    required int id,
    required int score,
    required bool rateClaimer,
    String? note,
  }) async {
    await _apiService.rate(
      id: id,
      score: score,
      rateClaimer: rateClaimer,
      note: note,
    );
  }

  @override
  Future<void> report(int id, String reason) async {
    await _apiService.report(id, reason);
  }
}
