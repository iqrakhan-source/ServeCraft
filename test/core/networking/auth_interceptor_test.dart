import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_interceptors.dart';
import 'package:prop_crm/core/storage/storage_keys.dart';
import '../../mocks/fake_storage_service.dart';

void main() {
  late FakeStorageService storageService;

  setUp(() {
    storageService = FakeStorageService();
  });

  group('AuthInterceptor', () {
    test('attaches Bearer token header when token exists in storage', () async {
      await storageService.setString(
        StorageKeys.authToken,
        'test_jwt_access_token_12345',
      );

      final interceptor = AuthInterceptor(storageService: storageService);
      final options = RequestOptions(path: ApiConstants.profile);

      interceptor.onRequest(options, RequestInterceptorHandler());

      // Verify the headers on the options object modified by onRequest
      expect(
        options.headers[ApiConstants.authorizationHeader],
        equals('Bearer test_jwt_access_token_12345'),
      );
      expect(
        options.headers[ApiConstants.contentTypeHeader],
        equals(ApiConstants.applicationJson),
      );
      expect(
        options.headers[ApiConstants.acceptHeader],
        equals(ApiConstants.applicationJson),
      );
      expect(
        options.headers[ApiConstants.clientTypeHeader],
        equals(ApiConstants.clientConsumer),
      );
    });

    test('omits Authorization header when token is null or empty', () {
      final interceptor = AuthInterceptor(storageService: storageService);
      final options = RequestOptions(path: ApiConstants.login);

      interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers.containsKey(ApiConstants.authorizationHeader), isFalse);
      expect(
        options.headers[ApiConstants.contentTypeHeader],
        equals(ApiConstants.applicationJson),
      );
    });

    test('triggers onUnauthorized callback on 401 response', () async {
      bool unauthorizedCalled = false;
      final dio = Dio();
      dio.interceptors.add(
        AuthInterceptor(
          storageService: storageService,
          onUnauthorized: () {
            unauthorizedCalled = true;
          },
        ),
      );

      dio.httpClientAdapter = _MockStatusAdapter(401);

      try {
        await dio.get(ApiConstants.profile);
      } catch (_) {}

      expect(unauthorizedCalled, isTrue);
    });
  });
}

class _MockStatusAdapter implements HttpClientAdapter {
  final int statusCode;
  _MockStatusAdapter(this.statusCode);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"message": "Unauthorized"}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
