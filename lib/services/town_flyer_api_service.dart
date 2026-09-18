import 'dart:io';

import 'package:dio/dio.dart';

import '../core/core.dart';
import '../models/models.dart';

class TownFlyerApiService {
  TownFlyerApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<TownFlyerDto>> getLive(int townId) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/api/towns/$townId/flyers',
    );
    final data = response.data ?? const [];
    return data
        .whereType<Map>()
        .map((row) => TownFlyerDto.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<TownFlyerQuotaDto> getQuota({int? townId}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/me/flyers',
      queryParameters: {
        'townId': ?townId,
      },
    );
    return TownFlyerQuotaDto.fromJson(response.data ?? const {});
  }

  Future<TownFlyerCreateResultDto> create({
    required int townId,
    required File image,
    required double latitude,
    required double longitude,
    String? physicalAddress,
    String? contactPhone,
  }) async {
    final form = FormData.fromMap({
      'Latitude': latitude.toStringAsFixed(6),
      'Longitude': longitude.toStringAsFixed(6),
      if (physicalAddress != null && physicalAddress.trim().isNotEmpty)
        'PhysicalAddress': physicalAddress.trim(),
      if (contactPhone != null && contactPhone.trim().isNotEmpty)
        'ContactPhone': contactPhone.trim(),
    });
    form.files.add(
      MapEntry(
        'Image',
        await MultipartFile.fromFile(
          image.path,
          filename: image.path.split(Platform.pathSeparator).last,
        ),
      ),
    );

    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/towns/$townId/flyers',
      data: form,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
    return TownFlyerCreateResultDto.fromJson(response.data ?? const {});
  }

  Future<void> remove(int flyerId) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/api/flyers/$flyerId/remove',
      data: <String, dynamic>{},
    );
  }
}
