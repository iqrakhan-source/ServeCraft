// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/core/config/app_config.dart';
import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';
import 'package:prop_crm/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:prop_crm/features/auth/data/models/register_customer_request.dart';
import 'package:prop_crm/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:prop_crm/features/auth/presentation/providers/auth_provider.dart';
import '../../../mocks/fake_storage_service.dart';

void main() {
  test('Live Backend API Test - Customer Registration', () async {
    AppConfig.initialize(
      config: const AppConfig(
        environment: AppEnvironment.development,
        appName: 'Luxe Salon & Spa',
        appVersion: '1.0.0',
        apiBaseUrl: ApiConstants.defaultBaseUrl,
        enableLogging: true,
        enablePromoOffers: true,
      ),
    );

    final storage = FakeStorageService();
    final apiClient = ApiClient.create(storageService: storage);

    apiClient.dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final sanitizedBody = options.data is Map
              ? Map<String, dynamic>.from(options.data as Map)
              : options.data;
          if (sanitizedBody is Map) {
            if (sanitizedBody.containsKey('password')) {
              sanitizedBody['password'] = '[PROTECTED]';
            }
            if (sanitizedBody.containsKey('confirmPassword')) {
              sanitizedBody['confirmPassword'] = '[PROTECTED]';
            }
          }
          print('--> ACTUAL REQUEST: ${options.method} ${options.uri}');
          print(
              '--> REQUEST HEADERS: Content-Type: ${options.headers['Content-Type']}, Accept: ${options.headers['Accept']}, X-Client-Type: ${options.headers['X-Client-Type']}');
          print('--> SANITIZED REQUEST BODY: $sanitizedBody');
          handler.next(options);
        },
        onResponse: (response, handler) {
          dynamic sanitize(dynamic data) {
            if (data is Map) {
              final result = <String, dynamic>{};
              for (final entry in data.entries) {
                if (['token', 'accessToken', 'refreshToken'].contains(entry.key)) {
                  result[entry.key] = '[PROTECTED_JWT]';
                } else {
                  result[entry.key] = sanitize(entry.value);
                }
              }
              return result;
            }
            return data;
          }

          final sanitizedData = sanitize(response.data);
          print('<-- ACTUAL HTTP STATUS: ${response.statusCode}');
          print('<-- SANITIZED RESPONSE: $sanitizedData');
          handler.next(response);
        },
        onError: (err, handler) {
          print('<-- ACTUAL ERROR HTTP STATUS: ${err.response?.statusCode}');
          print('<-- SANITIZED ERROR RESPONSE: ${err.response?.data}');
          handler.next(err);
        },
      ),
    );

    final remoteDataSource = AuthRemoteDataSourceImpl(apiService: apiClient);
    final repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      storageService: storage,
    );
    final provider = AuthProvider(repository: repository);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueEmail = 'e2e_$timestamp@example.com';
    final uniquePhone = '9${(timestamp % 1000000000).toString().padLeft(9, '0')}';
    final request = RegisterCustomerRequest(
      name: 'E2E Verification User',
      email: uniqueEmail,
      phone: uniquePhone,
      password: 'Password123!',
      confirmPassword: 'Password123!',
      gender: 'female',
    );

    final success = await provider.registerCustomer(request);
    expect(success, isTrue);
    expect(provider.status, equals(AuthStatus.profileIncomplete));
    expect(provider.currentUser?.email, equals(uniqueEmail));
    expect(storage.getString('auth_token'), isNotNull);

    final duplicateSuccess = await provider.registerCustomer(request);
    expect(duplicateSuccess, isFalse);
    expect(provider.hasError, isTrue);
    expect(provider.errorMessage, contains('already exists'));
  });
}
