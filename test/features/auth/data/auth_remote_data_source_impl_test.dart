import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';
import 'package:prop_crm/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:prop_crm/features/auth/data/models/complete_profile_request.dart';
import 'package:prop_crm/features/auth/data/models/register_customer_request.dart';
import 'package:prop_crm/features/auth/data/models/send_otp_request.dart';
import 'package:prop_crm/features/auth/data/models/verify_otp_request.dart';
import '../../../mocks/fake_storage_service.dart';

class MockAdapter implements HttpClientAdapter {
  late ResponseBody Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late MockAdapter mockAdapter;
  late ApiClient apiClient;
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    mockAdapter = MockAdapter();
    final storageService = FakeStorageService();
    apiClient = ApiClient.create(storageService: storageService);
    apiClient.dio.httpClientAdapter = mockAdapter;
    dataSource = AuthRemoteDataSourceImpl(apiService: apiClient);
  });

  group('AuthRemoteDataSourceImpl - registerCustomer', () {
    test('sends POST to /api/v1/customer/auth/register and returns parsed RegisterCustomerResponse', () async {
      RequestOptions? capturedOptions;

      mockAdapter.handler = (options) {
        capturedOptions = options;
        const responseJson = {
          'success': true,
          'message': 'Account registered successfully',
          'data': {
            'user': {
              'id': 'user_123',
              'name': 'Sarah Connor',
              'email': 'sarah@example.com',
              'phone': '9876543210',
              'role': 'customer',
              'isProfileComplete': false,
            },
            'accessToken': 'jwt_mock_access_token_12345',
            'refreshToken': 'mock_refresh_token_67890',
          }
        };

        return ResponseBody.fromString(
          jsonEncode(responseJson),
          201,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      const request = RegisterCustomerRequest(
        name: 'Sarah Connor',
        email: 'sarah@example.com',
        phone: '9876543210',
        password: 'Password123!',
        confirmPassword: 'Password123!',
        gender: 'female',
      );

      final result = await dataSource.registerCustomer(request);

      // Verify HTTP request details
      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.method, equals('POST'));
      expect(capturedOptions!.path, equals(ApiConstants.registerCustomer));
      expect(capturedOptions!.path, equals('/api/v1/customer/auth/register'));
      expect(capturedOptions!.data['name'], equals('Sarah Connor'));
      expect(capturedOptions!.data['email'], equals('sarah@example.com'));
      expect(capturedOptions!.data['phone'], equals('9876543210'));
      expect(capturedOptions!.data['gender'], equals('female'));

      // Verify response parsing
      expect(result.accessToken, equals('jwt_mock_access_token_12345'));
      expect(result.refreshToken, equals('mock_refresh_token_67890'));
      expect(result.user['id'], equals('user_123'));
      expect(result.user['name'], equals('Sarah Connor'));
    });

    test('throws BadRequestException when backend returns 400 with error message', () async {
      mockAdapter.handler = (options) {
        const errorJson = {
          'success': false,
          'message': 'An account with this email address already exists',
        };

        return ResponseBody.fromString(
          jsonEncode(errorJson),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      const request = RegisterCustomerRequest(
        name: 'Sarah Connor',
        email: 'duplicate@example.com',
        phone: '9876543210',
        password: 'Password123!',
        confirmPassword: 'Password123!',
        gender: 'female',
      );

      expect(
        () => dataSource.registerCustomer(request),
        throwsA(isA<BadRequestException>().having(
          (e) => e.message,
          'message',
          contains('already exists'),
        )),
      );
    });
  });

  group('AuthRemoteDataSourceImpl - getCurrentUser', () {
    test('sends GET to /api/v1/customer/profile and returns parsed UserModel', () async {
      RequestOptions? capturedOptions;

      mockAdapter.handler = (options) {
        capturedOptions = options;
        const responseJson = {
          'success': true,
          'message': 'Profile retrieved successfully',
          'data': {
            'id': 'user_123',
            'name': 'Sarah Connor',
            'email': 'sarah@example.com',
            'phone': '9876543210',
            'gender': 'female',
            'isProfileComplete': true,
          }
        };

        return ResponseBody.fromString(
          jsonEncode(responseJson),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final user = await dataSource.getCurrentUser();

      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.method, equals('GET'));
      expect(capturedOptions!.path, equals(ApiConstants.profile));
      expect(capturedOptions!.path, equals('/api/v1/customer/profile'));
      expect(user.id, equals('user_123'));
      expect(user.name, equals('Sarah Connor'));
      expect(user.email, equals('sarah@example.com'));
      expect(user.isProfileComplete, isTrue);
    });
  });

  group('AuthRemoteDataSourceImpl - Profile Updates', () {
    test('completeProfile sends PATCH to /api/v1/customer/profile', () async {
      RequestOptions? capturedOptions;

      mockAdapter.handler = (options) {
        capturedOptions = options;
        const responseJson = {
          'success': true,
          'message': 'Profile updated successfully',
          'data': {
            'id': 'user_123',
            'name': 'Sarah Connor',
            'email': 'sarah@example.com',
            'phone': '9876543210',
            'gender': 'female',
            'dateOfBirth': '1995-05-12',
            'isProfileComplete': true,
          }
        };

        return ResponseBody.fromString(
          jsonEncode(responseJson),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      const request = CompleteProfileRequest(
        name: 'Sarah Connor',
        email: 'sarah@example.com',
        gender: 'female',
        dateOfBirth: '1995-05-12',
      );

      final user = await dataSource.completeProfile(request);

      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.method, equals('PATCH'));
      expect(capturedOptions!.path, equals(ApiConstants.updateProfile));
      expect(capturedOptions!.path, equals('/api/v1/customer/profile'));
      expect(capturedOptions!.data['name'], equals('Sarah Connor'));
      expect(user.name, equals('Sarah Connor'));
      expect(user.isProfileComplete, isTrue);
    });

    test('updateProfile sends PATCH to /api/v1/customer/profile', () async {
      RequestOptions? capturedOptions;

      mockAdapter.handler = (options) {
        capturedOptions = options;
        const responseJson = {
          'success': true,
          'message': 'Profile updated successfully',
          'data': {
            'id': 'user_123',
            'name': 'Sarah Connor Updated',
            'phone': '9876543210',
            'email': 'sarah@example.com',
            'isProfileComplete': true,
          }
        };

        return ResponseBody.fromString(
          jsonEncode(responseJson),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final user = await dataSource.updateProfile({'name': 'Sarah Connor Updated'});

      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.method, equals('PATCH'));
      expect(capturedOptions!.path, equals(ApiConstants.updateProfile));
      expect(capturedOptions!.path, equals('/api/v1/customer/profile'));
      expect(user.name, equals('Sarah Connor Updated'));
    });

    test('updateClinicalPreferences sends PATCH to /api/v1/customer/profile/clinical-preferences', () async {
      RequestOptions? capturedOptions;

      mockAdapter.handler = (options) {
        capturedOptions = options;
        const responseJson = {
          'success': true,
          'message': 'Clinical preferences updated',
          'data': {
            'id': 'user_123',
            'name': 'Sarah Connor',
            'phone': '9876543210',
            'email': 'sarah@example.com',
            'isProfileComplete': true,
          }
        };

        return ResponseBody.fromString(
          jsonEncode(responseJson),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final user = await dataSource.updateClinicalPreferences({
        'allergies': ['latex'],
        'skinType': 'sensitive',
      });

      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.method, equals('PATCH'));
      expect(capturedOptions!.path, equals(ApiConstants.clinicalPreferences));
      expect(capturedOptions!.path, equals('/api/v1/customer/profile/clinical-preferences'));
      expect(capturedOptions!.data['skinType'], equals('sensitive'));
      expect(user.id, equals('user_123'));
    });
  });

  group('AuthRemoteDataSourceImpl - OTP endpoints', () {
    test('sendOtp sends POST to /api/v1/customer/auth/send-otp', () async {
      RequestOptions? capturedOptions;

      mockAdapter.handler = (options) {
        capturedOptions = options;
        const responseJson = {
          'success': true,
          'message': 'OTP sent',
          'data': {
            'expiresInSeconds': 60,
          }
        };

        return ResponseBody.fromString(
          jsonEncode(responseJson),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final response = await dataSource.sendOtp(const SendOtpRequest(phone: '9876543210'));

      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.method, equals('POST'));
      expect(capturedOptions!.path, equals(ApiConstants.sendOtp));
      expect(capturedOptions!.path, equals('/api/v1/customer/auth/send-otp'));
      expect(capturedOptions!.data['phone'], equals('9876543210'));
      expect(response.success, isTrue);
    });

    test('verifyOtp sends POST to /api/v1/customer/auth/verify-otp', () async {
      RequestOptions? capturedOptions;

      mockAdapter.handler = (options) {
        capturedOptions = options;
        const responseJson = {
          'success': true,
          'message': 'OTP verified',
          'data': {
            'token': 'jwt_mock_token_12345',
            'refreshToken': 'jwt_refresh_67890',
            'user': {
              'id': 'user_123',
              'name': 'Sarah Connor',
              'phone': '9876543210',
              'email': 'sarah@example.com',
              'isProfileComplete': true,
            },
            'isNewUser': false,
          }
        };

        return ResponseBody.fromString(
          jsonEncode(responseJson),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final response = await dataSource.verifyOtp(
        const VerifyOtpRequest(phone: '9876543210', otp: '123456'),
      );

      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.method, equals('POST'));
      expect(capturedOptions!.path, equals(ApiConstants.verifyOtp));
      expect(capturedOptions!.path, equals('/api/v1/customer/auth/verify-otp'));
      expect(capturedOptions!.data['phone'], equals('9876543210'));
      expect(capturedOptions!.data['otp'], equals('123456'));
      expect(response.token, equals('jwt_mock_token_12345'));
    });
  });
}
