import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towntrek_flutter/core/network/api_client.dart';

void main() {
  test('401 triggers a single refresh and replays the request', () async {
    var adapterCalls = 0;
    var refreshCalls = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.httpClientAdapter = _ScriptedAdapter((options) async {
      adapterCalls++;
      final auth = options.headers['Authorization']?.toString();
      if (options.path.contains('/api/parcels') && auth != 'Bearer fresh') {
        return _jsonResponse(401, {
          'error': {'code': 'UNAUTHORIZED', 'message': 'expired'},
        });
      }
      return _jsonResponse(200, {'ok': true});
    });

    final client = ApiClient.test(dio);
    client.updateHeaders({'Authorization': 'Bearer stale'});
    client.onUnauthorized = () async {
      refreshCalls++;
      client.updateHeaders({'Authorization': 'Bearer fresh'});
      return true;
    };

    final response = await client.get<Map<String, dynamic>>('/api/parcels');
    expect(response.statusCode, 200);
    expect(refreshCalls, 1);
    expect(adapterCalls, 2);
  });

  test('concurrent 401s share one in-flight refresh', () async {
    var refreshCalls = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.httpClientAdapter = _ScriptedAdapter((options) async {
      final auth = options.headers['Authorization']?.toString();
      if (auth != 'Bearer fresh') {
        return _jsonResponse(401, {
          'error': {'code': 'UNAUTHORIZED', 'message': 'expired'},
        });
      }
      return _jsonResponse(200, {'ok': true});
    });

    final client = ApiClient.test(dio);
    client.updateHeaders({'Authorization': 'Bearer stale'});
    client.onUnauthorized = () async {
      refreshCalls++;
      await Future<void>.delayed(const Duration(milliseconds: 40));
      client.updateHeaders({'Authorization': 'Bearer fresh'});
      return true;
    };

    await Future.wait([
      client.get<Map<String, dynamic>>('/api/parcels/a'),
      client.get<Map<String, dynamic>>('/api/parcels/b'),
    ]);

    expect(refreshCalls, 1);
  });

  test('failed refresh surfaces unauthorized', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.httpClientAdapter = _ScriptedAdapter((options) async {
      return _jsonResponse(401, {
        'error': {'code': 'UNAUTHORIZED', 'message': 'expired'},
      });
    });

    final client = ApiClient.test(dio);
    client.updateHeaders({'Authorization': 'Bearer stale'});
    client.onUnauthorized = () async => false;

    try {
      await client.get<Map<String, dynamic>>('/api/parcels');
      fail('Expected a 401 to throw');
    } catch (error) {
      expect(isUnauthorizedError(error), isTrue);
    }
  });

  test('REFRESH_INVALID is a dead refresh even without mapped ApiException', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/api/mobile/refresh'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/api/mobile/refresh'),
        statusCode: 400,
        data: {
          'error': {
            'code': 'REFRESH_INVALID',
            'message': 'Refresh token is invalid or has expired.',
          },
        },
      ),
    );

    expect(isAuthDeadRefreshError(error), isTrue);
  });

  test('refresh 400 REFRESH_INVALID is mapped by the interceptor chain', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.httpClientAdapter = _ScriptedAdapter((options) async {
      return _jsonResponse(400, {
        'error': {
          'code': 'REFRESH_INVALID',
          'message': 'Refresh token is invalid or has expired.',
        },
      });
    });

    final client = ApiClient.test(dio);
    try {
      await client.post<Map<String, dynamic>>(
        '/api/mobile/refresh',
        data: {'refreshToken': 'old'},
      );
      fail('Expected refresh to throw');
    } catch (error) {
      expect(isAuthDeadRefreshError(error), isTrue);
    }
  });
}

ResponseBody _jsonResponse(int status, Map<String, dynamic> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._onFetch);

  final Future<ResponseBody> Function(RequestOptions options) _onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _onFetch(options);
  }

  @override
  void close({bool force = false}) {}
}
