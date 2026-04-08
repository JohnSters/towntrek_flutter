import '../core/network/api_client.dart';
import '../models/models.dart';

class ParcelApiService {
  ParcelApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<ParcelBoardResponse> getBoard(int townId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/parcels',
      queryParameters: {'townId': townId},
    );
    return ParcelBoardResponse.fromJson(response.data!);
  }

  Future<ParcelDetailDto> getDetail(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>('/api/parcels/$id');
    return ParcelDetailDto.fromJson(response.data!);
  }

  Future<ParcelDetailDto> create(CreateParcelRequestDto request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/parcels',
      data: request.toJson(),
    );
    return ParcelDetailDto.fromJson(response.data!);
  }

  Future<ParcelDetailDto> claim(int id) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/parcels/$id/claim',
    );
    return ParcelDetailDto.fromJson(response.data!);
  }

  Future<ParcelDetailDto> pickedUp(int id) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/parcels/$id/pickedup',
    );
    return ParcelDetailDto.fromJson(response.data!);
  }

  Future<ParcelDetailDto> delivered(int id) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/parcels/$id/delivered',
    );
    return ParcelDetailDto.fromJson(response.data!);
  }

  Future<ParcelDetailDto> confirm(int id) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/parcels/$id/confirm',
    );
    return ParcelDetailDto.fromJson(response.data!);
  }

  Future<ParcelDetailDto> cancel(int id, String reason) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/parcels/$id/cancel',
      data: {'reason': reason},
    );
    return ParcelDetailDto.fromJson(response.data!);
  }

  Future<void> report(int id, String reason) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/api/parcels/$id/report',
      data: {'reason': reason},
    );
  }

  Future<void> rate({
    required int id,
    required int score,
    required bool rateClaimer,
    String? note,
  }) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/api/parcels/$id/rate',
      data: {'score': score, 'rateClaimer': rateClaimer, 'note': note},
    );
  }
}
