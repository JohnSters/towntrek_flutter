import 'package:dio/dio.dart';

import '../core/core.dart';
import '../models/town_request_dto.dart';

class TownRequestException implements Exception {
  TownRequestException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class TownRequestApiService {
  TownRequestApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<TownRequestSubmitResult> submit({
    required String name,
    required String province,
    String? notes,
    String? requesterEmail,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/town-requests',
        data: {
          'name': name,
          'province': province,
          if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
          if (requesterEmail != null && requesterEmail.trim().isNotEmpty)
            'requesterEmail': requesterEmail.trim(),
        },
        options: Options(
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      final code = response.statusCode ?? 0;
      if (code == 401 || code == 403) {
        throw TownRequestException(
          RequestTownConstants.signInRequiredApi,
          code,
        );
      }
      if (code == 429) {
        throw TownRequestException(
          'You have sent a few town requests recently. Please try again later.',
          429,
        );
      }

      final data = response.data ?? <String, dynamic>{};
      if (code != 200 && code != 201) {
        final error = data['error'];
        final message = error is String
            ? error
            : 'We couldn’t send your request. Please try again.';
        throw TownRequestException(message, code);
      }

      return TownRequestSubmitResult.fromJson(data);
    } on TownRequestException {
      rethrow;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) {
        throw TownRequestException(
          RequestTownConstants.signInRequiredApi,
          code,
        );
      }
      if (code == 429) {
        throw TownRequestException(
          'You have sent a few town requests recently. Please try again later.',
          429,
        );
      }
      throw TownRequestException(
        e.message ?? 'We couldn’t send your request. Please try again.',
        code,
      );
    }
  }
}
