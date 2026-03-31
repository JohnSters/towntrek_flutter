import 'dart:io';

import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../models/discovery_dto.dart';

class DiscoverySubmitException implements Exception {
  final String message;
  final int? statusCode;

  DiscoverySubmitException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Town discoveries API (`/api/discoveries`).
class DiscoveryApiService {
  DiscoveryApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<DiscoveryCategoryDto>> getCategories() async {
    final response = await _apiClient.get<List<dynamic>>('/api/discoveries/categories');
    final list = response.data ?? [];
    return list
        .map((e) => DiscoveryCategoryDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getDiscoveryCount(int townId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/discoveries/count',
      queryParameters: {'townId': townId},
    );
    return (response.data?['count'] as num?)?.toInt() ?? 0;
  }

  Future<List<TownDiscoveryDto>> getFeatured(int townId, {int count = 5}) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/api/discoveries/featured',
      queryParameters: {'townId': townId, 'count': count},
    );
    final list = response.data ?? [];
    return list
        .map((e) => TownDiscoveryDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DiscoveryListResponse> getDiscoveries(
    int townId, {
    int? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    final qp = <String, dynamic>{
      'townId': townId,
      'page': page,
      'pageSize': pageSize,
    };
    if (category != null) qp['category'] = category;

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/discoveries',
      queryParameters: qp,
    );
    return DiscoveryListResponse.fromJson(response.data!);
  }

  Future<TownDiscoveryDetailDto> getDetail(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/discoveries/$id',
    );
    return TownDiscoveryDetailDto.fromJson(response.data!);
  }

  /// Multipart suggest (anonymous). Throws [DiscoverySubmitException] on 429 / errors.
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
  }) async {
    final form = FormData.fromMap({
      'TownId': townId,
      'Title': title,
      'Category': category,
      if (description != null) 'Description': description,
      if (quickTip != null) 'QuickTip': quickTip,
      if (difficulty != null) 'Difficulty': difficulty,
      if (duration != null) 'Duration': duration,
      'IsFreeAccess': isFreeAccess.toString(),
      if (entryInfo != null) 'EntryInfo': entryInfo,
      if (seasonalNote != null) 'SeasonalNote': seasonalNote,
      if (directionsHint != null) 'DirectionsHint': directionsHint,
      if (latitude != null) 'Latitude': latitude.toString(),
      if (longitude != null) 'Longitude': longitude.toString(),
      if (submitterDisplayName != null) 'SubmitterDisplayName': submitterDisplayName,
    });

    for (var i = 0; i < images.length && i < 5; i++) {
      form.files.add(
        MapEntry(
          'Images',
          await MultipartFile.fromFile(
            images[i].path,
            filename: images[i].path.split(Platform.pathSeparator).last,
          ),
        ),
      );
    }

    try {
      final res = await _apiClient.dio.post<dynamic>(
        '/api/discoveries/suggest',
        data: form,
        options: Options(
          validateStatus: (s) => s != null && s < 600,
        ),
      );
      final code = res.statusCode ?? 0;
      if (code == 429) {
        throw DiscoverySubmitException(
          'You\'ve submitted a few suggestions recently. Please try again later.',
          429,
        );
      }
      if (code != 201 && code != 200) {
        throw DiscoverySubmitException(
          res.data?.toString() ?? 'Submission failed',
          code,
        );
      }
    } on DiscoverySubmitException {
      rethrow;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 429) {
        throw DiscoverySubmitException(
          'You\'ve submitted a few suggestions recently. Please try again later.',
          429,
        );
      }
      final msg = e.response?.data?.toString() ?? e.message ?? 'Submit failed';
      throw DiscoverySubmitException(msg, code);
    }
  }
}
